({
    checkDates: function (component, event, helper) {
        $A.localizationService.getToday($A.get('$Locale.timezone'), function (today) {
            let startDate = $A.localizationService.formatDate(component.get('v.dsfConfig').Start_Date__c);
            let endDate = $A.localizationService.formatDate(component.get('v.dsfConfig').End_Date__c);
            today = $A.localizationService.formatDate(today);
            component.set('v.isDateBetween', $A.localizationService.isBetween(today, startDate, endDate));
        })
    },
})