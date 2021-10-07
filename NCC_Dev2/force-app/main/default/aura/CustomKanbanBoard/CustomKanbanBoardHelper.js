({
    getRecordsSummary : function(component, event, helper, isInitial, originalRecordTypeFilter) {

        component.set("v.isLoading", true);

        //component is called twice. only call action if this attribute already has a value
        if (component.get("v.cardSourceObjectFields")){
            
            if (component.get("v.hasRecordTypeFilter")){
                let action = component.get("c.getKanbanDetailsPerRecordType");
                
                action.setParams({
                    "objectName" : component.get("v.cardSourceObjectName"),
                    "filterANDConditions" : JSON.stringify(component.get("v.cardFilterANDConditions")),
                    "filterORConditions" : JSON.stringify(component.get("v.cardFilterORConditions"))
                });

                action.setCallback(this, function(response){
                    let state = response.getState();

                    if (state === "SUCCESS") {
                        let results = JSON.parse(response.getReturnValue());
                        let recordTypeList = [];
                        let totalItems = 0;
                        let recordTypeCondition = component.get("v.cardFilterANDConditions");
                        let firstRecordTypeId;
                        const RECORD_TYPE_CONDITION = "RecordType.Name = ";

                        //combine the record type and the number of tickets beside it
                        for (let recordType in results) {
                            const TOTAL_ITEMS = results[recordType];
                            const RECORD_TYPE_DETAILS = recordType.split("|");
                            const RECORD_TYPE_NAME = RECORD_TYPE_DETAILS[0];
                            const RECORD_TYPE_ID = RECORD_TYPE_DETAILS[1];
                            totalItems += TOTAL_ITEMS;
                            recordTypeList.push({"recordTypeName" : RECORD_TYPE_NAME, "total" : TOTAL_ITEMS, "recordTypeId" : RECORD_TYPE_ID});

                            if (!Object.keys(recordTypeCondition).includes(RECORD_TYPE_CONDITION)){
                                recordTypeCondition[RECORD_TYPE_CONDITION] = RECORD_TYPE_NAME;
                            } else if (originalRecordTypeFilter) {
                                recordTypeCondition[RECORD_TYPE_CONDITION] = originalRecordTypeFilter;
                            }

                            if (!firstRecordTypeId){
                                firstRecordTypeId = RECORD_TYPE_ID;
                            }
                        }

                        helper.getResultTotalNumber(component, totalItems, true);
                        helper.setRecordTypeItemNumbers(component, helper, isInitial, recordTypeList);
                        
                        component.set("v.selectedTabId", firstRecordTypeId);
                        component.set("v.cardFilterANDConditions", recordTypeCondition);

                        //get all results related to record type
                        if (results){
                            helper.getResults(component, event, helper, true, false);
                        }
                        
                    } else {
                        helper.handleErrors(response.getError());

                        component.set("v.isLoading", false);
                    }
                });

                $A.enqueueAction(action);

            } else {
                helper.getResults(component, event, helper, false, false);
            }
        }
    },

    setRecordTypeItemNumbers : function(component, helper, isInitial, recordTypeList) {
        
        if (isInitial){
            component.set("v.cardRecordTypeItemNumbersList", helper.sortRecordTypes(recordTypeList));

        } else {
            let existingRecordTypes = component.get("v.cardRecordTypeItemNumbersList");
            let foundRecordTypes = [];

            for (let i = 0 ; i < existingRecordTypes.length ; i++){
                let existingRecordType = existingRecordTypes[i];

                for (let j = 0 ; j < recordTypeList.length ; j++){
                    let recordType = recordTypeList[j];

                    if (existingRecordType.recordTypeName === recordType.recordTypeName){
                        existingRecordType.total = recordType.total;
                        foundRecordTypes.push(existingRecordType.recordTypeName);
                        break;
                    }
                }
            }

            //zero-out total of other record types not found within results
            for (let i = 0 ; i < existingRecordTypes.length ; i++){
                let existingRecordType = existingRecordTypes[i];

                if(!foundRecordTypes.includes(existingRecordType.recordTypeName)){
                    existingRecordType.total = 0;
                }
            }

            //force to recognize that there was a change in the object attributes, else it will not reflect in the UI
            component.set("v.cardRecordTypeItemNumbersList", []); 
            component.set("v.cardRecordTypeItemNumbersList", helper.sortRecordTypes(existingRecordTypes));
        }
    },

    sortRecordTypes : function(recordTypeArray){
        const STATUS_ORDER = {
            'story': 0,
            'feature': 1,
            'functionality': 2,
            'dev': 3,
            'bug': 4,
            'qa': 5
        };
        
        return recordTypeArray.sort(function(a, b) {
            let status_A = STATUS_ORDER[a.recordTypeName.toLowerCase()];
            let status_B = STATUS_ORDER[b.recordTypeName.toLowerCase()];
            return status_A === status_B ? 0 : (status_A < status_B ? -1 : 1);
        });
    },
    
    getResults : function(component, event, helper) {
        component.set("v.isLoading", true);

        var action = component.get("c.getKanbanDetails");

        action.setParams({
            "objectName" : component.get("v.cardSourceObjectName"),
            "objectFields" : JSON.stringify(component.get("v.cardSourceObjectFields")),
            "columnFieldSource" : component.get("v.kanbanColumnFieldSource"),
            "filterANDConditions" : JSON.stringify(component.get("v.cardFilterANDConditions")),
            "filterORConditions" : JSON.stringify(component.get("v.cardFilterORConditions")),
            "sortByField" : component.get("v.cardSortByField")
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                let results = response.getReturnValue();

                component.set("v.kanbanData", results);
                component.set("v.isLoading", false);

                //only change total items label if there is no record type filter
                helper.getResultTotalNumber(component, results.records.length, !component.get("v.hasRecordTypeFilter"));
                
            } else {
                helper.handleErrors(response.getError());
            }

            component.set("v.isLoading", false);
        });

        $A.enqueueAction(action);
    },

    getResultTotalNumber : function(component, totalNumber, hasRecordTypeFilter){
        //only change total items label if there is no record type filter
        if (hasRecordTypeFilter){
            component.set("v.numberOfItems", totalNumber + " " + (totalNumber > 1 ? "items" : "item"));
        }
    },

	changeStatus : function(component, helper, recordId, picklistField, picklistValue) {

		let action = component.get("c.updateStatus");
        action.setParams({
            "recordId" : recordId,
            "kanbanField" : picklistField,
            "kanbanNewValue" : picklistValue
        });

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {
                helper.handleSuccess('Status has been successfully updated');
            } else {
                helper.handleErrors(response.getError());
            }
        });

        $A.enqueueAction(action);
	},

    handleErrors : function(errors) {
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error",
            type: "error"
        };

        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }

        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },

    handleSuccess : function(successMessage) {
        // Configure error toast
        let toastParams = {
            title: "Success",
            message: successMessage,
            type: "success"
        };

        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})