public class ParticipantTriggerUtility {
   
    public static void sendEmailToParticipant(Map<String, List<Participant__c>> participantMap, Set<Id> eventIds){
        Map<Id, Event__c> eventsMap = new Map<Id, Event__c>([SELECT Id, Email_Sender_Id__c, Email_Sender_Name__c, Email_Message_CC__c, Email_Message_BCC__c FROM Event__c WHERE Id =: eventIds]);
        Map<Id, OrgWideEmailAddress> owea = new Map<Id, OrgWideEmailAddress>([SELECT Id FROM OrgWideEmailAddress]);
        Compass_Setting__c compS = [SELECT Id, Name, Email_Template_Invitation_Id__c, Email_Template_Registration_Id__c 
                                    FROM Compass_Setting__c WHERE Name = 'Default Settings']; 
        
        if(participantMap.containsKey(UtilityConstant.PARTICIPANT_STATUS_INVITED)){
            for(Participant__c participant: participantMap.get(UtilityConstant.PARTICIPANT_STATUS_INVITED)){
                String emailSenderId = eventsMap.get(participant.Event__c).Email_Sender_Id__c;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.targetobjectid = participant.Member_Contact__c;
                system.debug('eventsMap: ' + eventsMap);
                system.debug('OWEA: ' + owea);
                message.setOrgWideEmailAddressId(owea.get(emailSenderId).Id);
                message.setSaveAsActivity(false);
                message.setWhatId(participant.Id);
                message.setTemplateId(compS.Email_Template_Invitation_Id__c);
                if(eventsMap.get(participant.Event__c).Email_Message_CC__c != null)  message.setCcAddresses(new List<String> {eventsMap.get(participant.Event__c).Email_Message_CC__c});
                if(eventsMap.get(participant.Event__c).Email_Message_BCC__c != null) message.setBccAddresses(new List<String> {eventsMap.get(participant.Event__c).Email_Message_BCC__c});
                
                Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
        }
        
               
        if(participantMap.containsKey(UtilityConstant.PARTICIPANT_STATUS_RESPONDED)){
            Id eventRegistrationTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: UtilityConstant.EMAIL_TEMPLATE_CONFIRMATION_NAME].Id;
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>(); 
            
            for(Participant__c participant: participantMap.get(UtilityConstant.PARTICIPANT_STATUS_RESPONDED)){
                String emailTemplateId = compS.Email_Template_Registration_Id__c != null ? compS.Email_Template_Registration_Id__c : eventRegistrationTemplate;
                String emailSenderId = eventsMap.get(participant.Event__c).Email_Sender_Id__c;
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setOrgWideEmailAddressId(eventsMap.get(participant.Event__c).Email_Sender_Id__c);
                message.setSaveAsActivity(false);
                message.setWhatId(participant.Id);
                message.setTemplateId(emailTemplateId);
                message.setTargetObjectId(participant.Member_Contact__c);
                emails.add(message);
            }
            Messaging.sendEmail(emails);
        }
        
    }
    
}