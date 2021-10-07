({
    doInit : function(component, event, helper) {    
       helper.doInitHelper(component, event, helper,false);   
    },
    
    onClick : function(component, event, helper) {
        var navbar = component.find('myNavbar');
        $A.util.toggleClass(navbar, 'responsive');
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

    },
   
    handleSaveItems : function(component, event, helper){
        //helper.updateParkingLots(component, event, helper);
    },

   handleSessionChange : function(component, event, helper){
        let sessionId = component.find("sessionInput").get("v.value");
        let sessionList = component.get("v.sessionList");
    //value = component.find("sessionInput").get("v.value"),
    //20201230 JL bug fix#00601:Session Picklist
    ////START
    /*
        let index = sessionList.findIndex(item => item.Id == sessionId);
    	let session = index >= 0? sessionList[index]: null;
    */    
        let index = sessionList.findIndex(item => item.recordId == sessionId);
    	let session = index >= 0? sessionList[index]: null;
	////END
        component.set("v.session",session);
        component.set("v.selectedSessionId",sessionId);
    }

    
})