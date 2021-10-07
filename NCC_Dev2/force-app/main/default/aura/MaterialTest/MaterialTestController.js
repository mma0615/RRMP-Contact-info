({
	doInit : function(component, event, helper) {
		
        var action = component.get("c.getMaterials");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();
                component.set('v.State', resultEvent);
                console.log("--- " +resultEvent);
            }
            
             console.log("--- state" +state);
        });

        $A.enqueueAction(action);
	}
})