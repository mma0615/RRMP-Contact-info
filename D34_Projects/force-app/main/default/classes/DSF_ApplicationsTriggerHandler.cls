public class DSF_ApplicationsTriggerHandler
{
    public static void bind_application_status_to_contact(List<Application__c> lstApplications)
    {
        Set<Id> setContactIds = new Set<Id>();
        for(Application__c app : lstApplications)
        {
            setContactIds.add(app.Student_Name__c);
        }
        List<Contact> lstContacts = [SELECT Id, Application_Status__c, App_Status_Detail__c
                                     FROM Contact
                                     WHERE Id in :setContactIds];

        for(Application__c app : lstApplications)
        {
            if(app.isCurrentApplication__c)
            {
                for(Contact c : lstContacts)
                {
                    if(c.Id == app.Student_Name__c)
                    {
                        c.Application_Status__c = app.Application_Status__c;
                        c.App_Status_Detail__c = app.App_Status_Detail__c;
                    }
                }
            }
        }
        update lstContacts;
    }
}