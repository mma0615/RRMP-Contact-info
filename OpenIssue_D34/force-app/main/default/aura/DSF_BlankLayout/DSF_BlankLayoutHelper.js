({
    redirectToHomepage: function(component, event, helper) {
		let navService = component.find("navService");
        let pageReference = {
            type: 'comm__namedPage',
            attributes: {
                    pageName: 'home',
                }
        };
        navService.navigate(pageReference);
    }
})