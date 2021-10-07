global class DSF_AdvisorsDataFixBatch implements Database.Batchable<sObject>{
    public String query;

    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id,AccountId,College_Account__c,(SELECT Id,School_Name__c FROM Applications__r WHERE School_Name__c != null ORDER by Application_Submission_Year__c DESC LIMIT 1) FROM Contact Where AccountId != null AND College_Account__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){
        for(Contact contactRecord :scope){
            if(contactRecord.Applications__r.size()>0){
                contactRecord.College_Account__c = contactRecord.Applications__r[0].School_Name__c;
            }else{
                contactRecord.College_Account__c = contactRecord.AccountId;
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC){
    }
}