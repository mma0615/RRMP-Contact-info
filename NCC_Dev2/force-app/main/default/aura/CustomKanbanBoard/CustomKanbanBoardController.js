({
    doInit : function(component, event, helper) {
        helper.getRecordsSummary(component, event, helper, true, '');
    },

    doView : function(component, event, helper) {
        window.open('/' + event.target.id, '_blank');
    },

    allowDrop : function(component, event, helper) {
        event.preventDefault();
    },
    
    drag : function (component, event, helper) {
        event.dataTransfer.setData('text/plain', event.target.id);
    },
    
    drop : function (component, event, helper) {
        event.preventDefault();
        var data = event.dataTransfer.getData("text");
        var tar = event.target;

        if (tar.tagName.toUpperCase() === "DIV") {
            tar = tar.firstChild;
        } else if (tar.tagName.toUpperCase() !== "UL"){
            while(tar.tagName.toUpperCase() !== "UL"){
                tar = tar.parentElement;
            }
        }
            
        tar.insertBefore(document.getElementById(data), tar.firstChild);

        helper.changeStatus(component, helper, data, component.get("v.kanbanColumnFieldSource"), tar.getAttribute('data-pickVal'));
    },

    refetchResults : function(component, event, helper){
        helper.getResults(component, event, helper, false, false);
    },

    resetResults : function(component, event, helper){
        let conditions = component.get("v.cardFilterANDConditions");
        let recordTypeList = component.get("v.cardRecordTypeItemNumbersList");
        let selectedTabId = isNaN(component.get("v.selectedTabId")) ? 0 : parseInt(component.get("v.selectedTabId"));

        //remove record type filter then re-apply after all results have been re-fetched
        if (Object.keys(conditions).includes("RecordType.Name = ")){
            delete conditions["RecordType.Name = "];
        }

        const PREVIOUS_REC_TYPE = recordTypeList.length ? recordTypeList[selectedTabId].recordTypeName : '';
        helper.getRecordsSummary(component, event, helper, false, PREVIOUS_REC_TYPE);
    },

    handlePicklistData : function(component, event, helper){
        let data = event.getParam('picklistData');
        const PICKLIST_SOURCE_FIELD = component.get("v.kanbanColumnFieldSource");
        let picklistValues = [];
        let values = data.picklistFieldValues[PICKLIST_SOURCE_FIELD].values;

        for (let i = 0 ; i < values.length ; i++){

            let picklistValue = values[i];

            if (picklistValue && picklistValue.value) {
                picklistValues.push(picklistValue.value);
            }
        }

        //needs to have a blank array first, or else it throws an error
		component.set('v.picklistDetails', []);
        component.set('v.picklistDetails', picklistValues);
        
        let isInitial = component.get('v.isInitial');

        //lazy loading - query only records related to currently selected record type to optimize loading time
        if (!isInitial) {
            let conditions = component.get("v.cardFilterANDConditions");
            let recordTypeList = component.get("v.cardRecordTypeItemNumbersList");
            const SELECTED_RECORD_TYPE = component.get("v.selectedTabId");
            let recordTypeDetail = recordTypeList.find(recordType => recordType.recordTypeId === SELECTED_RECORD_TYPE);

            conditions["RecordType.Name = "] = recordTypeDetail.recordTypeName;
            conditions["RecordType.IsActive = "] = true;

            helper.getResults(component, event, helper);
        }

        component.set('v.isInitial', false);
    }
})