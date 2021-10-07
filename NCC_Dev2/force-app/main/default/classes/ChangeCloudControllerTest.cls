@isTest 
public class ChangeCloudControllerTest {
    
    @testSetup
    static void makeTestData(){
        
        Apex_Trigger_Switch__c aps = new Apex_Trigger_Switch__c();
        aps.Name = 'EventTrigger';
        aps.Active__c = false;
        insert aps;
        
        Compass_Setting__c setting = new Compass_Setting__c();
        setting.Name = 'Default Settings';
        setting.Email_Sender_Id__c = 'qwerty';
        insert setting;
        
        Campaign__c camp = new Campaign__c();
        camp.Name = 'Test Campaign';
        insert camp;
        
        Account a = new Account();
        a.BillingStreet = 'Balston';
        a.BillingCity = 'Melbourne';
        a.BillingPostalCode = '3006';
        a.BillingState  = 'VIC';
        a.BillingCountry  = 'Australia';
        a.Name  = 'Imagine Marco';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'John';
        c.LastName = 'John';
        c.Department = 'IT';
        c.Email = 'John@test.com';
        insert c;
        
        Event__c e = new Event__c();
        e.Event_Id__c = 'xxxxxxxxxx';
        e.Campaign__c = camp.id;
        e.Start_Date_Time__c = DateTime.Now();
        e.End_Date_Time__c = DateTime.Now();
        e.Location__c = a.Id;
        insert e;

        Participant__c p = new Participant__c();
        p.Member_Contact__c = c.id;
        p.Event__c = e.id;
        insert p;
        
        Session__c s = new Session__c();
        s.Event__c = e.id;
        s.IsActive__c = true;
        s.Time_Zone__c = 'CDT';	
        s.Start_Date_Time__c = DateTime.Now();
        s.End_Date_Time__c = DateTime.Now();
        insert s;
        
        Session_Participant__c sp = new Session_Participant__c();
        sp.Participant__c = p.Id;
        sp.Session__c = s.Id;
        insert sp;
        
        Lead l = new Lead();
        l.FirstName = 'Jane';
        l.LastName = 'Doe';
        l.Email = 'JaneDoe@test.com';
        insert l;
        
    }
    
    @IsTest
    static void testInitTest() {
        CCEEventWrapper resultWrappers = new CCEEventWrapper();
        Participant__c p = [SELECT id,Name FROM Participant__c LIMIT 1];
        Test.startTest();
        resultWrappers = ChangeCloudController.getEventDetails('xxxxxxxxxx');
        Test.stopTest();
    }    

    @IsTest
    static void testInitTest2() {
        CCEEventWrapper resultWrappers = new CCEEventWrapper();
        Participant__c p = [SELECT id,Name FROM Participant__c LIMIT 1];
        Test.startTest();
        resultWrappers = ChangeCloudController.getEventDetailsHeader('xxxxxxxxxx',p.Name);
        Test.stopTest();
    }    
    
    
    @IsTest
    static void getEventSessionTest() {
        CCEEventWrapper resultWrappers = new CCEEventWrapper();
        Participant__c p = [SELECT id,Name FROM Participant__c LIMIT 1];
        Test.startTest();
        resultWrappers = ChangeCloudController.getEventSession('xxxxxxxxxx',p.Name,true);
        Test.stopTest();
    }    
    
    @IsTest
    static void getEventSessionTest2() {
        CCEEventWrapper resultWrappers = new CCEEventWrapper();
        Participant__c p = [SELECT id,Name FROM Participant__c LIMIT 1];
        Test.startTest();
        resultWrappers = ChangeCloudController.getEventSession('xxxxxxxxxx',p.Name,false);
        Test.stopTest();
    }    
        
    @IsTest
    static void getParticipantSessionTest() {
        List<compass_session_wrapper> resultWrappers = new List<compass_session_wrapper>();
        Participant__c p = [SELECT id,Name FROM Participant__c LIMIT 1];
        Test.startTest();
        resultWrappers = ChangeCloudController.getParticipantSession(p.Name);
        Test.stopTest();
    }    
    
    @IsTest
    static void updateAttendanceTest() {
        Boolean resultWrappers;
        Session_Participant__c p = [SELECT id FROM Session_Participant__c LIMIT 1];
        Test.startTest();
        resultWrappers = ChangeCloudController.updateAttendance(p.Id);
        Test.stopTest();
    }  
    
    
    
}