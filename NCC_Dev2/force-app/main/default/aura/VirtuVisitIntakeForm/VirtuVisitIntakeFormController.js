({  
    
    handleOnClick: function(component, event, helper) {
       helper.handleOnClick(component, event, helper);
    },
    handleSubmit: function(component, event, helper) {
       helper.handleSubmit(component, event, helper);
    },
    
    doInit : function(component, event, helper) {
        
        console.log('contactAvailability'+component.get("v.contactAvailability"));
        console.log('practiceManagementId'+component.get("v.practiceManagementId"));
        console.log('selectedTimeZone'+component.get("v.selectedTimeZone"));
        var url_string = location.href;
        
        if(url_string.includes("id")){
            var contactId = (url_string.split('id=')[1]).slice(0,18);
            if(contactId != null){
                component.set('v.contactId',contactId);
                helper.getContactRecord(component, contactId);
                
                /*Intake Form*/
                //helper.getIntakeForm(component, event, helper);
                
                helper.getIntakeFormTabs(component, event, helper);
                helper.getIntakeFormMap(component, event, helper);
                
                /*var intakeTypesList = [
                    {intakeType: 'Diabetes Risk Assessment', step: 1},
                    {intakeType: 'Travel and Exposure Screening', step: 2},
                    {intakeType: 'Primary Reason for Visit', step: 3},
                    {intakeType: 'Planned Travel Screening', step: 4},
                    {intakeType: 'Patient History - Past Conditions, Surgical History, Family History, Social History', step: 5}
                ]
                
                const intakeTypesCounter = new Map();
                const intakeTypes = new Map();
                
                for (var i = 0; i < intakeTypesList.length; i++) {
                    intakeTypes.set(intakeTypesList[i].intakeType, intakeTypesList[i].step);
                    intakeTypesCounter.set(intakeTypesList[i].step, intakeTypesList[i].intakeType);
                }
                component.set("v.intakeTypesList", intakeTypesList);
                component.set("v.intakeTypesCounter", intakeTypesCounter);
                component.set("v.intakeTypes", intakeTypes);*/
                //var intakeTypesCounter = component.get("v.intakeTypesCounter");
                //console.log(intakeTypesCounter);
                component.set("v.back", true);
                component.set("v.submit", true);
                //component.set("v.selTabId", intakeTypesCounter.get(1));
                //console.log('intakeTypesCounter.get(1)'+intakeTypesCounter.get(1));
                /*Intake Form End*/
            }
        }
    },
    
    next : function(component, event, helper) {
        
        var currentTab = component.get("v.selTabId");
        
        //console.log('valid2? '+helper.isSurveyInputValid(component, currentTab));
        var ifValid = helper.isSurveyInputValid(component, currentTab);
        console.log('ifValid'+ifValid);
        if(ifValid){
            const intakeTypesList = component.get("v.intakeTypesList");
            const intakeTypes = component.get("v.intakeTypes");
            const intakeTypesCounter = component.get("v.intakeTypesCounter");
            
            if(intakeTypesList.length == intakeTypes.get(currentTab)){
                /*component.set("v.next", true);
                component.set("v.submit", false);*/
            }
            if(intakeTypesList.length == intakeTypes.get(currentTab)+1){
                component.set("v.next", true);
                component.set("v.submit", false);
            }
                            
            component.set("v.back", false);
            component.set("v.selTabId" , intakeTypesCounter.get(intakeTypes.get(currentTab)+1));
            

            
        }
	},
    
    back : function(component, event, helper) {
        var currentTab = component.get("v.selTabId");
        const intakeTypesList = component.get("v.intakeTypesList");
        const intakeTypes = component.get("v.intakeTypes");
        const intakeTypesCounter = component.get("v.intakeTypesCounter");
        if(intakeTypes.get(currentTab)-1 == 1){
            component.set("v.back", true);
        }
        component.set("v.next", false);
        component.set("v.submit", true);
        component.set("v.selTabId" , intakeTypesCounter.get(intakeTypes.get(currentTab)-1));
	},
   
})