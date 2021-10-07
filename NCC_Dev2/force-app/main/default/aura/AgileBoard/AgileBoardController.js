({
    doInit : function(component, event, helper) {
        helper.getProjectList(component, event, helper);
        helper.getPicklistValues(component, helper, "Project_Task__c", "Priority__c", "priorityOptions");
        component.set("v.searchFilterANDConditions", {"Is_Closed__c = " : "false"});
        component.set("v.searchFilterORConditions", {});

        /**
        * Boolean value is to flag that the field needs to be linkified.
        * If passed to controller, controller will get the Id for the field, especially if it's a reference field
        * Example: if you add Epic__r.Name = true in here, controller will also query Epic__c to linkify it later
        **/
        let fields = {};
        fields["Name"] = true;
        fields["Priority__c"] = false;
        fields["Is_Closed__c"] = false;
        fields["Title__c"] = false;
        fields["Assigned_To_Name__c"] = false;
        fields["Status__c"] = false;
        fields["PROD_Due_Date__c"] = false;
        fields["Feature__r.Name"] = false;
        fields["Functionality__r.Name"] = false;
        component.set("v.sourceFieldsMap", fields);
    },

    filterCards : function(component, event, helper) {
        let conditionsAND = component.get("v.searchFilterANDConditions");
        let conditionsOR = component.get("v.searchFilterORConditions");
        let filterText = component.get("v.filterByText");
        let epic = component.get("v.filterByEpicName");
        let project = component.get("v.filterByProject");
        let priority = component.get("v.filterByPriority");
        let showClosed = component.get("v.isShowClosedTasks");

        if (filterText){
            conditionsOR["Assigned_To_Name__c LIKE "] = "%" + filterText + "%";
            conditionsOR["Title__c LIKE "] = "%" + filterText + "%";
            conditionsOR["Name LIKE "] = "%" + filterText + "%";
            conditionsOR["Feature__r.Name LIKE "] = "%" + filterText + "%";
            conditionsOR["Functionality__r.Name LIKE "] = "%" + filterText + "%";

            component.set("v.searchFilterORConditions", conditionsOR);
        } else {
            component.set("v.searchFilterORConditions", {});
        }

        if (project){
            conditionsAND["Project__c = "] = project;
        } else {
            delete conditionsAND["Project__c = "];
        }

        if (epic){
            conditionsAND["Epic__c = "] = (epic == "Unassigned") ? "" : epic;
        } else {
            delete conditionsAND["Epic__c = "];
        }

        if (priority){
            conditionsAND["Priority__c = "] = priority;
        } else {
            delete conditionsAND["Priority__c = "];
        }

        if (showClosed === false){
            conditionsAND["Is_Closed__c = "] = "false";
        } else {
            delete conditionsAND["Is_Closed__c = "];
        }

        component.set("v.searchFilterANDConditions", Object.keys(conditionsAND).length === 0 ? {} : conditionsAND);

        let kanbanBoard = component.find("customKanban");
        kanbanBoard.resetResults();
    },

    fetchEpicOptions : function(component, event, helper){
        component.set("v.epicOptions", []);
        component.set("v.filterByEpicName", "");
        let val = event.getParam("value");

        if (val) {
            helper.getEpicList(component, event, helper);
        } else if (val === ""){
            let filterCardAction = component.get('c.filterCards');
            filterCardAction.setParams({
                component,
                event,
                helper
            });
            $A.enqueueAction(filterCardAction);
        }
    },

    changeSorting : function(component, event, helper) {
        let kanbanBoard = component.find("customKanban");
        kanbanBoard.refetchResults();
    }
})