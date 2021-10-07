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
    getParameterByName: function(component, event, name) {
      name = name.replace(/[\[\]]/g, "\\$&");
      var url = window.location.href;
      var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
      var results = regex.exec(url);
      if (!results) return null;
      if (!results[2]) return '';
      return decodeURIComponent(results[2].replace(/\+/g, " "));
    }
})