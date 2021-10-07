({
	handleLoadedEmails : function(component, event, helper) {
		let rawEmails = component.get("v.rawEmails");
		rawEmails.map(e =>{
			let date = new Date(e.et4ae5__DateSent__c);
			let outputTime = date.toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric', });
			e.et4ae5__DateSent__c = outputTime;
		});
		component.set("v.Emails", rawEmails);
		component.set("v.isLoaded", true);
	},
 	selectedEmail : function(component, event, helper) {
		let EmailId = event.currentTarget.dataset.recordId;
		let msgEVT = component.getEvent("DSF_MessagesEVT");
            msgEVT.setParams({
                "recordId": EmailId,
                "screen" : 2
            });
            msgEVT.fire();
	}
})