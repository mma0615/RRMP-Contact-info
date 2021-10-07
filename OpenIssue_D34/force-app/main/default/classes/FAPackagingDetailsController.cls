global with sharing class FAPackagingDetailsController {
  public FAPackagingDetailsController() {}

  @RemoteAction
  global static list<FAPackagingDetails> getFAPackagingDetails() {
    list<User> uList = [SELECT contact.accountId FROM User WHERE Id = :UserInfo.getUserId()];
    Id currentAccountId = uList.isEmpty() ? null : uList[0].contact.accountId;
    list<Application__c> appList = [SELECT
                                    Student_Name__c,
                                    Student_Name__r.Birthdate,
                                    Student_Name__r.Cohort__r.Name,
                                    Student_Name__r.Name,
                                    Student_Name__r.Current_College_ID__c,
                                    Id,
                                    LastModifiedDate,
                                    Application_Submission_Year__c,
                                    Total_Budget__c,
                                    Tuition_Fees__c,
                                    Unmet_Need__c,
                                    Federal_Grants__c,
                                    State_Grants__c,
                                    Institutional_Scholarships__c,
                                    Other_Outside_Scholarships__c,
                                    Accepted_Workstudy__c,
                                    Accepted_Student_Loans__c,
                                    Parent_Loans__c,
                                    Other_Aid_Resources__c,
                                    Notes_if_Other_please_specify__c,
                                    FA_Priority_Deadline_Met__c
                                    FROM Application__c
                                    WHERE isCurrentApplication__c = true
                                    AND Student_Name__r.Student_Status__c = 'Recipient'
                                    AND (Mid_Year_Transfer_School__c = :currentAccountId OR (Mid_Year_Transfer_School__c = null AND School_Name__c = :currentAccountId))];

    map<Id,FAPackagingDetails> fpdList = new map<Id,FAPackagingDetails>();
    for (Application__c app : appList) {
      FAPackagingDetails fpd = new FAPackagingDetails();
      fpd.Id = app.Id;
      fpd.studentId = app.Student_Name__c;
      fpd.studentName = app.Student_Name__r.Name;
      fpd.birthdate = app.Student_Name__r.Birthdate;
      fpd.cohort = app.Student_Name__r.Cohort__r.Name;
      fpd.lastModifiedDate = app.LastModifiedDate;
      fpd.studentIdAtCollege = app.Student_Name__r.Current_College_ID__c;
      fpd.totalBudget = app.Total_Budget__c;
      fpd.tuitionFees = app.Tuition_Fees__c;
      fpd.unmetNeed = app.Unmet_Need__c;
      fpd.federalGrants = app.Federal_Grants__c;
      fpd.stateGrants = app.State_Grants__c;
      fpd.institutionalScholarships = app.Institutional_Scholarships__c;
      fpd.otherOutsideScholarships = app.Other_Outside_Scholarships__c;
      fpd.acceptedWorkstudy = app.Accepted_Workstudy__c;
      fpd.acceptedStudentLoans = app.Accepted_Student_Loans__c;
      fpd.parentLoans = app.Parent_Loans__c;
      fpd.otherAidResources = app.Other_Aid_Resources__c;
      fpd.notesIfOtherPleaseSpecify = app.Notes_if_Other_please_specify__c;
      fpd.fAPriorityDeadlineMet = app.FA_Priority_Deadline_Met__c;
      fpd.finalScholarshipPaymentAmount = 0;
      fpd.applicationSubmissionYear = app.Application_Submission_Year__c;
      fpdList.put(fpd.Id, fpd);
    }

    for(Student_Term__c st : [SELECT Id,Final_Scholarship_Payment_Amount__c,Final_EFC_Upon_FA_File_Completion__c,Application__c,isCurrentTerm__c FROM Student_Term__c WHERE Application__c IN :fpdList.keySet()]) {
      FAPackagingDetails fpd = fpdList.get(st.Application__c);
      if(fpd != null) {
        if(st.isCurrentTerm__c) {
          fpd.finalEFCUponFAFileCompletion = st.Final_EFC_Upon_FA_File_Completion__c;
        }
        if(st.Final_Scholarship_Payment_Amount__c != null) {
          fpd.finalScholarshipPaymentAmount += st.Final_Scholarship_Payment_Amount__c;
        }
      }
    }
    return fpdList.values();
  }

  global class FAPackagingDetails {
    public String studentId {get; set;}
    public String studentName {get; set;}
    public Date birthdate {get; set;}
    public String cohort {get; set;}
    public String Id {get; set;}
    public Datetime lastModifiedDate {get; set;}
    public String studentIdAtCollege {get; set;}
    public Double totalBudget {get; set;}
    public Double tuitionFees {get; set;}
    public Double unmetNeed {get; set;}
    public Double federalGrants {get; set;}
    public Double stateGrants {get; set;}
    public Double institutionalScholarships {get; set;}
    public Double otherOutsideScholarships {get; set;}
    public Double acceptedWorkstudy {get; set;}
    public Double acceptedStudentLoans {get; set;}
    public Double parentLoans {get; set;}
    public Double otherAidResources {get; set;}
    public String notesIfOtherPleaseSpecify {get; set;}
    public String fAPriorityDeadlineMet {get; set;}
    public Double finalScholarshipPaymentAmount {get; set;}
    public Double finalEFCUponFAFileCompletion {get; set;}
    public String applicationSubmissionYear {get; set;}
  }

  @RemoteAction
  global static map<String, list<Schema.PicklistEntry>> getSelectOptions() {
    map<String, list<Schema.PicklistEntry>> optionsMap = new map<String, list<Schema.PicklistEntry>>();

    Schema.DescribeFieldResult fr1 = Application__c.FA_Priority_Deadline_Met__c.getDescribe();
    optionsMap.put('FA_Priority_Deadline_Met__c', fr1.getPicklistValues());

    return optionsMap;
  }

  @RemoteAction
  global static FAPackagingDetails updateFAPackagingDetails(FAPackagingDetails fpd) {
    if (fpd.Id != null) {
      Application__c app = new Application__c();
      app.Id = fpd.Id;
      app.Total_Budget__c = fpd.totalBudget;
      app.Tuition_Fees__c = fpd.tuitionFees;
      app.Federal_Grants__c = fpd.federalGrants;
      app.State_Grants__c = fpd.stateGrants;
      app.Institutional_Scholarships__c = fpd.institutionalScholarships;
      app.Other_Outside_Scholarships__c = fpd.otherOutsideScholarships;
      app.Accepted_Workstudy__c = fpd.acceptedWorkstudy;
      app.Accepted_Student_Loans__c = fpd.acceptedStudentLoans;
      app.Parent_Loans__c = fpd.parentLoans;
      app.Other_Aid_Resources__c = fpd.otherAidResources;
      app.Notes_if_Other_please_specify__c = fpd.notesIfOtherPleaseSpecify;
      app.FA_Priority_Deadline_Met__c = fpd.fAPriorityDeadlineMet;
      update app;
      Application__c appAfterUpdate = [SELECT Unmet_Need__c FROM Application__c WHERE Id = :app.Id];
      fpd.unmetNeed = appAfterUpdate.Unmet_Need__c;
    }
    return fpd;
  }
}