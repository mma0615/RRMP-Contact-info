@isTest
public with sharing class ContactRollupsJob_test {

    public static testmethod void testScheduledJob() {
	    // Dummy CRON expression: midnight on March 15.
    	// Because this is a test, job executes
	    // immediately after Test.stopTest().
//    	String CRON_EXP = '0 0 0 15 3 ? 2022';

        
        // Create some Contact records
        List<Contact> cons = new List<Contact>();
        for (Integer i=0; i<10; i++) {
            Contact c = new Contact(LastName = 'Tester ' + i);
            cons.add(c);
        }
        insert cons;

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            ContactRollupsJob.CRON_EXP, 
            new ContactRollupsJob(2000));   
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(ContactRollupsJob.CRON_EXP,
         ct.CronExpression);

        System.debug('Scheduled Job ID: ' + jobId);
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
    }
}