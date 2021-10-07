({
    helperMethod1 : function(Data) {
        console.log('data ' ,Data);
    },
    searchRecords : function(component, searchString) {
        var action = component.get("c.getRecords");
        action.setParams({
            "searchString" : searchString
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                console.log('serverResult',serverResult);
                const results = [];
                serverResult.forEach(element => 
                                     {    
                                         results.push(element);
                                     });
                                         console.log('results',results);
                                         component.set("v.results", results);
                                         if(serverResult.length>0){
                                         component.set("v.openDropDown", true);
                                          }
                                         if(serverResult.length <= 0)
                                         {
                                         component.set("v.openDropDown", false);
                                         component.set("v.NotFound","");
                                         } 
                                         else 
                                         {
                                         component.set("v.NotFound","fond");
                                         }
                                     } else{
                                         var toastEvent = $A.get("e.force:showToast");
                                         if(toastEvent){
                                         toastEvent.setParams({
                                         "title": "ERROR",
                                         "type": "error",
                                         "message": "Something went wrong!! Check server logs!!"
                                     });
                toastEvent.fire();
            }
        }
                           });
        $A.enqueueAction(action);
    },
    
    AllSearchRecords : function(component, event, helper){
        console.log('This is helper method');
        var action = component.get("c.AllLabels");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                var size = serverResult.length;
                
                console.log('serverResult',serverResult);
                const results = [];
                serverResult.forEach(element => 
                                     {    
                                         results.push(element);
                                     });
                                         console.log('results',results);
                                         component.set("v.results", results);
                                         if(serverResult.length>0){
                                         component.set("v.openDropDown", true);
                                     }
                                     } else{
                                         var toastEvent = $A.get("e.force:showToast");
                                         if(toastEvent){
                                         toastEvent.setParams({
                                         "title": "ERROR",
                                         "type": "error",
                                         "message": "Something went wrong!! Check server logs!!"
                                     });
                toastEvent.fire();
            }
        }
        });
        $A.enqueueAction(action);
    }
    
})