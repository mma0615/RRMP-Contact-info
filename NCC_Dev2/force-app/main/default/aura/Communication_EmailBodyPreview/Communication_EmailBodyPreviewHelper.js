({
    initializeAttributes : function(component, event, helper) {
        const recordId = component.get('v.recordId');
        const action = component.get('c.getCommunication');
        action.setParams({ recordId });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS'){
                let communication = response.getReturnValue();
                console.log('Communication', communication);
                component.set('v.communication', communication);
            }
            else{
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