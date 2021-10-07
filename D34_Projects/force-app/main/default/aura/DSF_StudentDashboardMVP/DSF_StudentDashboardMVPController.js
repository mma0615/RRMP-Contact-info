({
    doInit : function(component, event, helper) {
        component.set("v.refresh", true);
        component.set("v.currentYear", new Date($A.get("$Label.c.DSF_App_Season_End_Date")).getFullYear());
    },

    onUserLoad: function (component, event, helper) {
        helper.calculateApplicationButtonLabelAndURL(component, event, helper);
    },
    onAppListLoad: function (component, event, helper) {
        component.set('v.application', component.get('v.applicationList')[0]);
    },
  
    onStudentTermLoad: function (component, event, helper) {
        component.set('v.studentTerm', component.get('v.studentTermList')[0]);
    },

})