({

    toggleSection : function(component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open material-section');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close material-section');
        }
    },

    doInit : function(component, event, helper) {
        document.title = 'Loading....';
        component.set("v.showSpinner", true);
        const queryString = decodeURIComponent(window.location.search);
        var eventId = (queryString.split('id=')[1]).split('&')[0];
        
        //eventId = 'pwB1UJeYAyh';
        component.set('v.eventId', eventId);
        
        var emailstr = '';
        try {
            emailstr = (queryString.split('email=')[1]).split('&')[0];
        }
        catch(err) {
            emailstr = '';
        }
    
        var PM = '';
        try {
            PM = (queryString.split('pm=')[1]).split('&')[0];
        }
        catch(err) {
            PM = '';
        }    
        
        //PM = 'EM-001766';
        var pstrue = 'false'
        
        if(PM != ''){
            pstrue = 'true';
            component.set('v.pstrue', true);
        }

        var action = component.get("c.getEventSession");
                
        action.setParams({ 
            eventId : eventId,
            participantNumber : PM,
            pstrue : pstrue
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();

               //this section is used to check if session is active or not
                //check is done in client-side to match user computer time
                var currentDateTime = new Date();

                for (let i = 0 ; i < resultEvent.SessionList.length ; i++){
                    for (let j = 0 ; j < resultEvent.SessionList[i].SessionDetailList.length ; j++){
                        let session = resultEvent.SessionList[i].SessionDetailList[j];
                        let dateStart = new Date(session.unformattedStartDate);
                        let dateEnd = new Date(session.unformattedEndDate);

                        session.isActive = helper.computeForSessionActive(helper, dateStart, dateEnd, currentDateTime);
                    }
                }

                component.set('v.sessionList', resultEvent.SessionList);   
                component.set('v.SessionsWithGeneralMaterial', resultEvent.SessionsWithGeneralMaterial);   
                

                try {
                    var resultMaterialList = JSON.parse(resultEvent.eventmaterialstr);
                    component.set('v.materialList', resultMaterialList);
                    
                    var sessionRec = resultEvent.SessionList[0];

                    if(sessionRec.sessionPageTitle != null || sessionRec.sessionPageTitle != undefined){
                        document.title = sessionRec.sessionPageTitle;
                        component.set('v.sessionPageTitle', sessionRec.sessionPageTitle);

                    } else {
                        component.set('v.sessionPageTitle', 'SESSIONS');
                    }
                }
                catch(err) {
                    console.log('error --------------- ' +err);
                }

            } else if (state === "ERROR") {
                let errors = response.getError();
                let message = "Error on Loading sessions page"; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                
                helper.showToast("Oops!", message, "error", "pester");
            }

            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);

    },
    
    handleAttend: function(component, event, helper) {

        component.set("v.showSpinner", true);
        var value = event.getSource().get("v.value");
        var valueSplit = value.split("|");
        var ParticipantSessionId = valueSplit[0];

        var action = component.get("c.updateAttendance");

        action.setParams({ 
            ParticipantSessionId : ParticipantSessionId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();

                if(resultEvent){
                    var sessionList = component.get("v.sessionList");
                    var sessionDetail = sessionList[valueSplit[1]].SessionDetailList[valueSplit[2]];
                    sessionDetail.isAttended = true;

                    component.set("v.sessionList", sessionList);
                    helper.showToast("Success!", "Your attendance has been recorded successfully.", "success");
                    
                }else{
                    helper.showToast("Error!", "Something went wrong. Please contact the administrator.", "error");
                }
            }

            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    },

    toggleMaterial: function(component, event, helper) {
        var sessionId = event.getSource().get("v.value");
        //var materialbox = component.find(sessionId).getElement();
        var x = document.getElementById(sessionId);
        var y  = document.getElementById(sessionId+'toggle');

        if (x.style.display === "block") {
            x.style.display = "none";
            event.getSource().set("v.label","");
            event.getSource().set("v.class","arrow-down");
        } else {
            x.style.display = "block";
            event.getSource().set("v.label","");
            event.getSource().set("v.class","arrow-up");
        }  

        //$A.util.removeClass(materialbox, 'hideme');
        //$A.util.addClass(materialbox, 'showme');
    },

    downloadAllMaterial: function(component, event, helper) {
        var materialList = event.getSource().get("v.value");
        for(let i=0; i<materialList.length; i++){
            window.open(materialList[i].DownloadURL, '_blank');
        }	
    }
})