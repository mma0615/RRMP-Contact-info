@RestResource(urlMapping='/Appeals/v0.1/*')
global with sharing class SyncWebService_Appeal {


    @HttpGet
    global static List<Appeal__c> getAppeal() {

        RestRequest req = RestContext.request;
        String reqLocation = req.remoteAddress;
        System.debug('Request from IP: ' + reqLocation);
        
        // Confirm user has permissions to this object.        
        if(Schema.SObjectType.Appeal__c.isAccessible() ) {
        
            // Pull last successful sync date from External_Access_Log__c and set asOfDate
            AggregateResult[] lastSync = [SELECT MAX(Access_Date__c) date
                                               FROM External_Access_Log__c
                                               WHERE Status__c = 'Successful' AND
                                          Object_Queried__c = 'Appeals'];
            DateTime asOfDate = DateTime.valueOf(lastSync[0].get('date'));
    
            // Create new log stub.
            External_Access_Log__c newLog = new External_Access_Log__c(Access_Date__c=DateTime.now(),
                                                      Status__c='Starting',Access_Server_Process__c=reqLocation,
                                                      Object_Queried__c='Appeals');
            System.debug('Access from ' + reqLocation);
            Insert newLog;
    
    
            // Determine Application Submission Year to check for: 
            Date current = Date.today();
            String appYearCheck;
            
            /* OLD CODE - Checks for current year or current and previous year, depending on date:
            //   If the current date is greater than 5/1, then only the current year is queried for. 
            //   If the date is 5/1 or less, than the current year and the previous year is queried for.
            //   
            If (current.month() > 5 || (current.month()== 5 && current.day() > 1) || current.year() == 2018) {
                appYearCheck = '(Application__r.Application_Submission_Year__c = \'' + String.valueOf(current.year()) + '\')';
            } 
            else {
                appYearCheck = '(Application__r.Application_Submission_Year__c = \'' + String.valueOf(current.year()) + '\' OR ' +
                    'Application__r.Application_Submission_Year__c = \'' + String.valueOf(current.year()-1) + '\')';
            }
            */ 
            
            // NEW CODE - Just check for the current application year. Restore this code after testing.
            appYearCheck = '(Application__r.Application_Submission_Year__c = \'' + String.valueOf(current.year()) + '\')';
            
            // TESTING ONLY - Remove after testing is done.
            //appYearCheck = '(Application__r.Application_Submission_Year__c = \'2018\')';

            List<Appeal__c> appeals = Database.query('SELECT Status__c,Appeal_Form_Notes__c,Application__c,' +
                                       'Application__r.Student_Name__r.ApplydID__c,' +
                                       'Application__r.ApplydID__c ' +
                                       'FROM Appeal__c ' +
                                       'WHERE SystemModStamp > :asOfDate AND ' +
                                       appYearCheck);
            newLog.Rows_pulled__c = appeals.size();
            newLog.Status__c = 'Successful';
            update newLog;

            return appeals;
        }
        else {
            // access check failed, create error log entry.
            External_Access_Log__c newLog = new External_Access_Log__c(Access_Date__c=DateTime.now(),
                                                      Status__c='Error',Object_Queried__c='Appeals',
                                                      Access_Server_Process__c=reqLocation,
                                                      Notes__c='Requester failed Schema.SObjectType.Appeal__c.isAccessible() check.');
            System.debug('Access from ' + reqLocation);
            System.debug('Requester failed Schema.SObjectType.Appeal__c.isAccessible() check.');
            Insert newLog;

            List<Appeal__c> empty = new List<Appeal__c>();
            return empty;
        }
        
    }
}