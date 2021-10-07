({
	getSearchResults : function(cmp, event, helper) {
        const lwcLookup = cmp.find('lookup').getElement();
        let keyword = event.getParam('searchTerm');
        let idList = event.getParam('selectedIds');
        const action = cmp.get("c.searchContactRecipient");
        action.setParams({ searchTerm : keyword, selectedIds : idList });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === "SUCCESS"){
                const returnValue = response.getReturnValue();
                // get a reference of the LWC lookup element and use the lookup's setSearchResults
                // to set Search Results based on the keyword
                lwcLookup.setSearchResults(returnValue);
            }else{
                helper.showToastError(helper.logError(response.getError()));
            }
        });
        
        $A.enqueueAction(action);	
    },
    // {"icon":"standard:contact","id":"0030300000GY6rtAAD","sObjectType":"Contact","subtitle":"eangelo@ulapp.com","title":"EdpaulTest3 EPTest","titleFormatted":"Edpaul<strong>Test</strong>3 EP<strong>Test</strong>","subtitleFormatted":"eangelo@ulapp.com"}
    getJourneyParticipants : function(cmp, event, helper){
        const recordId = cmp.get('v.recordId');
        const action = cmp.get("c.getJourneyParticipants");
        action.setParams({ recordId });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === "SUCCESS"){
                const returnValue = response.getReturnValue();
                cmp.set('v.initialSelection', _.map(returnValue, function(item){
                          return { icon: "standard:contact", 
                          		   id: item.Contact__c, 
                          		   sObjectType: "Contact", 
                                   subtitle: item.Contact__r.Name,
                                   title: item.Contact__r.Email };
                }));
                //console.log('Initial Selection', JSON.stringify(cmp.get('v.initialSelection')));
                cmp.set('v.contactIdList', _.map(cmp.get('v.initialSelection'), function(item){ return item.id; })); 
                cmp.set('v.isLoading', false);
            }else{
                helper.showToastError(helper.logError(response.getError()));
            }
        });
        
        $A.enqueueAction(action);	
    },

    intializeSelectedRecipients : function(cmp, event, helper){
        const initialLookupIds = cmp.get('v.contactIdList')
        const action = cmp.get("c.getLookupResultsById");
        action.setParams({ initialLookupIds });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === "SUCCESS"){
                const returnValue = response.getReturnValue();
                cmp.set('v.initialSelection', returnValue);
                //console.log('Initial Selection', JSON.stringify(cmp.get('v.initialSelection')));
                cmp.set('v.isLoading', false);
            }else{
                helper.showToastError(helper.logError(response.getError()));
            }
        });
        
        $A.enqueueAction(action);	
    },
    
    logError : function(errors){
        if (errors) {
            if (errors[0] && errors[0].message) {
                // log the error passed in to AuraHandledException
                console.log("Error message: " + 
                errors[0].message);
            }
        } else {
        	console.log("Unknown error");
        }
	},

    showToastError : function(error) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type" : "error",
            "message": error
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
	}
    
})