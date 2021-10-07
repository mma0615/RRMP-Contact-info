({
	doInit : function(component, event, helper) {
		helper.getAvailableFields(component, event, helper);
	},
    
    handleRegistrationForm : function(component, event, helper){
        helper.saveRegistrationForm(component, event, helper);
    },
    
    handleEdit : function(component, event, helper){
        component.set("v.isReadOnly" , false);
    }, 

    handleCancel : function(component, event, helper){
        component.set("v.isReadOnly" , true);
        component.set("v.registrationFields", component.get("v.registrationFieldsCopy"));
    },

    checkAllFields : function(component, event, helper){
        let isChecked = event.getSource().get("v.checked");
        let checkBoxName = event.getSource().getLocalId();
        let resultList = component.get("v.registrationFields");
      
        for (let i = 0 ; i < resultList.length ; i++){
            if (checkBoxName == "selectAllFieldCheckbox"){
                resultList[i].active = isChecked;
            } else {
                resultList[i].required = isChecked;
            }
        }

        component.set("v.registrationFields", resultList);
    },

    checkSelectAllAndSetRequired : function(component, event, helper){
        let resultList = component.get("v.registrationFields");
        let isSelectAll = true;
        let isRequiredAll = true;

        for (let i = 0 ; i < resultList.length ; i++){
            if (!resultList[i].active){
                isSelectAll = false;
                resultList[i].required = false;
                isRequiredAll = false;
            }

            if(!resultList[i].required){
                isRequiredAll = false;
            }
        }

        component.set("v.selectAll", isSelectAll);
        component.set("v.requiredAll", isRequiredAll);
        component.set("v.registrationFields", resultList);
    }, 

    checkRequiredAll : function(component, event, helper){
        let resultList = component.get("v.registrationFields");
        let isRequiredAll = true;

        for (let i = 0 ; i < resultList.length ; i++){
            if(!resultList[i].required){
                isRequiredAll = false;
            }
        }

        component.set("v.requiredAll", isRequiredAll);
    }
})