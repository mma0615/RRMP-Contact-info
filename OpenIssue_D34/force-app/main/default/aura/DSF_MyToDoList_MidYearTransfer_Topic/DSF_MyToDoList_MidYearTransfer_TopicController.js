({
    showFileUploader: function(component, event, helper) {
        helper.handleShowFileUploader(component, event, helper);
    },

    onUploadFinished: function(component, event, helper) {
        helper.handleUploadFinished(component, event, helper);
    },

    onStudentTermLoad: function (component, event, helper) {
        const studentTerm = component.get('v.studentTerm');
        component.set('v.studentTermLoaded', true);

        component.set('v.finalAwardStatusIncludesTimedOut', studentTerm.Final_Award_Status__c ? studentTerm.Final_Award_Status__c.includes('Timed Out') : false);
        component.set('v.currentYearFall', studentTerm.Term_Year__c == 'Fall ' + new Date().getFullYear());

        if(component.get('v.dsfConfigLoaded')) {
            helper.checkStudentTermDates(component, event, helper);
        }
    },

    onApplicationLoad: function (component, event, helper) {
        const application = component.get('v.application');
        component.set('v.applicationLoaded', true);

        component.set('v.midYearTransferStatusContainsNotApproved', application.Mid_Year_Transfer_Status__c ? application.Mid_Year_Transfer_Status__c.includes('Not Approved') : false);

        if(component.get('v.dsfConfigLoaded')) {
            helper.checkApplicationDates(component, event, helper);
        }
    },

    onDsfConfigLoad: function (component, event, helper) {
        component.set('v.dsfConfigLoaded', true);

        if(component.get('v.studentTermLoaded')) {
            helper.checkStudentTermDates(component, event, helper);
        }
        helper.checkApplicationDates(component, event, helper);
    },

    navigateToMidYearTransferURL: function (component, event, helper) {
        component.find('navService').navigate({
            type: "comm__namedPage",
            attributes: {
                pageName: component.get('v.midYearTransferURL')
            }
        });
    },
})