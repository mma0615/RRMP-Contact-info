({
    onStudentTermLoad: function (component, event, helper) {
        const studentTerm = component.get('v.studentTerm');
        component.set('v.studentTermContainsFullTime', studentTerm.Enrollment_Type__c ? studentTerm.Enrollment_Type__c.includes('Full Time') : false);

        $A.localizationService.getToday($A.get("$Locale.timezone"), function (today) {
            let endDate = $A.localizationService.formatDate(component.get('v.studentTerm').Term_End_Date__c);
            today = $A.localizationService.formatDate(today);
            component.set('v.isCorrectDateToDisplay', $A.localizationService.isBefore(today, endDate));
        });
    },
})