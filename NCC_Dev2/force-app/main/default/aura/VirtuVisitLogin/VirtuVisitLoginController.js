({
	doInit : function(component, event, helper) {
        document.body.style.background = '#e2e7ea';
	},
    login : function(component, event, helper) {
        var username = component.get("v.username");
        var password = component.get("v.password");
    	console.log(password+username);
        
        var action = component.get("c.loginContact");
        action.setParams({
            username : username,
            password : password
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('result:'+result);
                if(result.includes('success')){
                    var contactId = result.split("-")[1];
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": (document.location.href).replace('patient-login', 'patient-home?id=') + contactId
                    });
                    urlEvent.fire();
                }
                else{
                    component.set("v.errorMessage", result);
                }
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
    }
})