({
    doInit: function(component, event, helper) {
        
        helper.setPicklistValues(component, event, helper);
        
        //component.set('v.recordId', component.get("v.pageReference").state.id);
        var telemeetId = component.get('v.telemeetId');
        //console.log('telemeetId'+telemeetId);
        if(telemeetId){
            helper.getTelemeetRecord(component, telemeetId);
        }
        
    },
    addAvailability: function(component, event, helper) {
        component.set('v.searchButtonClicked', true);
        var contRec = component.find("contact-recordId");
        var specialty = component.get("v.specialty");
        var startdate = component.get('v.startdate');
        var enddate = component.get('v.enddate');
        var contId = (contRec.get("v.selectedOption") == undefined ? '' : contRec.get("v.selectedOption"));
        if(contId != '' || specialty != ''){
            if(contId != ''){            
                helper.getContactRecord(component, contId);
            }
            else{
                component.set("v.contact", null);
            }
            helper.getContactAvailability(component, contId, specialty, startdate, enddate);
            component.set("v.error", '');
        }
        else{        
            component.set("v.contact", null);
            component.set("v.contactAvailability", null);
        }
        
    },
    
    handleConfirmDialog : function(component, event, helper) {
        
        var telemeetId = component.get('v.telemeetId');
        console.log('telemeetId>>>'+telemeetId);
        component.set('v.showConfirmDialog', true);
        var conavaId = event.target.id;
        component.set('v.contactAvailabilityId', conavaId);
        
        helper.getConAvaRecord(component, conavaId);
        //helper.getTelemeetRecord(component, telemeetId);
        
        component.set("v.error", '');
    },
    handleConfirmDialogYes : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        var contactAvailabilityId = component.get('v.contactAvailabilityId');
        var area = component.get('v.area');
        var otherarea = component.get('v.otherarea');
        var internalnotes = component.get('v.internalnotes');
        
        //var contRec = component.find("resource-contact");
        //var contId =  contId = (contRec.get("v.selectedOption") == undefined ? '' : contRec.get("v.selectedOption"));
        
        //helper.scheduleMeeting(component, contactAvailabilityId, area, otherarea, internalnotes, contId);
        
        
        var telemeetId = component.get('v.telemeetId');
        if(telemeetId){
            console.log('contactAvailabilityId'+contactAvailabilityId);
            console.log('telemeetId'+telemeetId);
        	helper.updateTeleMeet(component, contactAvailabilityId, telemeetId);
        }
        else{
            alert('No Telemeet Record Associated.');
        }
        
        var addAvailability = component.get('c.addAvailability');
        $A.enqueueAction(addAvailability);
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        component.set('v.showConfirmDialogCompleted', false);
        component.set('v.contactAvailabilityId', null);
        component.set("v.error", '');
    },
    
    scheduleMeet: function(component, event, helper) {
        component.set("v.contactInfoIsOpen", true);
        
    },
    
    returntotelemeet: function(component, event, helper) {
        var telemeetId = component.get('v.telemeetId');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": telemeetId,
            "slideDevName": "detail"
        });
        navEvt.fire();
        component.set('v.showConfirmDialogCompleted', false);
    }
})