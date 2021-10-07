({
	doInit : function(component, event, helper) {
		component.set("v.currUserId", $A.get("$SObjectType.CurrentUser.Id"));
	}
})