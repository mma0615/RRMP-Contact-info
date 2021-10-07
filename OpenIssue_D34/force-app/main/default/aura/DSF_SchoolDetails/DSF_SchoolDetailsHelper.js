({
    closeModal : function (component, event, helper){
        let backdrop = component.find("backdrop");
        let modal    = component.find("modal");
        $A.util.removeClass(backdrop, "slds-backdrop--open");
        $A.util.removeClass(modal, "slds-fade-in-open");
    },

    getSchools : function (component, event, helper) { 
        
        let action = component.get("c.getUniversities");
        action.setCallback(this,function(response){
            let state = response.getState();
            
            if (state === "SUCCESS"){
                let universities = response.getReturnValue();
                if(universities != null && universities != ''){
                    let names = new Array();
                    let name;
                    for (let university in universities){
                        name = {label: universities[university].Name, value: universities[university].Id};
                        names.push(name);
                    }
                   
                    component.set("v.universities", names);
                } else{
                    console.log("Universities are null")
                }
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message );
                    }
                }
            }
            
        });
        $A.enqueueAction(action);
    },

    updateApp : function (component, event, helper) { 
        
        component.set('v.updateCollege', true);

        let application = component.get("v.application");  
        let action = component.get("c.updateApplication");
        action.setParams({"applicationId" : application.Id,
                          "newSchoolId" : application.School_Name__c
                        });

        action.setCallback(this,function(response){
            let state = response.getState();  
            
            if (state === "SUCCESS"){
           
                //on college update reload the whole page
                location.reload(); 
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            }            
        });
        $A.enqueueAction(action);  
    },

    getCurrentApplication : function (component, event, helper) { 
        
        let action = component.get("c.getCurrentApplication"); 
        action.setCallback(this,function(response){
            let state = response.getState();
            
            if (state === "SUCCESS"){
                let currenAppl = response.getReturnValue();
                if(currenAppl != null && currenAppl != ''){                
                    component.set("v.application", currenAppl);
                } 
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message );
                    }
                }
            }
            
        });
        $A.enqueueAction(action);
    },

})