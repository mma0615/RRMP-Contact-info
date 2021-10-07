global class PreferredName1 implements Database.Batchable<sObject> {
     public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT Id, FirstName, Preferred_Name__c FROM Contact';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> contacttoUpdateList = new List<Contact>();
        
        
        //Fetch the Contact value from the scope into a set.
        for(Contact cobj : scope){
            cobj.Preferred_Name__c = cobj.FirstName;
            contacttoUpdateList.add(cobj)  ;
        }
        
        update contacttoUpdateList;
    }
    global void finish(Database.BatchableContext BC){
    }
}