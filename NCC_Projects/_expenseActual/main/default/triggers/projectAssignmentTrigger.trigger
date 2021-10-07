/**
 * projectAssignmentHandler
 * @author Minh Ma 
 * @date 02/12/2021
 * @description Krow__Project_Assignment__c trigger
 *
 * Update History:
 * 02/12/2021 - Initial Version
 */
trigger projectAssignmentTrigger on Krow__Project_Assignment__c (after insert, after update, 
    after delete, after undelete)  
{

    Apex_Trigger_Switch__c switchh = Apex_Trigger_Switch__c.getInstance('projectAssignmentTrigger');
    if(switchh != null && !switchh.Active__c)
    {
        return;
    }

    projectAssignmentHandler handler = new projectAssignmentHandler();
     
    if (trigger.isAfter )
    {
        if (trigger.isInsert )
            handler.onAfterInsert( trigger.new );
        else if (trigger.isUpdate )
            handler.onAfterUpdate( trigger.new, trigger.oldMap );
        else if (trigger.isDelete )
            handler.onAfterDelete( trigger.oldMap );
        else if (trigger.isUndelete )
            handler.onAfterUndelete( trigger.new );
    }

}