trigger SessionTrigger on Session__c (before insert, before update, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        SessionTriggerHandler.populateSessionDetails(Trigger.new,null,null,null);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        SessionTriggerHandler.populateSessionDetails(Trigger.new,Trigger.newmap,Trigger.old,trigger.oldmap);
    }
}