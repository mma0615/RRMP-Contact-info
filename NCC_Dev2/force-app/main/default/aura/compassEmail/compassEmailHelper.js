({
    sendEmail : function(cmp, event, helper) {
        cmp.set('v.isLoading', true);
        let action = cmp.get('c.sendCompassEmail');
        // console.log('recordId', cmp.get('v.recordId'));
        // console.log('orgWideEmailAddressRecord.Id', cmp.get('v.orgWideEmailAddressRecord').Id);
        // console.log('contactIdList', cmp.get('v.contactIdList'));
        // console.log('subject', cmp.get('v.subject'));
        // console.log('emailBody', cmp.get('v.emailBody'));
        // console.log('ccRecipients', cmp.get('v.ccRecipients'));
        // console.log('bccRecipients', cmp.get('v.bccRecipients'));
        let ccRecipients = cmp.get('v.ccRecipients').join();
        let bccRecipients = cmp.get('v.bccRecipients').join();
        action.setParams({
            'recordId' :  cmp.get('v.recordId'),
            'orgWideEmailId' : cmp.get('v.orgWideEmailAddressRecord').Id,
            'contactRecipientIds' : cmp.get('v.contactIdList'),
            'subject' : cmp.get('v.subject'),
            'emailBody' : cmp.get('v.emailBody'),
            'ccRecipients' : ccRecipients,
            'bccRecipients' : bccRecipients,
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS'){
                const returnValue = response.getReturnValue();
                console.log('Apex Successfully Invoked!');
                if(returnValue){
                    helper.showToastError(helper.logError(returnValue));
                    cmp.set('v.isLoading', false);
                }
                else{
                    helper.showSuccessToast('Email/s Successfully Sent');
                    helper.closeModal();
                }
            }
            else{
                helper.showToastError(helper.logError(response.getError()));
                cmp.set('v.isLoading', false);
            }
        })
        $A.enqueueAction(action);
	},

    showSuccessToast : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : "success",
            "message": message
        });
        toastEvent.fire();
    },

    showToastError : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type" : "error",
            "message": message
        });
        toastEvent.fire();
    },

    showToastWarning : function(message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Field Required!",
            "type" : "warning",
            "message": message
        });
        toastEvent.fire();
    },
    
    logError : function(errors){
        if (errors) {
            if (errors[0] && errors[0].message) {
                // log the error passed in to AuraHandledException
                let errorMessage = "Error message: " + errors[0].message
                console.log(errorMessage);
                return errorMessage;
            }
            else{
                console.log("Unknown error", JSON.stringify(errors));
                return "Unknown error", JSON.stringify(errors);
            }
        } else {
        	console.log("Unknown error", JSON.stringify(errors));
            return "Unknown error", JSON.stringify(errors);
        }
	},

    closeModal : function(){
        $A.get("e.force:closeQuickAction").fire();     
    }
})