@isTest
private class ContactService_Test {

  @isTest static void testEducationRollup() {
    Account testHighSchool = new Account();
    testHighSchool.Name = 'High School';
    insert testHighSchool;
      
    Account testHighSchool1 = new Account();
    testHighSchool1.Name = 'East Longmont High School';
    insert testHighSchool1;  
      
     Contact testContact = new Contact();
    testContact.FirstName = 'Test';
    testContact.LastName = 'Test';
    insert testContact;

    Degrees__c degree = new Degrees__c();
    degree.Degree_Type__c = 'Bachelor\'s';
    degree.Student__c = testContact.Id;
    insert degree;

    Student_Education_History__c educationHistory = new Student_Education_History__c();
    educationHistory.Student__c = testContact.Id;
    educationHistory.High_School_Grade__c = '12';
    educationHistory.High_School_Name__c = testHighSchool.Id;
    educationHistory.Academic_Year__c = '2017-18';
    insert educationHistory;

    Student_Education_History__c educationHistory1 = new Student_Education_History__c();
    educationHistory1.Student__c = testContact.Id;
    educationHistory1.High_School_Grade__c = '12';
    educationHistory1.High_School_Name__c = testHighSchool1.Id;
    educationHistory1.Academic_Year__c = '2018-19';  
    insert educationHistory1;  
      
    Test.startTest();

    List<Contact> contacts = new List<Contact>{testContact};

    contacts = ContactService.setRollupEducationInformation(contacts);
    update contacts;

    Contact updatedContact = [SELECT Id, Highest_Degree_Earned__c, First_Degree_Earned__c, Last_High_School_Attended__c FROM Contact WHERE Id = :testContact.Id];
    System.assertEquals('Bachelor\'s', updatedContact.Highest_Degree_Earned__c);
    System.assertEquals('Bachelor\'s', updatedContact.First_Degree_Earned__c);
    System.assertEquals(testHighSchool1.Id, updatedContact.Last_High_School_Attended__c);
   system.debug('Last high school-' + updatedContact.Last_High_School_Attended__c);  

    Test.stopTest();
  }

}