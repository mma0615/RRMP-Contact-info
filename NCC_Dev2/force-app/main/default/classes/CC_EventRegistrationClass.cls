/**
@author Edison Crisostomo
@date 24 August 2020
@group NCC
@description Registration Page
@revision   Edison Crisostomo - 24 AUG 2020 - Initial version
Angelo Rivera - Added logic on linking Contact when user registers
Jasmine Nguyen - 10 SEPTEMBER 2020 - Modified code to use Start Date Time and End Date Time fields
Angelo Rivera - 31 OCT 2020 - Updated code to reference new custom objects.
**/
public without sharing class CC_EventRegistrationClass {
    
    @AuraEnabled
    public static resultWrapper DoInit(String campaignId,String pm){
        System.debug(LoggingLevel.DEBUG, 'CampaignId: ' + campaignId);
        
        resultWrapper returnResult = new resultWrapper();
        returnResult.SessionList = new List<SessionWrapper>();
        
        String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        //removed: no value on PM
        //Participant__c contactrec = [SELECT Id, Member_Contact__r.FirstName, Member_Contact__r.LastName, Member_Contact__r.Email,Member_Contact__r.Department FROM Participant__c WHERE Name = :pm Limit 1];
        
        // campaignId = 'g3UZle8Tnj1';
        
        List<Event__c> campaignRec = [SELECT Id, Name, OwnerId, Contact_Us_User__c, Time_Zone__c FROM Event__c WHERE  Event_Id__c =: campaignId];
        if(campaignRec.size() > 0){
            /*removed
            returnResult.FirstName = contactrec.Member_Contact__r.FirstName;
            returnResult.LastName = contactrec.Member_Contact__r.LastName;
            returnResult.Email = contactrec.Member_Contact__r.Email;
            returnResult.Department = contactrec.Member_Contact__r.Department;
            */
            //List<SessionWrapper> sessionListResult = new List<SessionWrapper>();
            List<Session__c> EventSessionList = [SELECT Id, Name, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c
                                                 FROM Session__c WHERE Event__c =: campaignRec[0].Id  AND IsActive__c = true ORDER BY  Start_Date_Time__c,Name];
            
            for(Session__c session : EventSessionList){
                SessionWrapper sessionwrapper = new SessionWrapper();
                sessionwrapper.isSelected = false;
                sessionwrapper.EventId = session.Id;
                sessionwrapper.EventName = session.Name;
                //sessionwrapper.EventName = contactrec.FirstName;
                sessionwrapper.EventDate = session.Start_Date_Time__c.format('MMMM d, yyyy', strTZone);
                sessionwrapper.StartTime = session.Start_Date_Time__c.format('h:mm a', strTZone) + ' ' + session.Time_Zone__c;
                sessionwrapper.EndTime = session.End_Date_Time__c.format('h:mm a', strTZone) + ' ' + session.Time_Zone__c;
                returnResult.SessionList.add(sessionwrapper);
            }
            return returnResult;
        }else{
            return null;
        }
    }
    
    /**@AuraEnabled
    public static Contact getContactInfo(string emailstr){
        //guest user cant read contact record
        Contact contactrec = [SELECT Id, FirstName, LastName, Email,Department FROM Contact WHERE Email = : emailstr Limit 1];
        return contactrec;
    }
    **/
    
    public static String getCampaignMemberStatus(Id contactId, Id campaignId){
        String strStatus;
        List<Participant__c> cmpMemberList = [SELECT Id, Name, Status__c FROM Participant__c WHERE Event__c =: campaignId AND Member_Contact__c =: contactId];
        if(!cmpMemberList.isEmpty()){
            strStatus = cmpMemberList.get(0).Status__c;
        }else{
            strStatus = 'Not Registered';
        }
        return strStatus;
    }
    
    
    @AuraEnabled
    public static String submitBooking(String campaignId,String FirstName, String LastName, String Email, String Company,List<String> sessionIds) {
        Boolean insertParticipant = true;
        Boolean insertSession = true;
        List<Event__c> campaignRec = [SELECT Id,Name FROM Event__c WHERE  Event_Id__c =: campaignId];
        List<Contact> lstContacts = [SELECT Id, Email FROM Contact WHERE Email =: Email ORDER BY LastModifiedDate DESC ];
        Contact contactRec = new Contact();
        
        Participant__c participant = new Participant__c();
        participant.Event__c = campaignRec.get(0).Id;
        
        if(!lstContacts.isEmpty()){ //Search for existing contact
            contactRec = lstContacts.get(0);
            String strStatus = getCampaignMemberStatus(contactRec.Id,campaignRec.get(0).Id);
            
            if(strStatus == 'Responded'){ //Checks if the contact is already registered
                insertSession = false;
                return 'Registered';
            }else if(strStatus == 'Invited') { // If Status is Sent, update to Responded
                Participant__c cmp = [SELECT Id, Status__c, Member_Contact__c FROM Participant__c WHERE Event__c =: campaignRec.get(0).Id AND Member_Contact__c =: contactRec.Id];
                cmp.Status__c = 'Responded';
                update cmp;
                insertParticipant = false;
                participant.Id = cmp.Id;
                
            }else{ //Add the contact as campaign member
                participant.Member_Contact__c = contactRec.Id;
                participant.Status__c = 'Responded';
            }
            
        }
        
        else{ //checks for existing lead to be converted to contact as participant
            List<Lead> lstLeads = [SELECT Id, Name, Email FROM Lead WHERE  Email =: Email ORDER BY LastModifiedDate DESC];
            if(!lstLeads.isEmpty()){
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(lstLeads.get(0).Id);
                lc.setDoNotCreateOpportunity(true);
                
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                contactRec.Id = lcr.getContactId();
            }else{
                Contact conRecord = new Contact();
                conRecord.FirstName = FirstName;
                conRecord.LastName = LastName;
                conRecord.Email = Email;
                insert conRecord;
                contactRec.Id = conRecord.Id;
            }
            participant.Member_Contact__c = contactRec.Id;
            participant.Status__c = 'Responded';
        }
        
        if(insertParticipant) insert participant;
        
        if(insertSession){
            //Inserts Sessions against the participant
            List<Session_Participant__c> sessionList = new List<Session_Participant__c>();
            for(String sessionId : sessionIds){
                Session_Participant__c sessionRec = new Session_Participant__c();
                sessionRec.Participant__c = participant.Id;
                sessionRec.Event__c = campaignRec.get(0).Id;
                sessionRec.Session__c = sessionId;
                sessionRec.Contact__c = contactRec.Id;
                sessionList.add(sessionRec);
            }
            try{
                insert sessionList;
                System.debug(LoggingLevel.DEBUG, '--- Insert Success: ' + sessionList.size());
                
                participant.Session_Modified__c = true;
                update participant;
            }
            catch(Exception ex){
                System.debug(LoggingLevel.DEBUG, '--- Insert Error: ' + ex.getMessage());
            }
        }
        
        return 'Success';        
    }
    
    public class resultWrapper {
        
        @AuraEnabled public String FirstName {get;set;}
        @AuraEnabled public String LastName {get;set;}
        @AuraEnabled public String Email {get;set;}
        @AuraEnabled public String Department {get;set;}
        @AuraEnabled public List<SessionWrapper> SessionList {get;set;} 
    }  
    
    
    public class SessionWrapper {
        @AuraEnabled public boolean isSelected {get;set;}
        @AuraEnabled public String EventId {get;set;}
        @AuraEnabled public String EventName {get;set;}
        @AuraEnabled public String EventDate {get;set;}
        @AuraEnabled public String StartTime {get;set;}
        @AuraEnabled public String EndTime {get;set;} 
    }
    
}