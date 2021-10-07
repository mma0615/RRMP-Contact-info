({
    checkDates: function (component, event, helper) {
        $A.localizationService.getToday($A.get('$Locale.timezone'), function (today) {
            let startDate = $A.localizationService.formatDate(component.get('v.application').Application_Submission_Date_Time__c);
            let endDate = $A.localizationService.formatDate(component.get('v.dsfConfig').End_Date__c);
            today = $A.localizationService.formatDate(today);
            component.set('v.isDateBetween', $A.localizationService.isBetween(today, startDate, endDate));
        })
    },

    navigateToCollegePortal: function (component, event, helper) {
        console.log('%c test');
       // console.log(component.get('v.application').School_Name__r.Website);
        var app = component.get('v.application');
        console.log('%c App:' + JSON.stringify(app));
        if (app!=null && app.School_Name__c != null){
            console.log('%c 123' + app.School_Name__c);
            console.log('%c ' + app.Name);
           var appwebsite = app.School_Name__r.Website__c;
           console.log(app.School_Name__c);
           console.log(appwebsite);
        }
        component.find('navService').navigate({
            type: "standard__webPage",
            attributes: {
                url: (component.get('v.application').School_Name__r.College_Portal_Link__c)
                
            }
        });
    },
});