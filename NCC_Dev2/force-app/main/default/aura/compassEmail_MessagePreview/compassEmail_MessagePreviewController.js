({
	doInit : function(cmp, event, helper) {
        let orgWideEmailAddressRecord = cmp.get('v.orgWideEmailAddressRecord');
        if(orgWideEmailAddressRecord){
            cmp.set('v.selectedSender', orgWideEmailAddressRecord.Id);
        }
	},
    
    afterScriptsLoaded : function(cmp, event, helper){
        helper.getOrgWideEmailAddress(cmp, event, helper);
        helper.getEmailTemplates(cmp, event, helper);

	},
    
    handleSenderChange : function(cmp, event, helper){
        let selectedOrgWideEmail = _.find(cmp.get('v.orgWideEmailList'), function(item){
            return item.Id === event.getParam('value');
        });
        cmp.set('v.orgWideEmailAddressRecord', selectedOrgWideEmail);
        cmp.set('v.selectedSender', selectedOrgWideEmail.Id)
        // console.log('Selected OrgWideEmailAddress > ', selectedOrgWideEmail);
    },
    
    handleTemplateChange : function(cmp, event, helper){
        let selectedTemplateId = event.getParam('value');
        cmp.set('v.emailTemplateId', selectedTemplateId);
        const emailTemplateList = cmp.get('v.emailTemplateList');
        let selectedTemplate = _.find(emailTemplateList, function(item){
            return item.Id === selectedTemplateId;
        });
        if(selectedTemplate.HtmlValue){
        	cmp.set('v.emailBody',selectedTemplate.HtmlValue);
        }else{
        	cmp.set('v.emailBody', selectedTemplate.Body.replace(/(?:\r\n|\n)/g, '<br/>'));
        }
        cmp.set('v.subject', selectedTemplate.Subject);
    },
    
    handleSubjectChange : function(cmp, event, helper){
        cmp.set('v.subject', event.getParam('value'));
    },
})