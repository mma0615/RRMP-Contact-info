@isTest
private class StudentTermBatchService_Test {
  private static List<Contact> createTestContacts(List<Account> accList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    List<Contact> objList = new List<Contact>();
    for (Integer i = 0; i < accList.size(); i++) {
      for (Integer x = 0; x < 5; x++) {
        Contact obj = new Contact();
        obj.lastName = 'Contact ' + i + '-' + x;
        obj.firstName = 'Test';
        obj.recordTypeId = stRT;
        obj.DPSID__c = accList[i].Id;
        objList.add(obj);
      }
    }
    insert objList;
    return objList;
  }

  private static List<Account> createTestAccounts(Integer testSize) {
    Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
    List<Account> objList = new List<Account>();
    for (Integer i = 0; i < testSize; i++) {
      Account obj = new Account();
      obj.recordTypeId = collRT;
      obj.name = 'Test Account ' + i;
      objList.add(obj);
    }
    insert objList;
    return objList;
  }
  
  private static List<Application__c> createTestApplications(List<Contact> conList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    List<Application__c> objList = new List<Application__c>();
    for (Integer i = 0; i < conList.size(); i++) {
      if (conList[i].recordTypeId == stRT) {
        Application__c obj = new Application__c();
        obj.student_name__c = conList[i].Id;
        obj.school_name__c = conList[i].DPSID__c;
        objList.add(obj);
      }
    }
    insert objList;
    return objList;
  }

  private static List<Student_Term__c> createTestStudent_Terms(List<Application__c> appList, List<Account> uniList) {
    Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
    List<Student_Term__c> objList = new List<Student_Term__c>();
    for (Integer i = 0; i < appList.size(); i++) {
      for (Integer x = 0; x < uniList.size(); x++) {
        Student_Term__c obj = new Student_Term__c();
        obj.college_or_university__c = uniList[x].Id;
        obj.Application__c = appList[i].Id;
        obj.Term_Semester__c = Math.mod(i, 2) == 0 ? 'Fall' : 'Spring';
        obj.Term_Eligibility_Status__c = 'Scholar';
        obj.student_id_at_college__c = String.valueOf(Math.round(Math.random() * 10000));
        objList.add(obj);
      }
    }
    insert objList;
    return objList;
  }

  private static Map<String, DSF_Term_Settings__c> createDsfSettings() {

    Map<String, DSF_Term_Settings__c> settings = new Map<String, DSF_Term_Settings__c>();
    DSF_Term_Settings__c setting2 = new DSF_Term_Settings__c();
    setting2.Name = 'Fall';
    setting2.Term_Name__c = 'Fall';
    setting2.Term_Start_Date__c = Date.today().addDays(-20);
    setting2.Term_End_Date__c = Date.today().addDays(30);

    DSF_Term_Settings__c setting1 = new DSF_Term_Settings__c();
    setting1.Name = 'Spring';
    setting1.Term_Name__c = 'Spring';
    setting1.Term_Start_Date__c = Date.today().addDays(90);
    setting1.Term_End_Date__c = Date.today().addDays(150);

    settings.put(setting1.Name, setting1);
    settings.put(setting2.Name, setting2);
    insert settings.values();
    return settings;
  }

  private static User createTestUser(String userProfileName, Contact con) {
    Profile p = [SELECT Id, name from Profile WHERE UserType = 'PowerCustomerSuccess' AND Name = :userProfileName];
    User u = new User(Alias = 'ajtant', Email = 'community-org@testorg.com',
                      EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                      LocaleSidKey = 'en_US', ProfileId = p.Id, contactId = con.Id,
                      TimeZoneSidKey = 'America/Los_Angeles', UserName = 'community-org' + String.valueOf(Math.Round(Math.Random() * 1000)) + '@testorg.com');
    return u;
  }

  private static Contact createTestContact(Id contactRecordType, Account acc) {
    Contact con = new Contact(lastName = 'contact', firstName = 'test', accountId = acc.Id, recordTypeID = contactRecordType);
    insert con;
    return con;
  }

  static testMethod void testUserPermissionsForStudentTerm() {
    map<String, Id> recordMap = new map<String, Id>();
    for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE (sobjecttype = 'Contact') OR (sobjecttype = 'Account')]) {
      recordMap.put(rt.name, rt.Id);
    }

    Integer testSize = 5;
    Map<String, DSF_Term_Settings__c> settings = createDsfSettings();
    List<Account> accList = createTestAccounts(testSize);
    Contact con1 = createTestContact(recordMap.get('General'), accList[0]);
    User user1 = createTestUser('College - Student Finance', con1);
    List<Contact> conList = createTestContacts(accList);
    List<Application__c> appList = createTestApplications(conList);
    List<Student_Term__c> stList = createTestStudent_Terms(appList, accList);
   
    Test.startTest();
    System.schedule('Student Terms Permissions Batch Job Test', '0 0 0/1 1/1 * ? *', new StudentTermsBatchService());
    Test.stopTest();

    //System.runAs(user1) {
      list<Contact> conResult = [Select Id From Contact Where Id In :conList];
      System.assertEquals(conList.size(), conResult.size());
    //}


  }
}