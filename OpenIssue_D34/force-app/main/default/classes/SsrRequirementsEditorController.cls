global with sharing class SsrRequirementsEditorController {
  public SsrRequirementsEditorController() {}

    
  @RemoteAction
  global static list<RequirementsWorksheet> getStudentTerms() {
    List<User> uList = [SELECT contact.accountId FROM User WHERE Id = :UserInfo.getUserId()];
      system.debug('ulist' + ulist);
    Id currentSchoolId = !uList.isEmpty() ? uList[0].contact.accountId : null;
      system.debug(' currentSchoolId' + currentSchoolId);
    list<Student_Term__c> stList = [SELECT
                                    Application__c,
                                    Application__r.Student_Name__c,
                                    Application__r.Student_Name__r.Birthdate,
                                    Application__r.Student_Name__r.Cohort__r.Name,
                                    Application__r.Student_Name__r.FirstName,
                                    Application__r.Student_Name__r.LastName,
                                    Application__r.Student_Name__r.MobilePhone,
                                    Application__r.Student_Name__r.Email,
                                    //Reason_for_Ineligibility__c,
                                    Final_Award_Status__c,                                
                                    Id,
                                    LastModifiedDate,
                                    Projected_College_Graduation_Comments__c,
                                    //Projected_College_Graduation_Term__c,
                                    //Projected_College_Graduation_Year__c,
                                    Projected_Coll__c,
                                    SSR_Requirements_Completed__c,
                                    Student_ID_at_College__c,
                                    SSR_Comments__c,
                                    At_Risk_of_Stopping_Out__c,
                                    //At_Risk_Reason_Current_Term__c,
                                    At_Risk_Comments__c,
                                    Projected_to_Graduate_end_of_acad_yr__c
                                    FROM Student_Term__c
                                    WHERE isCurrentTerm__c = true AND
                                    Term_Eligibility_Status__c = 'Finalist'
                                    AND College_or_University__c = :currentSchoolId
                                    AND (Application__r.Mid_Year_Transfer_School__c = null
                                    OR Application__r.Mid_Year_Transfer_School__c = :currentSchoolId)];

    list<RequirementsWorksheet> rwList = new list<RequirementsWorksheet>();
    for (Student_Term__c st : stList) {
      RequirementsWorksheet rw = new RequirementsWorksheet();
      rw.applicationId = st.Application__c;
      rw.studentId = st.Application__r.Student_Name__c;
      // rw.birthdate = st.Application__r.Student_Name__r.Birthdate;
      rw.birthdate = st.Application__r.Student_Name__r.Birthdate != null ? st.Application__r.Student_Name__r.Birthdate.format() : null; 
      rw.cohort = st.Application__r.Student_Name__r.Cohort__r.Name;
      rw.studentName = st.Application__r.Student_Name__r.LastName + ', ' + st.Application__r.Student_Name__r.FirstName;
      rw.awardstatus = st.Final_Award_Status__c;
      rw.id = st.Id;
      rw.lastModifiedDate = st.LastModifiedDate;
      rw.graduationcomments = st.Projected_College_Graduation_Comments__c;
      rw.graduationTermYear = st.Projected_Coll__c  ;
      //rw.graduationterm = st.Projected_College_Graduation_Term__c;
      //rw.graduationyear = st.Projected_College_Graduation_Year__c;
      rw.ssrComments = st.SSR_Comments__c;
      rw.ssrRequirementsCompleted = st.SSR_Requirements_Completed__c;
      rw.studentIdAtCollege = st.Student_ID_at_College__c;
    //  rw.atRiskComments = st.At_Risk_Comments__c;
      //rw.atRiskReason = st.At_Risk_Reason_Current_Term__c;
     // rw.atRiskOfStoppingOut = st.At_Risk_of_Stopping_Out__c;
      rw.mobilePhone = st.Application__r.Student_Name__r.MobilePhone;
      rw.email = st.Application__r.Student_Name__r.Email;
      rw.graduationEOY = st.Projected_to_Graduate_end_of_acad_yr__c;
      rwList.add(rw);
    }
    return rwList;
  }

  global class RequirementsWorksheet {
    public String applicationId {get; set;}
    public String studentId {get; set;}
    public String studentName {get; set;}
    public String birthdate {get; set;}
    public String cohort {get; set;}
    public String awardstatus {get; set;}
    public String ssrComments {get; set;}
    public String graduationEOY {get; set;}
    public String Id {get; set;}
    public Datetime lastModifiedDate {get; set;}
    public String graduationComments {get; set;}
    public String graduationTermYear {get;set;}
   // public String graduationTerm {get; set;}
   // public String graduationYear {get; set;}
    public String ssrRequirementsCompleted {get; set;}
    public String studentIdAtCollege {get; set;}
  //  public String atRiskComments {get; set;}
    //public String atRiskReason {get; set;}
   // public String atRiskOfStoppingOut {get; set;}
    public String mobilePhone {get; set;}
    public String email {get; set;}
    
  }

  @RemoteAction
  global static map<String, list<Schema.PicklistEntry>> getSelectOptions() {
    map<String, list<Schema.PicklistEntry>> optionsMap = new map<String, list<Schema.PicklistEntry>>();
      system.debug('getlist otpions');

   // optionsMap.put('At_Risk_of_Stopping_Out__c', Student_Term__c.At_Risk_of_Stopping_Out__c.getDescribe().getPicklistValues());
    
    //optionsMap.put('At_Risk_Reason_Current_Term__c', Student_Term__c.At_Risk_Reason_Current_Term__c.getDescribe().getPicklistValues());

    optionsMap.put('SSR_Requirements_Completed__c', Student_Term__c.SSR_Requirements_Completed__c.getDescribe().getPicklistValues());

  //  optionsMap.put('Projected_College_Graduation_Term__c', Student_Term__c.projected_college_graduation_term__c.getDescribe().getPicklistValues());

    optionsMap.put('Projected_to_Graduate_end_of_acad_yr__c', Student_Term__c.Projected_to_Graduate_end_of_acad_yr__c.getDescribe().getPicklistValues());
    optionsMap.put('Projected_Coll__c', Student_Term__c.Projected_Coll__c.getDescribe().getPicklistValues());  
    return optionsMap;
  }

  @RemoteAction
  global static void notifyUpdatesDone(){
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    List<User> uList = [SELECT contact.firstName, contact.lastName, contact.Account.Name FROM User WHERE Id = :UserInfo.getUserId()];
    if (!uList.isEmpty()) {
      email.setSubject('SSR Updates Done for ' + uList[0].contact.Account.Name + ' by ' +
                      uList[0].contact.firstName + ' ' + uList[0].contact.lastName);  
      email.setPlainTextBody(uList[0].contact.firstName + ' ' + uList[0].contact.lastName + 
          ' from ' + uList[0].contact.Account.Name + ' has submitted data for SSR.');  
      List<String> sendTo = new List<String>();
      sendTo.add('collegeinfo@denverscholarship.org');    
      email.setToAddresses(sendTo);
      Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
    }
  }
    
  @RemoteAction
  global static RequirementsWorksheet updateStudentTerm(RequirementsWorksheet rw) {
    if (rw.Id != null) {
      Student_Term__c st = new Student_Term__c();
      st.SSR_Requirements_Completed__c = rw.ssrRequirementsCompleted;
      st.Student_ID_at_College__c = rw.studentIdAtCollege;
      st.SSR_Comments__c = rw.ssrComments;
      st.Projected_Coll__c  = rw.graduationTermYear;
      //st.Projected_College_Graduation_Term__c = rw.graduationterm;
      //st.Projected_College_Graduation_Year__c = rw.graduationyear;
      st.Projected_College_Graduation_Comments__c = rw.graduationcomments;
   //   st.At_Risk_Comments__c = rw.atRiskComments;
      //st.At_Risk_Reason_Current_Term__c = rw.atRiskReason;
    //  st.At_Risk_of_Stopping_Out__c = rw.atRiskOfStoppingOut;
      st.Projected_to_Graduate_end_of_acad_yr__c = rw.graduationEOY;
  
      st.Id = rw.Id;
      update st;
    }
    if(rw.studentId != null) {
      Contact con = new Contact();
      con.Id = rw.studentId;
      con.MobilePhone = rw.mobilePhone;
      con.Email = rw.email;
      update con;
    }
    return rw;
  }
}