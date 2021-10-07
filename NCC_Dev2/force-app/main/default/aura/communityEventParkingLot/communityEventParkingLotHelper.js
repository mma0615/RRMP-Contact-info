({
    doInitHelper : function(component, event, helper, statusList, typeList) {
        console.log('handleSort'+statusList);
        document.title = 'Loading....';
        let namespaceVal = '';
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

        var url_string = document.location.href;
        var eventId = (url_string.split('id=')[1]).slice(0,11);
        var contactId = null;
        const contactParam = (url_string.split('contactId=')[1]);

        if(contactParam != undefined){
            contactId = contactParam.slice(0,11);
            component.set('v.contactId',contactId);
        }

        component.set('v.eventId',eventId);

        let action = component.get("c.getParkingLotDetails");
        
        action.setParams({ 
            eventId : eventId,
            contactId : contactId,
            statusList : statusList,
            typeList2 : typeList
        });
        
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                let resultMap = JSON.parse(response.getReturnValue());
                let parkingLots = resultMap.parkingLotList;
                if(parkingLots){
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
                    if( row.Escalated_To__c){
                        row.Escalated_To__c = row.Escalated_To__c;
                    }
                    
                    else{
                        row.Escalated_To__c = '';
                    }
                    if( row.Raised_By__c){
                        row.Raised_By__Name = row.Raised_By__r.Name;
                    }
                    
                    else{
                        row.Raised_By__Name = '';
                    }
                    if (row.Addressed_By__c){
                        row.Addressed_By__Name = row.Addressed_By__r.Name;
                    }
                    else{
                        row.Addressed_By__Name ='';
                    }
                    if (row.Session__c){
                        row.Session_Name = row.Session__r.Name;
                    }
                    else{
                        row.Session_Name ='';
                    }
                        //Parking Lot Info
                        row.Parking_Lot_Info = row.Name + '\n' + row.Session_Name + '\n' + row.Status__c  + '\n' + row.Type__c;
                }
                }
                
                if(resultMap.campaignRecord.Location__c){
                    component.set('v.location', resultMap.campaignRecord.Location__r.Name); 
                }
                else{
                    component.set('v.location', ''); 
                }
                
                
                if(resultMap.campaignRecord.Parking_Lot_Page_Title__c != null || resultMap.campaignRecord.Parking_Lot_Page_Title__c !=  undefined){
                    component.set('v.parkingPageTitle', resultMap.campaignRecord.Parking_Lot_Page_Title__c);
                    document.title = resultMap.campaignRecord.Parking_Lot_Page_Title__c;
                }else{
                    component.set('v.parkingPageTitle', 'PARKING LOT');
                }
                
                if(resultMap.contact){
                    component.set('v.email', resultMap.contact.Email); 
                    component.set('v.columns', [
                        {label: '', fieldName: '', type: 'text' ,editable: false, wrapText: true, initialWidth: 50},
                       {label: 'Parking Lot Information', fieldName: 'Parking_Lot_Info', type: 'text' ,editable: false, wrapText: true},
                       //{label: 'Parking Lot Number', fieldName: 'Name', type: 'text' ,editable: false, wrapText: true},
                       //{label: 'Session', fieldName: namespaceVal+'Session_Name', type: 'text' ,editable: false, wrapText: true},
                       //{label: 'Type', fieldName: namespaceVal+'Type__c', type: 'text' ,editable: true, wrapText: true},
                       //{label: 'Category', fieldName: namespaceVal+'Category__c', type: 'text' ,editable: true, wrapText: true},
                       {label: 'Description', fieldName: namespaceVal+'Description__c', type: 'text' ,editable: false, wrapText: true},
                       //{label: 'Raised By', fieldName: namespaceVal+'Raised_By__Name', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Resolution/Answer', fieldName: namespaceVal+'Resolution_Answer__c', type: 'text' ,editable: false, wrapText: true},
                        //{label: 'Status', fieldName: namespaceVal+'Status__c', type: 'text' ,editable: true, wrapText: true},
                        //{label: 'Addressed By', fieldName: namespaceVal+'Addressed_By__Name', type: 'text' ,editable: false},
                        //{label: 'Escalated to', fieldName: namespaceVal+'Escalated_To__c', type: 'text' ,editable: false } 
                        {label: '', fieldName: '', type: 'text' ,editable: false, wrapText: true, initialWidth: 50}
                    ]);
                }
                else{
                    component.set('v.columns', [
                        {label: '', fieldName: '', type: 'text' ,editable: false, wrapText: true, initialWidth: 50},
                       {label: 'Parking Lot Information', fieldName: 'Parking_Lot_Info', type: 'text' ,editable: false, wrapText: true},
                       //{label: 'Parking Lot Number', fieldName: 'Name', type: 'text' ,editable: false, wrapText: true},
                       //{label: 'Session', fieldName: namespaceVal+'Session_Name', type: 'text' ,editable: false, wrapText: true},
                       //{label: 'Type', fieldName: namespaceVal+'Type__c', type: 'text' ,editable: true, wrapText: true},
                       //{label: 'Category', fieldName: namespaceVal+'Category__c', type: 'text' ,editable: true, wrapText: true},
                       {label: 'Description', fieldName: namespaceVal+'Description__c', type: 'text' ,editable: false, wrapText: true},
                       //{label: 'Raised By', fieldName: namespaceVal+'Raised_By__Name', type: 'text' ,editable: false, wrapText: true},
                        {label: 'Resolution/Answer', fieldName: namespaceVal+'Resolution_Answer__c', type: 'text' ,editable: false, wrapText: true},
                        //{label: 'Status', fieldName: namespaceVal+'Status__c', type: 'text' ,editable: true, wrapText: true},
                        //{label: 'Addressed By', fieldName: namespaceVal+'Addressed_By__Name', type: 'text' ,editable: false},
                        //{label: 'Escalated to', fieldName: namespaceVal+'Escalated_To__c', type: 'text' ,editable: false } 
                        {label: '', fieldName: '', type: 'text' ,editable: false, wrapText: true, initialWidth: 50}
                    ]);
                }
                component.set('v.commentTag', resultMap.campaignRecord.Parking_Lot_Tag_Line__c);
                component.set('v.commentMessage', resultMap.campaignRecord.Parking_Lot_Message__c);
                component.set('v.eventName', resultMap.campaignRecord.Name);
                component.set('v.eventRecordId', resultMap.campaignRecord.Id);
                resultMap.sessionList[0].selected = true;
                component.set('v.session', resultMap.sessionList[0]);
                //component.set("v.selectedSessionId",resultMap.sessionList[0].Id);//commented 20201230 JL bug/fix#00601:Session Picklist
                component.set("v.selectedSessionId",resultMap.sessionList[0].recordId);//added 20201230 JL bug/fix#00601:Session Picklist
                component.set('v.types', resultMap.typeList);
                component.set('v.categories', resultMap.categoryList);
                //component.set('v.sessionList', resultMap.sessionList);//commented 20201230 JL bug/fix#00601:Session Picklist
                component.set('v.sessionList', resultMap.sessionWrapper);//added 20201230 JL bug/fix#00601:Session Picklist
                component.set('v.parkingLots', parkingLots);
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
        let action = component.get("c.createParkingLot");    
         
        action.setParams({
            eventId : component.get("v.eventRecordId"),
            session : component.get("v.selectedSessionId"),
            email : component.get("v.email"),
            phone : component.get("v.phone"),
            description : component.get("v.description"),
            type : component.get("v.type"),
            category : component.get("v.category")
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
                component.set("v.category","");
                helper.doInitHelper(component,event,helper);
                
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                let message = 'Error on Creating Parking Lot'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                   message = errors[0].message;
                }
                this.showToast('Oops!', message, "error", "pester");
                component.set("v.showSpinner", false);
            }
            else {
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
    },

    updateParkingLots : function(component, event, helper) {
        let action = component.get("c.updateParkingLots");    
        let draftValues = event.getParam('draftValues');
        action.setParams({
            parkingLots : JSON.stringify(draftValues)
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();

            if (state === "SUCCESS") {
                this.showToast('Success!', "Your changes has been saved.", "success", "pester");
                component.set("v.showSpinner", false);
                helper.doInitHelper(component,event,helper,true);
               
                //$A.get('e.force:refreshView').fire();
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                let message = 'Error on Updating Parking Lots'; // Default error message
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


   

})