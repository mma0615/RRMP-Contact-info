({
    result: {},
    
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
    
    // Update survey answers upon input
    handleOnClick: function(component, event, helper) {
        
        const questionId = event.target.getAttribute('data-question-id');
        const userAnswer = {};
        userAnswer.Question = event.target.question;
        
        console.log('target'+event.target.value);
        
        var multiSelect = [];
        console.log(document.getElementById(questionId).classList.contains("multiselect"));
        if(document.getElementById(questionId).classList.contains('multiselect')){
            console.log('mel');
            var options = document.getElementById(questionId).getElementsByTagName("input");
            
            for ( i=0; i<options.length; i++)
            {
                if(options[i].type == "checkbox" && options[i].checked){
                    console.log(JSON.stringify(options[i]));
                    //if(!multiSelect.includes(event.target.value)){
                        multiSelect.push(options[i].value);
                    //}
                }
            }
            userAnswer.AnswerList = multiSelect;
        }
        else{
            userAnswer.Answer = event.target.value;
        }
        
        console.log('hanleOnClick'+JSON.stringify(userAnswer));   
        this.result[questionId] = userAnswer;
        this.validationOnChange(component, questionId, event.target.name);
        
    },
    handleSubmit: function(component, event, helper) {
        
        var currentTab = component.get("v.selTabId");
        
        var url_string = location.href;
        //Encounter Reason
        var reason = '';
        if(url_string.includes('reason=')){
            reason = (url_string.split('reason=')[1]);
            if(reason.includes('&')){
                reason = reason.split('&')[0];
                reason = reason.replace("+", " ");
            }
        }
        //Doctor
        var doctorId = '';
        if(url_string.includes('doctorId=')){
            doctorId = (url_string.split('doctorId=')[1]).slice(0,18);
        }
        //Service
        var serviceId = '';
        if(url_string.includes('serviceId=')){
            serviceId = (url_string.split('serviceId=')[1]);
            if(serviceId.includes('&')){
                serviceId = serviceId.split('&')[0];
                serviceId = serviceId.replace("+", " ");
            }
        }
        
        if(this.isSurveyInputValid(component, currentTab)){
            console.log('currentTab on Submit: '+currentTab);
            console.log('contactId: '+component.get("v.contactId"));
            console.log('result: '+JSON.stringify(this.result));
            var action = component.get("c.createEncounter");
            action.setParams({
                conId : component.get("v.contactId"), //Logged-in Contact
                serviceId : serviceId,
                reason : reason,
                doctorId : doctorId,
                result : JSON.stringify(this.result), //Intake Form Question & Answer
                contactAvailabilityId: component.get("v.contactAvailability"),
                practiceManagementId: component.get("v.practiceManagementId"),
                selectedTimeZone: component.get("v.selectedTimeZone")
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    var result = response.getReturnValue();
                    
                    console.log('result'+result);
                    component.set("v.submitted", true);
                    //component.set("v.surveyQuestions", result);
                }
                else{
                    console.log('ERROR:');
                    console.log(response.getError());
                }
            });
            $A.enqueueAction(action);
        }
        console.log('result: '+JSON.stringify(this.result));
    },
    
    // Validate question on change
    validationOnChange: function(component, questionId, elementName) {
        if(this.result[questionId] != undefined){
            if(this.result[questionId].Answer == '' || this.result[questionId].Answer == []){
            	this.toggleErrorMessage(component,questionId, 'on');
            }
            else{
            	this.toggleErrorMessage(component,questionId, 'off');
            }
        }
    },
    
    //Toggle error visiblity
    toggleErrorMessage: function(component, questionId, onOrOff) {
        const errorElement = document.getElementById("data-error-id="+questionId);
        if(errorElement != null){
        	errorElement.style.display = (onOrOff == 'on' ? 'unset' : 'none');
        }
        else{
            //console.log('element not found');
        }
    },
    
    // Verify if all survey questions have been answered
    isSurveyInputValid: function(component, currentTab) {
        console.log('currentTab'+currentTab);
        var isValid = true;
        //const bodyElement = document.getElementByClassName(".intake-form");
        var bodyElementVar = "."+currentTab.replaceAll(' ','_').replaceAll(',','_');
        var bodyElement = document.querySelector(bodyElementVar);
        var elements = bodyElement.querySelectorAll('input, select, fieldset');
        
        for (i = 0; i < elements.length; i++) {
            if(elements[i].hasAttribute('data-question-id')){
                const questionId = elements[i].getAttribute('data-question-id');
                console.log(questionId);
                
                if(elements[i].hasAttribute('required') && 
                   (this.result[questionId] === undefined ||
                    this.result[questionId].Answer == '')){
                    this.toggleErrorMessage(component, questionId, 'on');
                    isValid = false;
                	//console.log('no value');
                }
                else /*if(elements[i].hasAttribute('required') && 
                   (this.result[questionId] != undefined ||
                    this.result[questionId].Answer != ''))*/{
                    //isValid = true;
                    this.toggleErrorMessage(component, questionId, 'off');
                    //console.log('with value');
                }
            }
        }
        
        console.log(this.result);
        return isValid;
    },
    
    getIntakeForm: function(component, event, helper) {
        var action = component.get("c.getIntakeFormRecords");
        action.setParams({
            "conId" : component.get('v.contacId') //not used
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    row.counter = i+1;
                    row.options = row.Options__c != undefined ? row.Options__c.split(/\r?\n/) : [];
                }
                //console.log('result'+result);
                component.set("v.surveyQuestions", result);
            }
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
    getIntakeFormTabs: function(component, event, helper) {
        var action = component.get("c.getIntakeFormTabs");
        action.setParams({
            "conId" : component.get('v.contacId') //not used
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                
                const intakeTypesCounter = new Map();
                const intakeTypes = new Map();
                for (var i = 0; i < result.length; i++) {
                    intakeTypes.set(result[i].Name, result[i].Step__c);
                    intakeTypesCounter.set(result[i].Step__c, result[i].Name);
                }
                component.set("v.intakeTypesList", result);
                component.set("v.intakeTypesCounter", intakeTypesCounter);
                component.set("v.intakeTypes", intakeTypes);
                
                component.set("v.selTabId", intakeTypesCounter.get(1));
                var currentTab = component.get("v.selTabId");
                if(result.length == intakeTypes.get(currentTab)){
                    component.set("v.next", true);
                    component.set("v.submit", false);
                }
            }
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
    },
    
    getIntakeFormMap: function(component, event, helper) {
        var action = component.get("c.getIntakeFormRecordsMap2");
        action.setParams({
            "conId" : component.get('v.contacId') //not used
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                var acts = [];
                /*for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    row.counter = i+1;
                    row.options = row.Options__c != undefined ? row.Options__c.split(/\r?\n/) : [];
                }*/
                
                for(var key in result){
                    for(var i = 0; i < result[key].length; i++){
                        //console.log(result[key][i]);
                        var row = result[key][i];
                        row.counter = i+1;
                        
                        //row.keyVal = (row.Intake_Form_Tab__r.Name).replace(' ', '-');
                        row.options = row.Options__c != undefined ? row.Options__c.split(/\r?\n/) : [];
                    }
                    acts.push({value:result[key], key:key.split('*****')[0], key1: key.split('*****')[0].replaceAll(' ','_').replaceAll(',','_'), desc : key.split('*****')[1]});
                }
                //console.log('result'+JSON.stringify(acts));
                component.set("v.intakeQuestions", acts);
            }
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
	},
})