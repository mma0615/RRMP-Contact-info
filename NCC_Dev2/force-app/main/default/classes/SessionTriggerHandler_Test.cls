@isTest (SeeAllData = false)
public class SessionTriggerHandler_Test {
    @isTest
    static void testInsert(){
         List<Apex_Trigger_Switch__c> switchRecs = TestDataFactory.createAllTriggerSwitch();
        insert switchRecs;
        Event__c evt = TestFactory.createEvent('Test');
        //with start and end
        List<Session__c> sessionList = new List<Session__c>();
        Session__c newCampaign = new Session__c();
        newCampaign.Name = 'Test';
        newCampaign.Event__c = evt.Id;
        newCampaign.IsActive__c = true ;
        newCampaign.Start_Date_Time__c = date.today();
        newCampaign.End_Date_Time__c = date.today().addDays(5);
        sessionList.add(newCampaign);
        
        //with Start
        Session__c newCampaign2 = new Session__c();
        newCampaign2.Name = 'Test2';
        newCampaign2.Event__c = evt.Id;
        newCampaign2.IsActive__c = true ;
        newCampaign2.Start_Date_Time__c = date.today();
        sessionList.add(newCampaign2);

		//with End
        Session__c newCampaign3 = new Session__c();
        newCampaign3.Name = 'Test2';
        newCampaign3.Event__c = evt.Id;
        newCampaign3.IsActive__c = true ;
        newCampaign3.End_Date_Time__c = date.today().addDays(5);
        sessionList.add(newCampaign3);
        
        //without Start and End
        Session__c newCampaign4 = new Session__c();
        newCampaign4.Name = 'Test2';
        newCampaign4.Event__c = evt.Id;
        newCampaign4.IsActive__c = true ;
        sessionList.add(newCampaign4);
        
         //with same start and end
        Session__c newCampaign5 = new Session__c();
        newCampaign5.Name = 'Test';
        newCampaign5.Event__c = evt.Id;
        newCampaign5.IsActive__c = true ;
        newCampaign5.Start_Date_Time__c = date.today();
        newCampaign5.End_Date_Time__c = date.today();
        sessionList.add(newCampaign5);
        
        test.startTest();
        insert sessionList;
        test.stopTest();
        
        List<Session__c> results = [SELECT Id FROM Session__c];
        System.assert(!results.isEmpty());
    }
    
    @isTest
    static void testUpdate(){
        List<Apex_Trigger_Switch__c> switchRecs = TestDataFactory.createAllTriggerSwitch();
        insert switchRecs;
        Event__c evt = TestFactory.createEvent('Test');
        Session__c newCampaign = new Session__c();
        newCampaign.Name = 'Test';
        newCampaign.Event__c = evt.Id;
        newCampaign.IsActive__c = true ;
        newCampaign.Start_Date_Time__c = date.today();
        newCampaign.End_Date_Time__c = date.today().addDays(5);
        insert newCampaign;
        
        test.startTest();
        newCampaign.Name ='Test Updated';
        update newCampaign;
        
        test.stopTest();
        
        List<Session__c> results = [SELECT Id, Name FROM Session__c WHERE Name = 'Test Updated'];
        System.assert(!results.isEmpty());
    }
}