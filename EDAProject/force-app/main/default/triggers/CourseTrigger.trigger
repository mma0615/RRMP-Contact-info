/**
 * CourseTrigger
 * @author Capgemini GS / Minh Ma (minh.ma@capgemini-gs.com)
 * @date 01/07/2020
 * @description A trigger to execute functionalities for before insert/update and after insert/update
 * on Course records.
 *
 * Update History:
 * 01/07/2021 - Initial Version
 */
trigger CourseTrigger on hed__Course__c (before insert, before update) {

    CourseHandler handler = new CourseHandler();
    
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