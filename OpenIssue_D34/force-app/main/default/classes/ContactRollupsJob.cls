global class ContactRollupsJob implements Database.Batchable<sObject>, Schedulable {
  public static final String CRON_EXP = '0 0 0/1 1/1 * ? *';
  public static final Integer DEFAULT_BATCH_SIZE = 2000;
  global Integer batchSize;

  global ContactRollupsJob(Integer batchSize) {
    this.batchSize = batchSize;
  }

  global Database.QueryLocator start(Database.BatchableContext bc) {
    // possibly only search by students or something along those lines
    return Database.getQueryLocator([SELECT Id,cohort__r.name,cohort__c FROM Contact]);
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
    Database.executeBatch(this, this.batchSize);
  }

  global static String schedule(String cron, Integer batchSize) {
    if (cron == null) {
      cron = CRON_EXP;
    }
    if (batchSize == null) {
      batchSize = DEFAULT_BATCH_SIZE;
    }
    ContactRollupsJob job = new ContactRollupsJob(batchSize);
    return System.schedule('Contact Rollups Job', cron, job);
  }

  global static String executeRollups(Integer bSize) {
    if (bSize == null) {
      bSize = DEFAULT_BATCH_SIZE;
    }
    ContactRollupsJob job = new ContactRollupsJob(bSize);
    return Database.executeBatch(job, bSize);
  }

}