({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
    },
    
    handleRankChange : function(component, event, helper) {
        var selectedRankId = event.getSource().get("v.value");
        var rankOptions = component.get("v.optionsRank");
        
        var sessionPart = component.get("v.sessionPart");
        sessionPart.Rank = rankOptions[parseInt(selectedRankId)].label;
        
        helper.handleFireEvent(component, event, helper);
    },
    
    handleFirstNameChange : function(component, event, helper) {
        helper.handleFireEvent(component, event, helper);
    },
    
    handleLastNameChange : function(component, event, helper) {
        helper.handleFireEvent(component, event, helper);
    },
    
    handleEmailChange : function(component, event, helper) {
        helper.handleFireEvent(component, event, helper);
    }
})