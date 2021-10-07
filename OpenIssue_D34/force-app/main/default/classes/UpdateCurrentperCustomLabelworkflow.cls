global class UpdateCurrentperCustomLabelworkflow implements Database.Batchable<sObject> {
     public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String vprevappyear = String.valueof(System.today().year() - 1);
        query = 'Select id, name , Current_per_Custom_Label_WORKFLOW__c from Application__c where (Application_Submission_Year__c = :vprevappyear and  Current_per_Custom_Label_WORKFLOW__c = true) ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Application__c> scope) {
      List<Application__c> apptoupdate = new List<Application__c>();
                
        //Fetch the Application value from the scope into a set.
        for (Application__c app:scope){
            if (app.Current_per_Custom_Label_WORKFLOW__c == true){
                app.Current_per_Custom_Label_WORKFLOW__c = false;
            }
            
            apptoupdate.add(app);
            
        }
        update apptoupdate;
        system.debug('No.of applications updated :' + apptoupdate.size());
    }
    global void finish(Database.BatchableContext BC){
    }
}