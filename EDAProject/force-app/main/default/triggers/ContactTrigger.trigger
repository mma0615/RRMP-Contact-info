/**
 * ContactTrigger
 * @author Capgemini GS / Minh Ma (minh.ma@capgemini-gs.com)
 * @date 01/07/2020
 * @description A trigger to execute functionalities for before insert/update and after insert/update
 * on Contact records.
 *
 * Update History:
 * 01/07/2021 - Initial Version
 */
trigger ContactTrigger on Contact (before insert) {

    ContactHandler handler = new ContactHandler();
    
    if( trigger.isBefore )
    {
        if( trigger.isInsert )
            handler.onBeforeInsert( trigger.new );
        else if( trigger.isUpdate )
            handler.onBeforeUpdate( trigger.new, trigger.oldMap );
    }
     
    if( trigger.isAfter )
    {
        if( trigger.isInsert )
            handler.onAfterInsert( trigger.new );
        else if( trigger.isUpdate )
            handler.onAfterUpdate( trigger.new, trigger.oldMap );
    }

}