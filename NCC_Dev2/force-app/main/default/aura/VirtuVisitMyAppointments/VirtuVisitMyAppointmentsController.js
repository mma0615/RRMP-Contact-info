({
    doInit: function(component, event, helper) {
        var url_string = location.href;
		if(url_string.includes("id")){
            var contactId = (url_string.split('id=')[1]).slice(0,18);
            var action = component.get("c.getMyAppointments");
            action.setParams({
                "contactId" : contactId
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    var result = response.getReturnValue();
                    var TimeZoneSidKey = 'America/New_York'; //Org Timezone
                    component.set("v.timeZoneSidKey", TimeZoneSidKey);
					
                    for ( i=0; i < result.length; i++){
                        var row = result[i];
                        var timeZone = row.Time_Zone__c;
                        row.Time_Zone__c = (timeZone == 'PT' ? 'Pacific/Pitcairn' : (timeZone == 'PDT' ? 'America/Los_Angeles' : timeZone));
                    }
                    component.set("v.connects", result);
                }
                else{
                    console.log('ERROR:');
                    console.log(response.getError());
                }
            });
            $A.enqueueAction(action);	
        }
    }
})