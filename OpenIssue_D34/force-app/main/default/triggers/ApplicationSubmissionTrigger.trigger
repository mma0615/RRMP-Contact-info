trigger ApplicationSubmissionTrigger on Application_Submission__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  new ApplicationSubmissionTriggerHandler().run();
}