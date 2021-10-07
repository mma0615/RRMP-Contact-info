({
    getProjectList : function(component, event, helper) {
        let action = component.get("c.getProjectList");

        action.setCallback(this, function(response){
            let state = response.getState();

            if (state === "SUCCESS") {
                let respValue = response.getReturnValue();
                let options = [];
                options.push({'label' : 'All', 'value' : ''})
                respValue.forEach(element => options.push({'label' : element.Name, 'value' : element.Id}));
                component.set("v.projectOptions", options);

            } else {
                helper.handleErrors(response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    getEpicList : function(component, event, helper) {
        let action = component.get("c.getEpicList");

        action.setParams({
            "projectId" : event.getParam("value")
        });

        action.setCallback(this, function(response){
            let state = response.getState();

            if (state === "SUCCESS") {
                let respValue = response.getReturnValue();
                let options = [];
                options.push({'label' : 'All', 'value' : ''});
                options.push({'label' : 'Unassigned', 'value' : 'Unassigned'})
                respValue.forEach(element => options.push({'label' : element.Name, 'value' : element.Id}));
                component.set("v.epicOptions", options);
                component.set("v.filterByEpicName", "");

                let filterCardAction = component.get('c.filterCards');
                filterCardAction.setParams({
                    component,
                    event,
                    helper
                });
                $A.enqueueAction(filterCardAction);
            } else {
                helper.handleErrors(response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    
    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error",
            type: "error"
        };

        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }

        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },

    getPicklistValues : function(component, helper, sObjectName, fieldName, componentName){
        let action = component.get("c.getPicklistValues");

        action.setParams({
            sObjectName,
            fieldName
        });

        action.setCallback(this, function(response){
            let state = response.getState();

            if (state === "SUCCESS") {
                let resp = response.getReturnValue();
                let values = [{label : "All", value : ""}];

                for (let i = 0 ; i < resp.length ; i++){
                    let picklistValue = resp[i];
                    values.push({label : picklistValue, value : picklistValue});
                }

                component.set("v." + componentName, values);

            } else {
                helper.handleErrors(response.getError());
            }
        });

        $A.enqueueAction(action);
    }
})