({
	doInit : function(component, event, helper) {
		let link = window.location.href;
		if (link.includes("ForgotPassword")) {
			component.set("v.screen", "newpassword");
		}
	},
	handleEnterKey : function(component, event, helper) {
        if(event.which == 13) {
            let currStep = component.get('v.screen');
            let nextStep;
            if(currStep == 'login') {
				let isLoginReqSent = component.get('v.isLoginReqSent');
				if(!isLoginReqSent) {
					nextStep = component.get('c.userLogin');
					$A.enqueueAction(nextStep);
				}
            } else if (currStep == 'resetpassword') {
                nextStep = component.get('c.forgotPassword');
                $A.enqueueAction(nextStep);
            }
        }
    },
	userLogin : function (component, event, helper) {
		component.set("v.isLoginReqSent", true);

		let user = component.find('email');
		let pass = component.find('password');
		let valid = false;

		if(user.get('v.value').length > 0 && user.get('v.validity').valid &&
			pass.get('v.value').length > 0 && pass.get('v.validity').valid) {
			valid = true;
		} else {
			component.set("v.showErrorMessage", true);
			component.set("v.isLoginReqSent", false);
		}

		if (valid) {
			let action = component.get("c.login");
			action.setParams({
				username: user.get("v.value"),
				password: pass.get("v.value"),
				startUrl: $A.get("$Label.c.DSF_Landing_Page")
			});
			action.setCallback(this, function(response){
				let state = response.getState();
				if (state === "SUCCESS") {
					if(response.getReturnValue() != 'blank') {
						component.set("v.showErrorMessage", true);
					} else {
						component.set("v.showErrorMessage", false);
					}
				}
				component.set("v.isLoginReqSent", false);
			});
			$A.enqueueAction(action);
		} else if (!valid) {
			component.set("v.isLoginReqSent", false);
		}
	},
	goToForgotPassword : function(component, event, helper) {
		component.set("v.screen", "resetpassword");
	},
	forgotPassword : function(component, event, helper) {
		let user = component.find("emailReset");
		let email = component.get("v.email");
		if (user.get('v.value').length > 0 && user.get('v.validity').valid) {
			let action = component.get("c.resetPassword");
			action.setParams({
				username: email
			});
			action.setCallback(this, function(response){
				let state = response.getState();
				let value = response.getReturnValue();
				if (state === "SUCCESS" && value === true) {
					component.set("v.screen", "emailsent");

					let evt = component.getEvent("DSF_Login_Event");
					evt.setParams({"showTabs": false});
					evt.fire();
				} else {
					console.log(`%c ERROR: ${state}`, `font-weight: bold; font-size: 20px; color: darkred`);
				}
			});
			$A.enqueueAction(action);
		}
	},
    showContactUs : function (component, event, helper) {
		let evt = $A.get("e.c:DSF_ShowContactUsEVT");
        evt.setParams({"showContactUs": true});
        evt.fire();  
	}
})