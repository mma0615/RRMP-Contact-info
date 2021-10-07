({
    handleShowFileUploader: function(component, event, helper) {
    $A.createComponent("c:DSF_NewFileAndCaseModal",
        {
            applicationId: component.get('v.application').Id,
            fileLabel: component.get("v.uploadProofOfLawfulPresence"),
            caseSubject: component.get('v.lawfulPresenceCaseSubject'),
            DSF_FileUploadFinished: component.getReference("c.onUploadFinished")
        },
        function(content, status) {
            if (status === "SUCCESS") {
                component.find('lawfulPresenceFileUploader').showCustomModal({
                    header: component.get("v.uploadProofOfLawfulPresence"),
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
            "fieldToUpdate" : {'Lawful_Presence_Doc_Submission_Date__c': component.get('v.today')}});
        cmpEvent.fire();
    }
})