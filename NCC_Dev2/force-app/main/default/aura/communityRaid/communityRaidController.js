({
    doInit : function(component, event, helper) {    
       helper.doInitHelper(component, event, helper,false);   
    },     
    
    handleSubmit : function(component, event, helper){
      
        let allValid = component.find('contactUsForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid){
            component.set("v.showSpinner", true);
            helper.submitParkingLot(component, event, helper);
        } 
    }
       
})