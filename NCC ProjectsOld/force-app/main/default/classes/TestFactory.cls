@isTest 
public with sharing class TestFactory {
    
    // Create contact
    public static Contact createContact(String firstname, String lastname, String email){
        Contact newContact = new Contact();
        newContact.Firstname = firstname;
        newContact.Lastname = lastname;
        newContact.Email = email;
        newContact.Contact_Type__c = 'Client';
        insert newContact;
        return newContact;
    }
    
    // Create campaign
    public static Campaign createCampaign(String campaignName, String recordType){
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        Campaign newCampaign = new Campaign();
        newCampaign.Name = campaignName;
        newCampaign.RecordTypeId = recordTypeId;
        newCampaign.IsActive = true;
        insert newCampaign;
        return newCampaign;
    }
    
    // Create Event
    public static Event__c createEvent(String EventName){
        Campaign__c  campaignRec = new   Campaign__c();
        insert campaignRec;
        
        Event__c newCampaign = new Event__c();
        newCampaign.Name = EventName;
        newCampaign.Campaign__c =campaignRec.Id;
        insert newCampaign;
        return newCampaign;
    }
    
    // Create Session
    public static Session__c createSession(String SessionName, String eventId){
        Session__c newCampaign = new Session__c();
        newCampaign.Name = SessionName;
        newCampaign.Event__c = eventId;
        insert newCampaign;
        return newCampaign;
    }
    
    // Create Participant
    public static Participant__c createParticipant(String campaignId, Contact cont){
        Participant__c cm = new Participant__c();
        cm.Event__c = campaignId;
        cm.Member_Contact__c = cont.Id;
        cm.Status__c = 'Invited';
        insert cm;
        return cm;
    }
    
    // Create survey
    public static Survey__c createSurvey(String campaignId, String surveyName){
        Survey__c newSurvey = new Survey__c();
        newSurvey.Event__c = campaignId;
        newSurvey.Name = surveyName;
        newSurvey.Active__c = true;
        insert newSurvey;
        return newSurvey;
    }
    
    // Create survey question
    public static Survey_Question__c createSurveyQuestion(String surveyId, String description, String type, Integer sortingOrder){
        Survey_Question__c newSQ = new Survey_Question__c();
        newSQ.Survey__c = surveyId;
        newSQ.Description__c = description;
        newSQ.Question_Type__c = type;
        newSQ.Sorting_Order__c = sortingOrder;
        insert newSQ;
        return newSQ;
    }
    
    // Create survey response
    public static Survey_Response__c createSurveyResponse(String campaignId, String surveyId, String accountId){
        Survey_Response__c newSR = new Survey_Response__c();
        newSR.Event__c = campaignId;
        newSR.Survey__c = surveyId;
        newSR.Account__c = accountId;
        insert newSR;
        return newSR;
    }
    
    // Create survey answer
    public static Survey_Answer__c createSurveyAnswer(String surveyResponseId, String question, String answer){
        Survey_Answer__c newSA = new Survey_Answer__c();
        newSA.Survey_Response__c = surveyResponseId;
        newSA.Question__c = question;
        newSA.Answer__c = answer;
        insert newSA;
        return newSA;
    }
    
    //Create person account
    public static Account createPersonAccount(String firstname, String lastname, String email){
        String personAccountRecordTypeId = getRecordTypeId('Person Account', 'Account');
        Account newPersonAccount = new Account();
        newPersonAccount.put('FirstName', firstname);
        newPersonAccount.put('LastName', lastname);
        newPersonAccount.put('PersonEmail', email);
        newPersonAccount.put('RecordTypeId', personAccountRecordTypeId);
        insert newPersonAccount;
        return newPersonAccount;
    }
    
    // Get record type ID
    public static String getRecordTypeId(String recordTypeName, String SObjectName){
        RecordType recordType =  [SELECT Id FROM RecordType WHERE Name =: recordTypeName and SObjectType =: SObjectName LIMIT 1];
        return recordType.Id;
    }
    
    // Create content version 
    public static ContentVersion createContentVersion(String title, String description){
        ContentVersion cv = new ContentVersion();
        cv.Description = description;
        cv.Title = title;
        cv.PathOnClient = 'test';
        cv.VersionData = EncodingUtil.base64Decode('U29tZSBDb250ZW50');
        insert cv;
        return cv;
    }
    
    // Create content document link
    public static ContentDocumentLink createContentDocumentLink(String contentDocumentId, String linkedEntityId, String shareType, String visibility){
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = linkedEntityId;
        cdl.Visibility = visibility;
        cdl.ShareType = shareType;
        insert cdl;
        return cdl;
    }
    
    // Create content distribution
    public static ContentDistribution createContentDistribution(ContentVersion cv){
        ContentDistribution cd = new ContentDistribution();
        cd.Name = cv.Title;
        cd.ContentVersionId = cv.Id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        return cd;
    }
    
    // Create user
    public static User createInteralUser(String firstname, String lastname, String email, String profileName){
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
        User u = new User();
        u.FirstName = firstname;
        u.LastName = lastname;
        u.Email = email;
        u.Username = email;
        u.Alias = firstname.charAt(0)+lastname;
        u.Email='standarduser@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey='America/New_York';
        insert u;
        return u;
    }
    
    // Create campaign member
    public static CampaignMember createCampaignMember(String campaignId, Contact cont){
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = campaignId;
        cm.ContactId = cont.Id;
        cm.Status = 'Sent';
        insert cm;
        return cm;
    }
    
    
    public interface DataFactory{
        void make();
        void persist();
        
    }
    
    public class ParkingLotTestDataFactory implements DataFactory{
        Contact con;
        Event__c evt;
        Session__c sess;
        Parking_Lot__c pl;
        
        public void make(){
            this.con = createContact('Test', 'Con', 'test@email.com');
            insert this.con;
            this.evt = createEvent('Test');
            insert this.evt;
            this.sess = createSession('Sess', this.evt.Id);
            insert this.sess;
            this.pl = createParkingLot(this.evt.Id, this.sess.Id, this.con.Id);
        }
        
        public void persist(){
            insert this.pl;
            
        }
        
        public Contact createContact(String firstname, String lastname, String email){
            Contact newContact = new Contact();
            newContact.Firstname = firstname;
            newContact.Lastname = lastname;
            newContact.Email = email;
            newContact.Contact_Type__c = 'Client';
            return newContact;
        }
        
        
        public Event__c createEvent(String EventName){
            Campaign__c  campaignRec = new   Campaign__c();
            insert campaignRec;
            
            Event__c newCampaign = new Event__c();
            newCampaign.Name = EventName;
            newCampaign.Campaign__c =campaignRec.Id;
            newCampaign.Event_Id__c = 'Test';
            return newCampaign;
        }
        
        public Session__c createSession(String SessionName, String eventId){
            Session__c newCampaign = new Session__c();
            newCampaign.Name = SessionName;
            newCampaign.Event__c = eventId;
            newCampaign.IsActive__c = true ;
            newCampaign.Start_Date_Time__c = date.today();
            newCampaign.End_Date_Time__c = date.today().addDays(5);
            return newCampaign;
        }
        
        public Parking_Lot__c createParkingLot(String eventId, String session, String raisedById){
            Parking_Lot__c newParkingLot = new Parking_Lot__c(
                Event__c = eventId,
                Session__c = session,
                Raised_By__c = raisedById,
                Description__c = 'Question 1',
                Status__c = 'Open',
                Type__c = 'Issue'
            );
            return newParkingLot;         
        }
        
        //usage
        // TestFactory.DataFactory df = new ParkingLotTestDataFactory();
        // df.make();
        // df.persist();
    }
}