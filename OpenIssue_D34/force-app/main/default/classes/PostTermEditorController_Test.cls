@isTest
private class PostTermEditorController_Test {

    // Using (SeeAllData=true) because permissions and configuration of a regular user are needed for testing to function.
  @isTest(SeeAllData=true)
  static void testPostTermEditorController() {

    PageReference pageRef = Page.PostTermEditor;
    Test.setCurrentPage(pageRef);

    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

    Profile p = [SELECT Id FROM Profile WHERE Name='College - FA&CC Combined'];  
// Uncomment the production line for uploading to production, switch out for Dev line for testing in Dev.
// Production
  UserRole r = [SELECT Id FROM UserRole WHERE Name='University of Colorado Denver Customer User'];
// Dev 
 //  UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName='UniversityofDenverCustomerUser1'];
   
    User u = [SELECT Id, Contact.AccountId, ContactId, ProfileId FROM User 
              WHERE ProfileId = :p.Id 
              AND UserRoleId = :r.Id
              AND IsActive = TRUE Limit 1];
    Account acc = [Select Id From Account Where Id = :u.Contact.AccountId];
      system.debug('user-' + u.id +  'account-' + acc.Id );

/*  With SeeAllData=true, entries will be pulled from regular data, example must be added there.
 *     
    Id genRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId();  
    Contact con1 = new Contact(lastName='Contact', firstName = 'Test', recordTypeId=genRT, accountId=acc.Id);
    insert con1;

    Application__c app = new Application__c();
    app.Student_Name__c = con1.Id;
    app.Application_Submission_Year__c = String.valueOf(Date.today().year());
    insert app;

    Student_Term__c st1 = new Student_Term__c();
    st1.College_or_University__c = acc.Id;
    st1.Application__c = app.Id;
    st1.Term_Semester__c = 'Fall';
    Date now = System.Date.today();
    st1.Term_End_Date__c = Date.today().addDays(30);
    st1.Term_Eligibility_Status__c = 'Finalist';
    st1.Enrollment_Type__c = 'Full Time Incentive (15 or more credit hours)';
    st1.Calculated_Award_Amount__c = 1000;
    
    insert st1;
*/    
    Test.startTest();
 
    System.RunAs(u) {

        PostTermEditorController ctrl = new PostTermEditorController();
        PostTermEditorIframeController ctrlIframe = new PostTermEditorIframeController();
        list<PostTermEditorController.PostTermWorksheet> stResults = PostTermEditorController.getStudentTerms();
        map<String,list<Schema.PicklistEntry>> optionsMap = PostTermEditorController.getSelectOptions();
        system.assertNotEquals(stResults, null);
        if (stResults != null && stResults.size() > 0) {
        PostTermEditorController.PostTermWorksheet stResult = PostTermEditorController.updateStudentTerm(stResults[0]);
        system.assertNotEquals(stResult, null);
        }
    }
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void TestnotifyUpdatesDone() {
    Profile p = [SELECT Id FROM Profile WHERE Name='College - FA&CC Combined'];  
    User u = [SELECT Id FROM User WHERE ProfileId = :p.Id AND IsActive = TRUE Limit 1];
    Test.startTest();
      System.RunAs(u){
        PostTermEditorController.notifyUpdatesDone();  
      }  
    Test.stopTest();
  }
    
}