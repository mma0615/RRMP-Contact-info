trigger StudentTermTrigger on Student_Term__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new StudentTermTriggerHandler().run();
}