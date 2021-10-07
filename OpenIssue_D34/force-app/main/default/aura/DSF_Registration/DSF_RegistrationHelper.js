({
    createAccount : function(component, event) {
        let contacts = component.get('v.contact_list');
        let firstName = component.get('v.firstName'); 
        let email = component.get('v.email');

        let action = component.get("c.registration");

        action.setParams({
                'firstName' : contacts[0].FirstName,
                'lastName' : contacts[0].LastName,
                'preferredName' : firstName,
                'email' : email, 
                'accountId' : contacts[0].AccountId,
                'contactId' : contacts[0].Id 
        });
        action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    //alert("From server: " + response.getReturnValue());
                    component.set("v.screen", "");
                    let evt = component.getEvent("DSF_Login_Event");
                    evt.setParams({"showTabs": false});
                    evt.fire();
                    let ineligible_evt = component.getEvent('DSF_Ineligible_Event');
                    ineligible_evt.setParams({'message' : '', 'is_default_message' : false, 'isIneligible' : false});
                    ineligible_evt.fire();
                }
                else {
                    let errors = response.getError();
                    if (errors) {
                        if(errors[0] && errors[0].exceptionType && errors[0].exceptionType === 'Site.ExternalUserCreateException'){
                            component.set('v.emailErrorMessage', 'An account for this DPS or college ID already exists. Please use the Forgot Password link or contact DSF for help.');
                            /*Email address is already in use. Please try a different email address.*/
                        }
                        if (errors[0] && errors[0].message) {
                            console.log("Error message creating user: " + 
                                     errors[0].message + email + firstName );
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                return true;
        });

        $A.enqueueAction(action);
        return false;
    }, 

    validateField : function(component, event, helper){

        var inputCmp = component.find('fieldId');
        inputCmp.showHelpMessageIfInvalid();

        if(inputCmp.get('v.validity').valueMissing){
           inputCmp.focus();
        }

        return !inputCmp.get('v.validity').valueMissing;
    },

    backToLoginHandler: function(component, event, helper){
        let cmpEvent = component.getEvent("DSF_backToLogIn");
        cmpEvent.setParams({"comeBack" : true});
        cmpEvent.fire();
    }

});