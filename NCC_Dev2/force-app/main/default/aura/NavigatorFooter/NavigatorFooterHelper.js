({
    initNavigatorAttributes : function(component, event){
        const navigatorRecord = event.getParam('navigatorRecord');
        component.set('v.navigatorRecord', navigatorRecord);
        component.getElement().style.setProperty('--theme-color1', navigatorRecord.Theme_Color_1__c);
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

    logError : function(errors){
        if (errors) {
            if (errors[0] && errors[0].message) {
                // log the error passed in to AuraHandledException
                let errorMessage = "Error message: " + errors[0].message
                console.error(errorMessage);
                return errorMessage;
            }
            else{
                console.error("Unknown error", JSON.stringify(errors));
                return "Unknown error", JSON.stringify(errors);
            }
        } else {
        	console.error("Unknown error", JSON.stringify(errors));
            return "Unknown error", JSON.stringify(errors);
        }
	},

})