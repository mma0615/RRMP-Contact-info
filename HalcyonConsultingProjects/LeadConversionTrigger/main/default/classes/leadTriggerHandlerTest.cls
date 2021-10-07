@istest
public with sharing class leadTriggerHandlerTest 
{
    @istest
    public static void leadConversionTest() 
    {
        lead leadObj = new lead();
        leadObj.LastName = 'TestLName';
        leadObj.FirstName = 'TestFName';
        insert leadObj;

        Meeting_Notes__c meetingNotesObj = new Meeting_Notes__c();
        meetingNotesObj.Name = 'TestMeetingNote';
        meetingNotesObj.Lead_Name__c = leadObj.Id;
        insert meetingNotesObj;

        Test.startTest();               

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadObj.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        Test.stopTest();
    }
}