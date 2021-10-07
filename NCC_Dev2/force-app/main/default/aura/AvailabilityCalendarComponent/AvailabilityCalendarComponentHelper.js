({
    handleSubmit: function(component, event, helper) {
        
        var action = component.get("c.createEncounter");
        action.setParams({
            conId : component.get("v.contactId"), 
            doctorId : component.get("v.resourceId"),
            contactAvailabilityId: component.get("v.contactAvailability"),
            selectedTimeZone: component.get("v.selectedTimeZone")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                
                console.log('result'+result);
                component.set("v.scheduled", true);
                //$A.get('e.force:refreshView').fire();
                
                //component.set("v.surveyQuestions", result);
            }
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
        
        //console.log('result: '+JSON.stringify(this.result));
    },
    
    setSFTimezone : function(component, event, helper) {
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var sfTimeZone = component.get("c.getSFTimezone");
                sfTimeZone.setCallback(this,function(response){
                    var state = response.getState();
                    if(state == 'SUCCESS'){
                        var result = response.getReturnValue();
                        let SFTimeZoneMap = new Map();
                        for(var key in result){
                            SFTimeZoneMap.set(key, result[key]);
                        }
                        component.set("v.SFTimeZoneMap", SFTimeZoneMap);
                        console.log('hey'+component.get("v.resourceId"));
                        var setDefaultTZ = component.get("c.getDoctorRecord"); 
                        setDefaultTZ.setParams({
                            "doctorId": component.get("v.resourceId")
                        });
                        setDefaultTZ.setCallback(this,function(response){
                            var state = response.getState();
                            if(state == 'SUCCESS'){
                                console.log(component.get("v.SFTimeZoneMap"));
                                var result = response.getReturnValue();
                                console.log('result'+JSON.stringify(result));
                                if (result.Organization_Time_Zone__c != null) {
                                    component.find("selectedTimeZone").set("v.value", result.Organization_Time_Zone__c);
                                }
                                component.set("v.doctor", result);
                                resolve(state);
                                var selectDate = component.get('c.selectDate');
                                $A.enqueueAction(selectDate);
                                
                            }
                            else{
                                console.log('ERROR:');
                                console.log(response.getError());
                            }
                        });
                        $A.enqueueAction(setDefaultTZ); 
                    }
                    else{
                        console.log('ERROR:');
                        console.log(response.getError());
                    }
                });
                $A.enqueueAction(sfTimeZone);
            })
        );
        
    },
    
    setPicklistField : function(component, event, helper) { 
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var action = component.get("c.getTimeZoneValuesFromField");
                action.setCallback(this,function(response){
                    var state = response.getState();
                    if(state == 'SUCCESS'){
                        resolve(state);
                        var result = response.getReturnValue();
                        var SFTimeZoneList = [];
                        let SFTimeZoneMap = new Map();
                        for(var key in result){
                            SFTimeZoneList.push({key:key,value:result[key]});
                            SFTimeZoneMap.set(key, result[key]);
                        }
                        component.set("v.SFTimeZone", SFTimeZoneList);
                    }
                    else{
                        console.log('ERROR:');
                        console.log(response.getError());
                    }
                });
                $A.enqueueAction(action); 
            })
        );
        
    }
})