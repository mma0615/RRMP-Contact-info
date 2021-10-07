trigger EncounterTrigger on Encounter__c  (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    if(Trigger.isBefore && Trigger.isInsert){
        EncounterTriggerHandler.onBeforeInsert(Trigger.new,Trigger.newMap,Trigger.old,Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        EncounterTriggerHandler.onAfterInsert(Trigger.new,Trigger.newMap,Trigger.old,Trigger.oldMap);
    }

}