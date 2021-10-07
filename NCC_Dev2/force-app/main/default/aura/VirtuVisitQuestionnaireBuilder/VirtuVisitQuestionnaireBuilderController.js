({
	 doInit : function(component, event, helper) {
        var url_string = location.href;
        
        if(url_string.includes("id")){
            var contactId = (url_string.split('id=')[1]);//.slice(0,18);
            if(contactId){
                component.set('v.contacId',contactId);
                helper.getContactRecord(component, contactId);
                helper.setPicklistValues(component, event, helper);
            }
        }
         
    },
    
    newQuestionnaire : function(component, event, helper) {
        component.set("v.newQuestionnaire", true);
        
        
    },
        
    addNewQuestion  : function(component, event, helper) {
             
        $A.createComponents([
            //0
            ["aura:html",
             { 
                 'tag': 'tr',
                 'body': 'tr'
                 //'HTMLAttributes':{"class":"prev-date"+(pastDate == 1 ? " disable" : ""), "onclick":(pastDate != 1 ? component.getReference("c.selectDate") : ""), "id":prevMonthDate}
             }],
                //1
                ["aura:html",
                 { 
                     'tag': 'td',
                     'body': 'td'
                 }],
                    //2
                    ["lightning:input",{
                        "name" : "Question",
                        "label": "Question:",
                        "aura:id": "Question"
                    }], 
                //3
                ["aura:html",
                 { 
                     'tag': 'td',
                     'body': 'td'
                 }],
                    //4
                    ["lightning:select",{
                        "name" : "Question Type",
                        "label": "Question Type:",
                        "aura:id": "QuestionType"
                    }],
                        //5
                        ["option", {
                            value: "Text", 
                            label: "Text" 
                        }],
                        //6
                        ["option", {
                            value: "Radio", 
                            label: "Radio" 
                        }],
                        //7
                        ["option", {
                            value: "Picklist", 
                            label: "Picklist" 
                        }],
                        //8
                        ["option", {
                            value: "MultiSelect", 
                            label: "MultiSelect" 
                        }], 
            	//9
                ["aura:html",
                 { 
                     'tag': 'td',
                     'body': 'td'
                 }],
                    //10
                    ["lightning:textarea",{
                        "name" : "Options",
                        "label": "Options:",
                        "aura:id": "Options"
                    }],
        ],
            
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    var tr = components[0];
                    var td = components[1];
                    var question = components[2];
                    var td2 = components[3];
                    var questionTypeSelect = components[4];
                    var td3 = components[9];
                    var answer = components[10];
                    
                    //Question
                    td.set("v.body", question);
                    
                    //Question Type
                    questionTypeSelect.set("v.body", [components[5], components[6], components[7], components[8]]);
                    td2.set("v.body", questionTypeSelect);
                    
                    //Answer
                    td3.set("v.body", answer);
                    
                    //Append All TD
                    tr.set("v.body", [td, td2, td3]);
                    
                    var outerDiv = component.find('quest').get('v.body');
                    outerDiv.push(tr);	
                    component.find('quest').set('v.body', outerDiv);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
		);
    },
	cancelQuestionnaire : function(component, event, helper) {
            component.set("v.newQuestionnaire", false);
    },
    
	saveQuestionnaire : function(component, event, helper) {
            let ques = component.find("Question");
            let quesType = component.find("QuestionType");
            let ops = component.find("Options");
            //var questResult = {};
            var quesList = [];
            
        if(ques) {
            //if multiple
            if(ques.length) {
                let output = "Array of "+ques.length+" ";
                ques.forEach(function(v,i) {
                    quesList.push({"Question" : v.get('v.value'), 
                                   "QuestionType" : quesType[i].get('v.value'), 
                                   "Options" : (quesType[i].get('v.value') == 'Text' ? '' : ops[i].get('v.value'))
                                  });
                    /*v.set("v.value", "");
                    quesType[i].set("v.value", "");
                    ops[i].set("v.value", "");*/
            		/*console.log('Question:'+v.get('v.value'));
            		console.log('Question Type:'+quesType[i].get('v.value'));
            		console.log('Answer:'+ops[i].get('v.value'));*/
                });
            }
            //if one question only
            else {
                quesList.push({"Question" : ques.get('v.value'), 
                               "QuestionType" : quesType.get('v.value'), 
                               "Options" : (quesType.get('v.value') == 'Text' ? '' : ops.get('v.value'))
                              });
                /*ques.set("v.value", "");
                quesType.set("v.value", "");
                ops.set("v.value", "");*/
            }
            
            console.log('quesList'+JSON.stringify(quesList));
        }
            
            
        var questionnaire_Name = component.get("v.questionnaire_Name");
        var questionnaire_Description = component.get("v.questionnaire_Description");
        var question = component.get("v.question");
        var questionType = component.get("v.questionType");
        var options = component.get("v.options");
        var action = component.get("c.createQuestionnaire");
        action.setParams({
            "questionnaireName" : questionnaire_Name,
            "questionnaireDescription" : questionnaire_Description,
            "question" : question,
            "questionType" : questionType,
            "options" : options,
            "questionList": JSON.stringify(quesList)
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                
                component.set("v.questionnaire_Name", "");
                component.set("v.questionnaire_Description", "");
                component.set("v.newQuestionnaire", false);
                component.set("v.message", 'Questionnaire Successfully Created.');
                setInterval(
                    function(){ 
                        component.set("v.message", '');
                    }, 3000);
                
            }
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);	
        
    },
    
})