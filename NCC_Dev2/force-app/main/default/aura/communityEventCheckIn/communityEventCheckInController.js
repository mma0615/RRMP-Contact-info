({
    doInit : function(component, event, helper) {
        
        var ParticipantNumber = 'EM-000070';
        var action = component.get("c.getParticipantSession");
        
        console.log('ParticipantNumber  ' + ParticipantNumber);
        
        action.setParams({ 
            ParticipantNumber : ParticipantNumber
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state  ' + state);
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();
                component.set('v.sessionList', resultEvent);
                console.log('resultEvent  ' + resultEvent);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    handleAction : function(component, event, helper) {
        console.log("im click");
        
        var btnValue = event.getSource().get("v.value");
        console.log("value =  " + btnValue);
    }
    
})