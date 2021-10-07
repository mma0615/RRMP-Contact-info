({
    checkDates: function (component, event, helper) {
        $A.localizationService.getToday($A.get("$Locale.timezone"), function (today) {
            let startDate = $A.localizationService.formatDate(component.get('v.dsfConfig').Start_Date__c);
            let endDate = $A.localizationService.formatDate(component.get('v.dsfConfig').End_Date__c);
            component.set('v.today', today);
            today = $A.localizationService.formatDate(today);
            component.set('v.isDateBetween', $A.localizationService.isBetween(today, startDate, endDate));
            component.set('v.isBeforeStartDate', $A.localizationService.isBefore(today, startDate));
            component.set('v.isBeforeEndDate', $A.localizationService.isBefore(today, endDate));
        });
    },
    
    showFileUploader: function(component, event, helper) {
        let fafsaRecord = component.get("v.fafsa");
        if(fafsaRecord == undefined || fafsaRecord == null){
            helper.saveFafsa(component, helper);
        }else{
            helper.handleShowFileUploader(component);
        }
    },

    onUploadFinished: function(component, event, helper) {
        helper.handleUploadFinished(component, event, helper);
    },
})