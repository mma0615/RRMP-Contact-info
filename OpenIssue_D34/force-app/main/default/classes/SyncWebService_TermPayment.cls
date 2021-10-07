@RestResource(urlMapping='/TermPayments/v0.1/*')
global with sharing class SyncWebService_TermPayment {
    @HttpGet
    global static List<Student_Term_Payments__c> getTermPayments() {
        
        RestRequest req = RestContext.request;
        String reqLocation = req.remoteAddress;
        System.debug('Request from IP: ' + reqLocation);
        
		// Confirm user has permissions to this object.        
        if(Schema.SObjectType.Student_Term_Payments__c.isAccessible() ) {

            // Pull last successful sync date from External_Access_Log__c and set asOfDate
            AggregateResult[] lastSync = [SELECT MAX(Access_Date__c) date
                                               FROM External_Access_Log__c
                                               WHERE Status__c = 'Successful' AND
                                          Object_Queried__c = 'Student Term Payments'];
            DateTime asOfDate = DateTime.valueOf(lastSync[0].get('date'));

            // Create new log stub.
			External_Access_Log__c newLog = new External_Access_Log__c(Access_Date__c=DateTime.now(),
                                                      Status__c='Starting',Access_Server_Process__c=reqLocation,
                                                      Object_Queried__c='Student Term Payments');
            System.debug('Access from ' + reqLocation);
            Insert newLog;
    

            List<Student_Term_Payments__c> stPayments = [SELECT Payment_Date__c, Student_Term__c,
                                                       Student_Term__r.Application__r.Student_Name__r.ApplydID__c,
                                                       Student_Term__r.Application__r.ApplydID__c
                                                       FROM Student_Term_Payments__c
                                                       WHERE SystemModStamp > :asOfDate AND
                                                        Student_Term__r.isCurrentTerm__c = TRUE];        
            
    		newLog.Rows_pulled__c = stPayments.size();
            newLog.Status__c = 'Successful';
            update newLog;

            return stPayments;
        }
        else {
            // access check failed, create error log entry.
			External_Access_Log__c newLog = new External_Access_Log__c(Access_Date__c=DateTime.now(),
                                                      Status__c='Error',Object_Queried__c='Student Term Payments',
                                                      Access_Server_Process__c=reqLocation,
                                                      Notes__c='Requester failed Schema.SObjectType.Student_Term_Payments__c.isAccessible() check.');
            System.debug('Access from ' + reqLocation);
            System.debug('Requester failed Schema.SObjectType.Student_Term_Payments__c.isAccessible() check.');
            Insert newLog;

            List<Student_Term_Payments__c> empty = new List<Student_Term_Payments__c>();
            return empty;
        }
        
    }
}