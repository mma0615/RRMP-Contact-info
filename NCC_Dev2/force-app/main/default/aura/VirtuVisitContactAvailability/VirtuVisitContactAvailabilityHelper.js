({
    
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
                        resolve(state);
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
                        var result = response.getReturnValue();
                        var SFTimeZoneList = [];
                        
                        let SFTimeZoneMap = new Map();
                        for(var key in result){
                            SFTimeZoneList.push({key:key,value:result[key]});
                            SFTimeZoneMap.set(key, result[key]);
                        }
                        component.set("v.SFTimeZone", SFTimeZoneList);
                        resolve(state);
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