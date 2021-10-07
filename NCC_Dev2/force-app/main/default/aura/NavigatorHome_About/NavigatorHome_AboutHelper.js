({
    initializeAttributes : function(component, event, helper) {
        let url_strings = document.location.href.split('?');
        const urlParams = new URLSearchParams(url_strings[1]);
        const navigatorId = urlParams.get('id');
        const sectionName = 'About';
        const action = component.get('c.getSectionAttributes');
        action.setParams({ navigatorId, sectionName });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS'){
                try{
                    let sectionAttributes = response.getReturnValue();
                    let sectionAttrList = [];
                    if(sectionAttributes.length){
                        sectionAttributes.forEach(function(attr){
                            if(attr.Type__c === 'Image'){
                                attr.Value__c = attr.Value__c.replace('<p>', '');
                                attr.Value__c = unescape(attr.Value__c.replace('</p>', '')).replace(/&amp;/g, '&');
                                sectionAttrList.push(attr);
                            }
                            else{
                                sectionAttrList.push(attr);
                            }
                        });
                        component.set('v.sectionAttributes', sectionAttrList)
                    }
                    else{
                        console.error('NavigatorHome_About: No configurations available');
                    }
                }
                catch(e){
                    console.log(e.message);
                }
            }
            else{
                helper.showToastError(helper.logError(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
      
    showToastError : function(message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type" : "error",
            "message": message
        });
        toastEvent.fire();
    },

    logError : function(errors){
        if (errors) {
            if (errors[0] && errors[0].message) {
                // log the error passed in to AuraHandledException
                let errorMessage = "Error message: " + errors[0].message
                console.log(errorMessage);
                return errorMessage;
            }
            else{
                console.log("Unknown error", JSON.stringify(errors));
                return "Unknown error", JSON.stringify(errors);
            }
        } else {
        	console.log("Unknown error", JSON.stringify(errors));
            return "Unknown error", JSON.stringify(errors);
        }
	},
})