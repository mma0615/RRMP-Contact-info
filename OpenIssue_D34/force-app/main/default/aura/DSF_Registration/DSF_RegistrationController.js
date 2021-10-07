({  
    handleEnterKey : function(component, event, helper) {
        if(event.which == 13) {
            let currStep = component.get('v.screen');
            let nextStep;
            if(currStep == 'step1') {
                nextStep = component.get('c.nextToStep2');
                $A.enqueueAction(nextStep);
            } else if (currStep == 'step2') {
                let usersLoaded = component.get('v.usersLoaded');
                let contactsLoaded = component.get('v.contactsLoaded');
                let contactIneligible = component.get('v.contactIneligible');
                if(!((!usersLoaded && !contactsLoaded) || contactIneligible)) {
                    nextStep = component.get('c.nextToStep3');
                    $A.enqueueAction(nextStep);
                }
            } else if (currStep == 'step3') {
                nextStep = component.get('c.validate');
                $A.enqueueAction(nextStep);
            }
        }
    },

    nextToStep2 : function(component, event, helper) {
		component.set("v.screen", "step2");
    }, 

    loadUserAndContactData : function(component, event, helper) {  
        var birthdate = component.find('birthdate');
        var dpsid = component.find('dpsid');
        if(birthdate.get('v.validity').valid && dpsid.get('v.validity').valid){
            component.set('v.loadData', true);
        }
    },

    checkIfUserAlreadyExist : function(component, event, helper) { 
        var users_list = component.get('v.users_list');
        if(users_list != null && users_list.length > 0){
            component.set("v.userExist", true); 
            console.log(`%c User exists`, `font-weight: bold; font-size: 16px; color: darkred`);
        } else {
            component.set("v.userExist", false); 
            console.log(`%c User does not exists`, `font-weight: bold; font-size: 16px; color: darkred`);
        }
         

        component.set("v.usersLoaded", true);
        component.set('v.loadData', false);
    },

    checkIfContactAlreadyExist : function(component, event, helper) { 
        var contact_list = component.get('v.contact_list');  
        if(contact_list != null && contact_list.length > 0){
            var contact = contact_list[0];
            if(!contact.Eligible_For_Initial_Registration__c){
               component.set('v.errorMessage', contact.Ineligible_to_Reapply_Ever_Message__c);
               component.set('v.contactIneligible', true);
                console.log(`%c Ineligible`, `font-weight: bold; font-size: 16px; color: darkblue`);
            } else {
                component.set('v.contactIneligible', false);
                component.set('v.errorMessage', '');
                console.log(`%c Eligible`, `font-weight: bold; font-size: 16px; color: darkgreen`);
            }
            component.set("v.contactExists", true);
        } else {
            component.set("v.contactExists", false); 
            component.set('v.contactIneligible', true);
            component.set('v.errorMessage', '');
            console.log(`%c Does not exist`, `font-weight: bold; font-size: 16px; color: darkred`);
        }

        component.set("v.contactsLoaded", true);
        component.set('v.loadData', false);
    },
    
    nextToStep3 : function(component, event, helper) {
        let usersLoaded = component.get('v.usersLoaded');
        let contactsLoaded = component.get('v.contactsLoaded');

        let firstName = component.find('firstName');
        let lastName = component.find('lastName');
        let birthdate = component.find('birthdate');
        let dpsid = component.find('dpsid');

        if(!usersLoaded && !contactsLoaded) {
            firstName.reportValidity();
            lastName.reportValidity();
            birthdate.reportValidity();
            dpsid.reportValidity();
            return;
        }
 
        var contactExists = component.get('v.contactExists');
        var userExist = component.get('v.userExist') ;
 
        if(userExist || !contactExists){
            return;
        } 

        var contact_list = component.get('v.contact_list');

        if(contact_list != null && contact_list.length > 0){
            var contact = contact_list[0];
            if(!contact.Eligible_For_Initial_Registration__c || contact.DPS_Enrollment_Eligibility__c == 'No'){
                component.set('v.errorMessage', contact.Ineligible_to_Reapply_Ever_Message__c);
                return;
            }
        }

        if(firstName.get('v.validity').valid && lastName.get('v.validity').valid &&
           birthdate.get('v.validity').valid && dpsid.get('v.validity').valid && contactExists) {
            component.set("v.screen", "step3");
            component.set("v.errorMessage", "");
        } else {
            firstName.reportValidity();
            lastName.reportValidity();
            birthdate.reportValidity();
            dpsid.reportValidity();
        }
    },
    
    validate :function(component, event, helper) {
        let contacts = component.get('v.contact_list'); 

        component.set('v.errorMessage', '');

        var isValid = helper.validateField(component, event, helper);

        // Exit function if invalid
        if(!isValid) {
            component.set('v.errorMessage', 'Please update the missing form entries and try again.');
            return;
        }
 
        if(isValid && contacts.length > 0) {
            let contact = contacts[0]; 

            if(contact.Eligible_For_Initial_Registration__c){
                helper.createAccount(component, event);
            } 
        }
    }, 

    showContactUs : function(component, event, helper) {
        let evt = $A.get("e.c:DSF_ShowContactUsEVT");
        evt.setParams({"showContactUs": true});
        evt.fire();
    },

    backToLogin : function(component, event, helper) {
        helper.backToLoginHandler(component, event, helper);
    }
})