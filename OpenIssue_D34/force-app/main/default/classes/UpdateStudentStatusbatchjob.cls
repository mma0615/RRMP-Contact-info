global class UpdateStudentStatusbatchjob implements Database.Batchable<sObject> {
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'select id, name ,Student_Status__c, Total_Payments_Amount_to_Date__c from Contact where Student_Status__c = \'Non-Applicant\' ' ;  
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> contacttoUpdateList = new List<Contact>();
 
        //Fetch the Contact value from the scope into a set.
        for(Contact cobj : scope){
            if (cobj.Total_Payments_Amount_to_Date__c > 0){
                cobj.Student_Status__c = 'Scholar';
            }
            else 
                cobj.Student_Status__c = ' ';
            
            contacttoUpdateList.add(cobj);
        } //for
        update contacttoUpdateList;
       system.debug('contacts to update ' + contacttoUpdateList.size());
    }
    global void finish(Database.BatchableContext BC){
    }
}