@isTest
private class StudentTermService_Test {
  private static List<Contact> createTestContacts(List<Account> accList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    Id genRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId();
    List<Contact> objList = new List<Contact>();
    for (Integer i = 0; i < accList.size(); i++) {
      Contact obj = new Contact();
      obj.lastName = 'Contact ' + i;
      obj.firstName = 'Test';
      obj.recordTypeId = stRT;
      objList.add(obj);
    }
    for (Integer i = 0; i < accList.size(); i++) {
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
      Student_Term__c obj = new Student_Term__c();
      obj.college_or_university__c = uniList[i].Id;
      obj.Application__c = appList[i].Id;
      obj.Term_Semester__c = Math.mod(i, 2) == 0 ? 'Fall' : 'Spring';
      obj.Term_Eligibility_Status__c = 'Scholar';
      obj.student_id_at_college__c = String.valueOf(Math.round(Math.random() * 10000));
      objList.add(obj);
    }
    insert objList;
    return objList;
  }

  private static Map<String, DSF_Term_Settings__c> createDsfSettings() {

    Map<String, DSF_Term_Settings__c> settings = new Map<String, DSF_Term_Settings__c>();
    DSF_Term_Settings__c setting2 = new DSF_Term_Settings__c();
    setting2.Name = 'Fall Default';
    setting2.Term_Name__c = 'Fall';
    setting2.Default_Setting__c = true;
    setting2.Term_Start_Date__c = Date.today().addDays(-20);
    setting2.Term_End_Date__c = Date.today().addDays(30);

    DSF_Term_Settings__c setting1 = new DSF_Term_Settings__c();
    setting1.Name = 'Spring Default';
    setting1.Term_Name__c = 'Spring';
    setting1.Default_Setting__c = true;
    setting1.Term_Start_Date__c = Date.today().addDays(90);
    setting1.Term_End_Date__c = Date.today().addDays(150);

    settings.put(setting1.Term_Name__c, setting1);
    settings.put(setting2.Term_Name__c, setting2);
    insert settings.values();
    return settings;
  }

  static testMethod void testSetStartAndEndDatesForStudentTerm() {
    Integer testSize = 5;
    Test.StartTest();
    Map<String, DSF_Term_Settings__c> settings = createDsfSettings();
    List<Account> accList = createTestAccounts(testSize);
    List<Contact> conList = createTestContacts(accList);
    List<Application__c> appList = createTestApplications(conList);
    List<Student_Term__c> stList = createTestStudent_Terms(appList, accList);

    for (Student_Term__c st : [Select Term_Start_Date__c, Term_End_Date__c, Term_Semester__c From Student_Term__c Where Id In :stList]) {
      System.assertEquals(st.Term_Start_Date__c, settings.get(st.Term_Semester__c).Term_Start_Date__c, 'start date should equal custom setting start date');
      System.assertEquals(st.Term_End_Date__c, settings.get(st.Term_Semester__c).Term_End_Date__c, 'end date should equal custom setting end date');
    }
    Test.StopTest();
  }

  static testMethod void testSetCurrentStudentCollegeId() {
    Integer testSize = 1;
    Test.StartTest();
    Map<String, DSF_Term_Settings__c> settings = createDsfSettings();
    List<Account> accList = createTestAccounts(testSize);
    List<Contact> conList = createTestContacts(accList);
    List<Application__c> appList = createTestApplications(conList);
    List<Student_Term__c> stList = createTestStudent_Terms(appList, accList);

    for (Student_Term__c st : [Select student_id_at_college__c, application__r.student_name__r.current_college_id__c From Student_Term__c Where Id In :stList]) {
      System.assertEquals(st.student_id_at_college__c, st.application__r.student_name__r.current_college_id__c, 'College Student ID should be same on student term and contact if student term is current oldest');
    }
    Test.StopTest();
  }

  static testMethod void testSetCurrentStudentTerms() {
    Integer testSize = 1;
    Test.StartTest();
    Map<String, DSF_Term_Settings__c> settings = createDsfSettings();
    List<Account> accList = createTestAccounts(testSize);
    List<Contact> conList = createTestContacts(accList);
    List<Application__c> appList = createTestApplications(conList);
    List<Student_Term__c> stList = createTestStudent_Terms(appList, accList);

    for (Student_Term__c st : [Select Id, Term_Start_Date__c, Term_End_Date__c, iscurrentterm__c From Student_Term__c Where Id In :stList]) {
      if (st.term_end_date__c > date.today() && st.term_end_date__c > date.today()) {
        System.assertEquals(st.iscurrentterm__c, true, 'Student term should be current in a current term');
      } else {
        System.assertEquals(st.iscurrentterm__c, false, 'Student term should not be current in a current term');
      }
    }
    Test.StopTest();
  }
}