({
    handleShowFileUploader: function(component, event, helper) {
        $A.createComponent("c:DSF_NewFileAndCaseModal",
            {
                applicationId: component.get('v.application').Id,
                fileLabel: component.get("v.submitTranscriptForProgramExtensionTooltip"),
                DSF_FileUploadFinished: component.getReference("c.onUploadFinished"),
                caseSubject: component.get('v.programExtensionCaseSubject'),
                allowMultiple : true
            },
            function(content, status) {
                if (status === "SUCCESS") {
                component.find('programExtensionFileUploader').showCustomModal({
                    header: component.get("v.submitTranscriptForProgramExtensionTooltip"),
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

    fireUpdateAppEvent : function(component) {
        var cmpEvent = component.getEvent("updateAppEvent");
        cmpEvent.setParams({
            "fieldToUpdate" : {
                                'One_Year_Extension_Form_Submitted__c': 'Yes - Pending',
                                'Program_Extension_Proof_Submitted_Date__c': component.get('v.today')
                                }
                        });
        cmpEvent.fire();
    }
})