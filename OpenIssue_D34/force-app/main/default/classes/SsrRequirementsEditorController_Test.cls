@isTest
private class SsrRequirementsEditorController_Test {

    // Using (SeeAllData=true) because permissions and configuration of a regular user are needed for testing to function.
  @isTest(SeeAllData=true)
  static void testSsrRequirementsEditorController() {

    PageReference pageRef = Page.SsrRequirementsEditor;
    Test.setCurrentPage(pageRef);

    Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account;
    Map<String,Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
    Map<String, DSF_Term_Settings__c> settings = createDsfSettings();

/*  *** Commenting out to run as actual user in system 
    Account acc = new Account(name='Test College',recordTypeId=AccountRecordTypeInfo .get('College/University').getRecordTypeId());
    insert acc;
*/    
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
 
    System.RunAs(u) {

        SsrRequirementsEditorController ctrl = new SsrRequirementsEditorController();
        SsrRequirementsEditorIframeController ctrlIframe = new SsrRequirementsEditorIframeController();
        list<SsrRequirementsEditorController.RequirementsWorksheet> stResults = SsrRequirementsEditorController.getStudentTerms();
        map<String,list<Schema.PicklistEntry>> optionsMap = SsrRequirementsEditorController.getSelectOptions();
        if (stResults != null && stResults.size() > 0 ){
        SsrRequirementsEditorController.RequirementsWorksheet stResult = SsrRequirementsEditorController.updateStudentTerm(stResults[0]);
        system.assertNotEquals(stResults, null);
        }
        
//        system.assertNotEquals(stResult, null);
    }
    Test.stopTest();
  }

  @isTest(SeeAllData=true)
  static void TestnotifyUpdatesDone() {
    Profile p = [SELECT Id FROM Profile WHERE Name='College - FA&CC Combined'];  
    User u = [SELECT Id FROM User WHERE ProfileId = :p.Id AND IsActive = TRUE Limit 1];
    Test.startTest();
      System.RunAs(u){
        SsrRequirementsEditorController.notifyUpdatesDone();  
      }  
    Test.stopTest();
  }

  @isTest    
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
}