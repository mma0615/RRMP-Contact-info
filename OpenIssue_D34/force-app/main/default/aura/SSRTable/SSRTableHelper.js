({
    //First, we get the account ID associated with the current User
    fetchUser:function(component) {
        var userCheck = component.get("c.fetchUser");
        userCheck.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userAccount = response.getReturnValue();
                component.set("v.userAccount",userAccount);
                //Once we have set the aura component for the account ID, we proceed to the next helper function
                this.checkDate(component);
            }
        });
        $A.enqueueAction(userCheck);
     },

     //Second, we check if the current date is within the Fall term and set the corresponding attribute in order to conditionalize 
     //the projected graduation columns
     setFallTerm:function(component){
        var d = new Date();
        var n = d.getMonth();

        //January in getMonth is 0, so 5 is June. if the month is greater than 5, then the date is between 7/1 and 12/31
        if(n>5){
            component.set("v.isFallTerm",true); 
        }
        else {
            component.set("v.isFallTerm",false); 
        }
     },

    //Third, we check to see if they are within the date range for accessing the editor
    checkDate:function(component) {
        var userAccountId = component.get("v.userAccount");
        var dateCheck = component.get("c.fetchDate");
        dateCheck.setParams({
            collegeAccountId: userAccountId 
        });
        dateCheck.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue()) {
                    //They are within the editor access timefram, so proceed to creating picklists and setting up the table
                    this.getPickLists(component);
                }
                else {
                    //The are not within the editor access timeframe, so set the invalid date attribute on the component to false and do nothing else
                    component.set("v.invalidDate", true);
                    component.set("v.isLoading",false);
                }
            }
        });
        $A.enqueueAction(dateCheck);
     },
    
    //Fourth, we parse through all the picklist options and save to the picklists aura attribute
    getPickLists : function(component) {
        //Specify the list of editable picklist fields. The sequence of these fields defines their index values 
        //in the  "populatePicklist" function below. The first field in this list will be index 0 in that function and so forth
        var fieldList = [
            'Projected_Coll__c',
            'SSR_Requirements_Completed__c',
            'Projected_to_Graduate_end_of_acad_yr__c'
         ];

        //Empty array to accept the results from all the picklist fields 
        var allPicklists = [];

        //For each field name in the fieldList Array we are going to call the getPicklistValues method on our controller
        //and save the results to our picklists attribute on the component.  
        for (var i = 0; i < fieldList.length; i++) {
                var action = component.get("c.getPicklistValues");
                action.setParams({
                    objectAPIName: "Student_Term__c",
                    fieldAPIName: fieldList[i]
                });
                
                action.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                            //create an empty array
                            var types = new Array();
                            var pl = JSON.parse(JSON.stringify( response.getReturnValue()));

                            //For each response, push a label/value combination
                            for (var key in pl) {
                                types.push({label:key,value:pl[key]});
                            }

                            //Push all of our label/values to the allpicklists variable
                            allPicklists.push({types});
                            
                            //Set the picklists attribute to the value of the allPicklists variable
                            component.set("v.picklists",allPicklists);

                            if(allPicklists.length== fieldList.length) {
                                //We are done setting up picklists. Proceed to setting up the table
                                this.setupTable(component);
                            }
                    }
                    else{
                        //The controller returned an error. We append that to the bottom of the table and log to the conosle.
                        var errors = response.getError();
                        var message = "Error: Unknown error";
                        if(errors && Array.isArray(errors) && errors.length > 0) {
                            message = "Error: "+errors[0].message;
                            component.set("v.error", message);
                            console.log("Error: "+message);
                        }
                    }
                });
                $A.enqueueAction(action);
            }
     },

     //Setup the rows that will be used for the aura iteration on the component table.
     setupTable:function(component){
        var action = component.get("c.getRecords"); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                for (var r = 0; r < rows.length; r++) {
                    var row = rows[r];

                    //Aura components don't allow for the use of dot notation on related record fields, so we need to translate those to their own variable names.
                    if (row.Application__r.Student_Name__r) {
                        row.FirstName = row.Application__r.Student_Name__r.FirstName;
                        row.LastName = row.Application__r.Student_Name__r.LastName;
                        row.BirthDate = row.Application__r.Student_Name__r.Birthdate;
                        row.Mobile = row.Application__r.Student_Name__r.MobilePhone;
                        row.Email = row.Application__r.Student_Name__r.Email;
                        //Construct the Student info cell information
                        row.StudentInfo = "<div><a tabindex='-1' target='_blank' href='/s/contact/"+row.Application__r.Student_Name__r.Id+"'>"+ row.Application__r.Student_Name__r.LastName + ", " + row.Application__r.Student_Name__r.FirstName + "</a><br>DOB:" + this.reformatDate(row.Application__r.Student_Name__r.Birthdate) +"</div>";
                        row.Cohort = row.Application__r.Student_Name__r.Cohort__r.Name;
                    }
                }
                //Set the data attribute to the processed results
                component.set("v.data", rows);

                //Move on to the jQueryDataTable function in this file to start constructing the table.
                this.jQueryDataTable(component);
            }
        });
        $A.enqueueAction(action); 
     },

     //Simple helper function to reformat the date to mm/dd/yyyy
     reformatDate : function format(inputDate) {
        var date = new Date(inputDate);
        if (!isNaN(date.getTime())) {
            var day = date.getDate().toString();
            var month = (date.getMonth() + 1).toString();
            // Months use 0 index.
            return (month[1] ? month : '0' + month[0]) + '/' +
               (day[1] ? day : '0' + day[0]) + '/' + 
               date.getFullYear();
        }
    },  
    
    //Constructs the dataTable and its associated features. Many of the sub-functions in this function are unique to the 
    //jQuery dataTable plugin
    jQueryDataTable :function(component) {
        setTimeout(function(){
            //Get the vlue of the fallTerm attribute. This will be used for conditionalization in constructing the table
            var fallTerm = component.get("v.isFallTerm");
            
            //Initialize the datable and save as variable 'table' for subsequent manipulation in this function
            var table = jQuery('#datatableId').DataTable( {
                dom: 'Bf<"wrapper1"<"wrapper2"t>>lip',
                orderCellsTop: true,
                "order": [[ 1, "asc" ]],

                //Define our buttons for clear filter, column visibility and vibility groupings
                buttons: [
                    { text: 'Clear Filters',
                        action: function ( e, dt, node, config ) {
                            // Reset Column filtering
                            $('#datatableId thead tr:eq(1) th input, #datatableId thead tr:eq(1) th select').val('').change();
                            // Redraw table (and reset main search filter)
                            $("#datatable").DataTable().search("").draw();
                            table.columns().visible( true );
                        },
                    },
                    {
                        extend: 'colvis',
                        columns: ':gt(1)',
                        text:'Show/Hide Columns'
                    },
                    {
                        extend: 'columnToggle',
                        text:'Student Info',
                        columns: '.student'
                    },
                    {
                        extend: 'columnToggle',
                        text:'Projected Grad Info',
                        columns: '.grad'
                    },
                    {
                        extend: 'columnToggle',
                        text:'SSR',
                        columns: '.ssr'
                    },
                    {
                        extend: 'columnToggle',
                        text:'Contact',
                        columns: '.contact'
                    },
                ],
                //Apply currency formatting to any column with a class of currency
                "columnDefs": [ {
                        targets: "currency",
                        render: $.fn.dataTable.render.number(",", ".", 0, "$")
                    },
                ],
                //After the table is initialized, relocate the butons and search bar
                "initComplete": function( settings) {
                    $(".dt-buttons").appendTo("#top-buttons");
                    $("#datatableId_filter").appendTo("#top-search");

                    //If we're not in the fall term, hide the grad group visibility button
                    if(!fallTerm) { 
                        $("button[data-cv-idx='\\.grad']").hide(); 
                    }
                    //The table is done initiliazing so close the loading icon.
                    component.set("v.isLoading",false);
                }
            });
            
            //Find all column headers with a class of 'picklist' and insert a picklist filter in the second row
            table.columns( '.picklist' ).every( function () {
                var column = this;
                // Create the select list 
                var select = $('<select />')
                    .attr("tabindex",-1)
                    .appendTo(
                        $("#datatableId thead tr:eq(1) th").eq(column.index()).empty() 
                    )
                    .on( 'change', function () {
                        //On change, use the jQuery datatables search function. 
                        //In the cases of these values, use a regex search to search for exact match, rather than contains
                        if ($(this).val() == "New" || $(this).val() == "Meeting SAP" || $(this).val() == "No" ) {
                            column
                            .search( "^" + $(this).val() + "$", true, false, false)
                            .draw();
                        }
                        else {
                            column
                            .search( $(this).val() , false, false, false)
                            .draw();
                        }
                        
                    });
                    select.append( $('<option selected="selected" value="">---</option>') );

                // Get the unique values in the column and add as options to the select filter
                this
                    .cache( 'search' )
                    .sort()
                    .unique()
                    .each( function ( d ) {
                        if (d != "")  {
                        select.append( $('<option value="'+d+'">'+d+'</option>') );
                        }
                    } );
            } );

            //Find all column headers with a class of 'search-input' and insert a search field in the second row
            table.columns( '.search-input' ).every( function () {
                var column = this;
                var input = $('<input />')
                    .addClass("col-search")
                    .attr({"placeholder":"Filter by",
                            "tabindex":-1})
                    .on( 'keyup change', function () {
                        column
                            .search( $(this).val() )
                            .draw();
                    });
                    input.appendTo(
                        $("#datatableId thead tr:eq(1) th").eq(column.index()).empty() 
                    );
            });
        
            //Define what happens when the user clicks the row selection checkbox
            $("#datatableId").on("change", ".rowSelect", function(event){
                //We have 2 separate aura attributes SelectedRows is an array of the index values of 
                //selected rows and SelectedRowIds is an array of the associated record IDs
                var selectedRows = component.get("v.selectedRows");
                var selectedRowIds = component.get("v.selectedRowIds");
                //Get the record ID of the selected row
                var rowRecordId = event.currentTarget.parentNode.parentNode.id;
                //Get the index of the selected row
                var rowId = event.currentTarget.id;
                
                if (event.currentTarget.checked) {
                    //The checkbox has been checked. If the record ID is not in the array of selected rows, push the record ID to the selectedRowIds attribute and the index of the row to the selectedRows attribute. Finally add the selected class to the <tr>
                    if(selectedRows.indexOf(rowId) === -1) {
                        selectedRows.push(rowId);
                        selectedRowIds.push(rowRecordId);
                        event.currentTarget.parentNode.parentNode.classList.add("selected");
                    }
                }   
                else {      
                    //The checkbox is unchecked, so we remove the index and Id from our arrays and remove the selected class from the <tr>
                    var index = selectedRows.indexOf(rowId);
                    if (index > -1) {
                        selectedRows.splice(index, 1);
                        selectedRowIds.splice(index, 1);
                        event.currentTarget.parentNode.parentNode.classList.remove("selected");
                    }
                }
                
            });
       
            //Define the behavior for the select all checkbox 
            $("#datatableId").on("change", "#select-all", function(){
                //Use the jquery datable filter to only find rows that are visible. This accounts for pagination and filtered rows.
                var visiblePage = table.rows({ page: 'current', search: 'applied'  }).nodes().to$();
                
                //If the checkbox has been checked then check the boxes for all visible rows
                if($(this).prop("checked") == true){
                    visiblePage.each(function () {
                        $(this).find("input.rowSelect").prop( "checked", true ).change();
                        
                    });
                }
                //Otherwise, uncheck all visible rows
                else {
                    visiblePage.each(function () {
                        $(this).find("input.rowSelect").prop( "checked", false ).change();
                    });
                }
             });

            //Uncheck the select all checkbox when the users clicks a pagination link.
             $('#datatableId').on( 'page.dt', function () {
                $("#select-all").prop("checked",false);
             });

            //Supporting tabbing behavior. Add a focus class when users tab to focus on a td with the class "tab"
            $("#datatableId tbody").on("focus", ".tab", function(){   
                $(this).addClass("focus");
            });

            //Remove the class when they tab out
            $("#datatableId tbody").on("blur", ".tab", function(){     
                $(this).removeClass("focus");
            });

            //Supporting keyboard navigation behavior. If the user is focused on a editable field and hits enter, it will fire off the appropriate function to make the field editable
            $("#datatableId tbody").on("keydown",  ".editable", function(){
                if (event.keyCode == 13) {
                    component.set("v.isEditModeOn", true); //set table mode to edit
                    var fieldType = $(this).attr("data-type");
                    var fieldValue = $(this).attr("data-value");
                    //Check to see that the field hasn't been activated yet. Otherwise, we could overwrite updated fields in Click events
                    if (!$(this).hasClass( "active" )) {
                        if (fieldType == "picklist") { 
                            createPicklist($(this),fieldValue);
                        }
                        else {
                            createInputField($(this),fieldValue);
                        }
                        $(this).addClass("active");
                    }  
                }
            });

            //The following are functions for handling the field and edit behavior of the form.
            //The <td> fields on the body of the table have a class of "editable". Hook into the onclick event of those tds and, 
            //depending on the type of field, fire off createpicklist or createinput field, which replaces the TD content with an input

             $("#datatableId tbody").on("click", ".editable", function(){
                component.set("v.isEditModeOn", true); //set table mode to edit
                var fieldType = $(this).attr("data-type");
                var fieldValue = $(this).attr("data-value");
                //Check to see that the field hasn't been activated yet. Otherwise, we could overwrite updated fields in Click events
                if (!$(this).hasClass( "active" )) {
                    if (fieldType == "picklist") { 
                      createPicklist($(this),fieldValue);
                    }
                    else {
                        createInputField($(this),fieldValue);
                    }
                    $(this).addClass("active");
                }  
            });

            //The function accepts the name of the target field as a parameter and returns the 
            //appropriate picklist values. The index value of picklists[x] is defined by the order of the 
            //fields in the getPickLists function above
            function populatePicklist(fieldName){
                var picklists = component.get("v.picklists");
                switch(fieldName){
                    case 'Projected_Coll__c':
                        var options = picklists[0].types;
                        break;
                    case 'SSR_Requirements_Completed__c':
                        var options = picklists[1].types;
                        break;
                    case 'Projected_to_Graduate_end_of_acad_yr__c':
                        var options = picklists[2].types;
                        break;
                }
                return options;
            }

            //If the td we're making is a picklist field, this function handles the creation of the select 
            function createPicklist(target, fieldValue) {
                fieldType = target.attr("data-type"), //get field type value set on data-type
                fieldName = target.attr("data-name"); //get field name value set on data-name                
                var options = populatePicklist(fieldName);
                var select = $('<select />')
                .addClass("ctInput")
                .attr("tabindex",-1)
                .on("change", fieldChange);
 
                //construct the picklist options
                $.each(options, function (index,option) {
                    select.append(
                        $("<option></option>")
                        .attr("value", option.value)
                        .text(option.label)
                    );
                });
                //set the value of the select to the current value
                select.val(fieldValue);

                //update our cell with the constructed contents
                $(target).html(select);
                //This function supports tabbed behavior and sets the focus to the input, rather than the TD. 
                $(select).focus();
            }

            //If the td we're making is a textarea or select field, this function handles the creation of the field
            function createInputField(target,fieldValue){
                fieldType = target.attr("data-type"), //get field type value set on data-type
                fieldName = target.attr("data-name"), //get field name value set on data-name
                row = target.attr("data-row"), //for HTML number fields we want to set max/min/step values for client-side validation
                max = target.attr("data-max"),
                min = target.attr("data-min"),
                step = target.attr("data-step");

                //If the field is not a picklist then we have 3 other options, input of type text or number, or a textarea
                if (fieldType=="textarea"){
                    var inputTag = '<textarea />';
                }
                else {
                    var inputTag = '<input  />';
                }
                //If the field is a number or currency field then we can also define the min/max and step parameters
                if (fieldType=="number"|| fieldType=="currency") {
                    var atts = {
                        type:"number",
                        min:min,
                        max:max,
                        step:step,
                        tabindex:-1
                    };
                }
                else {
                    var atts = {
                        maxlength: 255,
                        type:fieldType,
                        tabindex:-1
                    };
                }

                //Create the input, set its value, add a class of ctInput and fire off the fieldChange function, defined in this file when the field is changed
                var input = $(inputTag)
                    .val(fieldValue)
                    .attr(atts)
                    .addClass("ctInput")
                    .on("change", fieldChange);
                    //Set the contents of the TD to the generated input field
                    $(target).html(input);
                    //This function supports tabbed behavior and sets the focus to the input, rather than the TD. 
                    $(input).focus();
            }

            //Handle the event of the input changing from its original value. This also checks to see if the user has multiple rows selected and handles asking if they want to make a batch update
            function fieldChange() {
                var selectedRows =  $(".rowSelect:checkbox:checked"),
                rowCount = selectedRows.length,
                fieldCell = $(this).parent("td"),
                originalValue = $(this).parent("td").attr("data-value"),
                fieldId = $(this).parent("td").attr("data-id"), 
                fieldType = $(this).parent("td").attr("data-type"), 
                fieldName = $(this).parent("td").attr("data-name"),
                row = $(this).parent("td").attr("data-row"),
                columns = $("td").filter('[data-name='+fieldName+']'),
                newValue = $(this).val();
                
                //For number fields, we detect if the change is invalid. If so, we fire off a warning and reset the value to its original value
                if($(this).is(":invalid")){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error!",
                        message: "You've attempted to change this field to an invalid value. The value has been reset.",
                        type: "error"
                    });
                    toastEvent.fire();
                    $(this).val(originalValue);   
                }

                //Otherwise, the change is valid
                else {
                    //If the user has selected multiple rows, we ask if they want to apply the change to all selected rows.
                    if(rowCount>1) {
                        if (confirm('Would you like to apply this update to all ' + rowCount + ' records?')) {     
                            for (var i = 0, len = selectedRows.length; i < len; i++) {
                                var targetCell = $(columns).filter('[data-row=' + selectedRows[i].id + ']');
                                cellId = targetCell.attr('data-id');
                                rowId =  targetCell.attr('data-row');
                                //update all the selected rows, except the row that fired off the mass edit.
                                if (row!=rowId) {
                                    if (fieldType == "picklist") { 
                                        createPicklist(targetCell,newValue);
                                        $(targetCell).addClass("active");
                                    }
                                    else {
                                        createInputField(targetCell, newValue);
                                        $(targetCell).addClass("active");
                                    }
                                } 
                                updateValue(component,cellId,fieldName,newValue,targetCell);   
                            }    
                        }
                        else {
                        //The user has selected to not apply a mass update, so we only apply the update to the single cell.    
                        updateValue(component,fieldId,fieldName,newValue,fieldCell);  
                        }
                    }
                    //The user did not have mutiple rows selected when apply the change, so we simply apply the update to the single cell
                    else {
                        updateValue(component,fieldId,fieldName,newValue,fieldCell);   
                    } 
                }
            }
            //The field has been updated and we push the change to the modifiedRecords array on the component, which will be used for a future save. 
            function updateValue(component,fieldId,fieldName,newValue,fieldCell){
                //Get the current set of unsaved changes
                records = component.get("v.modifiedRecords");

                //Check to see if the updated record's ID is already in the object of uncommited updates.
                var recIndex = records.findIndex(rec => rec.id === fieldId);
                if(recIndex !== -1){
                    //This record ID is already in the object, so we update the existing item with the field name and new value
                    records[recIndex][""+fieldName] = newValue;
                }
                else{
                    //This record ID is not in the modifiedRecords object, so we add a new item defined as {'salesforce record ID':{fieldName:value}}
                    var obj = {};
                    obj["id"] = fieldId;
                    obj[""+fieldName] = newValue;
                    records.push(obj);
                }
                //Update the modifiedRecords attribute
                component.set("v.modifiedRecords", records);
                //Add the changed class to the td which adds the beige background color
                $(fieldCell).addClass("changed");
            }
        },500);
    },

    finishedSaving : function(component) {
        //create variables for our table and get the data from our modifiedRecords and updateErrors attributes
        var table = $("#datatableId").DataTable(),
        updatedRecords = component.get("v.modifiedRecords");
        updateErrors = component.get("v.updateErrors");
        //use the jquery Datatables function to convert all rows to a jQuery object
        var allRows = table.rows().nodes().to$();
        
        //uncheck all rows and uncheck the select all checkbox
        allRows.each(function () {
            $(this).find("input.rowSelect").prop( "checked", false ).change();
        });
        $("#select-all").prop("checked",false);
        
        //For each records that was updated, add the updated class, which sets a green background on the cell
        updatedRecords.forEach(function (item) {
            var id = item.id;
            keys = Object.keys(item);
            keys.forEach(function(key){
                if(key!=id) {
                    var savedCell = table.cell('[data-id='+id+'][data-name='+key+']').node(); 
                    $(savedCell).removeClass("changed").removeClass("error").addClass("updated");
                }
            });
        }); 

        //If there are any errors, add an "error" class to the cell and append the error message beneath the field.
        if (updateErrors.length > 0) {
            updateErrors.forEach(function (item) {
                keys = Object.values(item);
                keys.forEach(function(key){
                    //for each td where we have an error, find the TD based on the data-id and data-name parameters on the TD. 
                    var errorCell = table.cell('[data-id='+key["StudentTermId"]+'][data-name='+key["Fields"][0]+']').node(); 
                    //Remove the changed class and add an error class which sets a reg background color
                    //Append the error message to the bottom of the TD, beneath the input
                    $(errorCell).removeClass("changed").addClass("error").
                    append("<br>"+key["Message"]);
                });
            });

            //Empty update errors to support re-checking
            updateErrors = [];
            component.set("v.updateErrors",updateErrors);
        }
    },

    //Generates our CSV export
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        var fallTerm = component.get("v.isFallTerm"); 
        
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
    
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        //We need to conditionalize our list of our fields and column headings based on which term we're in
        if(fallTerm) {
            var columns = [
                'FirstName',
                'LastName',
                'BirthDate',
                'Student_ID_at_College__c',
                'Cohort',
                'Final_Award_Status__c',
                'SSR_Requirements_Completed__c',
                'SSR_Comments__c',
                'Projected_to_Graduate_end_of_acad_yr__c',
                'Projected_College_Graduation_Comments__c',
                'Projected_Coll__c',
                'Mobile',
                'Email'
            ];

            var columnLabels = [
                'First Name',
                'Last Name',
                'Birthdate',
                'Student Id',
                'Cohort',
                'Award Status',
                'SSR Requirements Completed',
                'SSR Comments',
                'Projected to Graduate by End of Academic Year?',
                'Projected College Graduation Comments',
                'Projected College Graduation Term & Year',
                'Mobile',
                'Email'
            ];
        }

        else {

            var columns = [
                'FirstName',
                'LastName',
                'BirthDate',
                'Student_ID_at_College__c',
                'Cohort',
                'Final_Award_Status__c',
                'SSR_Requirements_Completed__c',
                'SSR_Comments__c',
                'Projected_Coll__c',
                'Mobile',
                'Email'
            ];

            var columnLabels = [
                'First Name',
                'Last Name',
                'Birthdate',
                'Student Id',
                'Cohort',
                'Award Status',
                'SSR Requirements Completed',
                'SSR Comments',
                'Projected College Graduation Term & Year',
                'Mobile',
                'Email'
            ];
        } 
        
        //create one arrays for our keys and labels
        keys = [];
        labels = [];
        
        //Populate our arrays with keys and labels
        for(var i=0; i < columns.length; i++){   
            keys.push(columns[i]);
            labels.push(columnLabels[i]);
        }
    
        //Create our variable and join our labels together, separated by commas. This creates our header row
        csvStringResult = '';
        csvStringResult += labels.join(columnDivider);
        csvStringResult += lineDivider;

        //this creates the body of the file. For each row of data in our table, parse through each column in our list of keys
        //and pull in that value. Replace any instances of 'undefined' with ''
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
        
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  

            // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }   
            if (objectRecords[i][skey] == "undefined" || typeof objectRecords[i][skey] === 'undefined') { 
                var fieldValue = "";
                }
            else { 
                var fieldValue = objectRecords[i][skey];
                }
            csvStringResult += '"'+ fieldValue+'"'; 
            
            counter++;

            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
    
        // return the CSV formate String 
        return csvStringResult;        
    }
})