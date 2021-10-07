@RestResource(urlMapping='/Scholars/v0.1/*')
global with sharing class SyncWebService_Scholar {
    @HttpGet
    global static List<Contact> getScholar() {

        RestRequest req = RestContext.request;
        String reqLocation = req.remoteAddress;
        System.debug('Request from IP: ' + reqLocation);
        
        // Confirm user has permissions to this object.        
        if(Schema.SObjectType.Contact.isAccessible() ) {
            // Pull last successful sync date from External_Access_Log__c and set asOfDate
            AggregateResult[] lastSync = [SELECT MAX(Access_Date__c) date
                                               FROM External_Access_Log__c
                                               WHERE Status__c = 'Successful' AND
                                          Object_Queried__c = 'Contacts'];
            // Note the date is no longer used in the Contact query below.
            //DateTime asOfDate = DateTime.valueOf(lastSync[0].get('date'));
            
            System.debug('Request Authorization: ' + req.headers.get('Authorization'));
            System.debug('Request remoteAddress: ' + req.remoteAddress );
            
            // Create new log stub.
            External_Access_Log__c newLog = new External_Access_Log__c(Access_Date__c=DateTime.now(),
                                                      Status__c='Starting',Access_Server_Process__c=reqLocation,
                                                      Object_Queried__c='Contacts');
            System.debug('Access from ' + reqLocation);
            Insert newLog;
    
            List<Contact> scholars = [SELECT Name, ApplydID__c, DPSID__c,Birthdate,Ineligible_to_Reapply_Ever__c,
                                        Cohort_text__c,Applyd_Student_Notes__c,Event_Name_1__c,Event_Details_1__c,
                                      Date_and_Time_01__c,Location_1__c,Event_Name_2__c,Event_Details_2__c,
                                      Date_and_Time_02__c,Location_2__c,Event_Name_3__c,Event_Details_3__c,
                                      Date_and_Time_03__c,Location_3__c
                                      FROM Contact
                                      WHERE Applyd_Fields_Modified__c = TRUE];
            newLog.Rows_pulled__c = scholars.size();
            newLog.Status__c = 'Successful';
            update newLog;
            
            List<Contact> scholarsToResetFlagList = new List<Contact>();
            for (Contact s : scholars) {
                Contact newS = new Contact();
                newS.Id = s.Id;
                newS.Applyd_Fields_Modified__c = FALSE;
                scholarsToResetFlagList.add(newS);
            }
            update scholarsToResetFlagList;

            return scholars;
                
        }
        else {
            // access check failed, create error log entry.
            External_Access_Log__c newLog = new External_Access_Log__c(Access_Date__c=DateTime.now(),
                                                      Status__c='Error',Object_Queried__c='Contacts',
                                                      Access_Server_Process__c=reqLocation,
                                                      Notes__c='Requester failed Schema.SObjectType.Contact.isAccessible() check.');
            System.debug('Access from ' + reqLocation);
            System.debug('Requester failed Schema.SObjectType.Contact.isAccessible() check.');
            Insert newLog;

            List<Contact> empty = new List<Contact>();
            return empty;
        }
    }
}