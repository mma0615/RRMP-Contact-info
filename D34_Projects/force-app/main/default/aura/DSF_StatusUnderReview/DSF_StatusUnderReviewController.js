({
    doInit : function(component, event, helper) {
        component.set("v.currentYear", new Date($A.get("$Label.c.DSF_App_Season_End_Date")).getFullYear());
    },
    goToDash : function(component, event, helper)
    {
        let navService = component.find("navService");

        let pageReference = 
        {
            type: 'comm__namedPage',
            attributes:
            {
                pageName: 'home'
            }
        };
        navService.navigate(pageReference);
    },
	
    goToMyApp : function(component, event, helper)
    {
        let navService = component.find("navService");
        let pageName = 'new-application-view';
        let currUser = component.get('v.currUser');
              

        if(currUser.Contact.Applications_Current_Renewal_ALL__c >= 1) {
            pageName = 'renewal-application-view';
        } else if(currUser.Contact.Applications_Current_New_ALL__c >= 1) {
            pageName = 'new-application-view';
        }

        let pageReference = 
        {
            type: 'comm__namedPage',
            attributes:
            {
                pageName: pageName
            }
        };
        navService.navigate(pageReference);
    }
})