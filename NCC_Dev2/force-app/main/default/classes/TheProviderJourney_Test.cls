/*******************************************************************************
* @author       Allen Francisco
* @date         11.02.2021
* @description  Test class for TheProviderJourney
* @revision     11.02.2021 - ADFrancisco - Created
*******************************************************************************/
@isTest
public class TheProviderJourney_Test {

    @TestSetup
    static void createData(){
		Campaign__c testCampaign = new Campaign__c();
        testCampaign.Name = 'Test Campaign Name';
        
        insert testCampaign;
        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'Test Journey';
        testJourney.Campaign__c = testCampaign.Id;
        testJourney.Status__c = 'For Review';
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
        
        
    }
    
    static testMethod void getUserJourney(){
        Journey__c jData = [SELECT Id FROM Journey__c LIMIT 1];
		Journey_Participant__c jParticipant = [SELECT Id FROM Journey_Participant__c LIMIT 1];
	
        TheProviderJourney.getUserJourney(jParticipant.Id);
        TheProviderJourney.getUserJourney(jData.Id);
    }
}