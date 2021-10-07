({
    toggleFilter : function(component, event, helper) {  
        component.set("v.isFilter", !component.get("v.isFilter"));
    },
    handleSort : function(component, event, helper) {  
        console.log('handleSort');
        var status_open = component.get("v.status_open");
        var status_closed = component.get("v.status_closed");
        
        var type_issue = component.get("v.type_issue");
        var type_question = component.get("v.type_question");
        var type_comment = component.get("v.type_comment");
        var statusArr =new Array();
        if(status_open == true){
            statusArr.push('Open');
        }
        if(status_closed == true){
            statusArr.push('Closed');
        }
        if(statusArr.length > 0){
            var statusList = JSON.stringify(statusArr);
        }
        
        var typeArr =new Array();
        if(type_issue == true){
            typeArr.push('Issue');
        }
        if(type_question == true){
            typeArr.push('Question');
        }
        if(type_comment == true){
            typeArr.push('Comment');
        }
        
        if(typeArr.length > 0){
            var typeList = JSON.stringify(typeArr);
        }
        
       helper.doInitHelper(component, event, helper, statusList, typeList, false);  
    },
    doInit : function(component, event, helper) {    
       helper.doInitHelper(component, event, helper, null, null, false);   
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
        helper.updateParkingLots(component, event, helper);
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