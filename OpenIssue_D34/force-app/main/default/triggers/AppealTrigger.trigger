trigger AppealTrigger on Appeal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new AppealTriggerHandler().run();
}