trigger ContactTrigger on Contact (before insert, before update) {

    if (Trigger.isBefore) {
        if(Trigger.isInsert) {
            ContactTriggerHandler.setUpNavigatorFields(trigger.new); 
        }      
    }
    if (Trigger.isBefore) {
        if(Trigger.isUpdate) {
            ContactTriggerHandler.setUpNavigatorFields(trigger.new); 
            ContactTriggerHandler.updatePageUrl(trigger.newMap, trigger.oldMap); 
        }      
    }
}