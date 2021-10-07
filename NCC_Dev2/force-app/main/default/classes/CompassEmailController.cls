public with sharing class CompassEmailController {
    private static final Integer MAX_RESULT = 10;
    private static final String CAMPAIGN_API_NAME = Campaign__c.sObjectType.getDescribe().getName();
    private static final String JOURNEY_API_NAME = Journey__c.sObjectType.getDescribe().getName();
    private static final String UNRECOGNIZED_ERROR = System.Label.Compass_Email_Unrecognized_Id_Error;

    @AuraEnabled
    public static List<OrgWideEmailAddress> getOrgWideEmailAddress(){
        try {
            List<OrgWideEmailAddress> emailAddresses = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress];
            return emailAddresses;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getDefaultSenderId(){
        try{
            return [SELECT Email_Sender_Id__c FROM Compass_Setting__c LIMIT 1].Email_Sender_Id__c;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<LookupSearchResult> searchContactRecipient(String searchTerm, List<String> selectedIds){
        // Execute search query
        String searchKey = '%' + searchTerm + '%';
        List<Contact> contactList = [SELECT Id, Name, Email FROM Contact
                                              WHERE (Name LIKE :searchKey OR Email LIKE :searchKey)
                                              AND Id NOT IN :selectedIds
                                              AND Email <> null
                                              AND HasOptedOutOfEmail <> true
                                              LIMIT :MAX_RESULT];
        System.debug('searchContactRecipient Query results >> ' + contactList);
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String contactIcon = 'standard:contact';
        for (Contact con : contactList) {
            results.add(new LookupSearchResult(con.Id, 'Contact', contactIcon, con.Name, con.Email));
        }
   
        results.sort();
        return results;
    }

    @AuraEnabled
    public static List<LookupSearchResult> getLookupResultsById(List<String> initialLookupIds){
        try{
            List<Contact> contactList = [SELECT Id, Name, Email FROM Contact WHERE Id IN :initialLookupIds];
            System.debug('searchContactRecipient Query results >> ' + contactList);
            // Prepare results
            List<LookupSearchResult> results = new List<LookupSearchResult>();
            String contactIcon = 'standard:contact';
            for (Contact con : contactList) {
                results.add(new LookupSearchResult(con.Id, 'Contact', contactIcon, con.Name, con.Email));
            }
    
            results.sort();
            return results;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<EmailTemplate> getEmailTemplates(){
        try {
            return [SELECT Id, Name, Subject, Body, HtmlValue FROM EmailTemplate ORDER BY NAME ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Journey_Participant__c> getJourneyParticipants(String recordId){

        Id objectId = recordId;
        if(String.valueOf(objectId.getSobjectType()) == CAMPAIGN_API_NAME){
            Map<Id, Journey__c> journeyList = new Map<Id, Journey__c>([SELECT Id from Journey__c WHERE Campaign__c = :objectId]);
            return [SELECT Id, 
                           Name, 
                           Contact__c, 
                           Contact__r.name, 
                           Contact__r.Email 
                           FROM Journey_Participant__c 
                           WHERE Journey__c = :journeyList.keySet()];
        }
        else if(String.valueOf(objectId.getSobjectType()) == JOURNEY_API_NAME){
            return [SELECT Id, 
                           Name, 
                           Contact__c, 
                           Contact__r.name, 
                           Contact__r.Email 
                           FROM Journey_Participant__c 
                           WHERE Journey__c = :objectId];
        }
        else{
            throw new AuraHandledException(UNRECOGNIZED_ERROR);
        }
    }


    public static String executeEmail(Communication__c communication, List<Communication_Recipient__c> recipientsList, String orgWideEmailId){
        String errorMessages = '';
        try{
            List<Map<String, Object>> responseList = EmailUtility.buildCommunicationEmailList(communication, recipientsList, orgWideEmailId);
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            for(Map<String, Object> response : responseList){
                if(response.get('hasError') == true){
                    List<String> errorList = (List<String>) response.get('messages');
                    for(String error : errorList){
                        System.debug(error);
                        errorMessages += error + '\n';
                    }
                }else{
                    // If there's no error then send
                    Messaging.SingleEmailMessage email = (Messaging.SingleEmailMessage) response.get('emailMessage');
                    emailMessages.add(email);
                }
            }
            if(!emailMessages.isEmpty()){
                EmailUtility.sendCommunicationEmailMessages(emailMessages);
            }
            else{
                errorMessages += 'No email was sent';
            }
    
        }catch(exception e){
            System.debug('CompassEmailController.executeEmail - ERROR! >>> ' + e.getMessage());
            System.debug('CompassEmailController.executeEmail - ERROR Stack Trace! >>> ' + e.getStackTraceString());
            System.debug('CompassEmailController.executeEmail - ERROR Line Number! >>> ' + e.getLineNumber());
            errorMessages += e.getMessage();
        }
        return errorMessages;
    }
    
    @AuraEnabled
    public static String sendCompassEmail(String recordId,
                                       String orgWideEmailId,
                                       List<String> contactRecipientIds,
                                       String subject,
                                       String emailBody,
                                       String ccRecipients,
                                       String bccRecipients){
        
        System.debug('Campaign/Journey Id >>> '+ recordId);
        System.debug('OrgWideEmailAddress Id >>> '+ orgWideEmailId);
        System.debug('Contact Id List >>> '+ contactRecipientIds);
        System.debug('Subject >>> '+ subject);
        System.debug('Email Body >>> '+ emailBody);
        System.debug('CC Recipients >>> '+ ccRecipients);
        System.debug('BCC Recipients >>> '+ bccRecipients);
        String separator = ',';
        String errors = '';
        Id objectId = recordId;
        String campaignId = null;
        String journeyId = null;

        Map<Id, Contact> selectedContactsMap = new Map<Id, Contact>([ SELECT Id, Name, Email from Contact WHERE Id IN :contactRecipientIds ]);
        Map<Id, Journey__c> journeyMap = null;
        List<Journey_Participant__c> journeyParticipants = new List<Journey_Participant__c>();

        if(String.valueOf(objectId.getSobjectType()) == CAMPAIGN_API_NAME){
            campaignId = recordId;
            journeyMap = new Map<Id, Journey__c>([ SELECT Id from Journey__c WHERE Campaign__c = :recordId ]);
            journeyParticipants = [ SELECT id, 
                                    Contact__c,
                                    Contact__r.Email, 
                                    Is_Active__c 
                                    from Journey_Participant__c 
                                    WHERE Contact__c IN :contactRecipientIds
                                    AND Journey__c IN :journeyMap.keySet()];
        }
        else if(String.valueOf(objectId.getSobjectType()) == JOURNEY_API_NAME){
            journeyId = recordId;
            journeyParticipants = [ SELECT id, 
                                    Contact__c, 
                                    Contact__r.Email, 
                                    Is_Active__c 
                                    from Journey_Participant__c 
                                    WHERE Contact__c IN :contactRecipientIds
                                    AND Journey__c = :recordId];
        }
        else{
            throw new AuraHandledException(UNRECOGNIZED_ERROR);
        }

        Map<Id, Journey_Participant__c> contactParticipantMap = new Map<Id, Journey_Participant__c>();
        for(Journey_Participant__c participant : journeyParticipants){
            if(contactParticipantMap.get(participant.Contact__c) == null){
                contactParticipantMap.put(participant.Contact__c, participant);
            }
        }

        Communication__c communication = new Communication__c(Frequency__c = EmailUtility.COMM_FREQUENCY_REALTIME,
                                                                Journey__c = journeyId, 
                                                                Campaign__c = campaignId, 
                                                                Organization_Wide_Email_Id__c = orgWideEmailId,
                                                                Email_Recipient_CC__c = ccRecipients,
                                                                Email_Recipient_BCC__c = bccRecipients,
                                                                Subject__c = subject,
                                                                Body__c = emailBody,
                                                                OwnerId = UserInfo.getUserId());

        try{
            Insert communication;
        }catch(DmlException e){
            errors += e.getMessage();
            System.debug('CompassEmailController.sendMassEmail - ERROR! >>> ' + errors + '\n');
        }

        List<Communication_Recipient__c> recipientsList = createRecipients(communication.Id, selectedContactsMap, contactParticipantMap);
        try{
            Insert recipientsList;
        }catch(DmlException e){
            errors += e.getMessage();
            System.debug('CompassEmailController.sendMassEmail - ERROR! >>> ' + errors);
        }

        if(errors == ''){
            executeEmail(communication, recipientsList, orgWideEmailId);
        }

        return errors;
    }

    private static List<Communication_Recipient__c> createRecipients(Id communicationId,
                                                                     Map<Id, Contact> selectedContactsMap,
                                                                     Map<Id, Journey_Participant__c> contactParticipantMap){
        List<Communication_Recipient__c> commsRecipientsToInsert = new List<Communication_Recipient__c>();
        for(Contact con : selectedContactsMap.values()){
            Communication_Recipient__c newRecipient = new Communication_Recipient__c(CC_Communication__c = communicationId,
                                                                                     Contact__c = con.Id,
                                                                                     Email__c = con.Email);
            // if there's an existing Journey Participant related to the contact, associate it with the Comms Recipient
            Journey_Participant__c participant = contactParticipantMap.get(con.Id);
            if(participant != null){
                newRecipient.Journey_Participant__c = participant.Id;
            }
            commsRecipientsToInsert.add(newRecipient);
        }
        return commsRecipientsToInsert;

    }
}