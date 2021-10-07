({
    calculateApplicationButtonLabelAndURL: function (component, event, helper) {
        let currentUser = component.get('v.currUser');
        let portalPageAccess = currentUser.Contact.Application_Portal_Page_Access__c;
		component.set("v.refresh", true);
        
        if(portalPageAccess === 'New Application Open') {
            component.set('v.finalApplicationButtonURL', component.get('v.applicationButtonURL'));
            component.set('v.finalApplicationButtonLabel', component.get('v.applicationButtonStart'))
        } else if(portalPageAccess === 'New Application Continue') {
            component.set('v.finalApplicationButtonURL', component.get('v.applicationButtonURL'));
            component.set('v.finalApplicationButtonLabel', component.get('v.applicationButtonContinue'));
        } else if(portalPageAccess === 'Renewal Application Open') {
            component.set('v.finalApplicationButtonURL', component.get('v.applicationButtonURLRenewal'));
            component.set('v.finalApplicationButtonLabel', component.get('v.applicationButtonStart'));
        } else if(portalPageAccess === 'Renewal Application Continue') {
            component.set('v.finalApplicationButtonURL', component.get('v.applicationButtonURLRenewal'));
            component.set('v.finalApplicationButtonLabel', component.get('v.applicationButtonContinue'));
        } else if(portalPageAccess === 'Current Finalist' || portalPageAccess === 'Current Submitted for Review' || portalPageAccess === 'Pending when Cycle Closed') {
            let childChangeButton = component.find('schoolDetails');
            let showButton = childChangeButton.get('v.disableChangeBtn');
            let application = childChangeButton.get('v.application');
           // let applicationList = childChangeButton.get('v.applicationsList');
            //let studentTermList = childChangeButton.get('v.studentTermList');
            let currUser = childChangeButton.get('v.currentUser');
            component.set('v.finalApplicationButtonLabel', component.get('v.applicationButtonView'));
            if(currentUser.Contact.Applications_Current_Finalist_Renewal__c >= 1 || currentUser.Contact.Applications_Current_Pending_Renewal__c >= 1 || currentUser.Contact.Applications_Current_Renewal_ALL__c >= 1) {
                component.set('v.finalApplicationButtonURL', component.get('v.applicationButtonViewURLRenewal'));
            } else if(currentUser.Contact.Applications_Current_Finalist_New__c >= 1 || currentUser.Contact.Applications_Current_Pending_New__c >= 1 || currentUser.Contact.Applications_Current_New_ALL__c >= 1) {
                component.set('v.finalApplicationButtonURL', component.get('v.applicationButtonViewURL'));
            }

        }
    },

})