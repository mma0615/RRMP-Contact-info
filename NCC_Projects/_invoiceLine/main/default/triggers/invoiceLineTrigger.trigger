/**
 * invoiceLineTrigger
 * @author Minh Ma 
 * @date 02/28/2021
 * @description Invoice_Line__c trigger
 *
 * Update History:
 * 02/28/2021 - Initial Version
 */
trigger invoiceLineTrigger on Invoice_Line__c (before insert) 
{
    invoiceLineTriggerHandler handler = new invoiceLineTriggerHandler();
     
    if (trigger.isBefore )
    {
        if (trigger.isInsert )
            handler.onBeforeInsert( trigger.new );
    }
}