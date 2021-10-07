({
    onUserLoad: function (component, event, helper) {
        let currentUser = component.get('v.currUser');
        let portalPageAccess = currentUser.Contact.Application_Portal_Page_Access__c;

        if(portalPageAccess === 'New Application Open') {
            component.set('v.finalButtonLabel', component.get('v.buttonStart'));
            component.set('v.finalButtonURL', component.get('v.buttonURL'));
        }
        if(portalPageAccess === 'New Application Continue') {
            component.set('v.finalButtonLabel', component.get('v.buttonContinue'));
            component.set('v.finalButtonURL', component.get('v.buttonURLContinue'));
        }
    },
})