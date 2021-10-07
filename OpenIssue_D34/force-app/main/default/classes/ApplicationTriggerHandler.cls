public with sharing class ApplicationTriggerHandler extends TriggerHandler {
  public override void beforeInsert() {
    //ApplicationService.setApplicationStatus(Trigger.new); // Commenting out because it is incorrectly deeming applications as renewals
    ApplicationService.setLawfulPresenceStatus(Trigger.new);
   // ApplicationService.setPortalStatusMessage(Trigger.new);
  }
  public override void beforeUpdate() {
    ApplicationService.setLawfulPresenceStatus(Trigger.new);
    ApplicationService.calculateUnmetNeed((map<Id, Application__c>)Trigger.newMap);
   // ApplicationService.setPortalStatusMessage(Trigger.new);  
  }
  public override void afterUpdate() {
    ApplicationService.setContactCitizenship((map<Id, Application__c>)Trigger.newMap);
  }
  public override void afterInsert() {
  	ApplicationService.setContactCitizenship((map<Id, Application__c>)Trigger.newMap);
  }  
}