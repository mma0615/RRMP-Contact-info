({
	doInit : function(cmp, event, helper) {
		//this.getOrgWideEmailAddress();
		const action = cmp.get('c.sendMassEmail');
        action.setParams({
            'recordId' :  'a5J030000004cHBEAY',
            'orgWideEmailId' : '0D2030000004CRvCAM',
            'contactRecipientIds' : ['0030300000HB6ihAAD', '0030300000Gbm3oAAB'],
            'ccRecipients' : "jlabnao@ulapp.co",
            'bccRecipients' : null,
            'subject' : 'Hard Code CC Test2',
            'emailBody' : 'Just a Test',
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS'){
                console.log('Apex Successfully Invoked!');
                const returnValue = response.getReturnValue();
                if(returnValue){
                    console.log('Error!!! ', returnValue);
                }
            }
            else{
                console.log('Error!!! ', response.getError());
            }
        })
        $A.enqueueAction(action);
	},
    
    getOrgWideEmailAddress : function(cmp, event, helper) {
		const action = cmp.get("c.getOrgWideEmailAddress");
        action.setCallback(this, function(response) {
            const state = response.getState();
            if(state === "SUCCESS"){
                const returnValue = response.getReturnValue();
                let options = _.map(returnValue, function(item){
                    return { label : item.DisplayName + ' <' + item.Address + '>', value : item.Id};
                });
                // console.log('options', options);
                // console.log('returnValue', returnValue);
                //cmp.set('v.senderOptions', options);
                cmp.set('v.orgWideEmailAddressRecord', returnValue[0]);
            }else{
                helper.logError(response.getError());
            }
        });
        
        $A.enqueueAction(action);
	},
})