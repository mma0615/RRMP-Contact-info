({
	getAvailableFields : function(component, event, helper) {
		var action = component.get("c.getAvailableRegistrationFields");
        action.setParams({ 
            eventRecordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var resultEvent = response.getReturnValue();
                component.set("v.registrationFields", resultEvent);
                component.set("v.registrationFieldsCopy", resultEvent);
                helper.checkSelectAllBoxes(component, resultEvent);
            }
        });
        
        $A.enqueueAction(action);
	},

    checkSelectAllBoxes : function(component, results){
        let isSelectAll = true;
        let isRequiredAll = true;

        for (let i = 0 ; i < results.length ; i++){
            if (!results[i].active){
                isSelectAll = false;
            }

            if (!results[i].required){
                isRequiredAll = false;
            }
        }

        component.set("v.selectAll", isSelectAll);
        component.set("v.requiredAll", isRequiredAll);
    },
    
    saveRegistrationForm : function(component, event, helper){
        component.set("v.isReadOnly", true);

        let updatedFields = component.get("v.registrationFields");
        let action = component.get("c.saveRegistrationFormFields");
        let fieldsForSaving = {};

        for (let i = 0 ; i < updatedFields.length ; i++){
            if(updatedFields[i]["active"]){
               fieldsForSaving[updatedFields[i]["key"]] = updatedFields[i]["required"]; 
            } 
        }
     
        action.setParams({ 
            eventRecordId : component.get("v.recordId"),
            updatedRegistrationFieldJSON : JSON.stringify(fieldsForSaving)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast("Success", "Event Registration Fields have been saved successfully", "success");
                component.set("v.registrationFieldsCopy", component.get("v.registrationFields"));
            }
        });
        
        $A.enqueueAction(action);
    },

    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type,
            "mode" : "pester"
        });
        toastEvent.fire();
    }
})