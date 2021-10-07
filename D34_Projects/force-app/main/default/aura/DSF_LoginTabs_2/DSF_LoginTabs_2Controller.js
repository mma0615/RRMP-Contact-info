({
    handleLoginEvent : function(component, event, helper) {
        component.set("v.showTabs", event.getParam("showTabs"));
    },

    handleIneligibleEvent :function(component, event, helper)
    {
        component.set('v.showTabs', false);
        component.set('v.ineligible', event.getParam('isIneligible')); 
        component.set('v.is_default_message', event.getParam('is_default_message'));
        component.set('v.message', event.getParam('message'));
    },
    handleContactUsEvent : function (component, event, helper){
        let param = event.getParam("showContactUs");
        console.log(param);
        component.set("v.showContactUs", param);
        console.log(component.get("v.showContactUs"));
    },
    showContactUs : function (component, event, helper) {
		component.set("v.showContactUs", true);
	},

    backToLogin: function (component, event, helper) {
        component.set('v.showTabs', true);
    },

    handleCreateAccountTabSelected: function (component, event, helper) {
        helper.refreshRegistrationForm(component, event, helper);
    },

    backToLoginEvtHandler: function (component, event, helper) {
        component.find("tabSet").set("v.selectedTabId","login");
    }
})