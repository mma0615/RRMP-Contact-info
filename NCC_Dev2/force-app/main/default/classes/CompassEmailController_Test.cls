@isTest
public with sharing class CompassEmailController_Test {
    private static final String UNRECOGNIZED_ERROR = System.Label.Compass_Email_Unrecognized_Id_Error;
    @testSetup static void setup() {

        Email_Settings__c setting = new Email_Settings__c();
        setting.Max_Email_CC_BCC_Number__c = 25;
        setting.Max_Email_To_Number__c = 100;
        insert setting;
        
        // Account
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        // Contact
        List<Contact> contactList = new List<Contact>();
        for(Integer i = 0; i < 3; i++){
            Contact newContact = new Contact();
            newContact.FirstName = 'Test FirstName' + i;
            newContact.LastName = 'Test LastName' + i;
            newContact.Email = 'testContactEmail' + i + '@testing.com';
            newContact.AccountId = testAccount.Id;
            contactList.add(newContact);
        }
        // for contact with HasOptedOutOfEmail set to true
        Contact newContact = new Contact(FirstName = 'Contact', 
                                         LastName = 'HasOptedOutOfEmail',
                                         Email = 'HasOptedOutOfEmail@testing.com',
                                         AccountId = testAccount.Id,
                                         HasOptedOutOfEmail = true);
        contactList.add(newContact);
        Insert contactList;

        // Campaign
        Campaign__c testCampaign = new Campaign__c();
        testCampaign.Name = 'Test Campaign';
        Insert testCampaign;

        // Journey
        List<Journey__c> journeyList = new List<Journey__c>();
        Journey__c testJourneyA = new Journey__c();
        testJourneyA.Name = 'Test Journey A';
        testJourneyA.Campaign__c = testCampaign.Id;
        testJourneyA.Status__c = 'For Review';
        journeyList.add(testJourneyA);

        Journey__c testJourneyB = new Journey__c();
        testJourneyB.Name = 'Test Journey B';
        testJourneyB.Campaign__c = testCampaign.Id;
        testJourneyB.Status__c = 'Approved';
        journeyList.add(testJourneyB);
        Insert journeyList;

        // Journey Participant
        List<Journey_Participant__c> journeyParticipantList = new List<Journey_Participant__c>(); 
        for(Contact con : contactList){
            Journey_Participant__c newParticipant = new Journey_Participant__c();
        
            newParticipant.Contact__c = con.Id;
            newParticipant.Journey__c = testJourneyA.Id;
            if(con.HasOptedOutOfEmail == true){
                newParticipant.Journey__c = testJourneyB.Id;
            }
            journeyParticipantList.add(newParticipant);
        }
        Insert journeyParticipantList;
        
        // OrgWideEmailAddress
        Id emailAddressesId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;

        // Communication
        Communication__c newComms = new Communication__c();
        newComms.Status__c = 'Draft';
        newComms.Campaign__c = testCampaign.Id;
        newComms.Frequency__c = 'Real-time';
        newComms.Organization_Wide_Email_Id__c = emailAddressesId;
        newComms.Email_Recipient_CC__c = 'cctest@testing.com, cctest2@testing.com';
        newComms.Email_Recipient_BCC__c = 'bcctest@testing.com';
        newComms.Subject__c = 'Test Subject';
        newComms.Body__c = 'Test Body';
        Insert newComms;

        // Communication Recipients
        List<Communication_Recipient__c> commsRecipients = new List<Communication_Recipient__c>(); 
        for(Journey_Participant__c jParticipant : journeyParticipantList){
            Communication_Recipient__c newRecipient = new Communication_Recipient__c();
            newRecipient.CC_Communication__c = newComms.Id;
            newRecipient.Journey_Participant__c = jParticipant.Id;
            newRecipient.Contact__c = jParticipant.Contact__c;
            commsRecipients.add(newRecipient);
        }
        Insert commsRecipients;

    }

    @isTest static void getOrgWideEmailAddress_Test(){
        List<OrgWideEmailAddress> emailAddresses = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress];
        Test.startTest();
        List<OrgWideEmailAddress> testAddresses = CompassEmailController.getOrgWideEmailAddress();
        System.debug('List 1' + emailAddresses);
        System.debug('List 2' + testAddresses);
        Test.stopTest();
        System.assert(!testAddresses.isEmpty());
        System.assertEquals(emailAddresses.size(), testAddresses.size());
    }

    @isTest static void getDefaultSenderId_Test(){
        // OrgWideEmailAddress
        Id emailAddressesId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;
        
        // Compass Setting
        Compass_Setting__c compassSetting = new Compass_Setting__c();
        compassSetting.Name = 'Test Compass Testing';
        compassSetting.Email_Sender_Id__c = emailAddressesId;
        compassSetting.Email_Sender_Name__c = 'Test Sender';
        Insert compassSetting;

        Test.startTest();
        Id senderId = CompassEmailController.getDefaultSenderId();
        Test.stopTest();
        System.assertEquals(senderId, compassSetting.Email_Sender_Id__c );
    }

    // @isTest static void getEmailTemplateRecord_Test(){
    //     EmailTemplate expected = [ SELECT Id FROM EmailTemplate LIMIT 1 ];
    //     Test.startTest();
    //     EmailTemplate testTemplate = CompassEmailController.getEmailTemplateRecord(expected.Id);
    //     Test.stopTest();
    //     System.assert(testTemplate != null && testTemplate.Id == expected.Id);
    // }

    @isTest static void searchContactRecipient_NotOptedOut_Test(){
        List<Contact> conList = [SELECT Id FROM Contact WHERE HasOptedOutOfEmail = FALSE];
        Test.startTest();
        List<String> noSelectedId = new List<String>();
        List<LookupSearchResult> testLookupResults = CompassEmailController.searchContactRecipient('Test', noSelectedId);
        Test.stopTest();
        // Only 3 contacts where inserted from test setup that contains 'Test' word in their name/email
        // So only the size of testLookupResults should only be 3 also
        System.assertEquals(conList.size(), testLookupResults.size());
    }

    @isTest static void searchContactRecipient_HasOptedOut_Test(){
        List<Contact> conList = [SELECT Id, Name, Email FROM Contact WHERE HasOptedOutOfEmail = TRUE];
        Test.startTest();
        List<String> noSelectedId = new List<String>();
        List<LookupSearchResult> testLookupResults = CompassEmailController.searchContactRecipient(conList[0].Email, noSelectedId);
        Test.stopTest();
        // If the contact record's HasOptedOutOfEmail field is set to true then there should be no search result
        System.assertEquals(0, testLookupResults.size());
    }    

    @isTest static void searchContactRecipient_WithInitialSelection_Test(){
        Map<Id, Contact> conMap = new Map<Id,Contact>([SELECT Id, Name, Email FROM Contact LIMIT 2]);
        List<String> conIdList = (List<String>)JSON.deserialize(JSON.serialize(conMap.keySet()), List<String>.class);
        Test.startTest();
        List<LookupSearchResult> testLookupResults = CompassEmailController.searchContactRecipient('Test', conIdList);
        Test.stopTest();
        // 2 contacts are already selected so there should only be one remaining contact to search for
        System.assert(testLookupResults.size() > 0 && testLookupResults.size() < 2);
    }

    @isTest static void getLookupResultsById_Test(){
        Map<Id, Contact> conMap = new Map<Id,Contact>([SELECT Id, Name, Email FROM Contact LIMIT 2]);
        List<String> conIdList = (List<String>)JSON.deserialize(JSON.serialize(conMap.keySet()), List<String>.class);
        Test.startTest();
        List<LookupSearchResult> testLookupResults = CompassEmailController.getLookupResultsById(conIdList);
        Test.stopTest();
        // Used 2 contacts to get the lookupResults by Id so ther
        System.assertEquals(testLookupResults.size(), 2); 
    }

    @isTest static void getLookupResultsById_Error_Test(){
        try{
            List<LookupSearchResult> testLookupResults = CompassEmailController.getLookupResultsById(null);
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
    }
    
    @isTest static void getEmailTemplates_Test(){
        // Email Template
        EmailTemplate testTemplate = new EmailTemplate();
        testTemplate.DeveloperName = 'Test_Email_Template';
        testTemplate.Name = 'Test Email Template';
        testTemplate.Body = 'This is a Test';
        testTemplate.TemplateType  = 'text';
        testTemplate.FolderId = UserInfo.getUserId();
        insert testTemplate;

        Test.startTest();
        List<EmailTemplate> templateList = CompassEmailController.getEmailTemplates();
        Test.stopTest();
        System.assert(templateList.size() > 0);
    }

    @isTest static void getJourneyParticipants_FromCampaign_Test(){
        Campaign__c testCampaign = [SELECT Id FROM Campaign__c LIMIT 1];
        Test.startTest();
        List<Journey_Participant__c> journeyList = CompassEmailController.getJourneyParticipants(testCampaign.Id);
        Test.stopTest();
        // getJourneyParticipants method should return all participants related to the Campaign
        // there are only 4 participants overall inserted in Test Setup
        System.assertEquals(4, journeyList.size());
    }
    
    @isTest static void getJourneyParticipants_FromJourney_Test(){
        Journey__c testJourney = [SELECT Id FROM Journey__c WHERE Name = 'Test Journey A' LIMIT 1];
        Test.startTest();
        List<Journey_Participant__c> journeyList = CompassEmailController.getJourneyParticipants(testJourney.Id);
        Test.stopTest();
        // getJourneyParticipants method should return all participants related to the Journey
        // there are only 4 participants overall inserted in Test Setup
        System.assertEquals(3, journeyList.size());
    }

    @isTest static void getJourneyParticipants_Error_Test(){
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        try{
            CompassEmailController.getJourneyParticipants(contactId);
        }
        catch(Exception e){
            System.assert(e.getMessage() != null);
        }
    }

    @isTest static void sendCompassEmail_Campaign_Test(){
        String recordId = [SELECT Id FROM Campaign__c LIMIT 1].Id;
        String emailAddressesId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;
        Map<Id, Contact> conMap = new Map<Id,Contact>([SELECT Id FROM Contact LIMIT 2]);
        List<String> contactRecipientIds = (List<String>)JSON.deserialize(JSON.serialize(conMap.keySet()), List<String>.class);
        String subject = 'Test Subject';
        String emailBody = '<p>Test Body</p>';
        String ccRecipients = 'Testing1@cctesting.com, Testing2@cctesting.com';
        String bccRecipients = 'Testing1@bcctesting.com';
        Test.startTest();
        String error = CompassEmailController.sendCompassEmail(recordId, 
                                                               emailAddressesId, 
                                                               contactRecipientIds, 
                                                               subject, 
                                                               emailBody, 
                                                               ccRecipients, 
                                                               bccRecipients);
        Test.stopTest();
        System.assertEquals('', error);
    }

    @isTest static void sendCompassEmail_Journey_Test(){
        String recordId = [SELECT Id FROM Journey__c LIMIT 1].Id;
        String emailAddressesId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;
        Map<Id, Contact> conMap = new Map<Id,Contact>([SELECT Id FROM Contact LIMIT 2]);
        List<String> contactRecipientIds = (List<String>)JSON.deserialize(JSON.serialize(conMap.keySet()), List<String>.class);
        String subject = 'Test Subject';
        String emailBody = '<p>Test Body</p>';
        String ccRecipients = 'Testing1@cctesting.com, Testing2@cctesting.com';
        String bccRecipients = 'Testing1@bcctesting.com';
        Test.startTest();
        String error = CompassEmailController.sendCompassEmail(recordId, 
                                                               emailAddressesId, 
                                                               contactRecipientIds, 
                                                               subject, 
                                                               emailBody, 
                                                               ccRecipients, 
                                                               bccRecipients);
        Test.stopTest();
        System.assertEquals('', error);
    }

    @isTest static void sendCompassEmail_UnrecognizedId_Test(){
        String recordId = [SELECT Id FROM Contact LIMIT 1].Id;
        String emailAddressesId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;
        Map<Id, Contact> conMap = new Map<Id,Contact>([SELECT Id FROM Contact LIMIT 2]);
        List<String> contactRecipientIds = (List<String>)JSON.deserialize(JSON.serialize(conMap.keySet()), List<String>.class);
        String subject = 'Test Subject';
        String emailBody = '<p>Test Body</p>';
        String ccRecipients = 'Testing1@cctesting.com, Testing2@cctesting.com';
        String bccRecipients = 'Testing1@bcctesting.com';
        Test.startTest();
        try{
            String error = CompassEmailController.sendCompassEmail(recordId, 
                                                                   emailAddressesId, 
                                                                   contactRecipientIds, 
                                                                   subject, 
                                                                   emailBody, 
                                                                   ccRecipients, 
                                                                   bccRecipients);
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();
    }

    @isTest static void executeEmail_Test(){
        Communication__c testComm = [SELECT Id, 
                                            Status__c, 
                                            Frequency__c, 
                                            Organization_Wide_Email_Id__c, 
                                            Email_Recipient_CC__c, 
                                            Email_Recipient_BCC__c,
                                            Email_Template_Id__c, 
                                            Subject__c, 
                                            Body__c 
                                            FROM Communication__c];
        List<Communication_Recipient__c> commsRecipients = [SELECT Id, 
                                                                   Email__c, 
                                                                   Journey_Participant__c, 
                                                                   Journey_Participant__r.Contact__c, 
                                                                   Contact__c, Contact__r.Email 
                                                                   FROM Communication_Recipient__c];
        Id emailAddressesId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;
        Test.startTest();
        CompassEmailController.executeEmail(testComm, commsRecipients, emailAddressesId);
        Test.stopTest();
    }

    @isTest static void executeEmail_Error_Test(){
        Communication__c testComm = null;
        List<Communication_Recipient__c> commsRecipients = [SELECT Id, Journey_Participant__c, Contact__c FROM Communication_Recipient__c];
        Id emailAddressesId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1].Id;
        Test.startTest();
        // passing null to communication parameter
        CompassEmailController.executeEmail(testComm, commsRecipients, emailAddressesId);
        Test.stopTest();
    }

    @isTest static void executeEmail_ErrorException_Test(){
        Test.startTest();
        // passing null to communication parameter
        try{
            CompassEmailController.executeEmail(null, null, null);
        }
        catch(exception e){
            System.assert(!String.isBlank(e.getMessage()));
        }
        Test.stopTest();
    }
}