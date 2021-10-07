({  
    getContactRecord: function(component, contactId) {
        var action = component.get("c.getContactRecord");
        action.setParams({
            "conId" : contactId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Logged In Contact: '+result);
                component.set("v.contact", result);
                component.set("v.loggedIn", true);
            }
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
    
     setPicklistValues: function(component, event, helper) {
        
        //questionType picklist values
        var questionType = component.get("c.getFieldValues");
        questionType.setParams({
            "fieldName": "Question Type"
        });        
        questionType.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var questionTypeVal = response.getReturnValue();
                component.set("v.questionTypeValues", questionTypeVal);
            }
   		});
        $A.enqueueAction(questionType);
     },
})