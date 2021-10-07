global class UpdateLastCollegeAttended implements Database.Batchable<sObject> {
     public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'select id, Name, Cohort_text__c, DPSID__c, Last_College_Attended__c, (Select  Name, Fall_Enrollment__c, Spring_Enrollment__c, Academic_Year__c  from  NSC_Enrollments__r order by Academic_Year__c  Desc limit 1 ) ' +
               ' from Contact where (Student_Status__c = \'Scholar\' )';
                             
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> contacttoUpdateList = new List<Contact>();
        
        
        //Fetch the Contact value from the scope into a set.
        for(Contact cobj : scope){
          if(cobj.NSC_Enrollments__r.size() > 0){
            PSI_Enrollment_Record__c nsc = cobj.NSC_Enrollments__r[0];
      
              if (nsc.Spring_Enrollment__c != null)
              {
                  
                  cobj.Last_College_Attended__c = nsc.Spring_Enrollment__c;
                  cobj.Last_College_Academic_Year__c = nsc.Academic_Year__c;       
              }
              else
              { 
                  cobj.Last_College_Attended__c = nsc.Fall_Enrollment__c;
                  cobj.Last_College_Academic_Year__c = nsc.Academic_Year__c; 
              }
              system.debug('Name- ' + cobj.Name + ' Cohort-' + cobj.Cohort_text__c + ' last college' +  cobj.Last_College_Attended__c );
            
            contacttoUpdateList.add(cobj);
               
         } //if
      } //for

      update contacttoUpdateList;
    }
    global void finish(Database.BatchableContext BC){
    }
}