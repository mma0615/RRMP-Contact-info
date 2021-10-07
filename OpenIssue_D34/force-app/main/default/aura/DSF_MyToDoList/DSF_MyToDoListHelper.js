({
	loadFafsaFromSF : function(component, event, helper) {
        
        let action = component.get("c.getFafsaDetail");
    
        action.setCallback(this,function(response){
            let state = response.getState();  
          //  debugger;
            if (state === "SUCCESS"){
                component.set('v.fafsa', response.getReturnValue());            
                    
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            }            
        });
        
        $A.enqueueAction(action);  		
	}
})