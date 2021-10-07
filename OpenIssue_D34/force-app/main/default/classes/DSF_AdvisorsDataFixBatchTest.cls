@IsTest
private class DSF_AdvisorsDataFixBatchTest {
    static testMethod void shouldUpdateCollegeAccountWhenNoApplication() {
        //GIVEN
        List<Account> testAccounts = createTestAccounts();
        Contact testContact = createTestContact('Student');
        testContact.AccountId = testAccounts[1].Id;
        insert testContact;
        testContact.College_Account__c = null;
        update testContact;
        //WHEN
        Test.startTest();
            DSF_AdvisorsDataFixBatch advisorsDataFixBatch = new DSF_AdvisorsDataFixBatch();
            DataBase.executeBatch(advisorsDataFixBatch);
        Test.stopTest();
        //THEN
        Contact resultContact = [SELECT Id, College_Account__c FROM Contact WHERE Id = :testContact.Id];
        System.assertNotEquals(null, resultContact.College_Account__c);
        System.assertEquals(testContact.AccountId, resultContact.College_Account__c);
    }

    static testMethod void shouldUpdateCollegeAccountToApplicationAccount() {
        //GIVEN
        List<Account> testAccounts = createTestAccounts();
        Contact testContact = createTestContact('Student');
        testContact.AccountId = testAccounts[1].Id;
        insert testContact;
        testContact.College_Account__c = null;
        update testContact;
        Application__c application = new Application__c(
                Student_Name__c = testContact.Id,
                School_Name__c = testAccounts[0].Id
        );
        insert application;
        //WHEN
        Test.startTest();
            DSF_AdvisorsDataFixBatch advisorsDataFixBatch = new DSF_AdvisorsDataFixBatch();
            DataBase.executeBatch(advisorsDataFixBatch);
        Test.stopTest();
        //THEN
        Contact resultContact = [SELECT Id, College_Account__c FROM Contact WHERE Id = :testContact.Id];
        System.assertNotEquals(testContact.AccountId, resultContact.College_Account__c);
        System.assertEquals(application.School_Name__c, resultContact.College_Account__c);
    }

    private static Contact createTestContact(String recordTypeName) {
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Contact contactRecord = new Contact(
                lastName = 'Contact ',
                firstName = 'Test',
                recordTypeId = recordTypeId
        );
        return contactRecord;
    }

    private static List<Account> createTestAccounts() {
        Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
        Id householdRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household Account').getRecordTypeId();
        List<Account> accList = new List<Account>();
        Account accColl = new Account(
                recordTypeId = collRT,
                name = 'Test College'
        );
        accList.add(accColl);
        Account accHousehold = new Account(
                recordTypeId = householdRT,
                name = 'Test Household'
        );
        accList.add(accHousehold);
        insert accList;
        return accList;
    }
}