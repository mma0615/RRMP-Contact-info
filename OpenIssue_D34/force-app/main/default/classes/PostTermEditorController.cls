global with sharing class PostTermEditorController {
  public PostTermEditorController() {}

  @RemoteAction
  global static list<PostTermWorksheet> getStudentTerms() {
    list<DSF_Editor_Access_Settings__c> editorSettings =
      [
        SELECT Id,Term_Year__c
        FROM DSF_Editor_Access_Settings__c
        WHERE Editor_Access_Start_Date__c <= TODAY
        AND Editor_Access_End_Date__c >= TODAY
        AND Editor_Id__c = 5
        ORDER BY Default_Setting__c ASC
        LIMIT 1
      ];
    String term = editorSettings.size() > 0 && editorSettings[0].Term_Year__c != null ? editorSettings[0].Term_Year__c : null;
      system.debug( 'user id' +  UserInfo.getUserId());
    List<User> uList = [SELECT contact.accountId FROM User WHERE Id = :UserInfo.getUserId()];
    Id currentSchoolId = !uList.isEmpty() ? uList[0].contact.accountId : null;
    System.debug('Term: ' + term + ', School Id: ' + currentSchoolId);
    
    // Create list of cohort strings, -5 years to Present to +1 year, used in Student Term query
    Date now = System.Date.today();
    Integer thisYear = now.year();
    List<String> cohortList = new List<String>();
    for(Integer i=(thisYear - 5); i<=(thisYear + 1); i++)
        if (i>=2017) cohortList.add(System.String.valueOf(i));
    System.debug('Cohorts: ' + cohortList);

      list<Student_Term__c> stList = [SELECT
                                    Application__c,
                                    Application__r.Student_Name__c,
                                    Application__r.Student_Name__r.Birthdate,
                                    Application__r.Student_Name__r.Cohort__r.Name,
                                    Application__r.Student_Name__r.FirstName,
                                    Application__r.Student_Name__r.LastName,
                                    Term_Year__c,
                                    Id,
                                    LastModifiedDate,
                                    Student_ID_at_College__c,
                                    Completed_15_or_more_credit_hours__c
                                    FROM Student_Term__c
                                    WHERE 
                                    Term_Year__c = :term
                                    AND Application__r.Student_Name__r.Cohort__r.Name IN :cohortList
                                    AND Enrollment_Type__c = 'Full Time Plus (15 or more credit hours)'
                                    AND Reason_for_Ineligibility__c = 'Eligible - Award Calculated'  
                                    AND College_or_University__c = :currentSchoolId
                                    ];

    list<PostTermWorksheet> ptwList = new list<PostTermWorksheet>();
    for (Student_Term__c st : stList) {
      PostTermWorksheet ptw = new PostTermWorksheet();
      ptw.applicationId = st.Application__c;
      ptw.studentId = st.Application__r.Student_Name__c;
      ptw.birthdate = st.Application__r.Student_Name__r.Birthdate != null ? st.Application__r.Student_Name__r.Birthdate.format() : null; 
      ptw.studentName = st.Application__r.Student_Name__r.LastName + ', ' + st.Application__r.Student_Name__r.FirstName;
      ptw.id = st.Id;
      ptw.cohort = st.Application__r.Student_Name__r.Cohort__r.Name;
      ptw.lastModifiedDate = st.LastModifiedDate;
      ptw.studentIdAtCollege = st.Student_ID_at_College__c;
      ptw.completed15 = st.Completed_15_or_more_credit_hours__c;
      ptw.termYear = st.Term_Year__c;
      ptwList.add(ptw);
    }
    return ptwList;
  }

  global class PostTermWorksheet {
    public String applicationId {get; set;}
    public String studentId {get; set;}
    public String studentName {get; set;}
    public String birthdate {get; set;}
    public String cohort {get; set;}
    public String completed15 {get; set;}
    public String Id {get; set;}
    public Datetime lastModifiedDate {get; set;}
    public String studentIdAtCollege {get; set;}
    public String termYear {get; set;}
  }

  @RemoteAction
  global static map<String, list<Schema.PicklistEntry>> getSelectOptions() {
    map<String, list<Schema.PicklistEntry>> optionsMap = new map<String, list<Schema.PicklistEntry>>();
    optionsMap.put('Completed_15_or_more_credit_hours__c', Student_Term__c.Completed_15_or_more_credit_hours__c.getDescribe().getPicklistValues());
    return optionsMap;
  }

  @RemoteAction
  global static void notifyUpdatesDone(){
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    List<User> uList = [SELECT contact.firstName, contact.lastName, contact.Account.Name FROM User WHERE Id = :UserInfo.getUserId()];
    if (!uList.isEmpty()) {
      email.setSubject('Credit Completion Editor Updates Done for ' + uList[0].contact.Account.Name + ' by ' +
                      uList[0].contact.firstName + ' ' + uList[0].contact.lastName);  
      email.setPlainTextBody(uList[0].contact.firstName + ' ' + uList[0].contact.lastName + 
          ' from ' + uList[0].contact.Account.Name + ' has submitted data for Credit Completion Editor.');  
      List<String> sendTo = new List<String>();
      sendTo.add('support@denverscholarship.org');    
      email.setToAddresses(sendTo);
      Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
    }
  }
    
  @RemoteAction
  global static PostTermWorksheet updateStudentTerm(PostTermWorksheet ptw) {
    if (ptw.Id != null) {
      Student_Term__c st = new Student_Term__c();
      st.Completed_15_or_more_credit_hours__c = ptw.completed15;  
      st.Student_ID_at_College__c = ptw.studentIdAtCollege;
      st.Id = ptw.Id;
      update st;
        //recalculate the formulas after the completed _15_or_more_credit_hours__c is set to yes/no to add incentives 
      st.recalculateFormulas(); 
    }
    return ptw;
  }

}