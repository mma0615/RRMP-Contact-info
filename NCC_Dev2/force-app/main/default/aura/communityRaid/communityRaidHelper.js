({
    doInitHelper : function(component, event, helper) {
        component.set("v.showSpinner", true);
        /*component.set('v.columns', [
            {label: 'Parking Lot', fieldName: 'Name', type: 'text' ,editable: false},
           // {label: 'Session', fieldName: 'Session_Name', type: 'text' ,editable: false},
            {label: 'Raised By', fieldName: 'Raised_By__Name', type: 'text' ,editable: false},
            {label: 'Question', fieldName: 'Description__c', type: 'text' , wrapText: true }, 
            {label: 'Resolution/Aswer', fieldName: 'Resolution_Answer__c', type: 'text' ,editable: false},
            {label: 'Type', fieldName: 'Type__c', type: 'text' ,editable: true},
            {label: 'Status', fieldName: 'Status__c', type: 'text' ,editable: true},
            {label: 'Addressed By', fieldName: 'Addressed_By__Name', type: 'text' ,editable: false},
            {label: 'Escalated to', fieldName: 'Escalated_To__c', type: 'text' ,editable: false } 
        ]);*/
        
        let url_string = document.location.href;
        let eventId = (url_string.split('id=')[1]).slice(0,11);
        const urlParams = new URLSearchParams(url_string);
        const contactId = urlParams.get('contactId');
        const token = urlParams.get('token');
        component.set('v.eventId',eventId);
        component.set('v.contactId',contactId);
        
        let action = component.get("c.getProjectRaidDetails");
        
        action.setParams({ 
            projectId : eventId,
        });
        
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                let resultMap = JSON.parse(response.getReturnValue());
                let parkingLots = resultMap.raidList;
                for (let i = 0; i < parkingLots.length; i++) {
                    let row = parkingLots[i];
                    if( row.Description__c){
                        row.Description__c = row.Description__c;
                    } 
                    else{
                        row.Description__c = '';
                    }
                    
                    if( row.Resolution_Answer__c){
                        row.Resolution_Answer__c = row.Resolution_Answer__c;
                    }
                    else{
                        row.Resolution_Answer__c = '';
                    }
                    
                    if( row.Type__c){
                        row.Type__c = row.Type__c;
                    }
                    else{
                        row.Type__c = '';
                    }
                    
                    if( row.Status__c){
                        row.Status__c = row.Status__c;
                    }
                    else{
                        row.Status__c = '';
                    } 
                    
                    if( row.Date_Raised__c){
                        row.Date_Raised__c = row.Date_Raised__c + ' EST';
                    }
                    else{
                        row.Date_Raised__c = '';
                    } 
                    
                }
                
                if(resultMap.contact){
                    component.set('v.email', resultMap.contact.Email); 
                    component.set('v.columns', [
                        {label: 'Project RAID ID', fieldName: 'Name', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Type', fieldName: 'Type__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Date Raised', fieldName: 'Date_Raised__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Description', fieldName: 'Description__c', type: 'text' ,editable: false, wrapText: true},
                        //{label: 'Likelihood', fieldName: 'Likelihood__c', type: 'text' ,editable: false, wrapText: true},
                        //{label: 'Impact', fieldName: 'Impact__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Resolution', fieldName: 'Resolution__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Raised By', fieldName: 'Raised_By_Email__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Status', fieldName: 'Status__c', type: 'text' ,editable: false, wrapText: true},
                    ]);
                        }
                        else{
                        component.set('v.columns', [
                        {label: 'Project RAID ID', fieldName: 'Name', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Type', fieldName: 'Type__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Date Raised', fieldName: 'Date_Raised__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Description', fieldName: 'Description__c', type: 'text' ,editable: false, wrapText: true},
                        //{label: 'Likelihood', fieldName: 'Likelihood__c', type: 'text' ,editable: false, wrapText: true},
                        //{label: 'Impact', fieldName: 'Impact__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Resolution', fieldName: 'Resolution__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Raised By', fieldName: 'Raised_By_Email__c', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Status', fieldName: 'Status__c', type: 'text' ,editable: false, wrapText: true},
                    ]);
                }
                component.set('v.types', resultMap.typeList);
                console.table(parkingLots);
                component.set('v.eventRecordId', resultMap.projectId);
                component.set('v.projectName', resultMap.projectName);
                component.set('v.parkingLots', parkingLots);
                component.set("v.commentTag", resultMap.project.Project_RAID_Tag_Line__c);
                component.set("v.commentMessage", resultMap.project.Project_RAID_Message__c);
                component.set("v.showSpinner", false);
                
                //Empty Fields
                
            }
            //Error
            else if (state === "ERROR") {
                let errors = response.getError();
                let message = 'Error on Loading Parking lot page'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                this.showToast('Oops!', message, "error", "pester");
                component.set("v.showSpinner", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    submitParkingLot : function(component, event, helper) {
        let action = component.get("c.createProjectRaid");    
        
        action.setParams({
            projectId : component.get("v.eventRecordId"),
            email : component.get("v.email"),
            description : component.get("v.description"),
            type : component.get("v.type")
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                this.showToast('Success!', "Your response has been submitted.", "success", "pester");
                component.set("v.showSpinner", false);
                //Reset fields
                component.set("v.description","");
                component.set("v.type","");
                component.set("v.email","");
                helper.doInitHelper(component,event,helper);
                
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                let message = 'Error on Creating Raid'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                this.showToast('Oops!', message, "error", "pester");
                component.set("v.showSpinner", false);
            }
                else {
                    console.log("Failed with state: " + state);
                    this.showToast('Oops!', "Something's not right. Please contact the administrator for help.", "error", "pester");
                    component.set("v.showSpinner", false);
                }
        });
        $A.enqueueAction(action);
    },
    
    
    showToast : function(title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type,
            "mode" : mode
        });
        toastEvent.fire();
    }
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
     
        $A.enqueueAction(action);
       
    },
    */
})