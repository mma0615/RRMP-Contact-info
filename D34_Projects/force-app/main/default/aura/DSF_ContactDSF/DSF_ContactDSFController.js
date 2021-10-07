({   
    
    
    sendMessage : function(component, event, helper) {
          
        component.set('v.errorMessage', '');

        var isValid = helper.validateAllFields(component, event, helper);

        // Exit function if invalid
        if(!isValid) {
            component.set('v.errorMessage', 'Please update the missing form entries and try again.');
            return;
        }
        let subjectMax = component.get("v.SubjectMaxLength");
        if(component.get("v.Subject").length > subjectMax ){
            component.set('v.errorMessage', component.get("v.SubjectErrorMsg"));
            return;
        }   
		
		var contact = component.get('v.Contact');
        var newCase = { 
            sobjectType : 'Case',
            Origin : 'Student Community', 
            Priority : 'Medium',
            ContactId : component.get("v.contactId"),
            First_Name__c : component.get("v.FirstName"), 
            Last_Name__c : component.get("v.LastName"), 
            ContactEmail : contact != null && contact.Id != null ? component.get("v.Email") : null,
            SuppliedEmail : (contact == null || contact == '' || contact == undefined) ? component.get("v.Email") : null,
            Date_Of_Birth__c : component.get("v.DateOfBirth"), 
            DPS_ID_College_ID__c : component.get("v.CollegeId"), 
            Subject : component.get("v.Subject"), 
            Description : component.get("v.Message") 
        };  
		console.log(newCase);
        
        component.set("v.newCase", newCase); 
        helper.createCase(component, event, helper);
    },

    handleUploadFinished : function (component, event, helper) {
        let uploadedFile = event.getParam("files")[0];
        let currentDocId = uploadedFile.documentId;
        let updateTitleAction = component.get("c.updateFileTitle");
        updateTitleAction.setParams({
            "contendDocumentId": currentDocId
        });
        updateTitleAction.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Uploaded",
                    "type": "success",
                    "message": "File uploaded successfully."
                }); 
                resultsToast.fire();  
                helper.clearFields(component, event, helper);
                helper.closeModal(component, event, helper);
            }
            else if (state === "ERROR") {
                console.log('Problem saving new Title, response state: ' + state);
            }
                else {
                    console.log('Unknown problem, response state: ' + state);
                }
        });
        $A.enqueueAction(updateTitleAction);
    }, 

    handleContactUpdated : function (component, event, helper) {
        var eventParams = event.getParams(); 
        if(eventParams.changeType === "LOADED") { 
            var con = component.get('v.Contact'); 

            if(con != null) {                
                component.set('v.contactId', con.Id);
                component.set('v.FirstName', con.FirstName);
                component.set('v.LastName', con.LastName);
                component.set('v.Email', con.Email);
                component.set('v.DateOfBirth', con.Birthdate != null ? con.Birthdate : null);
                component.set('v.CollegeId', con.DPSID__c);
            }
        } else if(eventParams.changeType === "CHANGED") {
            if (con != null && con.Email !=null)
            component.set('v.errorMessage', 'Please do not update the email address.');
 
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving or deleting the record
        }
    },
    close : function (component, event, helper) {
		helper.clearFields(component, event, helper);
        helper.closeModal(component, event, helper);
    },
    backToLogin : function (component, event, helper) {
        component.set("v.ShowContactUs", false);
    }
    
})