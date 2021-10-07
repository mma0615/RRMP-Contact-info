({
	doInit: function(component, event, helper) {
	    console.log('init '+ $A.get("$SObjectType.CurrentUser.Id"));
		component.set("v.currUserId", $A.get("$SObjectType.CurrentUser.Id"));
	}
})