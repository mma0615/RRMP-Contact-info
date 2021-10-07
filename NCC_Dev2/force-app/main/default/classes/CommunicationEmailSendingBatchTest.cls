@isTest
private class CommunicationEmailSendingBatchTest {
	
	@testSetup
    static void setup(){
        String alias = 'tstSysAd';
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User sysad = new User(
            Username=alias+'@test.com', Alias=alias, CommunityNickname=alias, TimeZoneSidKey='America/Chicago', 
            LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US',
            FirstName=alias, LastName=alias, Email=alias+'@test.com', ProfileId=profile.Id, Department = 'Test');
        insert sysad;
        
		//create email template
		EmailTemplate validEmailTemplate = new EmailTemplate();
		validEmailTemplate.isActive = true;
		validEmailTemplate.Name = 'unique_name_test_emailtemplate';
		validEmailTemplate.DeveloperName = 'unique_name_test_emailtemplate';
		validEmailTemplate.TemplateType = 'text';
		validEmailTemplate.FolderId = UserInfo.getUserId();
		validEmailTemplate.Subject = 'Test Template Subject';
		insert validEmailTemplate;
        
		System.runAs(sysad) {
            //create Account
            Account testAccount = new Account(Name='EmailUtilityTestAccount');
            insert testAccount;
            
            //create Contact
            List<Contact> contactList = new List<Contact>();
            for(Integer i=0;i<10;i++){
                contactList.add(new Contact(FirstName='EmailUtility', LastName='TestContact'+i, AccountId=testAccount.Id, Email='test_'+i+'@testEmailUtility.test'));
            }
            insert contactList;
            
            //create Journey__c
            Journey__c testJourney = new Journey__c(Name='EmailUtilityTestJourney');
            insert testJourney;
            
            //create Journey_Participant__c
            List<Journey_Participant__c> jpList = new List<Journey_Participant__c>();
            for(Contact cnt:contactList){
                jpList.add(new Journey_Participant__c(Journey__c=testJourney.Id, Contact__c=cnt.Id));
            }
            insert jpList;
            
            //create CommunicScheduliation__c record;
            List<Communication__c> commsList = new List<Communication__c>();
            for(Integer count=0; count<200; count++){
                Communication__c testRecord = new Communication__c();
                testRecord.Name = '';
                testRecord.Status__c = 'Draft';
                testRecord.Frequency__c = 'Scheduled';
                testRecord.Active__c = true;
                testRecord.Subject__c = 'Test Comm Subject'+count;
                testRecord.Body__c = 'Test Comm HTML Body'+count;
                testRecord.Email_Recipient_CC__c = 'testCC1'+count+'@testEmailUtility.test, testCC2'+count+'@testEmailUtility.test, testCC3'+count+'@testEmailUtility.test, testCC'+count+'@testEmailUtility.test';
                testRecord.Email_Recipient_BCC__c = 'testBCC1'+count+'@testEmailUtility.test, testBCC2'+count+'@testEmailUtility.test, testBCC3'+count+'@testEmailUtility.test, testBCC4'+count+'@testEmailUtility.test';
                testRecord.OwnerId = UserInfo.getUserId();
                commsList.add(testRecord);
            }
            insert commsList;
            
            //create Communication_Recipient__c
            List<Communication_Recipient__c> crList = new List<Communication_Recipient__c>();
            for(Communication__c comms:commsList){
                for(Journey_Participant__c jp:jpList){
                    crList.add(new Communication_Recipient__c(CC_Communication__c=comms.Id, Journey_Participant__c=jp.Id));
                }
            }
            insert crList;
        }
	}
    
    static void populateActiveSettings(){
     	Email_Settings__c settings = new Email_Settings__c();
        settings.Default_Org_Wide_Email_Id__c = 'nicole@ulapp.co';
        settings.Email_BCC_Limit_Error_Message__c = 'Maximum Email BCC Address Count Reached: 25.';
        settings.Email_CC_Limit_Error_Message__c = 'Maximum Email CC Address Count Reached: 25.';
        settings.Email_Disabled_Error_Message__c = 'Email Sending is disabled in settings.';
        settings.Email_Sent_Daily_Limit_Error_Message__c = 'Maximum Daily Email Sent Reached: 5000.';
        settings.Email_To_Limit_Error_Message__c = 'Maximum Email To Address Count Reached: 100.';
        settings.Email_Transaction_Limit_Error_Message__c = 'Maximum Transaction Email Sent Reached: 10.';
        settings.isActive__c = true;
        settings.Max_Email_CC_BCC_Number__c = 5;
        settings.Max_Email_To_Number__c = 11;
        insert settings;
    }
    
