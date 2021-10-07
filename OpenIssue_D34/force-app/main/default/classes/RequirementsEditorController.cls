global with sharing class RequirementsEditorController {
  public RequirementsEditorController() {}

  @RemoteAction
  global static list<RequirementsWorksheet> getReqWorksheets() {
    list<User> uList = [SELECT contact.accountId FROM User WHERE Id = :UserInfo.getUserId()];
    Id currentAccountId = uList.isEmpty() ? null : uList[0].contact.accountId;
    Date d = Date.today();
    String lastYear = d.month() > 4 ? String.valueOf(d.addYears(-1).year()) : String.valueOf(d.addYears(-2).year());

    list<Application__c> appList = [SELECT
                                    Student_Name__c,
                                    Student_Name__r.Birthdate,
                                    Student_Name__r.Cohort__r.Name,
                                    Student_Name__r.Name,
                                    Student_Name__r.Current_College_ID__c,
                                    Id,
                                    Dev_Ed_Math_Completed__c,
                                    Dev_Ed_English_Completed__c,
                                    Dev_Ed_Math_Term_Completed__c,
                                    Dev_Ed_English_Term_Completed__c,
                                    Application_Submission_Year__c,
                                    Last_Spring_College_Selection__c,
                                    Dev_Ed_Comments__c,
                                    LastModifiedDate
                                    FROM Application__c
                                    WHERE (Student_Name__r.Cohort__r.Name = '2014' OR Student_Name__r.Cohort__r.Name = '2015' OR Student_Name__r.Cohort__r.Name = '2016')
                                    AND (Dev_Ed_Req_Complete__c = 'No' OR Dev_Ed_Req_Complete__c = 'In Progress')
                                    AND Enrolled_Previous_Year__c = 'Yes'
                                    AND Student_Name__r.DPSID__c != '000000'
                                    AND Application_Submission_Year__c = '2017'
                                    AND Dev_Ed_Editor_Filter__c = 'Include in Dev Ed Editor'
                                    AND Last_Spring_College_Selection__c = :currentAccountId];

    list<RequirementsWorksheet> rwList = new list<RequirementsWorksheet>();
    for (Application__c app : appList) {
      RequirementsWorksheet rw = new RequirementsWorksheet();
      rw.Id = app.Id;
      rw.devEdMathComplete = app.Dev_Ed_Math_Completed__c;
      rw.devEdEnglishComplete = app.Dev_Ed_English_Completed__c;
      rw.devEdEnglishTermComplete = app.Dev_Ed_English_Term_Completed__c;
      rw.devEdMathTermComplete = app.Dev_Ed_Math_Term_Completed__c;
      rw.devEdComments = app.Dev_Ed_Comments__c;
      rw.studentId = app.Student_Name__c;
      rw.studentName = app.Student_Name__r.Name;
      rw.birthdate = app.Student_Name__r.Birthdate;
      rw.cohort = app.Student_Name__r.Cohort__r.Name;
      rw.year = app.Application_Submission_Year__c;
      rw.lastModifiedDate = app.LastModifiedDate;
      rw.studentIdAtCollege = app.Student_Name__r.Current_College_ID__c;
      rwList.add(rw);
    }
    return rwList;
  }

  global class RequirementsWorksheet {
    public String devEdMathComplete {get; set;}
    public String devEdEnglishComplete {get; set;}
    public String devEdEnglishTermComplete {get; set;}
    public String devEdMathTermComplete {get; set;}
    public String devEdComments {get; set;}
    public String studentId {get; set;}
    public String studentName {get; set;}
    public Date birthdate {get; set;}
    public String cohort {get; set;}
    public String year {get; set;}
    public String Id {get; set;}
    public Datetime lastModifiedDate {get; set;}
    public String studentIdAtCollege {get; set;}
  }

  @RemoteAction
  global static map<String, list<Schema.PicklistEntry>> getSelectOptions() {
    map<String, list<Schema.PicklistEntry>> optionsMap = new map<String, list<Schema.PicklistEntry>>();

    Schema.DescribeFieldResult fr1 = Application__c.Dev_Ed_Math_Completed__c.getDescribe();
    optionsMap.put('Dev_Ed_Math_Completed__c', fr1.getPicklistValues());

    Schema.DescribeFieldResult fr2 = Application__c.Dev_Ed_English_Completed__c.getDescribe();
    optionsMap.put('Dev_Ed_English_Completed__c', fr2.getPicklistValues());

    Schema.DescribeFieldResult fr3 = Application__c.Dev_Ed_English_Term_Completed__c.getDescribe();
    optionsMap.put('Dev_Ed_English_Term_Completed__c', fr3.getPicklistValues());

    Schema.DescribeFieldResult fr4 = Application__c.Dev_Ed_Math_Term_Completed__c.getDescribe();
    optionsMap.put('Dev_Ed_Math_Term_Completed__c', fr4.getPicklistValues());

    return optionsMap;
  }

  @RemoteAction
  global static RequirementsWorksheet updateApplication(RequirementsWorksheet rw) {
    if(rw.Id != null) {
      Application__c app = new Application__c();
      app.Id = rw.Id;
      app.Dev_Ed_Math_Completed__c = rw.devEdMathComplete;
      app.Dev_Ed_English_Completed__c = rw.devEdEnglishComplete;
      app.Dev_Ed_English_Term_Completed__c = rw.devEdEnglishTermComplete;
      app.Dev_Ed_Math_Term_Completed__c = rw.devEdMathTermComplete;
      app.Dev_Ed_Comments__c = rw.devEdComments;
      update app;
    }
    return rw;
  }
}