/*******************************************************************************
* @author       Allen Francisco
* @date         13.02.2021
* @description  Test class for ParticipantMilestoneTriggerHandler
* @revision     13.02.2021 - ADFrancisco - Created
*******************************************************************************/
@isTest
public class ParticipantMilestoneTriggerHandler_Test {
	
    static testMethod void runTrigger(){
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
        testPmilestones.System_Generated__c = true;
        insert testPMilestones;
    }
}