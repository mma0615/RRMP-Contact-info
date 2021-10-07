({
	init : function(component, event, helper) {
		 var url = $A.get('$Resource.LoginBackground');
        component.set('v.backgroundImageURL', url);
        let url_string = document.location.href;
        let projectId = (url_string.split('id=')[1]).slice(0,11);
        const urlParams = new URLSearchParams(url_string);
        const contactId = urlParams.get('contactId');
        const token = urlParams.get('token');
        component.set("v.projectId",projectId)
        if(contactId ==  null && token ==  null){
            
        }
        else{ 
            //let action = component.get("c.getNavigationDetailsWithVerif");
            let homeURL = $A.get("$Label.c.Project_Raid_Home_URL");
            let projectId = component.get("v.projectId");
            let contactId;
            let token;
            let redirectUrl = homeURL+'?id='+projectId+'&contactId='+contactId+'&token='+token;
            location.replace(redirectUrl);
        }
	},

	sendToken : function(component, event, helper) {
		helper.doSendToken(component, event, helper);	
   },
    submit : function(component, event, helper) {
		helper.doSubmit(component, event, helper);	
   }
    
})