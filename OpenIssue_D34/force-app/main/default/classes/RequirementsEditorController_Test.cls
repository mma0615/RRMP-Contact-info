@isTest
private class RequirementsEditorController_Test {

  private static list<Contact> createTestContacts(list<Account> accList,Cohort__c coh) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    Id genRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId();
    list<Contact> objList = new list<Contact>();
    for(integer i = 0; i < accList.size(); i++) {
      Contact obj = new Contact();
      obj.lastName = 'Contact ' + i;
      obj.firstName = 'Test';
      obj.recordTypeId = stRT;
      obj.Cohort__c = coh.Id;
      obj.DPSID__c = '999999';
      obj.AccountId = accList[i].Id;
      objList.add(obj);
    }
    for(integer i = 0; i < accList.size(); i++) {
      Contact obj = new Contact();
      obj.lastName = 'Uni User ' + i;
      obj.firstName = 'Test';
      obj.AccountId = accList[i].Id;
      obj.recordTypeId = genRT;
      obj.Cohort__c = coh.Id;
      obj.DPSID__c = '999999';
      objList.add(obj);
    }
    insert objList;
    return objList;
  }

/* Commented out - Need to use accounts from system to have correct permissions    
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
*/
    
  private static list<Application__c> createTestApplications(list<Contact> conList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    list<Application__c> appList = new list<Application__c>();
    for(Contact c : conList) {
      if(c.recordTypeId == stRT) {
        Application__c app = new Application__c();
        app.student_name__c = c.Id;
        app.Dev_Ed_Req_Complete__c = 'No';
        app.Enrolled_Previous_Year__c = 'Yes';
        app.Application_Submission_Year__c = '2017';
        app.Dev_Ed_Editor_Filter__c = 'Include in Dev Ed Editor';
        app.Last_Spring_College_Selection__c = c.AccountId;
        appList.add(app);
      }
    }
    insert appList;
    return appList;
  }

/*  private static list<Student_Term__c> createTestStudent_Terms(list<Application__c> appList, list<Account> uniList) {
    Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
    list<Student_Term__c> objList = new list<Student_Term__c>();
    for(integer i = 0; i < appList.size(); i++) {
      Student_Term__c obj = new Student_Term__c();
      obj.college_or_university__c = uniList[i].Id;
      obj.Term_Eligibility_Status__c = 'Scholar';
      obj.Application__c = appList[i].Id;
      obj.Term_Semester__c = Math.mod(i, 2) == 0 ? 'Fall' : 'Spring';
      objList.add(obj);
    }
    insert objList;
    return objList;
  }
*/

  @isTest(SeeAllData=true)
  static void testRequirementsEditor_Controller() {
    integer testSize = 5;
//    Commented out because ReqEditor queries on a static list of cohorts
//        Integer yearToCreate = Date.today().month() > 4 ? Date.today().year() : Date.today().addYears(-1).year();
    Cohort__c co = new Cohort__c();
//    co.Name = String.valueOf(yearToCreate - 1);
    co.Name = '2016';
    insert co;
      

//    list<Account> accList = createTestAccounts(testSize);
    Profile p = [SELECT Id FROM Profile WHERE Name='College - FA&CC Combined'];  
    User u = [SELECT Id, Contact.AccountId, ContactId, ProfileId FROM User WHERE ProfileId = :p.Id AND IsActive = TRUE Limit 1];
    Account acc = [Select Id From Account Where Id = :u.Contact.AccountId];
    list<Account> accList = new list<Account>();
    accList.add(acc);  
      
    list<Contact> conList = createTestContacts(accList,co);
    list<Application__c> appList = createTestApplications(conList);
//    list<Student_Term__c> stList = createTestStudent_Terms(appList, accList);

    PageReference pageRef = Page.RequirementsEditor;
    Test.setCurrentPage(pageRef);

    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();


/*    Account acc = new Account(name='Test College',recordTypeId=AccountRecordTypeInfo .get('College/University').getRecordTypeId());
    insert acc;

    Contact con1 = new Contact(lastName='Contact', firstName = 'Test',Cohort__c = co.Id);
    insert con1;

    Application__c app = new Application__c();
    app.Student_Name__c = con1.Id;
    app.Application_Submission_Year__c = String.valueOf(yearToCreate - 1);
    app.application_status__c = 'Scholar';
    app.Dev_Ed_Req_Complete__c = 'No';
    insert app;

    Application__c app2 = new Application__c();
    app2.Student_Name__c = con1.Id;
    app2.Application_Submission_Year__c = String.valueOf(yearToCreate);
    app2.application_status__c = 'Scholar';
    insert app2;
*/

    Test.startTest();
    System.RunAs(u) {
        RequirementsEditorController ctrl = new RequirementsEditorController();
        RequirementsEditorIframeController ctrlIframe = new RequirementsEditorIframeController();
        list<RequirementsEditorController.RequirementsWorksheet> stResults = RequirementsEditorController.getReqWorksheets();
        System.debug('Applications found: ' + stResults);
        map<String,list<Schema.PicklistEntry>> optionsMap = RequirementsEditorController.getSelectOptions();
        RequirementsEditorController.RequirementsWorksheet stResult = RequirementsEditorController.updateApplication(stResults[0]);
        system.assertNotEquals(stResults, null);
    }
    Test.stopTest();
  }
}