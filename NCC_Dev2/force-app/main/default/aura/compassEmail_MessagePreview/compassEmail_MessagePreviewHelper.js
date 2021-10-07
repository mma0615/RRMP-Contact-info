({
	getOrgWideEmailAddress : function(cmp, event, helper) {
		const action = cmp.get("c.getOrgWideEmailAddress");
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === "SUCCESS"){
                const returnValue = response.getReturnValue();
                let options = _.map(returnValue, function(item){
                    return { label : item.DisplayName + ' <' + item.Address + '>', value : item.Id};
                });
                cmp.set('v.senderOptions', options);
                cmp.set('v.orgWideEmailList', returnValue);

                // if there's no selected sender yet, set a default from compass settings.
                const orgWideEmailAddressRecord = cmp.get('v.orgWideEmailAddressRecord');
                if(!orgWideEmailAddressRecord && returnValue.length){
                    helper.setDefaultSender(cmp, event, helper, returnValue);
                }

            }else{
                helper.showToastError(helper.logError(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
	},
    
    getEmailTemplates : function(cmp, event, helper) {
		const action = cmp.get("c.getEmailTemplates");
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === "SUCCESS"){
                let returnValue = response.getReturnValue();
                let options = _.map(returnValue, function(item){
                    return { label : item.Name , value : item.Id };
                });
                // console.log('template options', options);
                cmp.set('v.emailTemplateOptions', options);
                cmp.set('v.emailTemplateList', returnValue);
                cmp.set('v.isLoading', false);
            }else{
                helper.showToastError(helper.logError(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
	},
    
    setDefaultSender : function(cmp, event, helper, orgWideEmailList) {
		const action = cmp.get("c.getDefaultSenderId");
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === "SUCCESS"){
                let returnValue = response.getReturnValue();
                cmp.set('v.selectedSender', returnValue);
                let selectedOrgWideEmail = _.find(orgWideEmailList, function(item){
                    return item.Id === returnValue;
                });
                cmp.set('v.orgWideEmailAddressRecord', selectedOrgWideEmail);
                
            }else{
                helper.showToastError(helper.logError(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
	},

    showToastError : function(error) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type" : "error",
            "message": error
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
	}
    
})