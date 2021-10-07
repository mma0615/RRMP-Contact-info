({
    doInitHelper: function (component, event, helper) {
        document.title = 'Loading....';
        let namespaceVal = '';
        component.set("v.showSpinner", true);
        let url_string = document.location.href;
        let eventId = url_string.split("id=")[1].slice(0, 11);
        const urlParams = new URLSearchParams(url_string);
        
        component.set("v.eventId", eventId);
        //component.set('v.contactId',contactId);
        //
        let action = component.get("c.getProjectDetails");
        
        action.setParams({
            eventId: eventId,
            //contactId : contactId
        });
        
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let resultMap = JSON.parse(response.getReturnValue());
                const {campaignRecord, typeList, sessionWrapper, projIssueList} = resultMap;
                let parkingLots = resultMap.projIssueList;
                const dataTableReady = projIssueList.map((issue) => {
                    const Description__c = issue.Description__c || "";
                    const Resolution__c = issue.Resolution__c || "";
                    const Type__c = issue.Type__c || "";
                    const Status__c = issue.Status__c || "";
                    const Session_Name = issue.Session__r.Name || "";
                    const { Name, Date_Raised__c, Raised_By_Email__c} = issue;
                    return {
                        Description__c,
                        Resolution__c,
                        Type__c,
                        Status__c,
                        Session_Name,
                        Name,
                        Date_Raised__c,
                        Raised_By_Email__c
                    };
                });
                console.log('im here');
                // for (let i = 0; i < parkingLots.length; i++) {
                //     let row = parkingLots[i];
                //     if (row.Description__c) {
                //         row.Description__c = row.Description__c;
                //     } else {
                //         row.Description__c = "";
                //     }
                //     if (row.Resolution__c) {
                //         row.Resolution__c = row.Resolution__c;
                //     } else {
                //         row.Resolution__c = "";
                //     }
                //     if (row.Type__c) {
                //         row.Type__c = row.Type__c;
                //     } else {
                //         row.Type__c = "";
                //     }
                //     if (row.Status__c) {
                //         row.Status__c = row.Status__c;
                //     } else {
                //         row.Status__c = "";
                //     }
                //     if (row.Session__c){
                //         row.Session_Name = row.Session__r.Name;
                //     }
                //     else{
                //         row.Session_Name ='';
                //     }
                // }
                
                if (resultMap.contact) {
                    component.set("v.email", resultMap.contact.Email);
                    component.set("v.columns", [
                        {
                            label: "Issue ID",
                            fieldName: "Name",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        {
                            label: "Date Raised",
                            fieldName: namespaceVal+"Date_Raised__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                         {
                            label: "Raised By",
                            fieldName: namespaceVal+"Raised_By_Email__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        {
                            label: "Session",
                            fieldName: namespaceVal+"Session_Name",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        {
                            label: "Issue Type",
                            fieldName: namespaceVal+"Type__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        
                        {
                            label: "Description",
                            fieldName: namespaceVal+"Description__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        //{label: 'Likelihood', fieldName: 'Likelihood__c', type: 'text' ,editable: false, wrapText: true},
                        //{label: 'Impact', fieldName: 'Impact__c', type: 'text' ,editable: false, wrapText: true},
                        {
                            label: "Resolution/Answer",
                            fieldName: namespaceVal+"Resolution__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                       
                        {
                            label: "Status",
                            fieldName: namespaceVal+"Status__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                    ]);
                        } else {
                         component.set("v.columns", [
                        {
                            label: "Issue ID",
                            fieldName: "Name",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        {
                            label: "Date Raised",
                            fieldName: namespaceVal+"Date_Raised__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                         {
                            label: "Raised By",
                            fieldName: namespaceVal+"Raised_By_Email__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        {
                            label: "Session",
                            fieldName: namespaceVal+"Session_Name",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        {
                            label: "Issue Type",
                            fieldName: namespaceVal+"Type__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        
                        {
                            label: "Description",
                            fieldName: namespaceVal+"Description__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                        //{label: 'Likelihood', fieldName: 'Likelihood__c', type: 'text' ,editable: false, wrapText: true},
                        //{label: 'Impact', fieldName: 'Impact__c', type: 'text' ,editable: false, wrapText: true},
                        {
                            label: "Resolution/Answer",
                            fieldName: namespaceVal+"Resolution__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                       
                        {
                            label: "Status",
                            fieldName: namespaceVal+"Status__c",
                            type: "text",
                            editable: false,
                            wrapText: true,
                        },
                    ]);
                }
                
                if(campaignRecord.Issue_Tracker_Page_Title__c != null || campaignRecord.Issue_Tracker_Page_Title__c !=  undefined){
                    component.set("v.issueTrackerPageTitle", campaignRecord.Issue_Tracker_Page_Title__c);
                    document.title = campaignRecord.Issue_Tracker_Page_Title__c;
                }else{
                    component.set("v.issueTrackerPageTitle", 'ISSUE TRACKER');
                }
                
                component.set("v.eventRecordId", campaignRecord.Id);
                component.set("v.types", typeList);
                component.set('v.sessionList', sessionWrapper);
                
                // component.set("v.parkingLots", parkingLots);
                component.set("v.parkingLots", dataTableReady);
                component.set("v.showSpinner", false);
            }
            //Error
            else if (state === "ERROR") {
                let errors = response.getError();
                let message = "Error on Loading Parking lot page"; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                this.showToast("Oops!", message, "error", "pester");
                component.set("v.showSpinner", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    submitParkingLot: function (component, event, helper) {
        let action = component.get("c.createProjectIssue");
        
        action.setParams({
            eventId: component.get("v.eventId"),
            session: component.get("v.selectedSessionId"),
            email: component.get("v.email"),
            description: component.get("v.description"),
            type: component.get("v.type"),
        });
        
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                this.showToast(
                    "Success!",
                    "Your issue has been submitted.",
                    "success",
                    "pester"
                );
                component.set("v.showSpinner", false);
                //Reset fields
                component.set("v.description", "");
                component.set("v.type", "");
                component.set("v.email", "");
                helper.doInitHelper(component, event, helper);
            } else if (state === "ERROR") {
                let errors = response.getError();
                let message = "Error on Creating Parking Issue"; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                this.showToast("Oops!", message, "error", "pester");
                component.set("v.showSpinner", false);
            } else {
                this.showToast(
                    "Oops!",
                    "Something's not right. Please contact the administrator for help.",
                    "error",
                    "pester"
                );
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast: function (title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            mode: mode,
        });
        toastEvent.fire();
    },
    /*
    updateParkingLots : function(component, event, helper) {
        let action = component.get("c.updateParkingLots");    
        let draftValues = event.getParam('draftValues');
        action.setParams({
            parkingLots : JSON.stringify(draftValues)
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log('FLAG 3');
            if (state === "SUCCESS") {
                console.log('FLAG 4');
                this.showToast('Success!', "Your changes has been saved.", "success", "pester");
                component.set("v.showSpinner", false);
                helper.doInitHelper(component,event,helper,true);
               
                //$A.get('e.force:refreshView').fire();
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                let message = 'Error on Uodating Parking Lots'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                   message = errors[0].message;
                }
                this.showToast('Oops!', message, "error", "pester");
                component.set("v.showSpinner", false);
            }
            else {
                console.log('FLAG 5');
                console.log("Failed with state: " + state);
                this.showToast('Oops!', "Something's not right. Please contact the administrator for help.", "error", "pester");
                component.set("v.showSpinner", false);
            }
        });
        console.log('FLAG 6');
        $A.enqueueAction(action);
        console.log('FLAG 7');
    },
	*/
});