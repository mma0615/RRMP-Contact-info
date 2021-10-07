global class UpdateCurrentTermMarker implements Database.Batchable<sObject> {
    public String query;
    static list<Application_Season_Cycle__mdt> appseason = [SELECT Id,Current_Term__c,Current_Term_1__c,Previous_Term__c, Previous_Term_1__c FROM Application_Season_Cycle__mdt LIMIT 1];
    static String currentterm = appseason.size() > 0 && appseason[0].Current_Term__c != null ? appseason[0].Current_Term__c : null;
    static String currentterm1 = appseason.size() > 0 && appseason[0].Current_Term_1__c != null ? appseason[0].Current_Term_1__c : null;
    static String previousterm = appseason.size() > 0 && appseason[0].Previous_Term__c != null ? appseason[0].Previous_Term__c : null;
    static String previousterm1 = appseason.size() > 0 && appseason[0].Previous_Term_1__c != null ? appseason[0].Previous_Term_1__c : null;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select id, name , isCurrentTerm__c, Student_Name__c,Term_year__c from Student_Term__c where (Term_Year__c =:currentterm  or Term_Year__c =:currentterm1 or Term_year__c =:previousterm or Term_Year__c =:previousterm1) ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Student_Term__c> scope) {
      List<Student_term__c> sttoupdate = new List<Student_term__c>();
        
      //Fetch the Student term value from the scope into a set.
        for (Student_Term__c stu:scope){
            system.debug(' Student tt' + stu.Student_Name__c + stu.name +  stu.Term_year__c  + 'current' + currentterm  );
            if(stu.Term_year__c == currentterm || stu.Term_year__c == currentterm1){
                system.debug('inside if' + currentterm);
                
                stu.isCurrentTerm__c = true;
                
            }
            else if (stu.Term_year__c == previousterm ||  stu.Term_year__c == previousterm1 ){
                system.debug('inside else' + previousterm );
                stu.isCurrentTerm__c = false;
                
            }
            sttoupdate.add(stu);
            system.debug(sttoupdate);
            
        }
        update sttoupdate;
    }
    global void finish(Database.BatchableContext BC){
    }
}