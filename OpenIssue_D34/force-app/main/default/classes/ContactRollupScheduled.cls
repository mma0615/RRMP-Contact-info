global class ContactRollupScheduled implements Database.Batchable<sObject>, Schedulable {
  public static final String CRON_EXP = '0 0 0/1 1/1 * ? *';

  global Database.QueryLocator start(Database.BatchableContext bc) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    return Database.getQueryLocator([SELECT Id,cohort__r.name,cohort__c 
                                     FROM Contact
                                     WHERE RecordTypeId=:stRT]);
  }

  global void execute(Database.BatchableContext bc, List<Contact> contacts) {
    contacts = StudentTermPaymentService.setRollupPaymentInformationForContacts(contacts);
    contacts = ContactService.setRollupTermEligibilityAndDevEdInformation(contacts);
    contacts = ContactService.setRollupEducationInformation(contacts);
    update contacts;
  }

  global void finish(Database.BatchableContext bc) {

  }

  global void execute(SchedulableContext sc) {
    Database.executeBatch(this);
  }
/*
  global static String schedule(String cron) {
    if (cron == null) {
      cron = CRON_EXP;
    }
    ContactRollupScheduled job = new ContactRollupScheduled();
    return System.schedule('Contact Rollups Job', cron, job);
  }

  global static String executeRollups() {
    ContactRollupScheduled job = new ContactRollupScheduled();
    return Database.executeBatch(job);
  }
*/
}