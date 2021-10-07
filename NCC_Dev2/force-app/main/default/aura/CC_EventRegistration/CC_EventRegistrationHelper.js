({
    getContactInformation : function(component, event) {
        
        const queryString = decodeURIComponent(window.location.search);

        try {
            emailstr = (queryString.split('email=')[1]).split('&')[0];
        }
        catch(err) {
            emailstr = '';
        }
        
        var action2 = component.get("c.getContactInfo");
        
        action2.setParams({ 
            emailstr : emailstr
        });
        
        action2.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();
                
                component.set('v.FirstName', resultEvent.FirstName);
                component.set('v.LastName', resultEvent.LastName);
                component.set('v.Email', resultEvent.Email);
                component.set('v.Company', resultEvent.Department);
            }
        });
        
        $A.enqueueAction(action2);
        
    },

    checkFieldsValidityAndGetInputValues : function(component) {
        const INPUT_FIELDS = component.get("v.dynamicFields");
        let inputFieldValues = {};
        let formFieldsAllValid = true;
        let result = {};

        //get values and check for required fields if it has value
        for (let i = 0 ; i < INPUT_FIELDS.length ; i++){
            const INPUT_VALUE = INPUT_FIELDS[i];

            //store field values
            if (INPUT_VALUE.Field.inputValue.length > 0) {
                inputFieldValues[INPUT_VALUE.Field.key] = INPUT_VALUE.Field.inputValue;
            
            //check if the field with no value is required
            } else if (INPUT_VALUE.Field.required){
                let fieldValidity = component.find(INPUT_VALUE.Field.key).reduce(function (validSoFar, inputCmp) {
                                        inputCmp.reportValidity();
                                        return validSoFar && inputCmp.checkValidity();
                                    }, true);
                
                if (!fieldValidity) {
                    formFieldsAllValid = false;
                }
            }
        }
        
        result["inputs"] = inputFieldValues;
        result["validity"] = formFieldsAllValid;

        return result;
    },

    checkSelectedSessionsAndReturnSelectedSessions : function(component) {
        let sessionIdList = [];
        const BOX_PACK_FIELDS = component.find("boxPack");

        //check sessions selected
        if(! Array.isArray(BOX_PACK_FIELDS)){
            if (BOX_PACK_FIELDS.get("v.value")) {
                sessionIdList.push(BOX_PACK_FIELDS.get("v.text"));
            }
        } else {
            for (let i = 0; i < BOX_PACK_FIELDS.length; i++) {
                if (BOX_PACK_FIELDS[i].get("v.value")) {
                    sessionIdList.push(BOX_PACK_FIELDS[i].get("v.text"));
                }
            }
        }

        return sessionIdList;
    }
})