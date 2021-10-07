({
    showFileUploader: function(component, event, helper) {
        helper.handleShowFileUploader(component, event, helper);
    },

    onUploadFinished: function(component, event, helper) {
        helper.handleUploadFinished(component, event, helper);
    },

    checkDates: function (component, event, helper) {
        $A.localizationService.getToday($A.get("$Locale.timezone"), function (today) {
            let startDate = $A.localizationService.formatDate(component.get('v.dsfConfig').Start_Date__c);
            let endDate = $A.localizationService.formatDate(component.get('v.dsfConfig').End_Date__c);
            component.set('v.today', today);
            today = $A.localizationService.formatDate(today);
            component.set('v.isBetweenDates', $A.localizationService.isBetween(today, startDate, endDate));
        });
    },

    navigateToGPAExceptionURL: function (component, event, helper) {
        component.find('navService').navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: component.get('v.GPAExceptionURL')
            }
        });
    },
})