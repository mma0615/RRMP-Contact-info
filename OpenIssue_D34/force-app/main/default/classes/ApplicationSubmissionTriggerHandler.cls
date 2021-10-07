public with sharing class ApplicationSubmissionTriggerHandler extends TriggerHandler {
  public override void afterInsert() {
    ApplicationSubmissionService.handleSubmissionApproval(Trigger.new, null);
  }

  public override void afterUpdate() {
    ApplicationSubmissionService.handleSubmissionApproval(Trigger.new, (Map<Id, Application_Submission__c>)Trigger.oldMap);
  }
}