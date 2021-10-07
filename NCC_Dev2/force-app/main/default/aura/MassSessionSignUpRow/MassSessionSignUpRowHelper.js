({
    doInitHelper : function(component, event, helper) {
        //Making a call to the Apex method to fetch the values of Rating field
        var action = component.get("c.fetchRankValues");
        
        //Getting the value of Rating field for a particular record from Component
        var rankValue = component.get('v.sessionPart.Rank');
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rankValues = response.getReturnValue();
                
                var rankId;
                var rankOptions = [];
                
                for(var i=0; i< rankValues.length; i++){
                    if(i == 0){
                        /** We need to make sure the first value of the Picklist is always None */
                        if(rankValue != undefined){
                            rankOptions.push({
                                id: 0, 
                                label: '--None--'
                            });
                        }else{
                            rankOptions.push({
                                id: 0, 
                                label: '--None--',
                                selected: true
                            });
                            rankId = 0;
                        }
                    }
                    
                    /** Am trying to compare the Rating field value with the list
                    that we get back from the Apex method and when there is a match
                    am adding selected: true to the JSON Object. */
                    
                    if(rankValues[i] == rankValue){
                        rankOptions.push({
                            id: i+1, 
                            label: rankValues[i],
                            selected: true 
                        });
                        rankId = i+1;
                    }else{
                        rankOptions.push({
                            id: i+1, 
                            label: rankValues[i]
                        });
                    }
                }
                var serverResponse = {
                    selectedRankId: rankId,
                    rank: rankOptions
                };
                
                component.set("v.optionsRank", serverResponse.rank);
                component.set("v.selectedValueRank", serverResponse.selectedRankId);
            }            
            else if(state === "INCOMPLETE"){
                
            }
                else if(state === "ERROR"){
                    var errors = response.getError();
                    if(errors){
                        if(errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    }else{
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    handleFireEvent : function(component, event, helper) {
        var sessionPart = component.get("v.sessionPart");
        console.log('ChildValue: ' + JSON.stringify(sessionPart));
        var compEvent = component.getEvent("massSessionEventReg");
        compEvent.setParams({"childSessionPart" : sessionPart });
        compEvent.fire();
    }
})