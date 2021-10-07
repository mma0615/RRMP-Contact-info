({
    addComment: function(component, event, helper) {
        
        // Prepare the action to create new case comment
        let addCommentAction = component.get("c.addCaseComment");
        addCommentAction.setParams({
            "commentBody": component.get("v.addedComment"),
            "caseId": component.get("v.recordId")
        });
		component.set("v.isLoaded", false);
        
        // Configure the response handler for the action
        addCommentAction.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "SUCCESS",
					"type": "success",
                    "message": "Comment added successfully."
                }); 
                resultsToast.fire();  
                component.set("v.addedComment", "");
                //reload comments
                let id = component.get("v.recordId");
                component.set("v.recordId","");
                component.set("v.recordId",id);
				component.set("v.isLoaded", true);
                
            }
            else if (state === "ERROR") {
                console.log('Problem saving Case Comment, response state: ' + state);
            }
                else {
                    console.log('Unknown problem, response state: ' + state);
                }
        });
        
        // Send the request to create the new comment
        $A.enqueueAction(addCommentAction);        
    },
})