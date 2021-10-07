({
    doInitHelper : function(component, event, helper) {
        //GET Roles/Table Values on Init        
        
        const queryString = decodeURIComponent(window.location.search);
        
        var sessionId = (queryString.split('id=')[1]).split('&')[0];
        component.set('v.sessionId', sessionId);
        
        var action = component.get('c.getRoles');
        action.setParams({
            sessId : sessionId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS"){
                if(result.tableValues){
                    console.log('T: ' + result.tableValues);
                    component.set('v.data', result.tableValues);
                    component.set('v.SignUpInstructions', 'No Sign-Up Instructions.');
                    if(result.signUpInstructions){
                        component.set('v.SignUpInstructions', result.signUpInstructions);
                    }
                    if(result.hasData == 'Yes'){
                        component.set('v.showEdit', true);
                        component.set('v.isDisabled', true);
                    }else{
                        component.set('v.showSave', true);
                        component.set('v.isDisabled', false);
                    }
                    component.set('v.hasData', true);
                    component.set('v.isLoading', false);
                }else{
                    component.set('v.hasData', false);
                    component.set('v.isLoading', false);
                }
            }else{
                component.set('v.isLoading', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Error retrieving session roles',
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
        this.getEventDetailsHelper(component, event, helper);
        this.getEventDetailsIdHelper(component, event, helper);
    },
    
    getEventDetailsHelper : function(component, event, helper) {
        const queryString = decodeURIComponent(window.location.search);
        
        var sessionId = (queryString.split('id=')[1]).split('&')[0];
        component.set('v.sessionId', sessionId);
        
        var action = component.get("c.getEventDetails2");
        
        action.setParams({ 
            sessId : sessionId
        });
        
        action.setCallback(this, function(response){
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();
                component.set('v.title', resultEvent);
            }
            else{
                console.log(response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },    

    getEventDetailsIdHelper : function(component, event, helper) {
        const queryString = decodeURIComponent(window.location.search);
        
        var sessionId = (queryString.split('id=')[1]).split('&')[0];
        component.set('v.sessionId', sessionId);
        
        var action = component.get("c.getEventDetailsId");
        
        action.setParams({ 
            sessId : sessionId
        });
        
        action.setCallback(this, function(response){
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();
                component.set('v.eventId', resultEvent);
            }
            else{
                console.log(response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    handleComponentEventHelper : function(component, event, helper) {
        
    },
    
    handleSaveSignUpHelper : function(component, event, helper) {
        //Save Session Participants  
        var sessionId = component.get("v.sessionId");
        var sessionPartList = component.get("v.data"); 
        component.set('v.isLoading', true);
        var action = component.get('c.saveSessionParticipants');
        action.setParams({
            sessionParticipants : JSON.stringify(sessionPartList),
            sessId : sessionId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                if(result.includes('Error')){
                    toastEvent.setParams({
                        title : 'Error',
                        message:result,
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set('v.isLoading', false);
                }else{
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Session Participants has been successfully registered',
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                   	toastEvent.fire();
                    //component.set('v.isLoading', false);
                    $A.get("e.force:refreshView").fire();
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Error registering session participants',
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    returnToCalendarHelper : function(component, event, helper) {
        var url = location.href;  // window.location.href;
        var pathname = location.pathname;  // window.location.pathname;
        var index1 = url.indexOf(pathname);
        var index2 = url.indexOf("/", index1 + 1);
        var baseLocalUrl = url.substr(0, index2) + '/s/sessions-calendar?id=' + component.get('v.eventId');
        
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
          "url": baseLocalUrl
        });
        eUrl.fire();
    },
    
    handleEditSignUpHelper : function(component, event, helper) {
        component.set('v.showSave', true);
        component.set('v.showEdit', false);
        component.set('v.showCancel', true);
        component.set('v.isDisabled', false);
    },
    
    handleCancelSignUpHelper : function(component, event, helper) {
		$A.get("e.force:refreshView").fire();
    }
})