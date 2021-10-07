({   
    validateEmail : function (email) {
    	const re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    	return re.test(String(email).toLowerCase());
    },
    
    commit : function(cmp, event, helper){
        const limit = cmp.get('v.limit');
        let inputValue = cmp.get('v.value').toLowerCase();
        let emailList = cmp.get('v.emailList');
        
        if(!helper.validateEmail(inputValue)){
            cmp.set('v.validationMessage', 'You have entered an invalid format.');
        }
        else if(emailList.length >= limit){
            cmp.set('v.validationMessage', 'You have reached the maximum emails entered.');
        }
        else if(emailList.includes(inputValue)){
            cmp.set('v.validationMessage', 'Email already exists.');
        }
        else{
            // workaround for validation message to be cleared.
            cmp.set('v.rerender', false);
            cmp.set('v.rerender', true);
            
            //pushing value to email list and some clean up.
            cmp.set('v.validationMessage', '');
            cmp.set('v.value', '');
            cmp.set('v.isValid', false);
            emailList.push(inputValue);
            cmp.set('v.emailList', emailList);

            helper.dispatchCommitEvent(cmp, event, helper);
        }
    },

    dispatchCommitEvent : function(cmp){
        let commitEvent = cmp.getEvent('emailInputCommit');
        commitEvent.setParams({ name : cmp.get('v.name'), emailList : cmp.get('v.emailList') });
        commitEvent.fire();
    }
})