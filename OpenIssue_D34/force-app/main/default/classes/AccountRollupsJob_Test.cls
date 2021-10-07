@isTest
public with sharing class AccountRollupsJob_Test {

    public static testmethod void testScheduledJob() {
	    // Dummy CRON expression: midnight on March 15.
    	// Because this is a test, job executes
	    // immediately after Test.stopTest().
//    	String CRON_EXP = '0 0 0 15 3 ? 2022';

        
        // Create some Contact records
        List<Account> acclist = new List<Account>();
        Id stRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        for (Integer i=0; i<10; i++) {
          Account acc = new Account();
          acc.RecordTypeId = stRT;  
          acc.name = 'Test Account ' + i; 
          acclist.add(acc);
       }
    insert acclist;
  
  
  
      

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            AccountRollupsJob.CRON_EXP, 
            new AccountRollupsJob());   
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(AccountRollupsJob.CRON_EXP,
         ct.CronExpression);
                  

        System.debug('Scheduled Job ID: ' + jobId);
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }     
    
}