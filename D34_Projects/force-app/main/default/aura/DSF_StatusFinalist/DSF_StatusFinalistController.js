({
    goToMyAccount: function (component, event, helper) {
        let navService = component.find("navService");
        let pageReference = {
                type: 'comm__namedPage',
                attributes: {
                        pageName: 'my-account'
                    }
            };
        navService.navigate(pageReference);
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

        if(currUser.Contact.Applications_Current_Finalist_Renewal__c >= 1) {
            pageName = 'renewal-application-view';
        } else if(currUser.Contact.Applications_Current_Finalist_New__c >= 1) {
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