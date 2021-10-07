@RestResource(urlMapping='/FAFSA/v0.1/*')
global with sharing class SyncWebService_FAFSA {
    // Example get method that will query and return a Contact
    @HttpGet
    global static List<FAFSA_Detail__c> getFAFSA() {

        RestRequest req = RestContext.request;
        String reqLocation = req.remoteAddress;
        System.debug('Request from IP: ' + reqLocation);
        
        // Confirm user has permissions to this object.        
        if(Schema.SObjectType.FAFSA_Detail__c.isAccessible() ) {
        
        	// First pull last successful sync date from External_Access_Log__c and set asOfDate
            AggregateResult[] lastSync = [SELECT MAX(Access_Date__c) date
                                          FROM External_Access_Log__c
                                          WHERE Status__c = 'Successful' AND
                                          Object_Queried__c = 'FAFSA Details'];
            DateTime asOfDate = DateTime.valueOf(lastSync[0].get('date'));
    
            // Create new log stub.
			External_Access_Log__c newLog = new External_Access_Log__c(Access_Date__c=DateTime.now(),
                                                      Status__c='Starting',Access_Server_Process__c=reqLocation,
                                                      Object_Queried__c='FAFSA Details');
            System.debug('Access from ' + reqLocation);
            Insert newLog;
    
    
            List<FAFSA_Detail__c> fafsas = [SELECT FAFSA_Completed_Date__c,FAFSA_Proof_Submission_Date__c,
                                               FAFSA_Requirement_Status__c,
                                               Student__r.ApplydID__c
                                               FROM FAFSA_Detail__c
                                               WHERE SystemModStamp > :asOfDate];
    		newLog.Rows_pulled__c = fafsas.size();
            newLog.Status__c = 'Successful';
            update newLog;
     
            return fafsas;
        }
        else {
            // access check failed, create error log entry.
			External_Access_Log__c newLog = new External_Access_Log__c(Access_Date__c=DateTime.now(),
                                                      Status__c='Error',Object_Queried__c='FAFSA Details',
                                                      Access_Server_Process__c=reqLocation,
                                                      Notes__c='Requester failed Schema.SObjectType.FAFSA_Detail__c.isAccessible() check.');
            System.debug('Access from ' + reqLocation);
            System.debug('Requester failed Schema.SObjectType.FAFSA_Detail__c.isAccessible() check.');
            Insert newLog;

           List<FAFSA_Detail__c> empty = new List<FAFSA_Detail__c>();
            return empty;
        }
        
    }
}