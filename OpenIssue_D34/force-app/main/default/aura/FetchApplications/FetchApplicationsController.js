({
    
   "echo" : function(component, event, helper) {
        var updateCall = component.get("c.fetchApplydApplications"); // This is your apex method

       // updateCall.setParams({ Id: cmp.get("v.recordId") }); //This is your parameter inside method
        
        //configure response handler for this action
        updateCall.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title" : "Applications fetched",
                    "message" : "Applications have been fetched."
                });
 
                //Update the UI: closePanel, show toast, refresh page
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
                $A.get("e.force:refreshView").fire();
            }else if(state === "ERROR"){
                console.log('Problem fetching applications, response state '+state);
            }else{
                console.log('Unknown problem: '+state);
            }
        });
        //send the request to updateCall
        $A.enqueueAction(updateCall);
 
   
    },
    cancelCall: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})