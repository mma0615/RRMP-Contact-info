trigger CommunicationTrigger on Communication__c (
    												after insert,
    												after update, 
    												before insert, 
    												before update) {
	if(trigger.isAfter && trigger.isInsert)
    {
    	CommunicationTriggerHelper.onAfterInsert(trigger.newMap);
    }
    if(trigger.isBefore && trigger.isInsert)
    {
    	CommunicationTriggerHelper.onBeforeInsert(trigger.newMap);
    }
    if(trigger.isAfter && trigger.isUpdate)
    {
    	CommunicationTriggerHelper.onAfterUpdate(trigger.newMap, trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate)
    {
    	CommunicationTriggerHelper.onBeforeUpdate(trigger.newMap, trigger.oldMap);
    }
}