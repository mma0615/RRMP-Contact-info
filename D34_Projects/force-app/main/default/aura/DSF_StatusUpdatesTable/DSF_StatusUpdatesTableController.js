({
	doInit : function (component, event, helper) {
		let user = component.get("v.User");
			if (user.ContactId == null){
				component.set("v.isLoaded", true);
			}
	},
	handleLoadedTasks : function(component, event, helper) {
		let rawtasks = component.get("v.rawTasks");
		let tasks = [];
        for(let t in rawtasks){
            if(rawtasks[t].Subject == "Student Alert" && rawtasks[t].Description != null && rawtasks[t].ActivityDate != null){
				tasks.push(rawtasks[t]);
			}
		}
		tasks.map(t =>{
			let date = new Date(t.ActivityDate);
			let outputTime = date.toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric', });
			t.ActivityDate = outputTime;
		});
		component.set("v.Tasks", tasks);
		component.set("v.isLoaded", true);
	}
})