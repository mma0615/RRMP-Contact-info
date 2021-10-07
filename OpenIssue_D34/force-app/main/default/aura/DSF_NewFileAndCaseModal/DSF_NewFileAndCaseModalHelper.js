({
    createCase: function(component, event, helper) {
        let newCase = component.get('v.caseRecord');
        console.log(JSON.stringify(newCase));
        newCase.Application__c = component.get('v.applicationId');
        newCase.Fafsa__c = component.get('v.fafsaId');
        newCase.Origin = 'Student Community';
        newCase.Subject = component.get('v.caseSubject');

        if(newCase) {
            component.find("caseRecordCreator").saveRecord(function(saveResult) {
                if(saveResult.state === 'SUCCESS' || saveResult.state === 'DRAFT') {
                    component.set('v.caseRecordId', saveResult.recordId);
                }
            })
        }
    },

    loadCaseTemplateAndCreateCase: function(component, event, helper) {
        component.find("caseRecordCreator").getNewRecord(
                    "Case",
                    null,
                    false,
                    $A.getCallback(function() {
                        var rec = component.get("v.caseRecord");
                        var error = component.get("v.errorMessage");
                        if(error || (rec === null)) {
                            return;
                        }
                        helper.createCase(component, event, helper);
                    })
                );
    },

    closeModal: function(component, event, helper) {
        component.find('fileUploader').notifyClose();
    },

    fireUploadedEvent: function(component, event, helper) {
        let evt = component.getEvent("DSF_FileUploadFinished");
        evt.fire();
    },

})