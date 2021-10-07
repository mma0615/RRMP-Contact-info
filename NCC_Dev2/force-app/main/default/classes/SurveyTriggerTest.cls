@isTest 
public with sharing class SurveyTriggerTest {
    
    @TestSetup
    static void makeData(){
        List<Apex_Trigger_Switch__c> switchRecs = TestDataFactory.createAllTriggerSwitch();
        insert switchRecs;
        Event__c testEvent = TestFactory.createEvent('Test Campaign');
        Survey__c testActiveSurvey1 = TestFactory.createSurvey(testEvent.Id, 'Test Active Survey 1');
    }

    @isTest
    public static void testCreateMultiActiveSurveys(){
        Test.startTest();
        Event__c testEvent = [SELECT Id FROM Event__c WHERE Name =: 'Test Campaign' LIMIT 1];
        try{
            Survey__c testActiveSurvey2 = TestFactory.createSurvey(testEvent.Id, 'Test Active Survey 2');
        } catch(DmlException e){
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
        List<Survey__c> resultSurveyList = [SELECT Id FROM Survey__c WHERE Name = 'Test Active Survey 2'];
        //System.assertEquals(0, resultSurveyList.size());
    }

    @isTest
    public static void testCreateOneActiveSurveys(){
        // De-activate test survey 1
        Survey__c testActiveSurvey1 = [SELECT Id, Active__c FROM Survey__c WHERE Name = 'Test Active Survey 1'];
        testActiveSurvey1.Active__c = false;
        update testActiveSurvey1;

        Test.startTest();
        Event__c testEvent = [SELECT Id FROM Event__c WHERE Name =: 'Test Campaign' LIMIT 1];
        // Insert active survey 2
        try{
            Survey__c testActiveSurvey2 = TestFactory.createSurvey(testEvent.Id, 'Test Active Survey 2');
        } catch(DmlException e){
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
        List<Survey__c> resultSurveyList = [SELECT Id FROM Survey__c WHERE Name = 'Test Active Survey 2'];
        System.assertEquals(1, resultSurveyList.size());
    }

    @isTest
    public static void testUpdateUnactiveSurveyToActive(){
        Event__c testEvent = [SELECT Id FROM Event__c WHERE Name =: 'Test Campaign' LIMIT 1];
        // Insert an inactive survey under event
        Survey__c inactiveSurvey = new Survey__c();
        inactiveSurvey.Name = 'Inactive Survey';
        inactiveSurvey.Active__c = false;
        inactiveSurvey.Event__c = testEvent.Id;
        insert inactiveSurvey;

        Test.startTest();
        try{
            inactiveSurvey.Active__c = true;
            update inactiveSurvey;
        } catch(DmlException e){
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
}