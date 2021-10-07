({
	getServices: function(component, contactId) {
        var action = component.get("c.getAllServicesRecord");
        action.setParams({
            "conId" : contactId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    row.counter = i+1;
                }
                console.log('result'+result);
                component.set("v.services", result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
    
    getContactRecord: function(component, contactId) {
        var action = component.get("c.getContactRecord");
        action.setParams({
            "conId" : contactId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('result'+result);
                component.set("v.contact", result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
})