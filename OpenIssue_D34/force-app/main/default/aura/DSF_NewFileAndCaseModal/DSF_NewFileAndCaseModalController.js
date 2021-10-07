({
    doInit: function(component, event, helper) {
        helper.loadCaseTemplateAndCreateCase(component, event, helper);
    },

    onUploadFinished: function(component, event, helper) {
        helper.fireUploadedEvent(component, event, helper);
        helper.closeModal(component, event, helper);
    }
})