({
    //Fetch the releted account on mouseHover 
    getDoctorLayout:function(component, event, helper){
        
        var getAccount = component.get('v.practiceDoctors');
        if(getAccount.length == 0){
            getAccount = component.get('v.doctors');
        }
        for(var i=0;i<getAccount.length;i++){
            if(getAccount[i].Id == component.get("v.reId")){
                component.set('v.mouseHoverData', getAccount[i]);
                break;
            }
            else if(getAccount[i].Contact__c == component.get("v.reId")){
                component.set('v.mouseHoverDataPracticeDoctor', getAccount[i]);
                break;
            }
        }

        component.set("v.hoverRow", parseInt(event.target.dataset.index));
        component.set("v.togglehover",true);
    },
    getMiniLayout:function(component, event, helper){
        
        var getAccount = component.get('v.doctors');
        for(var i=0;i<getAccount.length;i++){
            if(getAccount[i].Id == component.get("v.reId")){
                component.set('v.mouseHoverData', getAccount[i]);
                break;
            }
        }
        console.log('im here');
        component.set("v.hoverRow", parseInt(event.target.dataset.index));
        component.set("v.togglehover",true);
    },
    
	getContactRecord: function(component, contactId) {
        var action = component.get("c.getContactRecord");
        action.setParams({
            "conId" : contactId
        });
        console.log('hey'+contactId);
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
    
	getAllServices: function(component, contactId) {
        var action = component.get("c.getAllServicesRecord");
        action.setParams({
            "conId" : contactId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    row.counter = i+1;
                }
                console.log('services: '+result);
                component.set("v.services", result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
    
    getServiceRecord: function(component, serviceId) {
        var action = component.get("c.getServiceRecord");
        action.setParams({
            "serviceId" : serviceId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.service", result);
                if(result.Reason__c != null){
                    if((result.Reason__c).includes(';')){
                        var serviceReasons = result.Reason__c.split(';');
                        component.set("v.serviceReasons", serviceReasons);
                    }
                    else{
                        component.set("v.serviceReasons", result.Reason__c);
                    }
                }
                
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
    
    
    getAllPracticeManagement: function(component, contactId) {
        var action = component.get("c.getAllPracticeManagementRecord");
         action.setParams({
            "conId" : contactId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    row.counter = i+1;
                }
                console.log('practices: '+result);
                component.set("v.practices", result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);		
	},
    //Service Practice Many to Many Relationship
    getServicePractices: function(component, serviceId) {
        var action = component.get("c.getServicePracticesRecord");
         action.setParams({
            "serviceId" : serviceId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    row.counter = i+1;
                }
                console.log('services of practice management: '+JSON.stringify(result));
                component.set("v.servicePractices", result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);		
	},
    
    //Services in Practice Management
    getPracticeServices: function(component, practiceId) {
        var action = component.get("c.getPracticeServicesRecord");
         action.setParams({
            "practiceId" : practiceId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    row.counter = i+1;
                }
                console.log('services of practice management: '+result);
                component.set("v.practiceServices", result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);		
	},
    
    getPracticeDoctors: function(component, serviceId, practiceId) {
        var action = component.get("c.getPracticeDoctorsRecord");
        action.setParams({
            "practiceId" : practiceId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.practiceDoctors", result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
    
    getAllDoctors: function(component, serviceId, reason) {
        var action = component.get("c.getAllDoctors");
        action.setParams({
            "serviceId" : serviceId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.doctors", result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
    
    setPicklistValues: function(component, fieldName) {
        var action = component.get("c.getFieldValues");
        action.setParams({
            "fieldName": fieldName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.serviceReasons", result);
                //console.log(JSON.stringify(result));
            }
        });
        $A.enqueueAction(action);
        
        
    },
})