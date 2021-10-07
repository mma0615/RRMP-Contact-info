({
	doSendToken : function(component, event, helper) {
		let action = component.get("c.sendTokenCode");
        
        action.setParams({ 
            email : component.find("email").get("v.value")
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                  let  message = 'Token sent. Please check your email';
                this.showToast('Success!', message, "success", "pester");
            }
            else{
                helper.showToastError(helper.logError(response.getError()));
            }
        });
        $A.enqueueAction(action);
	},
    doSubmit: function(component, event, helper) {
		let action = component.get("c.doLogin");
        
        action.setParams({ 
            email : component.find("email").get("v.value"),
            token : component.find("token").get("v.value")
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                
                    let resultMap = JSON.parse(response.getReturnValue());
                let baseUrl = resultMap.baseUrl;
                let eventId = resultMap.eventId;
                let contactId = resultMap.contact.Contact_Id__c;
                debugger;
                let token = resultMap.contact.Login_Token__c;
                let redirectUrl = baseUrl+'?id='+eventId+'&contactId='+contactId+'&token='+token;
                    location.replace(redirectUrl);
                
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                let message = 'Error on Logging in'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                   message = errors[0].message;
                }
                this.showToast('Oops!', message, "error", "pester");
                
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

    showToastError : function(message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type" : "error",
            "message": message
        });
        toastEvent.fire();
    },
    // 6/2/2021 jlabn
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
})