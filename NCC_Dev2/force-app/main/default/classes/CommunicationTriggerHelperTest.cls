@isTest
private class CommunicationTriggerHelperTest {
	
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
            Communication__c testRecord = new Communication__c();
            testRecord.Name = '';
            testRecord.Status__c = 'Draft';
            testRecord.Frequency__c = 'Real-time';
            testRecord.Active__c = true;
            testRecord.Subject__c = 'Test Comm Subject';
            testRecord.Body__c = 'Test Comm HTML Body';
            testRecord.Email_Recipient_CC__c = 'testCC1@testEmailUtility.test, testCC2@testEmailUtility.test, testCC3@testEmailUtility.test, testCC4@testEmailUtility.test';
            testRecord.Email_Recipient_BCC__c = 'testBCC1@testEmailUtility.test, testBCC2@testEmailUtility.test, testBCC3@testEmailUtility.test, testBCC4@testEmailUtility.test';
            testRecord.OwnerId = UserInfo.getUserId();
            insert testRecord;
            
            //create Communication_Recipient__c
            List<Communication_Recipient__c> crList = new List<Communication_Recipient__c>();
            for(Journey_Participant__c jp:jpList){
                crList.add(new Communication_Recipient__c(CC_Communication__c=testRecord.Id, Journey_Participant__c=jp.Id));
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
    
    static void populateLowSettings(){
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
        settings.Max_Email_To_Number__c = 5;
        insert settings;
    }
    
    //happy path test for CommunicationTriggerHelper.onAfterUpdate()
    static testMethod void test_onAfterUpdate_positive(){
        //setting utility class for testing
        //EmailUtility.isTest = false;//
		EmailUtility.currentOrgEmailCalls=10;
		EmailUtility.currentTransactionEmailCalls=10;  
        //setup settings
        populateActiveSettings();
        
        //retrieve sample template
        EmailTemplate emailTemplate = Database.query(EmailUtility.getCreatableFieldsSOQL('EmailTemplate','DeveloperName =\'Event_Invitation_Template\''));//[SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName ='Event_Invitation_Template'];
		
        //retrieve Communication__c record
        List<Communication__c> comms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));//[SELECT Id, OwnerId, Email_Template_Id__c, Subject__c, Body__c, Email_Recipient_CC__c, Email_Recipient_BCC__c FROM Communication__c];
		System.debug('[test_onAfterUpdate_positive]BEFORE EMAIL-->'+comms);
        
        test.startTest();
        //mimic clicking SEND button
        for(Communication__c comm:comms){
            comm.Status__c = EmailUtility.COMM_STATUS_OUTBOX;
        }
        update comms;
        test.stopTest();
        List<Communication__c> afterComms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));
		System.debug('[test_onAfterUpdate_positive]after EMAIL-->'+afterComms);   
        System.assertEquals(true, afterComms[0].Status__c=='Sent');
    }
    
    //negative path test for CommunicationTriggerHelper.onAfterUpdate()-->
    static testMethod void test_onAfterUpdate_negative1(){
        //setting utility class for testing
        EmailUtility.isTest = true;//
		EmailUtility.currentOrgEmailCalls=10;
		EmailUtility.currentTransactionEmailCalls=5;  
        //setup settings
        populateLowSettings();
        
        //retrieve sample template
        EmailTemplate emailTemplate = Database.query(EmailUtility.getCreatableFieldsSOQL('EmailTemplate','DeveloperName =\'Event_Invitation_Template\''));//[SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName ='Event_Invitation_Template'];
		
        //retrieve Communication__c record
        List<Communication__c> comms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));//[SELECT Id, OwnerId, Email_Template_Id__c, Subject__c, Body__c, Email_Recipient_CC__c, Email_Recipient_BCC__c FROM Communication__c];
		System.debug('[test_onAfterUpdate_negative1]BEFORE EMAIL-->'+comms);
        
        test.startTest();
        //mimic clicking SEND button
        for(Communication__c comm:comms){
            comm.Status__c = EmailUtility.COMM_STATUS_OUTBOX;
        }
        try{
        	update comms;
        }
        catch(Exception e){
            System.debug('[test_onAfterUpdate_negative1]exception message-->'+e.getMessage());
            System.assertEquals(true, e.getMessage().contains('Maximum Email To Address Count Reached: 100.'));
        }
        test.stopTest();
        List<Communication__c> afterComms = Database.query(EmailUtility.getCreatableFieldsSOQL('Communication__c',''));
		System.debug('[test_onAfterUpdate_negative1]after EMAIL-->'+afterComms);   
    }
}