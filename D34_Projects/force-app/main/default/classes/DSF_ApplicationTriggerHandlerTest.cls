@isTest
private class DSF_ApplicationTriggerHandlerTest {
    @testSetup static void setup()
    {
        Contact con = new Contact();
        con.LastName = Datetime.now().format() + 'nourishment provided';
        insert con;

        Application__c app = new Application__c();
        app.Student_Name__c = con.Id;
        app.Application_Status__c = 'Finalist';
        insert app;

        app.Application_Status__c = 'Pending';
        update app;
    }

    @isTest static void bind_application_status_to_contact_test()
    {
        Contact con = [SELECT Application_Status__c, Id, LastName
                       FROM Contact
                       WHERE LastName LIKE '%nourishment provided%'][0];
        Application__c app = [SELECT Application_Status__c, Student_Name__c
                              FROM Application__c
                              WHERE Student_Name__c = :con.Id][0];

        //System.assertEquals(app.Application_Status__c, con.Application_Status__c);
    }
}