@isTest
private class ApplicationService_Test {
  //@isTest static void testSetApplicationStatus() {
  //  Id studentRT = [SELECT Id FROM RecordType WHERE sobjecttype = 'Contact' AND name = 'Student'].Id;

  //  Contact con = new Contact();
  //  con.lastName = 'Test';
  //  con.recordTypeId = studentRT;
  //  insert con;

  //  Application__c app = new Application__c();
  //  app.Student_Name__c = con.Id;
  //  insert app;

  //  Application__c app2 = new application__c();
  //  app2.Student_Name__c = con.Id;
  //  insert app2;

  //  Test.startTest();
  //  list<Application__c> appResults = [Select Id, Application_Type__c From Application__c Where (Id = :app.Id) Or (Id = :app2.Id) Order By Application_Type__c Asc];
  //  System.assertEquals('New', appResults[0].Application_Type__c);
  //  System.assertEquals('Renewal', appResults[1].Application_Type__c);
  //  Test.stopTest();
  //}

    
  @isTest static void testSetLawfulPresenceStatus() {
    Summer_Doc_Submission_Date__c summerDocSetting = new Summer_Doc_Submission_Date__c();
    summerDocSetting.Expiration_Date__c = Date.newInstance(Date.today().year(), 7, 15);
    insert summerDocSetting;

    Contact c = new Contact();
    c.LastName = 'Test';
//    c.US_Citizenship_Status__c = 'United States Citizen'; - this is now set in application first.
    insert c;

      
    Application__c app = new Application__c();
    app.Student_Name__c = c.Id;
// Need to set year so isCurrentApplication__c is set to true      
    if (Date.today().month() > 4) {
      app.Application_Submission_Year__c = String.valueOf(Date.today().year());
    }
    else {
      app.Application_Submission_Year__c = String.valueOf(Date.today().year()-1);
    }
    app.US_Citizenship_Status__c = 'United States Citizen';
    insert app;
    update c;

    Contact c2 = new Contact();
    c2.LastName = 'Test2';
    insert c2;

    Application__c app2 = new Application__c();
    app2.Student_Name__c = c2.Id;
    app2.Lawful_Presence_Docs__c = 'I-797 Approval Notice';
    app2.Lawful_Presence_Doc_Submission_Date__c = Date.newInstance(Date.today().year(), 7, 1);
    app2.Lawful_Presence_Proof_Expiration_Date__c = Date.newInstance(Date.today().year(), 9, 1);
    app2.Affirmation_Docs__c = 'Yes';
    app2.Affirmation_Date__c = Date.newInstance(Date.today().year(), 7, 1);
    app2.US_Citizenship_Status__c = 'Other/Don\'t Know';
    app2.Application_Submission_Year__c = app.Application_Submission_Year__c;
    insert app2;

    Test.startTest();

    List<Application__c> applications = [SELECT Id, Lawful_Presence_Req_Met__c FROM Application__c WHERE Id = :app.Id];
    System.assertEquals('N/A', applications[0].Lawful_Presence_Req_Met__c);

    List<Application__c> c2Applications = [SELECT Id, Lawful_Presence_Req_Met__c FROM Application__c WHERE Id = :app2.Id];
    System.assertEquals('Yes', c2Applications[0].Lawful_Presence_Req_Met__c);

    Test.stopTest();
  }

  @isTest static void testSetContactCitizenship() {
      // Two Scholars, first with one application, current year, status 'Legal Permanent Resident'
      //   second with two applications, last year 'Legal Permanent Resident', this year 'United States Citizen'
      Date thisDate = Date.today();
      Date lastYear = thisDate.addYears(-1);
      Id studentRT = [SELECT Id FROM RecordType WHERE sobjecttype = 'Contact' AND name = 'Student'].Id;
            
      Contact c1 = new Contact(lastName = 'Test1',recordTypeId=studentRT);
      insert c1;
      Contact c2 = new Contact(lastName = 'Test2',recordTypeId=studentRT);
      insert c2;
      
      List<Application__c> appList = new List<Application__c>();
      appList.add(new Application__c(Application_Submission_Year__c = String.valueOf(thisDate.year()),
                                       	Student_Name__c = c1.Id));

      appList.add(new Application__c(Application_Submission_Year__c = String.valueOf(thisDate.year()),
                                         Student_Name__c = c2.Id));
      appList.add(new Application__c(Application_Submission_Year__c = String.valueOf(lastYear.year()),
                                         Student_Name__c = c2.Id));
 
      insert appList;
     
      Test.startTest();
      appList[0].US_Citizenship_Status__c = 'Legal Permanent Resident';
      appList[1].US_Citizenship_Status__c = 'United States Citizen';
      update appList;
      appList[2].US_Citizenship_Status__c = 'Legal Permanent Resident';
      update appList[2];

      Map<Id,Contact> cMap = new Map<Id,Contact>([SELECT Id,US_Citizenship_Status__c FROM Contact]);
      Contact ctest1 = cMap.get(c1.Id);
      System.debug('Contact1: ' + ctest1);
      System.assertEquals('Legal Permanent Resident', cMap.get(c1.Id).US_Citizenship_Status__c);
      Contact ctest2 = cMap.get(c2.Id);
      System.debug('Contact2: ' + ctest2);
      System.assertEquals('United States Citizen', cMap.get(c2.Id).US_Citizenship_Status__c);
      Test.stopTest();
      
  }  

    
  @isTest static void testCalculateUnmetNeed() {
    Id studentRT = [SELECT Id FROM RecordType WHERE sobjecttype = 'Contact' AND name = 'Student'].Id;

    Contact con = new Contact();
    con.lastName = 'Test';
    con.recordTypeId = studentRT;
    insert con;

    Application__c app = new Application__c();
    app.Student_Name__c = con.Id;
    insert app;

    Student_Term__c st = new Student_Term__c();
    st.Application__c = app.Id;
    st.Term_Start_Date__c = Date.today().addDays(-30);
    st.Term_End_Date__c = Date.today().addDays(30);
    st.Final_EFC_Upon_FA_File_Completion__c = 100;
    insert st;

    //Fill out editor fields
    app.Total_Budget__c = 10000;
    app.Tuition_Fees__c = 100;
    app.Federal_Grants__c = 100;
    app.State_Grants__c = 100;
    app.Institutional_Scholarships__c = 100;
    app.Other_Outside_Scholarships__c = 100;
    app.Accepted_Workstudy__c = 100;
    app.Accepted_Student_Loans__c = 100;
    app.Parent_Loans__c = 100; //Should not be subtracted from unmet need
    app.Other_Aid_Resources__c = 100;
    update app;

    Test.startTest();
    Application__c appResult = [Select Unmet_Need__c From Application__c Where Id = :app.Id];
    System.assertEquals(9200, appResult.Unmet_Need__c);
    Test.stopTest();
  }
}