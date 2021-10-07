/*******************************************************************************
* @author       Allen Francisco
* @date         13.02.2021
* @description  Test class for MilestoneTriggerHandler
* @revision     13.02.2021 - ADFrancisco - Created
*******************************************************************************/
@isTest
public class MilestoneTriggerHandler_Test {
    static testMethod void runTrigger(){
        Campaign__c testCampaign = new Campaign__c();
        testCampaign.Name = 'Test Campaign Name';
        insert testCampaign;
        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'Test Journey';
        testJourney.Campaign__c = testCampaign.Id;
        testJourney.Status__c = 'For Review';
        insert testJourney;
        
        Milestone__c testMilestone = new Milestone__c();
        testMilestone.Journey__c = testJourney.Id;
        testMilestone.Name = 'Test Milestone';
        testMilestone.Type__c = 'Communication';
        insert testMilestone;
    }
}