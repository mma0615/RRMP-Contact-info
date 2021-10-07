({ 
    doInit : function (component, event, helper) {
        let user = component.get("v.User");
            if (user.ContactId == null){
                component.set("v.isLoaded", true);
            }
},
    startApplication : function(component, event, helper) {
        let navService = component.find("navService");

        let pageReference = {
            type: 'comm__namedPage',
            attributes:
            {
                pageName: 'contact-dsf'
            }
        };
        navService.navigate(pageReference);
    },
    showSelectedCase : function (component, event, helper) {
        let caseId = event.currentTarget.dataset.recordId;
        let cases = component.get("v.Cases");
        let currCase ;
        let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        
        for(let c in cases) {
            if (cases[c].Id == caseId) {
                currCase  = cases[c];				
                let date = new Date(currCase.CreatedDate);
                let outputDate = `${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()} at `;
                let outputTime = date.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
                currCase.CreatedDate = outputDate+outputTime.replace(" ","").toLowerCase();
            }
        }
        let msgEVT = component.getEvent("DSF_MessagesEVT");
            msgEVT.setParams({
                "recordId": currCase.Id,
                "screen" : 1
            });
            msgEVT.fire();
    },
    handleLoadedCases : function(component, event, helper) {
        let cases = component.get("v.rawCases");
        let statuses = [
            {status: component.get('v.StatusColorOrange'), classColor: "status_orange"},
            {status: component.get('v.StatusColorRed'), classColor: "status_red"}, 
            {status: component.get('v.StatusColorGreen'), classColor: "status_green"}
        ];
        cases.map(c => {
            	let date = new Date(c.CreatedDate);
            	let outputTime = date.toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric', });
        		c.ShortDate = outputTime; 
        		date = new Date(c.LastModifiedDate);
       	 		outputTime = date.toLocaleString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric', });
        		c.LastModifiedDate = outputTime;
        	statuses.map(s => {
            	if(c.Status == s.status){
            		c.statusColor = s.classColor;
    			}
			});
        });
            component.set("v.Cases", cases);
            component.set("v.isLoaded", true)
    }
})