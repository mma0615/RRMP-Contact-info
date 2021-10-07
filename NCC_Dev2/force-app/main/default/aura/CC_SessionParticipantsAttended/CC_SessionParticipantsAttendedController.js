({
    doInit : function(component, event, helper) {
        component.set("v.No_participants_to_display", $A.get("$Label.c.No_participants_to_display"));
        component.set("v.Btn_MarkAsAttended", $A.get("$Label.c.Btn_MarkAsAttended"));

        component.set("v.columns",[
            {label:"Session Participant Number", fieldName:"Name",type:"text"},
            {label:"Contact", fieldName:"Contact_Name__c",type:"text"},
            {label:"Session Start Date", fieldName:"Session_Start_Date__c",type:"date"},
            {label:"Status", fieldName:"Status__c",type:"text"},
        ]);

        var action = component.get("c.getSessionParticipants");
        action.setParams({ recordId : component.get("v.recordId")});
        
        action.setCallback(this,function(response){
            component.set("v.participants",response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    handleMarkAsAttendedClick : function(component, event, helper) {
        console.log(component.get("v.selectedParticipants"));

        if(component.get("v.selectedParticipants").length == 0) {
            helper.showToast(component, event, $A.get("$Label.c.AttendedWarningMessage") ,'ERROR','error');
        } else {
            var action = component.get("c.markSessionParticipantsToAttended");

            action.setParams({ recordId : component.get("v.recordId"), selectedParticipants : component.get("v.selectedParticipants")});        
            action.setCallback(this,function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.showToast(component, event, $A.get("$Label.c.AttendedSuccessMessage") ,'SUCCESS','success');
                    component.set("v.participants",response.getReturnValue());
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showToast(component, event, errors[0].message ,'ERROR','error');
                        }
                    } else {
                        helper.showToast(component, event, "Unknown error" ,'ERROR','error');
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    updateSelectedRecord : function(component,event,helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedParticipants', selectedRows);
        component.set('v.selectedRowsCount', selectedRows.length);
    }
})