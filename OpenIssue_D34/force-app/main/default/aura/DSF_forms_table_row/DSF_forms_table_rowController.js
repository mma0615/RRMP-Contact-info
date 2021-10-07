({
    goToLearnMoreLink: function(cmp, event, helper) {
        var navService = cmp.find("navService");
        var lm_link = cmp.get("v.lm_link");
        event.preventDefault();
        navService.navigate({
            type: "standard__webPage",
            attributes: {
                url: lm_link
            }
        });
    },

    goToCommunityLink: function(cmp, event, helper) {
            var navService = cmp.find("navService");
            var link = cmp.get("v.link");
            event.preventDefault();
            navService.navigate({
                type: "comm__namedPage",
                    attributes: {
                        pageName: link
                    }
            });
        }
})