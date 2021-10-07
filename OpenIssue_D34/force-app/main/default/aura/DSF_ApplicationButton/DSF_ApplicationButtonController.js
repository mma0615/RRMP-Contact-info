({
    startApplication : function(component, event, helper)
    {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams
        ({
            componentDef: "skbteqforce:DSF_ApplicationProgressStatus",
        });

        evt.fire();

        let navService = component.find("navService");
        let buttonURL = component.get('v.buttonURL');

        let pageReference = {
            type: 'comm__namedPage',
            attributes:
                {
                    pageName: buttonURL,
                }
        };
        navService.navigate(pageReference);
    },
})