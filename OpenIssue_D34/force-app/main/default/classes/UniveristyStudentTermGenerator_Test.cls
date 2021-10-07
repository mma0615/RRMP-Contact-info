@isTest
private class UniveristyStudentTermGenerator_Test {
private static list<Contact> createTestContacts(list<Account> accList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    Id genRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId();
    list<Contact> objList = new list<Contact>();
    for(integer i = 0; i < accList.size(); i++) {
      Contact obj = new Contact();
      obj.lastName = 'Contact ' + i;
      obj.firstName = 'Test';
      obj.recordTypeId = stRT;
      objList.add(obj);
    }
    for(integer i = 0; i < accList.size(); i++) {
      Contact obj = new Contact();
      obj.lastName = 'Uni User ' + i;
      obj.firstName = 'Test';
      obj.accountId = accList[i].Id;
      obj.recordTypeId = genRT;
      objList.add(obj);
    }
    insert objList;
    return objList;
  }

  private static list<Account> createTestAccounts(integer testSize) {
    Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
    list<Account> objList = new list<Account>();
    for(integer i = 0; i < testSize; i++) {
      Account obj = new Account();
      obj.recordTypeId = collRT;
      obj.name = 'Test Account ' + i;
      objList.add(obj);
    }
    insert objList;
    return objList;
  }

  private static list<Application__c> createTestApplications(list<Contact> conList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    Integer yearToCreate = Date.today().month() > 4 ? Date.today().year() : Date.today().addYears(-1).year();
    list<Application__c> objList = new list<Application__c>();
    for(integer i = 0; i < conList.size(); i++) {
      if(conList[i].recordTypeId == stRT) {
        Application__c obj = new Application__c();
        obj.student_name__c = conList[i].Id;
        obj.application_status__c = 'Finalist';
        obj.Application_Submission_Year__c = String.valueOf(yearToCreate);
        objList.add(obj);
      }
    }
    insert objList;
    return objList;
  }
    
    private static list<Student_Term__c> createPreviousStudentTerms(list<Application__c> Applist, List<Account> uniList) {
        
    List<Student_Term__c> sts = new List<Student_Term__c>();
   /* List<Id> stIds = new List<Id>();*/
    //Set common fields for all entries
    for (Application__c app : appList) {
      sts.add(new Student_Term__c(Application__c=app.Id,Term_Semester__c='Fall',
                                  FA_File_Completion_Deadline__c = 'Yes',
                                  Has_Student_Completed_4_Year_Degree__c = 'No',
								  //Term_End_Date__c=Date.valueOf(CURRENT_COHORT + '-11-20'),
                                  Term_Eligibility_Status__c='Finalist',
                                  SSR_Completed_Previous_Term__c = 'Yes',
                                  SAP_Status__c = 'Meeting SAP',
                                  Rec_d_Pymt_Previous_Term__c = 'No',
                                  Test_Only__c = true,
                                  College_or_University__c = uniList[0].Id,
                                  student_id_at_college__c = String.valueOf(Math.round(Math.random() * 10000))));  
    }
    
    insert sts;
    return sts;
   
  }

  @isTest
  static void testGenerateStudentTermsForUniversities() {
    integer testSize = 5;

    list<Account> accList = createTestAccounts(testSize);
    list<Contact> conList = createTestContacts(accList);
    list<Application__c> appList = createTestApplications(conList);
    list<Student_term__c> stlist = createPreviousStudentTerms(appList, accList);
    list<String> accIds = new list<Id>();
    for(Application__c app : appList) {
        system.debug('before add-' + app.School_Name__c);
      accIds.add(app.School_Name__c);
        
    }
      system.debug('accIds-' + accIds);
    Test.startTest();
    String jobId = UniveristyStudentTermGeneratorService.generateStudentTermsForUniversities(accIds, 'Fall');
    system.debug([Select School_Name__c,Id,DPSID__c,iscurrentapplication__c,Application_Submission_Year__c,application_status__c From Application__c Where School_Name__c In :accIds]);
    Test.stopTest();
    integer stResult = [Select count() from Student_Term__c Where college_or_university__c In :accIds];
    System.assertEquals(stResult, testSize);
  }
}