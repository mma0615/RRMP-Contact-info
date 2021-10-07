({
    
    doInit: function(component, event, helper) {
        component.set("v.showSpinner", true);
        const queryString = decodeURIComponent(window.location.search);
        let eventId = (queryString.split('id=')[1]).split('&')[0];
        
        let PM = '';
        try {
            PM = (queryString.split('pm=')[1]).split('&')[0];
        } catch(err) {
            PM = '';
        }         
        
        console.log('---- PM ' + PM);

        component.set("v.EventId", eventId);
        let action = component.get('c.DoInit');
        action.setParams({
            campaignId : eventId ,
            pm : PM
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let result = response.getReturnValue();
            
            if (state === "SUCCESS") {
                component.set('v.sessionList', result.SessionList);
                
                let participantRecord = result.participantRecordList;
                let regFieldList = [];

                for (let i = 0 ; i < result.registrationFieldList.length ; i++){
                    let field = result.registrationFieldList[i];
                    if(!$A.util.isUndefined(participantRecord)){
                        field["inputValue"] = participantRecord[0]["Member_Contact__r"][field["fieldName"]];
                    }
                    regFieldList.push({Field : field, IsPicklist : field.fieldType === "Picklist"});
                }
                component.set('v.dynamicFields', regFieldList);

            } else if (state === "ERROR") {
                let errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('--ERRORS--');
                        console.log(errors[0].message);
                    }
                }
            }
            component.set("v.showSpinner", false);
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    handleSubmit : function(component, event, helper) {                
        let url_string = document.location.href;
        let eventId = (url_string.split('id=')[1]).slice(0,11);
        
        const FIELD_RESULTS = helper.checkFieldsValidityAndGetInputValues(component);
        let sessionIdList = helper.checkSelectedSessionsAndReturnSelectedSessions(component);
        
        let toastEvent = $A.get("e.force:showToast");

        if(sessionIdList.length === 0){
            toastEvent.setParams({
                title : 'Error!',
                message: 'Please select a session.',
                duration:' 7000',
                type: 'error',
            });

            toastEvent.fire();
            
        } else if (FIELD_RESULTS["validity"]){
            console.log(FIELD_RESULTS["inputs"]);
            component.set("v.showSpinner", true);
            let action = component.get('c.submitBooking');
            action.setParams({
                campaignId : eventId,
                fieldInputs : JSON.stringify(FIELD_RESULTS["inputs"]),
                sessionIds : sessionIdList
            });
            action.setCallback(this, function(response) {
                let state = response.getState();
                let resp = response.getReturnValue();
				console.log('resp'+resp);
                if (state === "SUCCESS") {
                    component.set("v.showSpinner", false);
                    toastEvent.setParams({
                        title : 'Success!',
                        message: 'You are now registered to the event.',
                        duration:' 7000',
                        type: 'success',
                    });
                    toastEvent.fire();
                    
                    let urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url":  'https://' + window.location.hostname + '/Compass/s/events?id=' + component.get("v.EventId")
                    });
                    urlEvent.fire();
                } else if (state === "ERROR") {
                    let errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('--ERRORS--');
                            console.log(errors[0].message);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})