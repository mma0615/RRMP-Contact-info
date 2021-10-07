trigger EventTrigger on Event__c (before insert,before update) {

    CCEventTriggerHandler handler = new CCEventTriggerHandler();
    Apex_Trigger_Switch__c eventSwitch = Apex_Trigger_Switch__c.getInstance('EventTrigger');

    /* Before Insert */
    if(eventSwitch.Active__c){
        if(Trigger.isInsert  && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate  && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.new);
        }
    }

    
    
}