@isTest
private class ScholarshipEditorController_Test {

  private static list<Contact> createTestStudents(list<Account> accList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    list<Contact> objList = new list<Contact>();
    for(integer i = 0; i < accList.size(); i++) {
      Contact obj = new Contact();
      obj.lastName = 'Contact ' + i;
      obj.firstName = 'Test';
      obj.recordTypeId = stRT;
      objList.add(obj);
    }
    insert objList;
    return objList;
  }
    
  private static list<Contact> createTestContacts(list<Account> accList) {
    Id genRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId();
    list<Contact> objList = new list<Contact>();
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
      obj.Term_Eligibility_Status__c = 'Finalist';
      obj.Application__c = appList[i].Id;
      obj.Term_Semester__c = Math.mod(i, 2) == 0 ? 'Fall' : 'Spring';
      obj.Has_Student_Completed_4_Year_Degree__c = 'No';
      obj.Program_Enrolled__c = 'Certificate';
      obj.Applied_for_ASSET__c = 'No';
      obj.isCurrentTerm__c = true;
      objList.add(obj);
    }
    insert objList;
    return objList;
  }

    // Using (SeeAllData=true) because permissions and configuration of a regular user are needed for testing to function.
  @isTest(SeeAllData=true)
  static void testStudentScholarshipManagement_Controller() {
/*
    integer testSize = 5;

    list<Account> accList = createTestAccounts(testSize);
    list<Contact> conList = createTestContacts(accList);
    list<Contact> stuList = createTestStudents(accList);
    list<Application__c> appList = createTestApplications(stuList);
    list<Student_Term__c> stList = createTestStudent_Terms(appList, accList);



  *** Commenting out to run as actual user in system       
    Account acc = new Account(name='Test College',recordTypeId=AccountRecordTypeInfo .get('College/University').getRecordTypeId());
    insert acc;
*/

    PageReference pageRef = Page.ScholarshipEditor;
    Test.setCurrentPage(pageRef);
      
    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

    Profile p = [SELECT Id FROM Profile WHERE Name='College - FA&CC Combined'];  
// Uncomment the production line for uploading to production, switch out for Dev line for testing in Dev.
// Production
  	UserRole r = [SELECT Id FROM UserRole WHERE Name='University of Colorado Denver Customer User'];
// Dev 
//	UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName='UniversityofDenverCustomerUser1'];
    
    User u = [SELECT Id, Contact.AccountId, ContactId, ProfileId FROM User 
              WHERE ProfileId = :p.Id 
              AND UserRoleId = :r.Id
              AND IsActive = TRUE Limit 1];
    Account acc = [Select Id From Account Where Id = :u.Contact.AccountId];

    Test.startTest();
	System.runAs(u) {
        ScholarshipEditorController ctrl = new ScholarshipEditorController();
        ScholarshipEditorIframeController ctrliFrame = new ScholarshipEditorIframeController();
        list<ScholarshipEditorController.ScholarshipWorksheet> stResults = ScholarshipEditorController.getStudentTerms();
        Boolean egtcCheck = ScholarshipEditorController.isEGTC();
        map<String,list<Schema.PicklistEntry>> optionsMap = ScholarshipEditorController.getSelectOptions();
        system.assertNotEquals(stResults, null);
        if (stResults != null && stResults.size() > 0 ){
        Id checkId = stResults[0].studentTermId;
        List<Id> idList = new List<Id>();
        idList.add(checkId);
        }
/* Commenting out mass update code.
        ScholarshipEditorController.massUpdate(idList,'Program','Doctorate');
        ScholarshipEditorController.massUpdate(idList,'Appl. ASSET','Yes');
        ScholarshipEditorController.massUpdate(idList,'4 Year Degree','Yes');
        list<Student_Term__c> stCheckList = [SELECT Id, Program_Enrolled__c, Applied_for_ASSET__c,
               Has_Student_Completed_4_Year_Degree__c FROM Student_Term__c WHERE Id = :checkId ];
        system.assertEquals(stCheckList[0].Program_Enrolled__c, 'Doctorate');
        system.assertEquals(stCheckList[0].Applied_for_ASSET__c, 'Yes');
        system.assertEquals(stCheckList[0].Has_Student_Completed_4_Year_Degree__c, 'Yes');
*/	
    }  
    Test.stopTest();
  }
    
  @isTest(SeeAllData=true)
  static void TestnotifyUpdatesDone() {
    Profile p = [SELECT Id FROM Profile WHERE Name='College - FA&CC Combined'];  
    User u = [SELECT Id FROM User WHERE ProfileId = :p.Id AND IsActive = TRUE Limit 1];
    Test.startTest();
      System.RunAs(u){
        ScholarshipEditorController.notifyUpdatesDone();  
      }  
    Test.stopTest();
  }
  
    
}