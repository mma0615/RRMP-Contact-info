({
    //Called on initialization of our component and kicks off the process of checking conditions and constructing our table.
    //We're calling the fetchUser function in the helper js file to get the user's account ID
    doInit: function (component, event, helper) {
        component.set("v.isLoading",true);
        helper.fetchUser(component);
    },
    
    //Called when the user clicks cancel
    cancelSave: function() {
        if (confirm('This will cancel your current changes and reload the page. Do you want to proceed?')) {
            location.reload();
        }
    },

    //Called when the user clicks the "save" button
    saveTableRecords: function(component) {
        //Our total number of records and field+value updates to apply
        var recordsData = component.get("v.modifiedRecords");
        component.set("v.isLoading", true);
        component.set("v.saveNotification", false);
        
        //If the total number of records committed is over a specific value then batchify the saving process
        if (recordsData.length > 100) {
            var a = component.get('c.batchSave');
        } else {
            var a = component.get('c.singleSave');
        }
        $A.enqueueAction(a);
    },

    //Called when the user clicks the "Save and Notify" button
    saveTableRecordsAndNotify: function(component) {
        //Our total number of records and field+value updates to apply
        var recordsData = component.get("v.modifiedRecords");
        component.set("v.isLoading", true);
        component.set("v.saveNotification", true);

        //If the total number of records committed is over a specific value then batchify the saving process
        if (recordsData.length > 100) {
            var a = component.get('c.batchSave');
        } else {
            var a = component.get('c.singleSave');
        }
        $A.enqueueAction(a);
    },

    //Called if the amount of records is more than our specified threshhold in the SaveTableRecords function. 
    //This subdivides our total number of records into batches of smaller sets of records to avoid Apex CPU timeouts. 
    batchSave: function(component, event, helper) {        
        var notify = component.get("v.saveNotification"), //Determine if the user specified that a notification should go out after Save
        recordsData = component.get("v.modifiedRecords"), //Get the object of all records and field updates to commit
        batchCount = component.get("v.batchCount"), //We use an Aura component attribute to capture which batch of records we're processing. This starts as 0 and gets updated as batches are processed
        i = batchCount, //Set i to the current value of batch count
        j = recordsData.length, //Set j to the length of our array of records to be updated
        chunk = 50; //Set the chunk size for sub-arrays

        //Log which batch we're on to the console
        console.log(component.get("v.batchCount"));

        //set temparray to the chunked sub-array
        temparray = JSON.stringify(recordsData.slice(i, i + chunk));

        //Call the apex classs to update records.
        var action = component.get("c.updateRecordsv2");

        //Pass the chunked sub-array to the controller
        action.setParams({
            jsonString: temparray
        });

        //Set the callback for our updateRecordsv2 method in the Apex Class
        action.setCallback(this, function(response) {
            //This gets any error responses for each pass through
            var thisUpdateErrors = response.getReturnValue();

            var state = response.getState();

            if (state === "SUCCESS") {
                //Increase i by the chunk size ad set the aura component attribute to the new value
                i += chunk;
                component.set("v.batchCount", i);

                //If this loop has errors pass the results to the 'updateErrors" aura attribute on the component
                if (JSON.parse(thisUpdateErrors).length > 0) {
                    var errorsToPush = JSON.parse(thisUpdateErrors);
                    var updateErrors = component.get("v.updateErrors");
                    updateErrors.push(errorsToPush);
                }

                //We are still inside the range of sub-arrays, so retrigger this function
                if (i < j) {
                    var saveNext = component.get('c.batchSave');
                    $A.enqueueAction(saveNext);
                }

                //Otherwise, the loop index is greater than or equal to the number of chunked sub-arrays, so we can proceed with updating the user interface
                else {

                    var toastEvent = $A.get("e.force:showToast");
                    
                    //Get the aggregate result of errors that were passed through the loops
                    var totalUpdateErrors = component.get("v.updateErrors");

                    //If the user selected notify DSF proceed to show either the success or success with errors message
                    if (notify) {

                        //Call the notifyUpdatesDone function in our Apex class and define as a variable
                        var sendNotification = component.get("c.notifyUpdatesDone");

                        sendNotification.setCallback(this, function(response) {
                            //If there are any errors in our save, show a toast message indicating so and highlight the failed updates
                            if (totalUpdateErrors.length > 0) {
                                //Define our message
                                toastEvent.setParams({
                                    title: "Success!",
                                    message: "Changes Saved, with errors highlighted, and DSF has been notified",
                                    type: "success"
                                });
                                //Show our message
                                toastEvent.fire();
                                //Highlight the erroneous fields
                                helper.finishedSaving(component, totalUpdateErrors);
                            } else {
                                //There were no errors logged, so show a sucess message and then reload the page after 3 seconds.
                                toastEvent.setParams({
                                    title: "Success!",
                                    message: "Changes Saved and DSF has been notified",
                                    type: "success"
                                });
                                component.set("v.isLoading", false);
                                toastEvent.fire();
                                setTimeout(function() { location.reload(); }, 3000);
                            }
                        });
                        //This fires our sendNotification function, whose success callback functions are defined above. 
                        $A.enqueueAction(sendNotification);
                    } 
                    else {
                        //The user has not selected Notify DSF, so we enter into a similar conditional as above, but do not indicate that DSF was notified..
                        if (totalUpdateErrors.length > 0) {
                            toastEvent.setParams({
                                title: "Success!",
                                message: "Changes Saved, but with some errors highlighted.",
                                type: "success"
                            });
                            component.set("v.isLoading", false);
                            toastEvent.fire();
                            helper.finishedSaving(component, totalUpdateErrors);
                        } 
                        else {
                            toastEvent.setParams({
                                title: "Success!",
                                message: "Changes Saved",
                                type: "success"
                            });
                            toastEvent.fire();
                            setTimeout(function() { location.reload(); }, 3000);
                        }
                    }
                }
            } else {
                //There was an error returned by the Apex class and we append that to the bottom of the screen and log to the console.
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = "Error: " + errors[0].message;
                    console.log("Error: " + message);
                    component.set("v.error", message);
                    component.set("v.isLoading", false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    singleSave: function(component, event, helper) {
        var notify = component.get("v.saveNotification"), //Determine if the user specified that a notification should go out after Save
        recordsData = JSON.stringify(component.get("v.modifiedRecords")); //Get the object of all records and field updates to commit

        //Call the apex classs to update records.
        var action = component.get("c.updateRecordsv2");

        //Pass the full set of data to the class for updating
        action.setParams({
            jsonString: recordsData
        });

        //Set the callbacak  for our updateRecordsv2 method in the Apex Class
        action.setCallback(this, function(response) {
            //This gets the error responses for each pass through this For loop
            var thisUpdateErrors = response.getReturnValue();

            //If this loop has errors pass the results to the 'updateErrors" aura attribute on the component
            if (JSON.parse(thisUpdateErrors).length > 0) {
                var errorsToPush = JSON.parse(thisUpdateErrors);
                var updateErrors = component.get("v.updateErrors");
                updateErrors.push(errorsToPush);
            }

            var state = response.getState();

            if (state === "SUCCESS") {

                var toastEvent = $A.get("e.force:showToast");

                //If the user selected notify DSF proceed to show either the success or success with errors message
                if (notify) {

                    //The user has clicked the Notify DSF button, so we call the notifyUpdatesDone function in our Apex class and define as a variable
                    var sendNotification = component.get("c.notifyUpdatesDone");
                    sendNotification.setCallback(this, function(response) {
                        //If there are any errors in our save, show a toast message indicating so and highlight the failed updates
                        if (JSON.parse(thisUpdateErrors).length > 0) {
                            toastEvent.setParams({
                                title: "Success!",
                                message: "Changes Saved, with errors highlighted, and DSF has been notified",
                                type: "success"
                            });
                            component.set("v.isLoading", false);
                            //Show our message
                            toastEvent.fire();
                            //Highlight the erroneous fields
                            helper.finishedSaving(component);
                        } else {
                             //There were no errors logged, so show a sucess message and then reload the page after 3 seconds.
                            toastEvent.setParams({
                                title: "Success!",
                                message: "Changes Saved and DSF has been notified",
                                type: "success"
                            });
                            toastEvent.fire();
                            setTimeout(function() { location.reload(); }, 3000);

                        }
                    });
                    //This fires our sendNotification function, whose success callback functions are defined above. 
                    $A.enqueueAction(sendNotification);
                } 
                else {
                    //The user has not selected Notify DSF, so we enter into a similar conditional as above, but do not indicate that DSF was notified..
                    if (JSON.parse(thisUpdateErrors).length > 0) {
                        toastEvent.setParams({
                            title: "Success!",
                            message: "Changes Saved, but with some errors highlighted.",
                            type: "success"
                        });
                        component.set("v.isLoading", false);
                        toastEvent.fire();
                        helper.finishedSaving(component);

                    } else {
                        toastEvent.setParams({
                            title: "Success!",
                            message: "Changes Saved",
                            type: "success"
                        });
                        toastEvent.fire();
                        setTimeout(function() { location.reload(); }, 3000);
                    }
                }
            } 
            else {
                //There was an error returned by the Apex class and we append that to the bottom of the screen and log to the console.
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = "Error: " + errors[0].message;
                    console.log("Error: " + message);
                    component.set("v.error", message);
                }
            }
        });
        $A.enqueueAction(action);
    },

   
    //Called by our Export button drop-down. all is selected then we call the function downloadCSV. If export selected is clicked, call the function exportSelectedRows
    exportSelect: function(component, event) {
        var menuValue = event.getParam("value");
        if (menuValue == "export") {
            var a = component.get('c.downloadCsv');
        } else {
            var a = component.get('c.exportSelectedRows');
        }
        $A.enqueueAction(a);
    },

    downloadCsv: function(component, event, helper) {
        // get the Records from the data component
        var stockData = component.get("v.data");
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component, stockData);
        if (csv == null) { return; }

        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv'; // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },

    exportSelectedRows: function(component, event, helper) {
        // get the Records from the data component
        var stockData = component.get("v.data");
        var selectedRows = component.get("v.selectedRowIds");

        var filteredList = stockData.filter(function(item) {
            return selectedRows.indexOf(item.Id) !== -1;
        });

        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component, filteredList);
        if (csv == null) { return; }

        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv'; // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
})