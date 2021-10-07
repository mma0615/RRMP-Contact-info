@isTest
private class StudentTermPaymentService_Test {

  @isTest static void testPaymentsRollupForContacts() {

    Cohort__c coh = new Cohort__c(Name=String.valueOf(Date.today().year()));
	insert coh;
      
    Account testAccount = new Account();
    testAccount.Name = 'Test Account';
    insert testAccount;

    Contact testContact = new Contact();
    testContact.FirstName = 'Test';
    testContact.LastName = 'Test';
    testContact.Cohort__c = coh.Id;
    testContact.Email = 'test@dsf.com';
    insert testContact;

    Application__c testApplication = new Application__c();
    testApplication.Student_Name__c = testContact.Id;
    insert testApplication;

    Student_Term__c studentTerm = new Student_Term__c();
    studentTerm.Application__c = testApplication.Id;
    studentTerm.Term_Start_Date__c = Date.today();
    studentTerm.Term_End_Date__c = Date.today().addYears(1);
    insert studentTerm;

    Test.startTest();

    Student_Term_Payments__c payment1 = new Student_Term_Payments__c();
    payment1.Student_Term__c = studentTerm.Id;
    payment1.Payment_Amount__c = 500;
    payment1.Payment_Date__c = Date.today();
    insert payment1;

    List<Contact> contacts = new List<Contact>{testContact};
    contacts = StudentTermPaymentService.setRollupPaymentInformationForContacts(contacts);
    update contacts;

    Contact updatedContact = [SELECT Id, Most_Recent_Payment_Date__c, First_Payment_Date__c, Most_Recent_Payment_Amount__c, First_Payment_Amount__c, Total_Payments_Amount_to_Date__c FROM Contact WHERE Id = :testContact.Id];
    System.assertEquals(500, updatedContact.Most_Recent_Payment_Amount__c);
    System.assertEquals(500, updatedContact.First_Payment_Amount__c);

    payment1.Payment_Amount__c = 600;
    update payment1;

    contacts = StudentTermPaymentService.setRollupPaymentInformationForContacts(contacts);
    update contacts;

    updatedContact = [SELECT Id, Most_Recent_Payment_Date__c, First_Payment_Date__c, Most_Recent_Payment_Amount__c, First_Payment_Amount__c, Total_Payments_Amount_to_Date__c FROM Contact WHERE Id = :testContact.Id];
    System.assertEquals(600, updatedContact.Most_Recent_Payment_Amount__c);
    System.assertEquals(600, updatedContact.First_Payment_Amount__c);

    delete payment1;
    contacts = StudentTermPaymentService.setRollupPaymentInformationForContacts(contacts);
    update contacts;

    updatedContact = [SELECT Id, Most_Recent_Payment_Date__c, First_Payment_Date__c, Most_Recent_Payment_Amount__c, First_Payment_Amount__c, Total_Payments_Amount_to_Date__c FROM Contact WHERE Id = :testContact.Id];
    System.assertEquals(null, updatedContact.Most_Recent_Payment_Amount__c);
    System.assertEquals(null, updatedContact.First_Payment_Amount__c);

    Test.stopTest();
  }

  @isTest static void testPaymentsRollupForAccounts() {
    Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'College/University' AND SobjectType = 'Account'].Id;
    Account testAccount = new Account();
    testAccount.Name = 'Test Account';
    testAccount.RecordTypeId = recordTypeId;
    insert testAccount;

    Cohort__c coh = new Cohort__c(Name=String.valueOf(Date.today().year()));
	insert coh;

    Contact testContact = new Contact();
    testContact.FirstName = 'Test';
    testContact.LastName = 'Test';
    testContact.Cohort__c = coh.Id;
    testContact.Email = 'test@dsf.com' ;
    insert testContact;

    Application__c testApplication = new Application__c();
    testApplication.Student_Name__c = testContact.Id;
    insert testApplication;

    Student_Term__c studentTerm = new Student_Term__c();
    studentTerm.Application__c = testApplication.Id;
    studentTerm.College_or_University__c = testAccount.Id;
    studentTerm.Term_Start_Date__c = Date.today();
    studentTerm.Term_End_Date__c = Date.today().addYears(1);
    insert studentTerm;

    Test.startTest();

    Student_Term_Payments__c payment1 = new Student_Term_Payments__c();
    payment1.Student_Term__c = studentTerm.Id;
    payment1.Payment_Amount__c = 500;
    payment1.Payment_Date__c = Date.today();
    insert payment1;

    List<Account> accounts = new List<Account>{testAccount};
    StudentTermPaymentService.rollupPaymentInformationForAccounts(accounts);

    Account updatedAccount = [SELECT Id, Total_Dollars_Current_Term__c, Scholar_Recipients_Current_Term__c, Total_Dollars_Lifetime__c, Scholar_Recipients_Lifetime__c, Scholars_Current_Term__c, Scholars_Lifetime__c FROM Account WHERE Id = :testAccount.Id];
    System.assertEquals(500, updatedAccount.Total_Dollars_Current_Term__c);

    Test.stopTest();
  }

}