/**
* @description Test class for ParticipantTriggerHandler
* @revision
*           02.25.2021 - Afrancisco - Initial Creation
**/
@isTest
public class ParticipantTriggerHandler_Test {

    @testSetup
    static void createData(){
       OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        
        Apex_Trigger_Switch__c switchh = new Apex_Trigger_Switch__c();
        switchh.Name = 'ParticipantTrigger';
        switchh.Active__c = true;
        insert switchh;

        Campaign__c testCampaign = new Campaign__c();
        testCampaign.Name = 'Test Campaign Name';
        insert testCampaign;
        
        Contact testContact = new Contact();
        testContact.LastName = 'Test Contact';
        testContact.Email = 'test@email.com';
        insert testContact;
        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'Test Journey';
        testJourney.Campaign__c = testCampaign.Id;
        testJourney.Status__c = 'Approved';
        insert testJourney;
        
        EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'test', IsActive = true);
        system.runAs( new User(Id = UserInfo.getUserId())){
        	insert e;
        }
        
        
        Compass_Setting__c setting = new Compass_Setting__c();
        setting.Name = 'Default Settings';
        setting.Email_Sender_Name__c = 'NAME';
        setting.Email_Template_Invitation_Id__c = e.Id;
        setting.Email_Template_Registration_Id__c = e.Id;
        setting.Email_Sender_Id__c = owea.Id;
        insert setting;
        
        Apex_Trigger_Switch__c apexSwitch = TestDataFactory.createTriggerSwitch('EventTrigger');
        apexSwitch.Name = 'EventTrigger';
        insert apexSwitch;
        
        Event__c testEvent = new Event__c();
        testEvent.Campaign__c = [SELECT Id FROM Campaign__c LIMIT 1].Id;
        testEvent.Journey__c = [SELECT Id FROM Journey__c LIMIT 1].Id;
        testEvent.Milestone__c = true;
        testEvent.Email_Sender_Name__c = 'TEST 123';
        testEvent.Email_Message_CC__c = 'testMail@mail.com';
        testEvent.Email_Message_BCC__c = 'testMail@mail.com';
        testEvent.Email_Sender_Id__c = owea.Id;
        insert testEvent;
        
        Participant__c participantData = new Participant__c();
        participantData.Event__c = testEvent.Id;
        participantData.Member_Contact__c = testContact.Id;
        participantData.Session_Modified__c = false;
        insert participantData;
        
        Participant__c participantData1 = new Participant__c();
        participantData1.Event__c = testEvent.Id;
        participantData1.Member_Contact__c = testContact.Id;
        participantData1.Session_Modified__c = false;
        insert participantData1;
    }
    
    static testMethod void runInsertInvited(){
        List<Participant__c> participantList = new List<Participant__c>();
        Participant__c newparticipantData = new Participant__c();
        newparticipantData.Event__c = [SELECT Id FROM Event__c LIMIT 1].Id;
        newparticipantData.Member_Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        newparticipantData.Session_Modified__c = false;
        newparticipantData.Status__c = 'Invited';
        participantList.add(newparticipantData);

		Participant__c newparticipantData1 = new Participant__c();
        newparticipantData1.Event__c = [SELECT Id FROM Event__c LIMIT 1].Id;
        newparticipantData1.Member_Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        newparticipantData1.Session_Modified__c = false;
        newparticipantData1.Status__c = 'Invited';
        participantList.add(newparticipantData1);

	    insert participantList;
   
    }
    static testMethod void runInsertResponded(){
        List<Participant__c> participantList = new List<Participant__c>();
        Participant__c newparticipantData = new Participant__c();
        newparticipantData.Event__c = [SELECT Id FROM Event__c LIMIT 1].Id;
        newparticipantData.Member_Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        newparticipantData.Session_Modified__c = false;
        newparticipantData.Status__c = 'Responded';
        participantList.add(newparticipantData);

		Participant__c newparticipantData1 = new Participant__c();
        newparticipantData1.Event__c = [SELECT Id FROM Event__c LIMIT 1].Id;
        newparticipantData1.Member_Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        newparticipantData1.Session_Modified__c = false;
        newparticipantData1.Status__c = 'Responded';
        participantList.add(newparticipantData1);

	    insert participantList;
        
    }
    static testMethod void runUpdateInvited(){
        List<Participant__c> participantList = new List<Participant__c>();
        for(Participant__c par: [SELECT Id, Status__c, Session_Modified__c FROM Participant__c]){
            par.Status__c = 'Invited';
            par.Session_Modified__c = true;
            participantList.add(par);
        }
        if(!participantList.isEmpty()) update participantList;
    }
    static testMethod void runUpdateResponded(){
        List<Participant__c> participantList = new List<Participant__c>();
        for(Participant__c par: [SELECT Id, Status__c, Session_Modified__c FROM Participant__c]){
            par.Status__c = 'Responded';
            par.Session_Modified__c = true;
            participantList.add(par);
        }
        if(!participantList.isEmpty()) update participantList;
    }
}