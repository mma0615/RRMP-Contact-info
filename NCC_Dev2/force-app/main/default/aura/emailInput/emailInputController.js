({
    afterScriptsLoaded : function(cmp, event, helper){
        
    },
    
	handleInputChange : function(cmp, event, helper) {
        let inputValue = cmp.get('v.value');

        // if the user type something remove the validation message
        if(cmp.get('v.validationMessage')){
            cmp.set('v.validationMessage', '');
        }
        // console.log('Input Value >> ', inputValue);
        cmp.set('v.isValid', helper.validateEmail(inputValue));
	},
    
    handleKeyPress : function(cmp, event, helper){
        if (event.which == 13){
            helper.commit(cmp, event, helper);
        }   
    },
    
    handleClick : function(cmp, event, helper) {
		helper.commit(cmp, event, helper);
	},
    
    handleRemove : function(cmp, event, helper){
        const selected = event.getParams('item').name;
        // console.log('Selected Pill ', JSON.stringify(selected));
        cmp.set('v.emailList', _.filter(cmp.get('v.emailList'), function(item){
            return item !== selected;
        }));
        helper.dispatchCommitEvent(cmp);
    }
})