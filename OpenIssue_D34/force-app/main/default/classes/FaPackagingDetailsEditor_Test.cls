@isTest
private class FaPackagingDetailsEditor_Test {
  private static list<Contact> createTestContacts(list<Account> accList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    Id genRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId();
    list<Contact> objList = new list<Contact>();
    for(integer i = 0; i < accList.size(); i++) {
      Contact obj = new Contact();
      obj.lastName = 'Contact ' + i;
      obj.firstName = 'Test';
      obj.Student_Status__c = 'Recipient';
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
    list<Application__c> objList = new list<Application__c>();
    for(integer i = 0; i < conList.size(); i++) {
      if(conList[i].recordTypeId == stRT) {
        Application__c obj = new Application__c();
        obj.student_name__c = conList[i].Id;
        Integer yearToCreate = Date.today().month() > 6 ? Date.today().year() : Date.today().addYears(-1).year();
        obj.Application_Submission_Year__c = String.valueOf(yearToCreate);
        obj.application_status__c = 'Scholar';
        objList.add(obj);
      }
    }
    insert objList;
    return objList;
  }

  private static list<Student_Term__c> createTestStudent_Terms(list<Application__c> appList, list<Account> uniList) {
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

  @isTest
  static void testFAPackagingDetailsController() {
    integer testSize = 5;

    list<Account> accList = createTestAccounts(testSize);
    list<Contact> conList = createTestContacts(accList);
    list<Application__c> appList = createTestApplications(conList);
    list<Student_Term__c> stList = createTestStudent_Terms(appList, accList);

    PageReference pageRef = Page.RequirementsEditor;
    Test.setCurrentPage(pageRef);

    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

    Account acc = new Account(name='Test College',recordTypeId=AccountRecordTypeInfo .get('College/University').getRecordTypeId());
    insert acc;

    Contact con1 = new Contact(lastName='Contact', firstName = 'Test',Student_Status__c='Recipient');
    insert con1;

    Integer yearToCreate = Date.today().month() > 4 ? Date.today().year() : Date.today().addYears(-1).year();
    Application__c app = new Application__c();
    app.Student_Name__c = con1.Id;
    app.Application_Submission_Year__c = String.valueOf(yearToCreate);
    insert app;

    Student_Term__c st1 = new Student_Term__c();
    st1.College_or_University__c = acc.Id;
    st1.Application__c = app.Id;
    st1.isCurrentTerm__c = true;
    insert st1;


    Test.startTest();
    FAPackagingDetailsController ctrl = new FAPackagingDetailsController();
    FAPackagingDetailsIframeController iFrameCtrl = new FAPackagingDetailsIframeController();
    list<FAPackagingDetailsController.FAPackagingDetails> stResults = FAPackagingDetailsController.getFAPackagingDetails();
    system.assertNotEquals(stResults, null);  
    map<String,list<Schema.PicklistEntry>> optionsMap = FAPackagingDetailsController.getSelectOptions();
    if (stResults != null && stResults.size() > 0 ){
    FAPackagingDetailsController.FAPackagingDetails stResult = FAPackagingDetailsController.updateFAPackagingDetails(stResults[0]);
    system.assertNotEquals(stResults, null);
    }
    Test.stopTest();
  }
}