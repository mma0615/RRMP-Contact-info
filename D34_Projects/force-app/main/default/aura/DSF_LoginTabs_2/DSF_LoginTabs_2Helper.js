({
    refreshRegistrationForm: function (component, event, helper) {
        let registrationComponent = component.find('registrationComponent');

        registrationComponent.set('v.screen', 'step1');
        registrationComponent.set('v.firstName', '');
        registrationComponent.set('v.lastName', '');
        registrationComponent.set('v.date_of_birth', '');
        registrationComponent.set('v.dpsidOrCollegeId', '');
        registrationComponent.set('v.usersLoaded', false);
        registrationComponent.set('v.contactsLoaded', false);
        registrationComponent.set('v.contactIneligible', false);
        registrationComponent.set('v.password', '');
        registrationComponent.set('v.confirmPassword', '');
        registrationComponent.set('v.email', '');
        registrationComponent.set('v.errorMessage', '');
    },
})