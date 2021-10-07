public class UpdateTokenCodeBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Login_Token__c FROM Contact');
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope){
        List<Contact> contacts = new List<Contact>();
        for (Contact contact : scope){
            Integer len = 32;
            Blob blobKey = crypto.generateAesKey(128);
            contact.Login_Token__c =  EncodingUtil.convertToHex(blobKey).substring(0, len);
            contacts.add(contact);
        }
        update contacts;
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}