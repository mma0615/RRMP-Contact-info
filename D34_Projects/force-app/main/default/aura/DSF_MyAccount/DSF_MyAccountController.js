({
    doInit : function(component, event, helper) {        
        //set radio button values list
        var options = new Array();
        options.push({'label': component.get('v.checkboxYes'), 'value': true}, {'label': component.get('v.checkboxNo'), 'value': false}); 
        component.set('v.yesNoList', options);
    },

    toggleEmailAlert : function(component, event, helper) {
        let alert = document.getElementById("alertDiv");
        alert.classList.toggle("display-none_alert"); 
    },

    setUserSelection : function(component, event, helper) {
        var currContact = component.get('v.currContact'); 
        currContact.OK_to_Text__c = currContact.OK_to_Text__c != null && currContact.OK_to_Text__c == 'true' ? true : false;
        component.set('v.currContact', currContact);
    },
    
     

    handleSaveRecord : function(component, event, helper) {
        
        var newPwd = component.get("v.newPwd");
        var confirmPwd = component.get("v.confirmPwd"); 
        var changeEmail = component.get("v.changedEmail");


        var passwordFieldsValid = true;
        if(newPwd != '')
            passwordFieldsValid = helper.validatePasswordFields(component);

        var contFieldsValid = helper.validateFields(component, 'fieldId');

        var allValid = newPwd == confirmPwd && passwordFieldsValid && contFieldsValid;

        if(!allValid){
            component.set("v.errorMsg", 'Please update the missing fields and try again.');
            helper.showErrorDiv(component, event, helper);
            return;
        }

        if(component.get('v.duplicateUsername')){
            component.set("v.errorMsg", 'An account with this email already exists. Please use a different email.');
            helper.showErrorDiv(component, event, helper);
            component.set('v.duplicateUsername', false);
            return;
        }

        component.set("v.isSaveReqSent", true); 

        component.find("contactSaver").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                
                var noErrors = true;

                if (newPwd != '' && newPwd != null) {
                    var action = component.get("c.changePassword");
                    action.setParams({ "newPass" : newPwd })
                    action.setCallback(this, function(response){
                        let state = response.getState();
                        if (state === "SUCCESS") {

                            component.set('v.newPwd', '');
                            component.set('v.confirmPwd', '');
                            
                            helper.showSuccessDiv(component, event, helper);
                        } else if (state === "ERROR") {
                            
                            noErrors = false;
                            
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {

                                    debugger;
                                    if(errors[0] != null && errors[0].message.trim() == 'invalid repeated password'){
                                        component.set("v.errorMsg", 'Invalid repeated password.');
                                    } else if(errors[0] != null && errors[0].message.trim() == 'Your password must include numbers and uppercase and lowercase letters.'){
                                        component.set("v.errorMsg", 'Your password must include numbers and uppercase and lowercase letters.');
                                    } else {
                                        component.set("v.errorMsg", errors[0].message);
                                    }

                                    helper.showErrorDiv(component, event, helper);
                                }  
                            } else {
                                console.log("Unknown error");
                            }
                        } 
                    });
                    
                    $A.enqueueAction(action);
                } else if(noErrors) {
                    helper.showSuccessDiv(component, event, helper);   
                }                      
                        
                } else if (saveResult.state === "INCOMPLETE") {
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") { 
                    component.set("v.errorMsg", saveResult.error);
                    helper.showErrorDiv(component, event, helper);
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            
            component.set("v.isSaveReqSent", false);       
           // location.reload();
        }));     
        
    },

    handleEmailChange: function(component, event, helper) {
        var changedEmailVar = event.getSource().get('v.value');
        component.set("v.changedEmail", changedEmailVar); 

        var oldUserEmail = component.get('v.currentUserEmail');

        if(oldUserEmail != changedEmailVar) {
            var actionSaveUserEmail = component.get("c.checkIfUsernameExists");
                    
            actionSaveUserEmail.setParams({ "email" : changedEmailVar })
            actionSaveUserEmail.setCallback(this, function(response){
                let state = response.getState();
                let message = response.getReturnValue(); 
                if (state === "SUCCESS" && message == 'Username already exist. Username must be unique.' ) {
                    component.set('v.duplicateUsername', true);
                }  
            });
                
            $A.enqueueAction(actionSaveUserEmail);   
        }  
    },

    handleContactLoaded : function (component, event, helper) {
        var eventParams = event.getParams(); 
        if(eventParams.changeType === "LOADED") { 
            var con = component.get('v.currContact');  
            if(con != null) {                
               component.set('v.currentUserEmail', con.Email);
            }
        }
    },

     
})