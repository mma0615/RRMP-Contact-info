({
    saveFafsa: function(component, helper) {
       let fafsaRecord = {
            sobjectType: 'FAFSA_Detail__c',
            Academic_Year__c: component.get('v.currentApplicationSeasonYear'),
            Student__c: component.get('v.application').Student_Name__c
       } 
       if (fafsaRecord) {
        let action = component.get("c.saveFafsa");
        action.setParams({ fafsa : fafsaRecord });
        action.setCallback(this, function(response) {
            let state = response.getState(); 
            if (state === "SUCCESS") {
                let res = response.getReturnValue();
                if (res != '' && res != null) {
                    fafsaRecord.Id = res;
                    component.set("v.fafsa", fafsaRecord);
                    helper.handleShowFileUploader(component, event, helper);
                }
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
       }
    },

    handleShowFileUploader: function(component, event, helper) { 
        $A.createComponent("c:DSF_NewFileAndCaseModal",
         {
            fafsaId: component.get('v.fafsa').Id,
            fileLabel: component.get("v.uploadProofOfFAFSA"),
            caseSubject: component.get('v.fafsaProofCaseSubject'),
            DSF_FileUploadFinished: component.getReference("c.onUploadFinished")
         },
         function(content, status) {
             if (status === "SUCCESS") {
                 component.find('FAFSAProofUploader').showCustomModal({
                     header: component.get("v.uploadProofOfFAFSA"),
                     body: content,
                 })
             }
        });
    },
    
    handleUploadFinished: function(component, event, helper) {
        helper.showToast(component, event, helper);
        let fafsaRecord = component.get("v.fafsa"); 
        fafsaRecord.FAFSA_Proof_Submission_Date__c = component.get('v.today');
        if(fafsaRecord) {
            let action = component.get("c.updateFafsa");
            action.setParams({ fafsa : fafsaRecord });
            action.setCallback(this, function(response) {
                let state = response.getState();
                debugger;
                if (state === "SUCCESS") {
                    let res = response.getReturnValue();
                    if (res) {
                        component.getEvent('DSF_MyToDoList_RefreshFafsaEVT').fire();
                    }
                }
                else if (state === "ERROR") {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
})