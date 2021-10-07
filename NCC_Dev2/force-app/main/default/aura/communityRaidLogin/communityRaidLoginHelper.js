({
    doSendToken : function(component, event, helper) {
        let action = component.get("c.sendTokenCode");
        
        action.setParams({ 
            email : component.find("email").get("v.value")
            //email : 'lynne.daise@nationalcoordinationcenter.com'
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                let  message = 'Token sent. Please check your email';
                this.showToast('Success!', message, "success", "pester");
            }
             else if (state === "ERROR") {
                let errors = response.getError();
                let message = 'Error on sending email'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                this.showToast('Oops!', message, "error", "pester");
                
            }
        });
        $A.enqueueAction(action);
    },
    doSubmit: function(component, event, helper) {
        let action = component.get("c.doLogin");
        
        action.setParams({ 
            email : component.find("email").get("v.value"),
            //email : 'lynne.daise@nationalcoordinationcenter.com',
            token : component.find("token").get("v.value")
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                
                let resultMap = JSON.parse(response.getReturnValue());
                let homeURL = $A.get("$Label.c.Project_Raid_Home_URL");
                let projectId = component.get("v.projectId");
                let contactId = resultMap.contact.Id;
                let token = resultMap.contact.Login_Token__c;
                let redirectUrl = homeURL+'?id='+projectId+'&contactId='+contactId+'&token='+token;
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
})