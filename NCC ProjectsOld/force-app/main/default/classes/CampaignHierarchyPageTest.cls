@isTest
class CampaignHierarchyPageTest {
    
    @testSetup
    static void testSetup() {
        //Campaign 
        List<Campaign__c> campList = new List<Campaign__c>();
        Campaign__c camp1 = new Campaign__c();
        camp1.Name = 'Test Campaign 001';
        campList.add(camp1);
        
        insert campList;
        
        //Event
        List<Event__c> eventList = new List<Event__c>();
        Event__c event1 = new Event__c();
        event1.Name = 'Test Event 001';
        event1.Campaign__c = camp1.Id;
        eventList.add(event1);
        
        Event__c event2 = new Event__c();
        event2.Name = 'Test Event 002';
		event2.Campaign__c = camp1.Id;
        eventList.add(event2);

        insert eventList;
        
        //Session
        List<Session__c> sessionList = new List<Session__c>();
        Session__c session1 = new Session__c();
        session1.Name = 'Test Session 001';
        session1.Event__c = event1.Id;
        sessionList.add(session1);
        
        Session__c session2 = new Session__c();
        session2.Name = 'Test Session 002';
        session2.Event__c = event2.Id;
        sessionList.add(session2);
        
        insert sessionList;
        
    }
    
    @isTest
    static void checkObjectTypeTest(){
        Campaign__c camp = [Select Id From Campaign__c limit 1];
        String objectType;
        test.startTest();
        try{
            objectType = CampaignHierarchyPage.objectType(camp.Id);
        }
        catch(exception ex){}
        test.stopTest();
    }
    
    @isTest
    static void searchForCampaignTest(){
        Campaign__c camp = [Select Id From Campaign__c limit 1];
        List<Campaign__c> campList;
        test.startTest();
        try{
            campList = CampaignHierarchyPage.searchForCampaign(camp.Id);
        }
        catch(exception ex){}
        test.stopTest();
    }
    
    @isTest
    static void searchForEventTest(){
        Event__c event = [Select Id From Event__c limit 1];
        List<Event__c> eventList;
        test.startTest();
        try{
            eventList = CampaignHierarchyPage.searchForEvent(event.Id);
        }
        catch(exception ex){}
        test.stopTest();
    }
    
    @isTest
    static void searchForEventTest2(){
        Campaign__c campaign = [Select Id From Campaign__c limit 1];
        List<Event__c> eventList;
        test.startTest();
        try{
            eventList = CampaignHierarchyPage.searchForEvent(campaign.Id);
        }
        catch(exception ex){}
        test.stopTest();
    }
    
    @isTest
    static void searchForSessionTest(){
        Event__c event = [Select Id From Event__c limit 1];
        List<Id> eventId = new List<Id>();
        eventId.add(event.Id);
        Session__c session = [Select Id From Session__c limit 1];
        List<Session__c> sessionList;
        test.startTest();
        try{
            sessionList = CampaignHierarchyPage.searchForSession(eventId, null);
        }
        catch(exception ex){}
        test.stopTest();
    }
    
    @isTest
    static void searchForSessionTest2(){
        Session__c session = [Select Id From Session__c limit 1];
        List<Session__c> sessionList;
        List<Id> eventId = new List<Id>();
        test.startTest();
        try{
            sessionList = CampaignHierarchyPage.searchForSession(eventId, session.Id);
        }
        catch(exception ex){}
        test.stopTest();
    }
}