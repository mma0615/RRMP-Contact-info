({
    handleEvent : function(component, event, helper) {
        component.set("v.recordId", event.getParam("recordId"));
        component.set("v.screen", event.getParam("screen"));   
    },
    focusTable : function (component, event, helper) {
        let source = event.getSource().getLocalId();
        if (source != "support") {
            component.set("v.isNotDefaultSelected", true);
        }
        if(component.get("v.isNotDefaultSelected")) {
            document.getElementById(source).scrollIntoView();
        }
    }
})