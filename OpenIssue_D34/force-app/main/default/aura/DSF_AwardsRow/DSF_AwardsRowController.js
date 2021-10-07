({
    onInit : function(component, event, helper) {
        let terms = component.get("v.rawStudentTerms");
        
        if (screen.width < 768) {
            component.set("v.sldsSize", "slds-size_1-of-1 slds-p-bottom_medium");
        } else if (terms.length == 3) {
            component.set("v.sldsSize", "slds-size_1-of-3");
            component.set("v.minHeight", "min-height");
        }
        
        component.set("v.studentTerms", terms);
    }
})