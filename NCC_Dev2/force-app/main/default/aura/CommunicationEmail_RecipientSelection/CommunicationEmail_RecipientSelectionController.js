({
	doInit : function(cmp, event, helper) {
        //console.log('v.ccRecipients', cmp.get('v.ccRecipients'));
        //console.log('v.bccRecipients', cmp.get('v.bccRecipients'));

        helper.getCheckIfRecordIsSurvey(cmp, event, helper);
	},
    // using afterScriptsLoaded instead of doInit to make sure that lodash is loaded before using it.
    afterScriptsLoaded : function(cmp, event, helper){
        if(!cmp.get('v.contactIdList').length){
        	helper.getJourneyParticipants(cmp, event, helper, '');
        }
        else {
            helper.intializeSelectedRecipients(cmp, event, helper);
        }
	},

    handleContactSearch : function(cmp, event, helper){
		helper.getSearchResults(cmp, event, helper);
	},
    
    handleContactSelect : function(cmp, event, helper){
        try{
            const lookupElement = cmp.find('lookup').getElement();
            const selection = lookupElement.getSelection();
            cmp.set('v.initialSelection', selection);
            cmp.set('v.contactIdList', _.map(selection, function(item){ return item.id; })); 

        } catch(e) {
            console.log('Error', e);
        }

	},
    
    handleRemoveRecipient : function(cmp, event, helper){
        const selectedId = event.currentTarget.dataset.contactid;
        let contactRecipientsToBeRemoved = cmp.get('v.contactRecipientsToBeRemoved');
        contactRecipientsToBeRemoved.push(selectedId);
        cmp.set('v.contactRecipientsToBeRemoved', contactRecipientsToBeRemoved);
        cmp.set('v.initialSelection', _.filter(cmp.get('v.initialSelection'), function(item){
            return item.id !== selectedId
        }));
        // using contactIdList attribute as a reference for removing a selected recipient
        cmp.set('v.contactIdList', _.filter(cmp.get('v.contactIdList'), function(item){
            return item !== selectedId;
        }));
    },
    
    handleRecipientsChange : function(cmp, event, helper){
        const fieldName = event.getParam('name');
        const emailList = event.getParam('emailList');
        if(fieldName === 'cc'){
            cmp.set('v.ccRecipients', emailList);
            //console.log('ccRecipients', emailList);
        }
        else if(fieldName === 'bcc'){
            cmp.set('v.bccRecipients', emailList);
            //console.log('bccRecipients', emailList);
        }
    },

    handleParticipantChange : function(component, event, helper){
        let participantStatus = component.get("v.participantStatus");
        helper.getJourneyParticipants(component, event, helper, participantStatus);
    }
})