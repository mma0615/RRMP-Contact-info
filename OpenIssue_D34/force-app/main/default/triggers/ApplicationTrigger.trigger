trigger ApplicationTrigger on Application__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new ApplicationTriggerHandler().run();
}