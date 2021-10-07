global class AccountRollupsJob implements Database.Batchable<sObject>, Schedulable {
  public static final String CRON_EXP = '0 0 0/1 1/1 * ? *';

  global Database.QueryLocator start(Database.BatchableContext bc) {
    // possibly only search by students or something along those lines
    Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'College/University' AND SobjectType = 'Account'].Id;
    return Database.getQueryLocator([SELECT Id FROM Account WHERE RecordTypeId = :recordTypeId]);
  }

  global void execute(Database.BatchableContext bc, List<Account> accounts) {
    StudentTermPaymentService.rollupPaymentInformationForAccounts(accounts);
  }

  global void finish(Database.BatchableContext bc) {

  }

  global void execute(SchedulableContext sc) {
    Database.executeBatch(this);
  }

  global static String schedule(String cron) {
    if (cron == null) {
      cron = CRON_EXP;
    }
    AccountRollupsJob job = new AccountRollupsJob();
    return System.schedule('Account Rollups Job', cron, job);
  }

  global static String executeRollups() {
    AccountRollupsJob job = new AccountRollupsJob();
    return Database.executeBatch(job);
  }

}