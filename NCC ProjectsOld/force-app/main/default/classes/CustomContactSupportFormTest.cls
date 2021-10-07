@isTest
public with sharing class CustomContactSupportFormTest {
    
    // Test create task with missing data
    @isTest public static void testCreateTaskMissingData(){
        Test.startTest();
        String eventId = '';
        String firstname = 'CS';
        String lastname = 'User';
        String email = 'cs.user@gmail.com';
        String subject = 'Test Task';
        String comments = 'Lorem ipsum';
        String phone = '';
        ChangeCloudController.createTask(eventId, firstname, lastname, email, phone, subject, comments);
        Test.stopTest();
        List<Task> resultTasks = [SELECT Id FROM Task];
        System.assertEquals(0, resultTasks.size());
    }
    
    
    
    // Test creating task with exception thrown
    @isTest public static void testCreateTaskFakeTaskExceptionThrown(){
        Event__c testCampaign = TestFactory.createEvent('Event');
        testCampaign.Event_Id__c = 'sfjzu42308xlz';
        update testCampaign;
        String firstname = 'New';
        String lastname = 'Contact';
        String email = 'new.contact@gmail.com';
        String phone = '0123456789';
        String subject = 'Test Task 0001';
        String comments = 'Lorem Ipsum';
        
        Test.startTest();
        CustomContactSupportFormHelper.throwFakeTaskException = true;      
        try{
            ChangeCloudController.createTask(testCampaign.Event_Id__c, firstname, lastname, email, phone, subject, comments);
        } catch(Exception e){
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
    
    // Test creating task with exception thrown
    @isTest public static void testCreateTaskFakePersonAccountExceptionThrown(){
        Event__c testCampaign = TestFactory.createEvent('Event');
        testCampaign.Event_Id__c = 'sfjzu42308xlz';
        update testCampaign;
        String firstname = 'New';
        String lastname = 'Contact';
        String email = 'new.contact@gmail.com';
        String phone = '0123456789';
        String subject = 'Test Task 0001';
        String comments = 'Lorem Ipsum';
        
        Test.startTest();
        CustomContactSupportFormHelper.throwFakePersonAccountException = true;      
        try{
            ChangeCloudController.createTask(testCampaign.Event_Id__c, firstname, lastname, email, phone, subject, comments);
        } catch(Exception e){
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
    
    // Test getRecordID
    @isTest public static void testGetRecordId(){
        System.assertNotEquals(null, CustomContactSupportFormHelper.getRecordTypeId('Event', 'Campaign'));
    }
    
    // Test get event details
    @isTest public static void testGetEventDetails(){
        Event__c testCampaign = TestFactory.createEvent('Event');
        testCampaign.Event_Id__c = 'sfjzu42308xlz';
        update testCampaign;
        Test.startTest();
        System.assertNotEquals(null, CustomContactSupportFormHelper.getEventDetails(testCampaign.Event_Id__c));
        Test.stopTest();
    }
    
    // Test check contact exists
    @isTest public static void testCheckContactExsist(){
        Contact cont = TestFactory.createContact('Test', 'Contact', 'test.contact@gmail.com');
        Test.startTest();
        CustomContactSupportFormHelper.checkContactExists('Test', 'Contact', 'test.contact@gmail.com', '0842341232');
        Test.stopTest();
        System.assertNotEquals(null, cont);
    }
    
    // Test create task
    @isTest public static void testCreateTask(){
        User contactUsUser = TestFactory.createInteralUser('ContactUs', 'User', 'contactus@gmail.com', 'System Administrator');
        Event__c testCampaign = TestFactory.createEvent('Event');
        testCampaign.Event_Id__c = 'sfjzu42308xlz';
        testCampaign.Contact_Us_User__c = contactUsUser.Id;
        update testCampaign;
        
        String firstname = 'Existing';
        String lastname = 'Contact';
        String email = 'existing.contact@gmail.com';
        String phone = '0123456789';
        String subject = 'Test Task 0002';
        String comments = 'Lorem Ipsum';
        Contact cont = TestFactory.createContact('Test', 'Contact', 'test.contact@gmail.com');
        Test.startTest();
        CustomContactSupportFormHelper.createTaskHelper(testCampaign.Event_Id__c, firstname, lastname, email, phone, subject, comments);
        Test.stopTest();
        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId =: testCampaign.Id];
        System.assertNotEquals(0, tasks.size());
    }
    
    // Test create person account
    @isTest public static void testCreatePersonAccountPANotEnabled(){
        Test.startTest();
        System.assertNotEquals(null, CustomContactSupportFormHelper.createPersonAccount('Person', 'Account', 'person.account@gmail.com', '03123123'));
        Test.stopTest();
    }
}