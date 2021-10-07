({
 
    reply : function(component, event, helper) {
		let comment = component.find('fieldId');
        if(comment.get('v.value').length > 0 && comment.get('v.validity').valid) {
			helper.addComment(component, event, helper);
        } else {
			component.set('v.errorMessage', 'Comments cannot be empty.');
        }	
    },
    handleUploadFinished : function (component, event, helper) {   
        let uploadedFile = event.getParam("files")[0];
        console.log(uploadedFile);
        let currentDocId = uploadedFile.documentId;
        let updateTitleAction = component.get("c.updateFileTitle");
        updateTitleAction.setParams({
            "contendDocumentId": currentDocId
        });
        updateTitleAction.setCallback(this, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                let title = response.getReturnValue();
                let resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Uploaded",
                    "type": "success",
                    "message": "File " + uploadedFile.name + " uploaded successfully."

                }); 
                resultsToast.fire(); 
            }
            else if (state === "ERROR") {
                console.log('Problem saving new Title, response state: ' + state);
            }
                else {
                    console.log('Unknown problem, response state: ' + state);
                }
        });
        $A.enqueueAction(updateTitleAction);  
    },
    
    handleComments : function(component, event, helper) {
        let comms = component.get("v.comments");
        let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        comms.map(com=>{
        
		let date = new Date(com.CreatedDate);
		let outputDate = `${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()} at `;
		let outputTime = date.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
		com.CreatedDate = outputDate+outputTime.replace(" ","").toLowerCase()
        });
        component.set("v.handledComments", comms);
        component.set("v.isLoaded", true);
    },
    toMyMessages : function (component, event, helper) {
        let msgEVT = component.getEvent("DSF_MessagesEVT");
		msgEVT.setParams({
			"recordId": "",
			"screen" : 0
		});
		msgEVT.fire();
    },
    handleCase : function(component, event, helper) {
        let selectedCase = component.get("v.case");
        let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        let statuses = [
            {status: component.get('v.ColorOrange'), classColor: "status_orange"},
            {status: component.get('v.ColorRed'), classColor: "status_red"}, 
            {status: component.get('v.ColorGreen'), classColor: "status_green"}
        ];
        selectedCase.map(cs=>{  
		let date = new Date(cs.CreatedDate);
		let outputDate = `${months[date.getMonth()]} ${date.getDate()}, ${date.getFullYear()} at `;
		let outputTime = date.toLocaleString('en-US', { hour: 'numeric', minute: 'numeric', hour12: true });
        cs.CreatedDate = outputDate+outputTime.replace(" ","").toLowerCase();
        statuses.map(s => {
            if(cs.Status == s.status){
                cs.statusColor = s.classColor;
            }
        });
        });
    
        component.set("v.handledCase", selectedCase[0]);
    },
    closeModal : function (component, event, helper) {
        let modal    = component.find("modal");
        let backdrop = component.find("backdrop");
        $A.util.removeClass(modal, "slds-fade-in-open"); 
        $A.util.removeClass(backdrop, "slds-backdrop--open"); 
    },
    openModal : function (component, event, helper) {
        component.find('filesLoader').reloadList();
        let modal    = component.find("modal");
        let backdrop = component.find("backdrop");
        $A.util.addClass(modal, "slds-fade-in-open"); 
        $A.util.addClass(backdrop, "slds-backdrop--open");
    }, 


})