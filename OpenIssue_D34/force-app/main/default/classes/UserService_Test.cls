@isTest
private class UserService_Test {
  	
    /*
    
  private static User createTestUser(String userProfileName, Contact con) {
    Profile p = [SELECT Id, name from Profile WHERE UserType = 'PowerCustomerSuccess' AND Name = :userProfileName];
    User u = new User(Alias = 'ajtant', Email = 'community-org@testorg.com',
                      EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US' ,
                      LocaleSidKey = 'en_US', ProfileId = p.Id, contactId = con.Id,
                      TimeZoneSidKey = 'America/Los_Angeles', UserName = 'community-org' + String.valueOf(Math.Round(Math.Random() * 1000)) + '@testorg.com');
    return u;
  }

  private static Contact createTestContact(Id contactRecordType, Id accId) {
    Contact con = new Contact(lastName = 'contact', firstName = 'test', accountId = accId, recordTypeID = contactRecordType);
    insert con;
    return con;
  }

  @isTest
  static void testAssignPublicGroupsForCommunityUsers() {

    map<String, Id> recordMap = new map<String, Id>();
    for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE (sobjecttype = 'Contact') OR (sobjecttype = 'Account')]) {
      recordMap.put(rt.name, rt.Id);
    }

    Contact con1;
    Contact con2;
    Contact con3;
    User user1;
    User user2;
    User user3;
    User thisUser = [Select Id from User where Id = :UserInfo.getUserId()];
    System.runAs(thisUser) {
      Account acc = new Account(name = 'test school account', recordTypeID = recordMap.get('College/University'));
      insert acc;
      con1 = createTestContact(recordMap.get('General'), acc.Id);
      user1 = createTestUser('College - Student Finance', con1);
      insert user1;
        
      con2 = createTestContact(recordMap.get('General'), acc.Id);
      user2 = createTestUser('DSF - Advisor (external)', con2);
      insert user2;
      con3 = createTestContact(recordMap.get('General'), acc.Id);
      user3 = createTestUser('DSF - Advisor (external)', con3);
      insert user3;
    }

    Test.startTest();
    CommunitiesUserPermissionService.userPermissionsForCommunity();
    String devName = 'grp_' + con1.accountId;
    list<Group> groupResults = [SELECT Id FROM Group WHERE developerName = :devName];
    system.assertEquals(1, groupResults.size(), 'Should have 1 Group');

    integer memberCount = [SELECT count() FROM GroupMember Where userOrGroupId = :groupResults[0].Id];
    //system.assertEquals(3, memberCount, 'Should have 3 more group members then the intial count');
    Test.stopTest();
  }
    
  */
}