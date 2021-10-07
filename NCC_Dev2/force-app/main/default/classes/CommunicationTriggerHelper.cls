public with sharing class CommunicationTriggerHelper {
    public static void onBeforeInsert(Map<Id, Communication__c> newMap){
        //do this
    }
    public static void onBeforeUpdate(Map<Id, Communication__c> newMap, Map<Id, Communication__c> oldMap){
        //do this
    }
    public static void onAfterInsert(Map<Id, Communication__c> newMap){
        //do this
    }
    public static void onAfterUpdate(Map<Id, Communication__c> newMap, Map<Id, Communication__c> oldMap){
        //do this
        //List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		List<EmailUtility.singleMailMessageWrapper> emails = new List<EmailUtility.singleMailMessageWrapper>();
        //retrieve Communication_Recipient__c
        Map<Id, List<Communication_Recipient__c>> recipientPerCommsMap = new Map<Id, List<Communication_Recipient__c>>();
        for(Communication_Recipient__c recipient: [SELECT Id, 
            											Journey_Participant__c, 
                                                   		Journey_Participant__r.Contact__c, 
                                                   		Journey_Participant__r.Contact__r.Email,
                                                   		CC_Communication__c
													FROM Communication_Recipient__c
                                                   WHERE CC_Communication__c IN: newMap.keySet()
                                                  ])
        {
            List<Communication_Recipient__c> recipients = new List<Communication_Recipient__c>();
            if(recipientPerCommsMap.containsKey(recipient.CC_Communication__c)){
                recipients = recipientPerCommsMap.get(recipient.CC_Communication__c);
            }
            recipients.add(recipient);
            recipientPerCommsMap.put(recipient.CC_Communication__c, recipients);
        }
        for(Communication__c newComm : newMap.values()){
            if(newComm.Active__c && newComm.Frequency__c==EmailUtility.COMM_FREQUENCY_REALTIME && newComm.Status__c==EmailUtility.COMM_STATUS_OUTBOX){
				Map<String, Object> buildResponse = EmailUtility.wrapCommunicationEmailMessage(newComm, recipientPerCommsMap);
				if(buildResponse.containsKey('hasError')){
					Boolean hasError = (Boolean)buildResponse.get('hasError');
					if(!hasError){
						EmailUtility.singleMailMessageWrapper email = (EmailUtility.singleMailMessageWrapper)buildResponse.get('emailMessage');
						//EmailUtility.singleMailMessageWrapper email =  (Messaging.SingleEmailMessage)buildResponse.get('emailMessage');
						emails.add(email);
					}
					else{
						List<String> messages = (List<String>)buildResponse.get('messages');
						for(String errorMessage : messages){
							newComm.addError(errorMessage);							
						}
					}
				}
            }
        }
        
        if(!emails.isEmpty()){
			EmailUtility.sendCommunicationEmailMessageFuture(JSON.serialize(emails));
        }
    }
    
    
}