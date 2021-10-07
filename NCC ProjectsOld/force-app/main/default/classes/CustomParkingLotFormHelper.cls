/**
* Description: This is the helper class for CustomParkingLotFormController, which creates a parking lot record
* Author: Jester Cabantog
* Version: 1.0
* Last modified date: 12/16/2020
**/

public class CustomParkingLotFormHelper {
    // Retrieve record type Id
    public static String getRecordTypeId(String recordTypeName, String SObjectName){
        RecordType recordType =  [SELECT Id FROM RecordType WHERE Name =: recordTypeName and SObjectType =: SObjectName LIMIT 1];
        return recordType.Id;
    }
    
    //PT-00333 Event Parking Lot
    public static void createParkingLotHelper(String eventId, String session, String email, String phone, String description, String type){
        
        // Check a contact with entered email already exists to assign to the parking lot's raised by field
        // If no contacts found, a person account will be created along with a contact which will be used in the parking lot's raised by field
        String raisedById = checkContactExistsPL(email, phone);
        
        Parking_Lot__c newParkingLot = new Parking_Lot__c(
            Event__c = eventId,
            Session__c = session,
            Raised_By__c = raisedById,
            Description__c = description,
            Status__c = 'Open',
            Type__c = type
        );
        try{
            insert newParkingLot;
        }
        catch(DmlException e){
            throw new AuraHandledException(e.getMessage());
        }
        
    } 
    
    //PT-00333 Event Parking Lot
    // Check if a person account exists for the entered email
    public static String checkContactExistsPL(String email, String phone){
        List<Contact> contacts = [SELECT Firstname, Lastname, Email FROM Contact WHERE Email =: email LIMIT 1];
        if (contacts.size() > 0){
            return contacts[0].Id;
        } else {
            String task_whoId = createPersonAccountPL(email, phone);
            return task_whoId;
        }
    }
    
    //PT-00333 Event Parking Lot
    // If a person account does not exist, then create one
    public static String createPersonAccountPL(String email, String phone){
        if(Schema.SObjectType.Account.fields.getMap().containsKey('isPersonAccount')){
            Account newPersonAccount = new Account();
            newPersonAccount.put('FirstName', '');
            newPersonAccount.put('LastName', email);
            newPersonAccount.put('PersonEmail', email);
            if (phone != null) newPersonAccount.put('Phone', phone);
         
          
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
            conRecord.FirstName = '';
            conRecord.LastName = email;
            conRecord.Email = email;
            conRecord.Phone = phone;
            insert conRecord;
            return conRecord.Id;
        }
    }
}