/**
 * leadTrigger
 * @author Minh Ma 
 * @date 09/02/2021
 * 
 * Update History:
 * 09/02/2021 - Initial Version
 */
trigger leadTrigger on Lead (after update) 
{
    leadTriggerHandler handler = new leadTriggerHandler();
    
    /*
    if( trigger.isBefore )
    {
        if( trigger.isInsert )
            handler.onBeforeInsert( trigger.new );
        else if( trigger.isUpdate )
            handler.onBeforeUpdate( trigger.new, trigger.oldMap );
    }
    */
     
    if( trigger.isAfter )
    {
        /*
        if( trigger.isInsert )
            handler.onAfterInsert( trigger.new );
       */
        if( trigger.isUpdate )
            handler.onAfterUpdate( trigger.new, trigger.oldMap );
    }
}