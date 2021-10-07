({
    
    setPicklistValues: function(component, event, helper) {
        
        var timezone = component.get("c.getFieldValues");
        timezone.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var timezoneVal = response.getReturnValue();
                component.set("v.timezoneValues", timezoneVal);
            }
        });
        $A.enqueueAction(timezone);
    },
    saveAvailabilityRecord: function(component, contactId, timeStart, timeEnd, timeZone) {
        console.log(contactId+timeStart+timeEnd+timeZone);
        
        var TimeZoneSidKey = 'America/New_York';
        const changeTimezone = (dateToChange, timeZone) => {
            //console.log(dateToChange);
            var here = dateToChange;
            var invdate = new Date(here.toLocaleString('en-US', {
            timeZone: timeZone
        }));
        var diff = here.getTime() - invdate.getTime();
        return new Date(here.getTime() - diff);
    };
    var startDateTime = changeTimezone(new Date(timeStart), TimeZoneSidKey);
    var endDateTime = changeTimezone(new Date(timeEnd), TimeZoneSidKey);
    //    var startDateTime = timeStart;
      //  var endDateTime = timeEnd;
                    
        console.log('startDateTime'+startDateTime);
        console.log('endDateTime'+endDateTime);
        
        
        var action = component.get("c.saveAvailabilityRecord");
        action.setParams({
            "conId" : contactId,
            "timeStart" : startDateTime,
            "timeEnd" : endDateTime,
    "timezone" : timeZone
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                
                console.log('result'+result);
                component.set("v.addAvailability", false);
                /*component.set("v.selectedDateAfterSave", component.get("v.selectedDate"));
                var selectDate = component.get('c.selectDate'); 
                $A.enqueueAction(selectDate);
                */
                
                //component.set("v.services", result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
	},
})