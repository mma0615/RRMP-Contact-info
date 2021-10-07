({ 
    goToContactDsf : function(component, event, helper) {
        let navService = component.find("navService");
        let pageReference = {
            type: 'comm__namedPage',
            attributes:
            {
                pageName: 'contact-dsf'
            }
        };
        navService.navigate(pageReference);
    },
})