({
    handleShowFileUploader: function(component, event, helper) {
        $A.createComponent("c:DSF_NewFileAndCaseModal",
            {
                applicationId: component.get('v.application').Id,
                fileLabel: component.get("v.submitTranscriptForMidYearTransfer"),
                caseSubject: component.get('v.midYearTransferCaseSubject'),
                DSF_FileUploadFinished: component.getReference("c.onUploadFinished")
            },
            function(content, status) {
                if (status === "SUCCESS") {
                component.find('midYearFileUploader').showCustomModal({
                    header: component.get("v.submitTranscriptForMidYearTransfer"),
                    body: content,
                })
            }
        });
    },
    handleUploadFinished: function(component, event, helper) {
        helper.showToast(component, event, helper);
        helper.fireUpdateAppEvent(component, event, helper);
    },

    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },

    checkStudentTermDates: function (component, event, helper) {
        const studentTerm = component.get('v.studentTerm');
        $A.localizationService.getToday($A.get("$Locale.timezone"), function (today) {
            let startDate = $A.localizationService.formatDate(studentTerm.Term_Start_Date__c);
            let endDate = $A.localizationService.formatDate(component.get('v.termDate').End_Date__c);
            component.set('v.today', today);
            today = $A.localizationService.formatDate(today);
            component.set('v.todayBetweenTermStartDateAndEndDate', $A.localizationService.isBetween(today, startDate, endDate));
        });
    },

    checkApplicationDates: function (component, event, helper) {
        const application = component.get('v.application');
        let startDate = $A.localizationService.formatDate(application.Mid_Year_Transfer_Form_Submission_Date__c);
        let endDate = $A.localizationService.formatDate(component.get('v.formSubmissionDate').End_Date__c);
        component.set('v.midYearTransferSubDateBeforeEndDate', $A.localizationService.isBefore(startDate, endDate));
        component.set('v.midYearTransferStatusContainsNotApproved', application.Mid_Year_Transfer_Status__c ? application.Mid_Year_Transfer_Status__c.includes('Not Approved') : false);

    },

    fireUpdateAppEvent : function(component) {
        var cmpEvent = component.getEvent("updateAppEvent");
        cmpEvent.setParams({
            "fieldToUpdate" : {
                                'Mid_Year_Transfer_Status__c': 'Pending',
                                'Mid_Year_Transfer_Proof_Submission_Date__c': component.get('v.today')
                                }
                        });
        cmpEvent.fire();
    }
})