    static void populateLowLimitSettings(){
     	Email_Settings__c settings = new Email_Settings__c();
        settings.Default_Org_Wide_Email_Id__c = 'nicole@ulapp.co';
        settings.Email_BCC_Limit_Error_Message__c = 'Maximum Email BCC Address Count Reached: 25.';
        settings.Email_CC_Limit_Error_Message__c = 'Maximum Email CC Address Count Reached: 25.';
        settings.Email_Disabled_Error_Message__c = 'Email Sending is disabled in settings.';
        settings.Email_Sent_Daily_Limit_Error_Message__c = 'Maximum Daily Email Sent Reached: 5000.';
        settings.Email_To_Limit_Error_Message__c = 'Maximum Email To Address Count Reached: 100.';
        settings.Email_Transaction_Limit_Error_Message__c = 'Maximum Transaction Email Sent Reached: 10.';
        settings.isActive__c = true;
        settings.Max_Email_CC_BCC_Number__c = 3;
        settings.Max_Email_To_Number__c = 5;
        insert settings;
    }
    /**/
    static testmethod void test_Schedulable_positive() {
        String CRON_EXP = '0 0 12 ? * MON-FRI';
        // Create your test data
        populateActiveSettings();
        
        Test.startTest();

            String jobId = System.schedule('Schedule_CommunicationEmailSendingBatch',  CRON_EXP, new CommunicationEmailSendingBatch());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        // Add assert here to validate result
       
    }
    
    static testMethod void test_execute_positive(){
        populateActiveSettings();
        
        //query scheduled comms
        List<Communication__c> comms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));//[SELECT Id, OwnerId, Email_Template_Id__c, Subject__c, Body__c, Email_Recipient_CC__c, Email_Recipient_BCC__c FROM Communication__c];
		System.debug('[test_execute_positive]BEFORE EMAIL-->'+comms);
        //send comms to outbox(update status__c to 'Outbox')
        for(Communication__c comm:comms){
            comm.Status__c = EmailUtility.COMM_STATUS_OUTBOX;
        }
        update comms;
        //execute batch
        Test.startTest();
                
        CommunicationEmailSendingBatch obj = new CommunicationEmailSendingBatch();
        Id batchProcessed = DataBase.executeBatch(obj); 
        system.debug('[test_execute_positive]batchProcessed-->' +batchProcessed);
        system.assertEquals((batchProcessed!=null) , true);
        
        //checkcomms after batch
        Test.stopTest();  
        List<Communication__c> afterComms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));
		System.debug('[test_execute_positive]after EMAIL-->'+afterComms);   
    }
    
    //build email error
    static testMethod void test_execute_negative1(){
        populateLowLimitSettings();
        
        //query scheduled comms
        List<Communication__c> comms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));//[SELECT Id, OwnerId, Email_Template_Id__c, Subject__c, Body__c, Email_Recipient_CC__c, Email_Recipient_BCC__c FROM Communication__c];
		System.debug('[test_execute_negative1]BEFORE EMAIL-->'+comms);
        //send comms to outbox(update status__c to 'Outbox')
        for(Communication__c comm:comms){
            comm.Status__c = EmailUtility.COMM_STATUS_OUTBOX;
        }
        update comms;
        //execute batch
        Test.startTest();
                
        CommunicationEmailSendingBatch obj = new CommunicationEmailSendingBatch();
        Id batchProcessed = DataBase.executeBatch(obj); 
        system.debug('[test_execute_negative1]batchProcessed-->' +batchProcessed);
        system.assertEquals((batchProcessed!=null) , true);
        
        //checkcomms after batch
        Test.stopTest();  
        List<Communication__c> afterComms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));
		System.debug('[test_execute_negative1]after EMAIL-->'+afterComms);   
    }
    
    //sending error    
    static testMethod void test_execute_negative2(){
        EmailUtility.isTest = true;//
		EmailUtility.currentOrgEmailCalls=10;
		EmailUtility.currentTransactionEmailCalls=5; 
        
        populateActiveSettings();
        
        //query scheduled comms
        List<Communication__c> comms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));//[SELECT Id, OwnerId, Email_Template_Id__c, Subject__c, Body__c, Email_Recipient_CC__c, Email_Recipient_BCC__c FROM Communication__c];
		System.debug('[test_execute_negative2]BEFORE EMAIL-->'+comms);
        //send comms to outbox(update status__c to 'Outbox')
        Boolean hasMadeBadRecord = false;
        for(Communication__c comm:comms){
            comm.Status__c = EmailUtility.COMM_STATUS_OUTBOX;
            if(!hasMadeBadRecord){
                comm.Email_Recipient_CC__c = comm.Email_Recipient_CC__c.replace('.test', '');
                hasMadeBadRecord = true;
            }
        }
        update comms;
        //execute batch
        Test.startTest();
                
        CommunicationEmailSendingBatch obj = new CommunicationEmailSendingBatch();
        Id batchProcessed = DataBase.executeBatch(obj); 
        system.debug('[test_execute_negative2]batchProcessed-->' +batchProcessed);
        system.assertEquals((batchProcessed!=null) , true);
        
        //checkcomms after batch
        Test.stopTest();  
        List<Communication__c> afterComms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));
		System.debug('[test_execute_negative2]after EMAIL-->'+afterComms);   
    }
    
}