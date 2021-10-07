public with sharing class AppealTriggerHandler extends TriggerHandler {
  public override void beforeInsert() {
    AppealService.setStudentForAppeal(Trigger.new);
  }
}