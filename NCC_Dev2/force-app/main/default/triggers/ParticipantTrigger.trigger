trigger ParticipantTrigger on Participant__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    Apex_Trigger_Switch__c switchh = Apex_Trigger_Switch__c.getInstance('ParticipantTrigger');
    if(switchh != null && !switchh.Active__c){
        return;
    }    
    if(Trigger.isAfter){
        if(!ParticipantTriggerHandler.firstCall){
            ParticipantTriggerHandler.firstCall = true;
            if(Trigger.isInsert){
                ParticipantTriggerHandler.onAfterInsert(Trigger.new,Trigger.newMap,Trigger.old,Trigger.oldMap);
            }
            else if(Trigger.isUpdate){
                ParticipantTriggerHandler.onAfterUpdate(Trigger.new,Trigger.newMap,Trigger.old,Trigger.oldMap);
            }
        }
    }
}