({
	returnToMyMessages : function(component, event, helper) {
		let msgEVT = component.getEvent("DSF_MessagesEVT");
		msgEVT.setParams({
			"recordId": "",
			"screen" : 0
		});
		msgEVT.fire();
	},
	handleEmail : function(component, event, helper) {
        console.log("handler");
        let selectedEmails = component.get("v.Emails");
        let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let statuses = [
			{status: "On Hold", classColor: "status_orange"},
			{status: "New", classColor: "status_red"},
			{status: "Escalated", classColor: "status_red"},
			{status: "Closed", classColor: "status_green"}
		];
        selectedEmails.map(e=>{  
		let date = new Date(e.et4ae5__DateSent__c);
		let outputDate = `${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()} at `;
		let outputTime = date.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
        e.et4ae5__DateSent__c = outputDate+outputTime.replace(" ","").toLowerCase();
        });
		console.log(selectedEmails[0]);
        component.set("v.handledEmail", selectedEmails[0]);
		component.set("v.isLoaded", true);
    },
})