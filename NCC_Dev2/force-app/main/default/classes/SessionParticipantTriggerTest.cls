@isTest
private class SessionParticipantTriggerTest {
    @testSetup
    static void setup(){
        List<Apex_Trigger_Switch__c> atsList = new List<Apex_Trigger_Switch__c>();
        Apex_Trigger_Switch__c aps_sp = new Apex_Trigger_Switch__c();
        aps_sp.Name = 'SessionParticipantTrigger';
        aps_sp.Active__c = true;
        atsList.add(aps_sp);
        
        Apex_Trigger_Switch__c aps_event = new Apex_Trigger_Switch__c();
        aps_event.Name = 'EventTrigger';
        aps_event.Active__c = false;
        atsList.add(aps_event);
        
        insert atsList;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test Contact';
        con1.LastName = 'Record 1';
        con1.Email = 'testemail@testemail.com';
        insert con1;
        
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
        event2.Campaign__c = camp1.Id;
        event2.Name = 'Test Event 002';
        eventList.add(event2);
        
        insert eventList;
        
        //Session
        List<Session__c> sessionList = new List<Session__c>();
        Session__c session1 = new Session__c();
        session1.Name = 'Test Session 001';
        session1.Event__c = event1.Id;
        session1.Start_Date_Time__c = DateTime.newInstance(2020, 08, 29, 9, 30, 0);
        session1.End_Date_Time__c = DateTime.newInstance(2020, 08, 29, 10, 30, 0);
        sessionList.add(session1);
        
        Session__c session2 = new Session__c();
        session2.Name = 'Test Session 002';
        session2.Event__c = event2.Id;
        sessionList.add(session2);
        
        insert sessionList;
        
        //Session Participant
        List<Session_Participant__c> sessionParticipantList = new List<Session_Participant__c>();
        Session_Participant__c sp = new Session_Participant__c();
        sp.Session__c = session1.Id;
		sp.Event__c = event1.Id;
		sp.Contact__c = con1.Id;
        sp.Status__c = 'Attended';
        sp.Invitation_Date__c = DateTime.newInstance(2020, 08, 29, 9, 30, 0);
        sp.Registration_Date__c = DateTime.newInstance(2020, 08, 29, 9, 30, 0);
        sessionParticipantList.add(sp);
        
        insert sessionParticipantList;
    }
    
    @isTest private static void calendarInviteTest(){
        Session_Participant__c sp = [Select Status__c from Session_Participant__c LIMIT 1];
        sp.Status__c = 'Registered';
        
        Test.startTest();
        update sp;
        Test.stopTest();
    }
    
    
}