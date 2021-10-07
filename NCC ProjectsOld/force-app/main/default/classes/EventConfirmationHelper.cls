/**
@author Jasmine Nguyen
@date 05 September 2020
@group NCC
@description Event Confirmation Template
@revision APRivera - Updated object references
**/

public without sharing class EventConfirmationHelper {

    @testVisible
    public static Boolean throwFakeException = false;
    
    // Get sessions details
    public static List<SessionWrapper> getSessionsDetails(String campaignMemberId) {
        List<SessionWrapper> sessionsWrappers = new List<SessionWrapper>();
        
        List<Participant__c> campaignMembers = [SELECT Id, Event__c, Member_Contact__c, Member_Contact__r.AccountId, Event__r.OwnerId,
                                                        Event__r.Contact_Us_User__c, Event__r.Location__c, Event__r.Time_Zone__c
                                                FROM Participant__c WHERE Id =: campaignMemberId LIMIT 1];
        if (campaignMembers.size() > 0){
            String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
            for (Session_Participant__c s : [SELECT Id, Name,Event__c, Contact__c, Session__r.Start_Date_Time__c, Session__r.End_Date_Time__c,
                                            Event__r.Location__r.Name, Session__r.Time_Zone__c, Session__r.Name
                                             FROM Session_Participant__c
                                             WHERE Contact__c =: campaignMembers[0].Member_Contact__c
                                             AND Event__c =: campaignMembers[0].Event__c]){
                 if (s != null){
                     SessionWrapper sw = new SessionWrapper();
                     sw.Name = s.Session__r.Name;
                     sw.SessionDate = s.Session__r.Start_Date_Time__c.format('MM/dd/yyyy', strTZone);
                     sw.SessionTime = s.Session__r.Start_Date_Time__c.format('h:mm a', strTZone) + ' to ' + s.Session__r.End_Date_Time__c.format('h:mm a', strTZone) + ' ' + s.Session__r.Time_Zone__c;
                     sw.SessionLocation = s.Event__r.Location__r.Name;
                     sessionsWrappers.add(sw);
                 }
            }
        }
        System.debug('!@#-------- SESSIONS: ' + sessionsWrappers.size());
        return sessionsWrappers;
    }
    
    public class SessionWrapper{
        public String Name {get; set;}
        public String SessionDate {get; set;}
        public String SessionTime {get; set;}
        public String SessionLocation {get; set;}
    }
    
    // Get formatted date time
    public static String getFormattedDateTimeHelper(String campaignOwnerId, String campaignId, String startOrEndDate, String defined_format){
        String FormattedDatetime;
        if (campaignOwnerId == null || campaignId == null || startOrEndDate == null){
            return '';
        } else {
            String queryString = (startOrEndDate.toLowerCase() == 'start') ? 'SELECT Start_Date_Time__c, End_Date_Time__c, OwnerId, Contact_Us_User__c, Time_Zone__c FROM Event__c WHERE Id =: campaignId LIMIT 1'
                : 'SELECT Start_Date_Time__c, End_Date_Time__c, OwnerId, Contact_Us_User__c, Time_Zone__c FROM Event__c WHERE Id =: campaignId LIMIT 1';
            List<sObject> sobjList = Database.query(queryString);
            if (sobjList.size() > 0){
                Event__c campaign = (Event__c)sobjList[0];
                if (campaign != null ){
                    String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
                    if (campaign != null && throwFakeException == false){
                        DateTime localDateTime;
                        if (startOrEndDate.toLowerCase() == 'start' && campaign.Start_Date_Time__c != null){
                            localDateTime = campaign.Start_Date_Time__c;
                        } 
                        if (startOrEndDate.toLowerCase() == 'end' && campaign.End_Date_Time__c != null ){
                            localDateTime = campaign.End_Date_Time__c; 
                        }
                        if (localDateTime != null) FormattedDatetime = localDateTime.format(defined_format, strTZone) + ' ' + campaign.Time_Zone__c;
                        return FormattedDatetime;
                    }
                }  
            }
          
            return '';
            
        }
    }

}