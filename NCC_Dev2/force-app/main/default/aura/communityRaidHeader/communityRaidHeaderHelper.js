({
	doInitialize : function(component, event, helper) {
        
        let url_string = document.location.href;
        const urlParams = new URLSearchParams(url_string);
        let projectId = (url_string.split('id=')[1]).slice(0,11);
        component.set("v.projectId",projectId);
        const contactId = urlParams.get('contactId');
        const token = urlParams.get('token');
        component.set('v.token',token);
        component.set('v.contactId',contactId);
        //Get Logo
        let actionLogo = component.get("c.getProjectRaidLogo");
         actionLogo.setParams({ 
                projectId : projectId
            });
        actionLogo.setCallback(this, function(response){
                let state = response.getState();
                if (state === "SUCCESS") {
                     let resultMap = JSON.parse(response.getReturnValue());
                    component.set('v.campaignLogoURL', resultMap.projectLogo.Campaign_Logo_URL__c);
                    component.set('v.campaignLogoURL2', resultMap.projectLogo.Campaign_Logo_2_URL__c);
                }
                else if (state === "ERROR") {
                
                }
            });
            $A.enqueueAction(actionLogo);        
        
        
        if(contactId == null && token == null){
            
        }
        else{
            let action = component.get("c.doVerify");
            
            action.setParams({ 
                contactId : contactId,
                //email : 'lynne.daise@nationalcoordinationcenter.com',
                token : token
            });
            action.setCallback(this, function(response){
                let state = response.getState();
                if (state === "SUCCESS") {
                    
                }
                else if (state === "ERROR") {
                     let projectId = component.get("v.projectId");
                     let loginURL = $A.get("$Label.c.Project_Raid_Login_URL");
                    let redirectUrl = loginURL+'?id='+projectId;
                     
                    let errors = response.getError();
                    let message = 'Invalid Token: Redirecting to login page'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        //message = errors[0].message;
                    }
                    this.showToast('Oops!', message, "error", "pester");
                    setTimeout(function(){
                    location.replace(redirectUrl);
                    },2000);
                   
                }
            });
            $A.enqueueAction(action);
        }
        /*
          var isPhone = $A.get("$Browser.isPhone");
		component.set('v.isPhone', isPhone);
        
        var url_string = document.location.href;
        var eventId = (url_string.split('id=')[1]).slice(0,11);
        component.set('v.eventId',eventId);
        var action = component.get("c.getEventDetails");
        
        action.setParams({ 
            projectId : eventId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();
                //component.set('v.campaignLogoURL', resultEvent.CampaignLogoUrl);
                component.set('v.title', resultEvent.title);
                component.set('v.subtitle', resultEvent.subtitle);
            }
        });
        
        $A.enqueueAction(action);
        */
    },
	showToast : function(title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type,
            "mode" : mode
        });
        toastEvent.fire();
    },
})