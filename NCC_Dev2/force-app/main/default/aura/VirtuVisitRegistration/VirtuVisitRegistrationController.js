({
	doInit : function(component, event, helper) {
        document.body.style.background = '#e2e7ea';
	},
    
    createNewContact : function(component, event, helper) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid) {
            var firstName = component.get("v.FirstName");
            var lastName = component.get("v.LastName");
            var email = component.get("v.Email");
            var password = component.get("v.Password");
            helper.createContactRecord(component, firstName, lastName, email, password);
            //alert('All form entries look valid. Ready to submit!');
        } else {
            //alert('Please update the invalid form entries and try again.');
        }
    },
})