global class UpdateNewApplicationtoContact implements Database.Batchable<sObject>, Schedulable {
    public static final String CRON_EXP = '0 0 0/1 1/1 * ? *';
     public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String vappyear = String.valueof(System.today().year() );
        query = 'Select id, Student_Name__c, Application_Type__c,First_Generation_College_Student__c, Social_Security_Number__c, COF_ID__c, Race_Ethnicity__c,  Gender__c, Gender_Description__c,Race_Ethnicity_Other__c from Application__c where (Application_Submission_Year__c = :vappyear and Application_Type__c = \'New\') ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Application__c> scope) {
      List<Contact> contactstoupdate = new List<Contact>();
                
        //Fetch the Application value from the scope into a set.
        for (Application__c app:scope){
            if (app.Application_Type__c == 'New'){
                contact c = new Contact(id = app.Student_Name__c, First_Generation_College_Student__c = app.First_Generation_College_Student__c , Social_Security_Number__c = app.Social_Security_Number__c, COF_ID__c = app.COF_ID__c  ,Race_Ethnicity__c = app.Race_Ethnicity__c, Gender__c = app.Gender__c,Gender_self_identified__c = app.Gender_Description__c, Race_Ethnicity_Other__c = app.Race_Ethnicity_Other__c);
               if (app.Social_Security_Number__c != null || app.COF_ID__c != null)     
                    c.SSN_On_File__c = true;
                contactstoupdate.add(c);
            }
        }
     
        update contactstoupdate;
        system.debug('No.of contacts updated :' + contactstoupdate.size() );
    }
    global void finish(Database.BatchableContext BC){
    }
    global void execute(SchedulableContext sc) {
      Database.executeBatch(this);
  }
}