@IsTest
public with sharing class FileUploadUtilityTest {
    static testMethod void runTestCases() {
        Contact c = new contact(firstName = 'test', lastName = 'name', email='testing43593545@email.com');
        insert c;
        system.assertEquals('',FileUploadUtility.updateTargetRecord(c.Id, '12345678', 'firstName'));
        system.assertNotEquals('',FileUploadUtility.updateTargetRecord(c.Id, '12345678', 'fileId'));
    }
}