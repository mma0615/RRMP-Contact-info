({
    handleShowFileUploader: function(component, event, helper) {
        $A.createComponent("c:DSF_NewFileAndCaseModal",
            {
                applicationId: component.get('v.application').Id,
                fileLabel: component.get("v.submitCollegeTranscriptGPAException"),
                caseSubject: component.get('v.gpaExceptionCaseSubject'),
                DSF_FileUploadFinished: component.getReference("c.onUploadFinished")
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    component.find('gpaExceptionFileUploader').showCustomModal({
                    header: component.get("v.submitCollegeTranscriptGPAException"),
                    body: content,
                })
            }
        });
    },
    handleUploadFinished: function(component, event, helper) {
        helper.showToast(component, event, helper);
        helper.fireUpdateAppEvent(component);
    },

    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },

    fireUpdateAppEvent : function(component) {
        var cmpEvent = component.getEvent("updateAppEvent");
        cmpEvent.setParams({
            "fieldToUpdate" : {
                'High_School_GPA_Waiver_Form__c': 'Yes - Pending',
                'HS_GPA_Waiver_Transcript_Submission_Date__c': component.get('v.today')
            }
        });
        cmpEvent.fire();
    }
})