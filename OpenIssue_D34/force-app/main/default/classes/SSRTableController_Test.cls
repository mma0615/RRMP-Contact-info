/**
 * Created by Joe on 6/14/2020.
 */


@isTest
private class SSRTableController_Test {



// Using (SeeAllData=true) because permissions and configuration of a regular user are needed for testing to function.
@isTest(SeeAllData=false)
 static void testSSRTableController2() {
    TestUtility tu = testUtility.getInstance();



// Setup StudentAdvisor Contact and related community user

    User u;
    user AdvisorUser;
    Account acc;
   // the account owner of a portal user must have a role or causes an error.
    User thisUser = [SELECT Id
                       FROM User
                     //   WHERE Id = :UserInfo.getUserId()
                         WHERE     profile.name ='System Administrator' and UserRoleId!='' and isActive =true
                      limit 1];
   // System.runAs (thisUser) {
         acc = new Account(name='University of Colorado Denver',recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId());
        insert acc;
        /* */
        Profile p1 = [SELECT Id FROM Profile WHERE Name='College - FA&CC Combined'];
        contact AdvisorCon = new Contact(LastName ='testCon',AccountId = acc.Id);
        insert AdvisorCon;
        UserRole r = [SELECT Id FROM UserRole WHERE Name='University of Colorado Denver Customer User'];

          AdvisorUser= new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1.Id, country='United States',IsActive =true,
                ContactId = AdvisorCon.Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');

        insert AdvisorUser;
//    }

// Setup generic test data
    integer testSize = 5;

    list<Account> accList = tu.createTestAccounts(testSize);
    list<Contact> conList = tu.createTestContacts(accList);
    list<Contact> stuList = tu.createTestStudents(accList);
    list<Application__c> appList = tu.createTestApplications(stuList,acc);
    list<Student_Term__c> stList = tu.createTestStudent_Terms(appList, accList);

Test.startTest();
  System.runAs(AdvisorUser) {




    SSRTableController ctrl = new SSRTableController();
    List<Student_Term__c> lST = SSRTableController.getRecords();
  //   system.assert(lST.size() >0 );  // there are  student term records for this user
    Map<String,String> mPLV =  SSRTableController.getPicklistValues('Student_Term__c','Applied_for_ASSET__c');
    system.assert(mPLV.size() >0);  // The PL field has values

    Id uId= SSRTableController.fetchUser();
     system.assertEquals(acc.Id,uId);  // The current Advisor user has the UC Denver Account ID

    Boolean bFD = SSRTableController.fetchDate(true,acc.Id);  // based on custom settings of user don't assert
    string sRecordsToUpdate=JSON.serialize(stList);
    string sUpdateRslts= SSRTableController.updateRecordsv2(sRecordsToUpdate);
    SSRTableController.notifyUpdatesDone();
  }


Test.stopTest();
}
/*
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
*/

}