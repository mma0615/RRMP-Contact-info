@isTest(SeeAllData=true)
private class AppPermissionBatchService_Test {
  private static List<Contact> createTestContacts(List<Account> accList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    List<Contact> objList = new List<Contact>();
    for (Integer i = 0; i < accList.size(); i++) {
      for (Integer x = 0; x < 5; x++) {
        Contact obj = new Contact();
        obj.lastName = 'AppPermContact ' + i + '-' + x;
        obj.firstName = 'Test';
        obj.recordTypeId = stRT;
        obj.DPSID__c = accList[i].Id;
        objList.add(obj);
      }
    }
    insert objList;
    return objList;
  }

   private static List<Account> getUniAccounts(Integer testSize) {
    Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
    List<Account> objList = [select Id from Account where recordTypeId = :collRT LIMIT :testSize];
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
        obj.Mid_Year_Transfer_Status__c = 'Approved';
        obj.Mid_Year_Transfer_School__c = conList[i].DPSID__c;
        objList.add(obj);
      }
    }
    insert objList;
    return objList;
  }

  private static User createTestUser(String userProfileName, Contact con) {
    Profile p = [SELECT Id, name from Profile WHERE Name = :userProfileName];
    User u = new User(Alias = 'ajtant', Email = 'community-org@testorg.com',
                      EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                      LocaleSidKey = 'en_US', ProfileId = p.Id, contactId = con.Id,
                      TimeZoneSidKey = 'America/Los_Angeles', 
                      UserName = 'community-org' + String.valueOf(Math.Round(Math.Random() * 1000)) + '@testorg.com');
    return u;
  }

  private static Contact createTestContact(Id contactRecordType, Account acc, String fName) {
    Contact con = new Contact(lastName = 'Tester', firstName = fname, accountId = acc.Id, recordTypeID = contactRecordType);
    insert con;
    return con;
  }

  static testMethod void testAppPermissionBatchService_onDemand() {
    
    map<String, Id> recordMap = new map<String, Id>();
    for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE (sobjecttype = 'Contact') OR (sobjecttype = 'Account')]) {
      recordMap.put(rt.name, rt.Id);
    }
	Map<String, Group> groupMap = CommunitiesUserPermissionService.getUniversityGroups();

    Integer testSize = 5; // Note that testSize squared Applications will be created.
    List<Account> accList = getUniAccounts(testSize);
    Contact con1 = createTestContact(recordMap.get('General'), accList[0],'mainUser');
    User user1 = createTestUser('College - Student Finance', con1);
    List<Contact> conList = createTestContacts(accList);
    List<Application__c> appList = createTestApplications(conList);
    // Create one extra Account to test CommunitiesUserPermissionService code to create new sharing rules.
    Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
    Account extraUni = new Account(name='Test College01',recordTypeId = collRT);
    insert(extraUni);
    Contact extraCon = createTestContact(recordMap.get('General'), extraUni,'extraUser');
    User extraUser = createTestUser('College - Student Finance', extraCon);
    

	
    Test.startTest();
    AppPermissionBatchService.executeBatchOnDemand(10000);
//    System.schedule('Application based Permissions Batch Job', '0 0 0/1 1/1 * ? *', new AppPermissionBatchService());
    Test.stopTest();
    List<ContactShare> chkShare = [Select Id, contactId, userOrGroupId From ContactShare where contactId in :conList];
    System.debug('chkShare:' + chkShare);
    System.assertEquals(testSize * testSize, chkShare.size());

   }
    
  static testMethod void testAppPermissionBatchService_Schedule() {
     Test.startTest();
    AppPermissionBatchService.scheduleBatchJob('0 0 0/1 1/1 * ? *');
    Test.stopTest();

   }    
}