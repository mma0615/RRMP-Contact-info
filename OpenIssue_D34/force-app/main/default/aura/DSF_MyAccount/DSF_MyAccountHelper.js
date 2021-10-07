({  
    showErrorDiv : function(component, event, helper){
        component.set('v.showErrorMsg', true);        
        setTimeout(function(){ 
            component.set('v.showErrorMsg', false);            
        }, 5000);
    },

    showSuccessDiv : function(component, event, helper){        
        component.set('v.showSuccessMsg', true);        
        setTimeout(function(){ 
            component.set('v.showSuccessMsg', false);            
        }, 5000);
    },

    validateFields : function(component, fieldIds){
        var allValid = component.find(fieldIds).reverse().reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            if(inputCmp.get('v.validity').valueMissing){
            	inputCmp.focus();
            }
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);

        return allValid;
    },   


    validatePasswordFields : function(component){        

        var allValid = component.find('newPwdId').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return  inputCmp.checkValidity();
        }, true);

        return allValid;
    },   

});