@isTest
public class CCEventTriggerHandlerTest {
    @testSetup static void createData(){
        Compass_Setting__c comp = TestDataFactory.createCSData(1);
        insert comp;
        
		Campaign__c camp = TestDataFactory.createCampaign(1);
        insert camp;
        
        List<Apex_Trigger_Switch__c> switchRecs = TestDataFactory.createAllTriggerSwitch();
        insert switchRecs;
    }
    static testmethod void testOrgWide(){
        Campaign__c campRec = [Select Id, Name FROM Campaign__c WHERE Name =: 'Test Campaign1' ];
        system.debug('camp' + campRec);
        
        Compass_Setting__c comp = [Select Id, Name, Email_Sender_Id__c FROM Compass_Setting__c WHERE Name =: 'Default Settings' ];
        
        Test.startTest();        
        Event__c eve = new Event__c(Name = 'Test Event', Campaign__c = campRec.Id, Email_Sender_Id__c = NULL);
        insert eve;
        Test.stopTest();
    }
}