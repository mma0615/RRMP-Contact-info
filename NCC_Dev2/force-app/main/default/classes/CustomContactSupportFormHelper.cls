/**
* Description: This is the helper class for CustomContactSupportFormController, which creates a task from the data entered on the custom contact
* support form. The helpers will check if the event's Contact_Us_User field has a value, if yes it will asssign
* the task to this user, otherwise it will assign it to the event's owner. It will also check if a contact/person account
* exist with the email entered on the form, if yes it will link this contact/person account to the Name field on the task,
* otherwise it will create a person account from these details and assign it to the Name field. 
* Author: Jasmine Nguyen
* Version: 1.0
* Last modified date: 15/8/2020
**/
public without sharing class CustomContactSupportFormHelper{ 
    
    @testVisible
    public static Boolean throwFakeTaskException = false;
    
    @testVisible
    public static Boolean throwFakePersonAccountException = false;
    
    public static void createTaskHelper(String eventId, String firstname, String lastname, String email, String phone, String subject, String comments){
        
        // Check if Contact_Us_User__c is populated on event, if not assign task to event's owner
        Event__c event = getEventDetails(eventId);

        String task_OwnerId;
        if (event != null && (String.isNotBlank(event.Contact_Us_User__c))){
            task_OwnerId = event.Contact_Us_User__c;
        } else if (event != null && (String.isNotBlank(event.OwnerId))) {
            task_OwnerId = event.OwnerId;
        }
        
        // Check a contact with entered email already exists to assign to the task's Name field
        // If no contacts found, a person account will be created along with a contact which will be used in the task's Name field
        String task_WhoId = checkContactExists(firstname, lastname, email, phone);
        
        createTaskOnEvent(event, task_OwnerId, task_WhoId, subject, comments);
    } 
    
    // Create task
    public static void createTaskOnEvent(Event__c event, String task_OwnerId, String task_WhoId, String subject, String comments){
        Task newTask = new Task();
        newTask.Subject = subject;
        newTask.Description = comments;
        newTask.OwnerId = task_OwnerId;
        newTask.WhoId = task_WhoId;
        newTask.WhatId = event.Id;
        newTask.Task_Origin__c = 'Contact Us Page';
        newTask.Type = 'Email';
        newTask.ActivityDate = System.today();
        
        try{
            // Set WhatId to an invalid ID to trigger a fake exception
            if (throwFakeTaskException) newTask.WhatId = 'somerandomId';
            insert newTask;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Get event details
    public static Event__c getEventDetails(String eventId){
        List<Event__c> events = [SELECT Id, Name, Description__c, OwnerId, Contact_Us_User__c FROM Event__c WHERE Event_Id__c =: eventId];
        if (events.size() > 0){
            return events[0];
        } else{
            return null;
        }
    }
    
    // Check if a person account exists for the entered email
    public static String checkContactExists(String firstname, String lastname, String email, String phone){
        List<Contact> contacts = [SELECT Firstname, Lastname, Email FROM Contact WHERE Email =: email LIMIT 1];
        if (contacts.size() > 0){
            return contacts[0].Id;
        } else {
            //String task_whoId = createPersonAccount(firstname, lastname, email, phone);//[00780] Fix Partking Lot and Contact Us Form - Jester 2/5/2021
            String task_whoId = createContact(firstname, lastname, email, phone); //[00780] Fix Partking Lot and Contact Us Form - Jester 2/5/2021
            return task_whoId;
        }
    }
    /*START [00780] Fix Partking Lot and Contact Us Form - Jester 2/5/2021
    // If a person account does not exist, then create one
    public static String createPersonAccount(String firstname, String lastname, String email, String phone){
        if(Schema.SObjectType.Account.fields.getMap().containsKey('isPersonAccount')){
            Account newPersonAccount = new Account();
            newPersonAccount.put('FirstName', firstname);
            newPersonAccount.put('LastName', lastname);
            newPersonAccount.put('PersonEmail', email);
            if (phone != null) newPersonAccount.put('Phone', phone);
            // Set last name as null to trigger a fake exception
            if (throwFakePersonAccountException) newPersonAccount.put('LastName', '');
            String personAccountRecordTypeId = getRecordTypeId('Person Account', 'Account');
            newPersonAccount.put('RecordTypeId', personAccountRecordTypeId);
            
            
            try{
                insert newPersonAccount;
                Contact cont = [SELECT Id FROM Contact WHERE AccountId =: newPersonAccount.Id LIMIT 1];
                return cont.Id;
            } catch(DmlException e){
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            Contact conRecord = new Contact();
            conRecord.FirstName = firstname;
            conRecord.LastName = lastname;
            conRecord.Email = email;
            conRecord.Phone = phone;
            insert conRecord;
            return conRecord.Id;
        }
    }
    
    // Retrieve record type Id
    public static String getRecordTypeId(String recordTypeName, String SObjectName){
        RecordType recordType =  [SELECT Id FROM RecordType WHERE Name =: recordTypeName and SObjectType =: SObjectName LIMIT 1];
        return recordType.Id;
    }
	END [00780] Fix Partking Lot and Contact Us Form - Jester 2/5/2021 */
   
    //START [00780] Fix Partking Lot and Contact Us Form - Jester 2/5/2021
    public static String createContact(String firstname, String lastname, String email, String phone){
         Contact conRecord = new Contact();
            conRecord.FirstName = firstname;
            conRecord.LastName = lastname;
            conRecord.Email = email;
            conRecord.Phone = phone;
            insert conRecord;
            return conRecord.Id;
    }
    //END [00780] Fix Partking Lot and Contact Us Form - Jester 2/5/2021 
}