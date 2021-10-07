({  
    getContactRecord: function(component, contactId) {
        var action = component.get("c.getContactRecord");
        action.setParams({
            "conId" : contactId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Logged In Contact: '+result);
                component.set("v.contact", result);
                component.set("v.loggedIn", true);
            }
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
    
     handleNavigationMenu: function(component, contactId) {
        var action = component.get("c.getNavigationMenu");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.navigationmenu", result);
            }
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
})