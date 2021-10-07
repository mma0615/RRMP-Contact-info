({
    
    openModal : function (component, event, helper) {
        let modal    = component.find("modal");
        let backdrop = component.find("backdrop");
        $A.util.addClass(modal, "slds-fade-in-open"); 
        $A.util.addClass(backdrop, "slds-backdrop--open");
    },  
    openmsgModal : function(component, event, helper) {
        let msgmodal = component.find("msgmodal");
        let backdrop = component.find("backdrop");
        $A.util.addClass(msgmodal, "slds-fade-in-open");
        $A.util.addClass(backdrop, "slds-backdrop--open");
    },

    closeModal : function (component, event, helper) {
        let modal    = component.find("modal");
        let backdrop = component.find("backdrop");
        $A.util.removeClass(modal, "slds-fade-in-open"); 
        $A.util.removeClass(backdrop, "slds-backdrop--open");
        let isLogin = component.get("v.IsLogin");
        if(isLogin) {
            let msgmodal = component.find("msgmodal");
            let backdrop = component.find("backdrop");
            $A.util.removeClass(msgmodal, "slds-fade-in-open");
            $A.util.removeClass(backdrop, "slds-backdrop--open");
            component.set("v.ShowContactUs", false);
        } else {
            let navService = component.find("navService");
            let pageReference = {
            type: 'comm__namedPage',
            attributes:
            {
                pageName: 'my-messages'
            }
        };
        navService.navigate(pageReference);
        }
    },

    clearFields : function(component, event, helper) { 
        component.set("v.FirstName", "")
        component.set("v.LastName", "");
        component.set("v.Email", "");
        component.set("v.DateOfBirth", null);
        component.set("v.CollegeId", "");
        component.set("v.CollegeId", "");
        component.set("v.Message", ""); 
        component.set("v.Subject", ""); 
    },

    validateAllFields : function(component, event, helper){
        var allValid = component.find('fieldId').reverse().reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            if(inputCmp.get('v.validity').valueMissing){
            	inputCmp.focus();
            }
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);

        return allValid;
    }, 

    createCase : function (component, event, helper) { 
        
        let action = component.get("c.createCase");
        action.setParams({"newCase" : component.get("v.newCase")});
        action.setCallback(this,function(response){
            let state = response.getState();
            
            if (state === "SUCCESS"){
                let caseId = response.getReturnValue();
                if(caseId != null && caseId != ''){
                    component.set('v.caseRecordId', caseId);

                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "The case has been created successfully."
                    });
                    toastEvent.fire(); 

                    if (component.get("v.IsLogin")) {
                        helper.openmsgModal(component,event,helper)
                    }else {
                        helper.openModal(component, event, helper);  
                    }
                    
                } else{
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Failed to create case"
                    });
                    toastEvent.fire();                    
                }
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message + ' - Unable to submit case');
                    }
                }
            }
            
        });
        $A.enqueueAction(action);
    }
})