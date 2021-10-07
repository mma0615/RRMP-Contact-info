({
    checkDates: function (component, event, helper) {
        const dsfConfig = component.get('v.dsfConfig');
        $A.localizationService.getToday($A.get("$Locale.timezone"), function (today) {
            let startDate = $A.localizationService.formatDate(dsfConfig.Start_Date__c);
            let endDate = $A.localizationService.formatDate(dsfConfig.End_Date__c);
            component.set('v.today', today);
            today = $A.localizationService.formatDate(today);
            component.set('v.isBetweenDates', $A.localizationService.isBetween(today, startDate, endDate));
        });
    },

    onContactLoad: function (component, event, helper) {
        const contact = component.get('v.contact');
        component.set('v.cohortYearLessThanFourYearsInPast', contact.Cohort__r.Name <= new Date().getFullYear() - 4);
    },

    navigateToProgramExtensionLink: function (component, event, helper) {
        component.find('navService').navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: component.get('v.programExtensionFormURL')
            }
        });
    },

    showFileUploader: function(component, event, helper) {
        helper.handleShowFileUploader(component, event, helper);
    },

    onUploadFinished: function(component, event, helper) {
        helper.handleUploadFinished(component, event, helper);
    },
});