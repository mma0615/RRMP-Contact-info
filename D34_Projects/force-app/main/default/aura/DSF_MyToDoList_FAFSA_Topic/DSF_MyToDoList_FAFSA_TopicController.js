({
    navigateToFafsaGov: function (component, event, helper) {
        component.find('navService').navigate({
            type: "standard__webPage",
            attributes: {
                url: component.get('v.FAFSAgovLink')
            }
        });
    },
});