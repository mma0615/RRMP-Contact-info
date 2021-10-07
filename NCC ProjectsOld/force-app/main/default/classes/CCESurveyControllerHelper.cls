public without sharing class CCESurveyControllerHelper {
    @testVisible
    public static Boolean throwFakeException = false;

    @testVisible
    public static Boolean testCreateContact = false;

    public static Boolean isPersonAccountEnabled = Schema.SObjectType.Account.fields.getMap().containsKey('isPersonAccount');
    
    // Retrieve survey details
    public static String getSurveyHelper(String eventId){
        List<Event__c> campaignList = [SELECT Id FROM Event__c WHERE Event_Id__c =: eventId LIMIT 1];
        if (campaignList.size() > 0){
            List<Survey__c> surveys = [SELECT Id, Name, Campaign__c, Survey_Logo_URL__c, Disclaimer__c, Logo_Image_Id__c,
                                    (SELECT Id, Description__c, Question_Type__c, Min_Value__c, Max_Value__c, Step__c, Options__c FROM Survey_Questions__r ORDER BY Sorting_Order__c) 
                                    FROM Survey__c
                                    WHERE Event__c =: campaignList[0].Id AND Active__c = TRUE LIMIT 1];
            if (surveys.size() > 0) {
                SurveyWrapper sw = new SurveyWrapper();
                sw.BlobWrapper = (String.isBlank(surveys[0].Logo_Image_Id__c)) ? null : getContentVersionData(surveys[0].Logo_Image_Id__c);
                sw.Survey = surveys[0];
                return JSON.serialize(sw);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }    


    public static void createResponseHelper(String eventId, String campaignId, String contactDetails, String result, String dateOfSession){
        System.debug('--- Campaign Id: ' + campaignId);
        System.debug('--- Event Id: ' + eventId);
        List<Survey__c> surveyList = [SELECT Id, Event__c FROM Survey__c WHERE Event__r.Event_Id__c =: eventId AND Active__c  = TRUE LIMIT 1];

        if (surveyList.size() > 0){
            String surveyId = surveyList[0].Id;
            Contact cont = (Contact)JSON.deserialize(contactDetails, Contact.class);       
            Id IdToLink;
            System.debug('!@# cont.Email: ' + cont.Email);
            if(!String.isBlank(cont.Email) || cont.Email != ''){
                // Check if contact exists, if not, create one
                List<Contact> contactList = checkContactExist(cont.Email);
                if (contactList.size() == 0){
                    try{
                        IdToLink = createContact(cont.FirstName, cont.LastName, cont.Email, cont.Facility__c);
                    } catch(DmlException e){
                        throw new AuraHandledException(e.getMessage());
                    }
                } else {
                    // If there are multiple contact with the same email, use the first one found (filter logic can be implemented later)
                    IdToLink = contactList[0].Id;
                }
            }

            // Create survey response record
            // Link survey response record to campaign and contact
            Survey_Response__c newResponse = new Survey_Response__c();
            newResponse.Event__c = surveyList[0].Event__c;
            if(!String.isBlank(cont.Email) || cont.Email != '') newResponse.Contact__c = IdToLink;
            System.debug('!@# IdToLink: ' + IdToLink);
            newResponse.Survey__c = surveyId;
            newResponse.Date_of_Session__c  = Date.valueOf(dateOfSession);
            insert newResponse;
            
            // Create result records, link these to the response
            Map<String, UserAnswerWrapper> questionIDToUserAnswerMap = new Map<String, UserAnswerWrapper>();
            questionIDToUserAnswerMap = (Map<String, UserAnswerWrapper>)JSON.deserialize(result, Map<String, UserAnswerWrapper>.class);

            List<Survey_Answer__c> answersList = new List<Survey_Answer__c>();
            for (String questionId : questionIDToUserAnswerMap.keySet()){
                UserAnswerWrapper uaw = questionIDToUserAnswerMap.get(questionId);
                Survey_Answer__c sa = new Survey_Answer__c();
                sa.Survey_Question__c = questionId;
                sa.Question__c = uaw.Question;
                sa.Answer__c = uaw.Answer;
                sa.Survey_Response__c = newResponse.Id;
                answersList.add(sa);
            }

            // DML commit
            try{
                insert answersList;
            } catch(DmlException e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    }

    // Check if contact exists
    public static List<Account> checkPersonExist(String email){
        List<Account> personAccountList = [SELECT Id, Firstname, Lastname, PersonEmail FROM Account WHERE PersonEmail =: email AND isPersonAccount = true];
        return personAccountList;
    }

    // Retrieve survey answers
    public static String getSurveyAnswersHelper(String surveryResponseId){
        List<Survey_Answer__c> surveyAnswers = [SELECT Id, Question__c, Answer__c FROM Survey_Answer__c WHERE Survey_Response__c =: surveryResponseId];
        if (surveyAnswers.size() > 0){
            return JSON.serialize(surveyAnswers);
        } else {
            return null;
        }
    }

    // Retrieve version data (body) of content version
    public static BlobWrapper getContentVersionData(String contentVersionId){
        if (String.isBlank(contentVersionId)) return null;
        List<ContentVersion> cvList = [SELECT VersionData, FileType FROM ContentVersion WHERE Id =: contentVersionId LIMIT 1];
        if (cvList.size() > 0){
            BlobWrapper bw = new BlobWrapper();
            bw.FileType = cvList[0].FileType;
            bw.VersionData = EncodingUtil.base64Encode(cvList[0].VersionData);
            return bw;
        } else {
            return null;
        }
    }

    // Create person account
    public static String createPersonAccount(String firstname, String lastname, String email, String facility){
        String personAccountRecordTypeId = getRecordTypeId('Person Account', 'Account');
        Account newPersonAccount = new Account();
        newPersonAccount.put('FirstName', firstname);
        newPersonAccount.put('LastName', lastname);
        newPersonAccount.put('PersonEmail', email);
        newPersonAccount.put('Facility__pc', facility);
        // Set last name as null to trigger a fake exception
        if (throwFakeException) newPersonAccount.put('LastName', '');
        newPersonAccount.put('RecordTypeId', personAccountRecordTypeId);

        try{
            insert newPersonAccount;
            return newPersonAccount.Id;
        } catch(DmlException e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Check if contact exists
    public static List<Contact> checkContactExist(String email){
        List<Contact> contactList = [SELECT Id FROM Contact WHERE Email =: email];
        return contactList;
    }

    // Create contact, if person account is not enabled
    public static String createContact(String firstname, String lastname, String email, String facility){
        Contact newContact = new Contact();
        newContact.FirstName = firstname;
        newContact.LastName = (throwFakeException) ? '' : lastname;
        newContact.Email = email;
        newContact.Facility__c = facility;
        newContact.Contact_Type__c = 'Other';
        try {
            insert newContact;
            return newContact.Id;
        } catch(DmlException e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Retrieve record type Id
    public static String getRecordTypeId(String recordTypeName, String SObjectName){
        RecordType recordType =  [SELECT Id FROM RecordType WHERE Name =: recordTypeName and SObjectType =: SObjectName LIMIT 1];
        return recordType.Id;
    }
    
    // Survey wrapper class
    public class SurveyWrapper{
        public Survey__c Survey;
        public BlobWrapper BlobWrapper;
    }

    // Blob wrapper class
    public class BlobWrapper{
        public String FileType;
        public String VersionData;
    }

    // User answer wrapper class
    public class UserAnswerWrapper{
        public String Question;
        public String Answer;
    }
}