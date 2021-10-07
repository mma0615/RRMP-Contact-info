/**
 * Created by angelorivera on 30/8/20.
 * Modified by Jasmine Nguyen on 10/9/2020 to use Start_Date_Time__c and End_Date_Time__c fields
 */

@IsTest
private class CC_EventRegistrationClassTest {
    
    @testSetup
    static void makeTestData(){
        User campaignOwner = TestFactory.createInteralUser('Campaign', 'Owner', 'c.owner@gmail.com', 'System Administrator');
        Event__c parentEvent = TestFactory.createEvent('Parent Event');
        parentEvent.Event_Id__c = 'zhCoziiBzcb';
        parentEvent.OwnerId = campaignOwner.Id;
        parentEvent.Start_Date_Time__c = DateTime.newInstance(2020, 8, 29, 8, 30, 0);
        parentEvent.End_Date_Time__c = DateTime.newInstance(2020, 8, 31, 12, 30, 0);
        update parentEvent;

        Session__c childSession = TestFactory.createSession('Child Session', parentEvent.Id);
        childSession.Start_Date_Time__c = DateTime.newInstance(2020, 8, 29, 8, 30, 0);
        childSession.End_Date_Time__c = DateTime.newInstance(2020, 8, 31, 12, 30, 0);
        update childSession;

    }

    @IsTest
    static void testInit() {
        List<CC_EventRegistrationClass.SessionWrapper> SessionWrappers = new List<CC_EventRegistrationClass.SessionWrapper>();
        Test.startTest();
            SessionWrappers = CC_EventRegistrationClass.DoInit('zhCoziiBzcb');
        Test.stopTest();
        //System.assert(!SessionWrappers.isEmpty());
    }

    @IsTest
    static void testSubmitBookingSuccess() {
        List<String> lstSessionId = new List<String>();
        for(Session__c cmp : [SELECT Id FROM  Session__c WHERE Name = 'Child Session']){
            lstSessionId.add(cmp.Id);
        }
        String strResult='';
        Test.startTest();
            strResult = CC_EventRegistrationClass.submitBooking('zhCoziiBzcb', 'Test', 'LastName', 'testemail@test.com', 'Test Company', lstSessionId);
        Test.stopTest();
        //System.assert(strResult == 'Success');
    }

    @IsTest
    static void testSubmitBookingConvertLead() {
        Lead ld = new Lead(FirstName = 'Test', LastName='LastName', Email='testemail@test.com', Company = 'Test Company');
        insert ld;
        List<String> lstSessionId = new List<String>();
        for(Session__c cmp : [SELECT Id FROM  Session__c WHERE Name = 'Child Session']){
            lstSessionId.add(cmp.Id);
        }
        String strResult='';
        Test.startTest();
        strResult = CC_EventRegistrationClass.submitBooking('zhCoziiBzcb', 'Test', 'LastName', 'testemail@test.com', 'Test Company', lstSessionId);
        Test.stopTest();
        //System.assert(strResult == 'Success');
    }

    @IsTest
    static void testSubmitBookingLinkContact() {
        TestFactory.createContact('Test', 'Attendee', 'testemail@test.com');

        List<String> lstSessionId = new List<String>();
        for(Session__c cmp : [SELECT Id FROM  Session__c WHERE Name = 'Child Session']){
            lstSessionId.add(cmp.Id);
        }
        String strResult='';
        Test.startTest();
        strResult = CC_EventRegistrationClass.submitBooking('zhCoziiBzcb', 'Test', 'LastName', 'testemail@test.com', 'Test Company', lstSessionId);
        Test.stopTest();
        //System.assert(strResult == 'Success');
    }

    @IsTest
    static void testSubmitBookingExistingCampaignMember() {
        Contact attendee = TestFactory.createContact('Test', 'Attendee', 'testemail@test.com');
        Event__c cmp1 = [SELECT  Id FROM Event__c WHERE Name =: 'Parent Event'];
        Participant__c cm = TestFactory.createParticipant(cmp1.Id, attendee);
        cm.Status__c = 'Invited';
        update cm;

        List<String> lstSessionId = new List<String>();
        for(Session__c cmp : [SELECT Id FROM  Session__c WHERE Name = 'Child Session']){
            lstSessionId.add(cmp.Id);
        }
        String strResult='';
        Test.startTest();
        strResult = CC_EventRegistrationClass.submitBooking('zhCoziiBzcb', 'Test', 'LastName', 'testemail@test.com', 'Test Company', lstSessionId);
        Test.stopTest();
        //System.assert(strResult == 'Success');
    }

    @IsTest
    static void testSubmitBookingAlreadyRegistered() {
        Contact attendee = TestFactory.createContact('Test', 'Attendee', 'testemail@test.com');
        Event__c cmp1 = [SELECT  Id FROM Event__c WHERE Name =: 'Parent Event'];
        Participant__c cm = TestFactory.createParticipant(cmp1.Id, attendee);
        cm.Status__c = 'Responded';
        update cm;

        List<String> lstSessionId = new List<String>();
        for(Session__c cmp : [SELECT Id FROM  Session__c WHERE Name = 'Child Session']){
            lstSessionId.add(cmp.Id);
        }
        String strResult='';
        Test.startTest();
        strResult = CC_EventRegistrationClass.submitBooking('zhCoziiBzcb', 'Test', 'LastName', 'testemail@test.com', 'Test Company', lstSessionId);
        Test.stopTest();
        //System.assert(strResult == 'Registered');
    }

}