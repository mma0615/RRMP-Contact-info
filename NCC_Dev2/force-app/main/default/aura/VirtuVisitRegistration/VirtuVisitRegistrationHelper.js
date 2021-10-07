({
	createContactRecord : function(component, firstName, lastName, email, password) {
        var action = component.get("c.createContactRecord");
        action.setParams({
            firstName : firstName,
            lastName : lastName,
            email : email,
            password : password
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.ErrorMessage", result);
                 window.setTimeout(
                     $A.getCallback(function() {
                         component.set("v.ErrorMessage", "");
                     }), 3000
                 );
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);		
	}
})