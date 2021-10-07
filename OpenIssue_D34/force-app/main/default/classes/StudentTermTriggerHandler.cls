public with sharing class StudentTermTriggerHandler extends TriggerHandler {
  public override void beforeInsert() {
    StudentTermService.setStartAndEndDatesForStudentTerm(Trigger.new);
    StudentTermService.setCurrentStudentTerms(Trigger.new);
   // StudentTermService.setPortalStatusMessage(Trigger.new);
  }
  public override void afterInsert() {
    StudentTermService.setCurrentStudentCollegeId(Trigger.new);
    // Daniel and Cook are now tracked in the Student Term.
    // Turned off in this handler and StudentTermScholarshipTriggerHandler - Kelly, Raptek, 8/25/16  
    //ScholarshipService.handleDanielsAndCookScholarships(Trigger.new, null, true);
    //StudentTermService.calculateUnmetNeed(Trigger.new);
  }
  public override void beforeUpdate() {
    StudentTermService.setCurrentStudentTerms(Trigger.new);
    //StudentTermService.setPortalStatusMessage(Trigger.new);
   //StudentScholarshipCalculator.calculateScholarshipAmount(Trigger.new);
   // StudentScholarshipCalculator_2017.calculateScholarshipAmount(Trigger.new);
   // StudentScholarshipCalculator_2018.calculateScholarshipAmount(Trigger.new);
   // StudentScholarshipCalculator_2019.calculateScholarshipAmount(Trigger.new);
    StudentScholarshipCalculator_2020.calculateScholarshipAmount(Trigger.new);
    StudentScholarshipCalculator_2021.calculateScholarshipAmount(Trigger.new);
  }
  public override void afterUpdate() {
    StudentTermService.setCurrentStudentCollegeId(Trigger.new);
    // Daniel and Cook are now tracked in the Student Term.   
    //ScholarshipService.handleDanielsAndCookScholarships(Trigger.new, (Map<Id, Student_Term__c>)Trigger.oldMap, false);
    StudentTermService.calculateUnmetNeed(Trigger.new);
  }
}