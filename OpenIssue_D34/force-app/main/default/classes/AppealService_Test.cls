@isTest
private class AppealService_Test {
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

  private static list<Appeal__c> createTestAppeals(list<Student_Term__c> stList) {
    list<Appeal__c> objList = new list<Appeal__c>();
    for(integer i = 0; i < stList.size(); i++) {
      Appeal__c obj = new Appeal__c();
      obj.Student_Term__c = stList[i].Id;
      obj.Application__c = stList[i].Application__c;
      objList.add(obj);
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
      obj.Application__c = appList[i].Id;
      obj.Term_Semester__c = Math.mod(i, 2) == 0 ? 'Fall' : 'Spring';
      obj.Term_Eligibility_Status__c = 'Scholar';
      objList.add(obj);
    }
    insert objList;
    return objList;
  }

  static testMethod void testSetStudentForAppeal() {
    integer testSize = 5;

    list<Account> accList = createTestAccounts(testSize);
    list<Contact> conList = createTestContacts(accList);
    list<Application__c> appList = createTestApplications(conList);
    list<Student_Term__c> stList = createTestStudent_Terms(appList, accList);
    list<Appeal__c> appealList = createTestAppeals(stList);
    Test.StartTest();
    for(Appeal__c appeal : [Select Student__c From Appeal__c Where ID In :appealList]) {
      System.assertNotEquals(null, appeal.Student__c);
    }
    Test.StopTest();
  }
}