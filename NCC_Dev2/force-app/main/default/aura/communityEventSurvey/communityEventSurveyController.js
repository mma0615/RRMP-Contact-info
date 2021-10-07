({
    doInit : function(component, event, helper) {
        document.title = 'Loading....';
        var url_string = document.location.href;
        var eventId = (url_string.split('id=')[1]).slice(0,11);
        component.set('v.eventId',eventId);
        var action = component.get("c.getEventDetails");
        console.log(eventId);
        action.setParams({ 
            eventId : eventId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();
                console.log(resultEvent);
                if(resultEvent.surveyPageTitle != null || resultEvent.surveyPageTitle !=  undefined){
                    component.set('v.surveyPageTitle', resultEvent.surveyPageTitle);
                    document.title = resultEvent.surveyPageTitle;
                }else{
                    component.set('v.surveyPageTitle', 'SURVEY');
                }
            }
        });
        
        $A.enqueueAction(action);
        
    }

})