/*******************************************************************************
* @author       Allen Francisco
* @date         11.02.2021
* @description  Test class for JourneyParticipantServices
* @revision     11.02.2021 - ADFrancisco - Created
*******************************************************************************/
@isTest
public class JourneyParticipantServices_Test {

    @TestSetup
    static void createData(){
        
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        
        /*Organization org = new Organization();
        org.Name = 'Test org';
        org.TimeZoneSidKey = 'America/Chicago';
        insert org;*/
        
        Contact testContact = new Contact();
        testContact.LastName = 'Test Contact';
        testContact.Email = 'test@email.com';
        insert testContact;
        
		Campaign__c testCampaign = new Campaign__c();
        testCampaign.Name = 'Test Campaign Name';
        
        insert testCampaign;
        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'Test Journey';
        testJourney.Campaign__c = testCampaign.Id;
        testJourney.Status__c = 'Approved';
        insert testJourney;
        
        Journey_Participant__c testParticipant = new Journey_Participant__c();
        testParticipant.Journey__c = testJourney.Id;
        insert testParticipant;
        
        Participant_Milestone__c testPMilestones = new Participant_Milestone__c();
        testPMilestones.Journey__c = testParticipant.Id;
        insert testPMilestones;
        
        Milestone__c testMilestone = new Milestone__c();
        testMilestone.Journey__c = testJourney.Id;
        testMilestone.Name = 'Test Milestone';
        testMilestone.Type__c = 'Communication';
        insert testMilestone;
        
        Participant_Milestone_Metric__c pMilesMetric = new 	Participant_Milestone_Metric__c();
        pMilesMetric.Milestone__c = testPMilestones.Id;
        insert pMilesMetric;
        
        Task testTask = new Task();
        testTask.WhatId = testPMilestones.Id;
        testTask.Type = 'Related Information';
        insert testTask;
        
        Apex_Trigger_Switch__c apexSwitch = TestDataFactory.createTriggerSwitch('EventTrigger');
        apexSwitch.Name = 'EventTrigger';
        insert apexSwitch;
        
        Apex_Trigger_Switch__c apexSwitch1 = TestDataFactory.createTriggerSwitch('EventTrigger');
        apexSwitch1.Name = 'SessionParticipantTrigger';
        insert apexSwitch1;
            
        
        EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'test', IsActive = true);
        system.runAs( new User(Id = UserInfo.getUserId())){
        	insert e;
        }
        
        Compass_Setting__c compSetting = new Compass_Setting__c();
        compSetting.Name = 'Default Settings';
        compSetting.Email_Sender_Id__c = '123';
        compSetting.Email_Sender_Name__c = 'NAME';
        compSetting.Email_Template_Invitation_Id__c = e.Id;
        compSetting.Email_Template_Registration_Id__c = e.Id;
        insert compSetting;
        
        Event__c testEvent = new Event__c();
        testEvent.Campaign__c = testCampaign.Id;
        testEvent.Journey__c = testJourney.Id;
        testEvent.Milestone__c = true;
        testEvent.Email_Sender_Id__c = testContact.Id;
        testEvent.Email_Sender_Id__c = owea.Id;
        insert testEvent;
        
        Survey__c testSurvey = new Survey__c();
        testSurvey.Name = 'Test survey';
        testSurvey.Event__c = testEvent.Id;
        testSurvey.Campaign_1__c = testCampaign.Id;
        testSurvey.Journey__c = testJourney.Id;
        testSurvey.Milestone__c = true;
        insert testSurvey;
        
        Session__c testSession = new Session__c();
        testSession.Name = 'Test CC Session';
        testSession.Event__c = testEvent.Id;
        testSession.Milestone__c = true;
        testSession.Time_Zone__c = 'AKDT';
        testSession.Start_Date_Time__c = system.today();
        testSession.End_Date_Time__c = system.today() + 10;
        insert testSession;
        
        Communication__c testComms = new Communication__c();
        testComms.Name = 'Test Coomunication';
        testComms.Journey__c = testJourney.Id;
        testComms.Campaign__c = testCampaign.Id;
        testComms.Milestone__c = true;
        insert testComms;
        
        Session_Participant__c sessParticipant = new Session_Participant__c();
        sessParticipant.Event__c = testEvent.Id;
        sessParticipant.Contact__c = testContact.Id;
        sessParticipant.Session__c = testSession.Id;
        insert sessParticipant;
        
        Participant__c participantData = new Participant__c();
        participantData.Event__c = testEvent.Id;
        participantData.Member_Contact__c = testContact.Id;
        insert participantData;
        
        Milestone_Metric__c mMetric = new Milestone_Metric__c();
        mMetric.Journey__c = testJourney.Id;
        mMetric.Type__c = 'Communication';
        //mMetric.Name = 'Test Milestone Metric';
        insert mMetric;
        
    }
    
    static testMethod void generateMilestone(){
		Id journeyId = [SELECt Id FROM Journey__c LIMIT 1].Id;      
        
        JourneyParticipantServices.generateMilestones(journeyId);
    }   
    static testMethod void generateJourneyParticipants(){
        Id journeyId = [SELECt Id FROM Journey__c LIMIT 1].Id;    
        
        JourneyParticipantServices.generateJourneyParticipants(journeyId);
        
    }
    static testMethod void getUserJourney(){
        Set<Id> setIds = new Set<Id>();
        setIds.add([SELECt Id FROM Journey_Participant__c LIMIT 1].Id);
        JourneyParticipantServices.getUserJourneys(setIds);
    }
    static testMethod void getMilestoneFromJourney(){
        Set<Id> setIds = new Set<Id>();
        setIds.add([SELECt Id FROM Journey__c LIMIT 1].Id);
        JourneyParticipantServices.getMilestoneFromJourney(setIds);
    }
    static testMethod void getUserMilestones(){
        Set<Id> setIds = new Set<Id>();
        setIds.add([SELECt Id FROM Participant_Milestone__c LIMIT 1].Id);
        JourneyParticipantServices.getUserMilestones(setIds);
    }
    
}