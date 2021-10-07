/**
 * invoiceTrigger
 * @author Minh Ma 
 * @date 02/26/2021
 * @description Krow__Invoice__c trigger
 *
 * Update History:
 * 02/26/2021 - Initial Version
 */
trigger invoiceTrigger on Krow__Invoice__c (after insert, after update) 
{
    invoiceTriggerHandler handler = new invoiceTriggerHandler();
     
    if (trigger.isAfter )
    {
        if (trigger.isInsert )
            handler.onAfterInsert( trigger.new );
        else if (trigger.isUpdate )
            handler.onAfterUpdate( trigger.new, trigger.oldMap );
    }

}