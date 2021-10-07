global class UpdateSpringCollegeAttended implements Database.Batchable<sObject> {
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String vprevappyear = String.valueof(System.today().year() - 1);
        query = 'Select id, Name, Student_Name__r.Spring_College_Selection__c, Application_Submission_Year__c from Application__c where (Application_Submission_Year__c = :vprevappyear and Application_Status__c = \'Finalist\') ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Application__c> scope) {
        String vspringyear = 'Spring ' + System.today().year();
        list<Student_term__c> springlist = [select id, Name, Application__c,College_or_University__r.Name, Student_Name__c from Student_term__c where Term_Year__c =:vspringyear 
                                            and (Enrollment_Type__c = 'Full Time Plus (15 or more credit hours)'
                                                 or Enrollment_Type__c = 'Full Time (12 - 14 credit hours)'
                                                 or Enrollment_Type__c = '3/4 Time (9 - 11 credit hours)'
                                                 or Enrollment_Type__c = 'Half Time (6 - 8 credit hours)'
                                                 or Enrollment_Type__c = 'Less than Half time (5 or less credit hours)'
                                                 or ( Enrollment_Status__c != 'Not Enrolled' and Enrollment_Status__c != ''))];
        map<id, Student_term__c> studentmap = new map<id, Student_term__c>();
        //map the student term to the Application
        for(Student_term__c st: springlist){
            studentmap.put(St.Application__c,st);
        }
        system.debug('size'+ studentmap.size());
        
        list<contact> ctlisttoupdate = new list<contact>();
        
        for(Application__c ap: scope) {
            Student_Term__c extraFieldsForCurrentStudentTerm = studentmap.get(ap.id);   
            if (extraFieldsForCurrentStudentTerm != null){
                contact c = new Contact(id = ap.Student_Name__c, Spring_College_Selection__c =  extraFieldsForCurrentStudentTerm.College_or_University__r.Name  );
                ctlisttoupdate.add(c);
            }   
        }
        update ctlisttoupdate;
        system.debug('contactlist to update'+ ctlisttoupdate.size());
        
    }
    global void finish(Database.BatchableContext BC){
    }
}