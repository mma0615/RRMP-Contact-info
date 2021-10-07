/*************************************************
* Created by:  Allen Francisco
* Task#:	    00702
* Data:	    January 23, 2020
* Description: Controller for EventCalendar lightning component.
**************************************************
*/
public without sharing class EventCalendarController {
    @AuraEnabled
    public static List<eventWrapper> getEventList(String contactId){
        List<eventWrapper> eventListData = new List<eventWrapper>();
        //try{
            String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
            String conId = [SELECT Id FROM Contact WHERE Contact_Id__c =: contactId LIMIT 1].Id;
            for(Participant__c par: [SELECT Id, Status__c, Member_Contact__c, Event__c, Event__r.Start_Date_Time__c, Event__r.End_Date_Time__c, 
                                     Event__r.Name, Event__r.Time_Zone__c FROM Participant__c WHERE Member_Contact__c =: conId]){
                                         eventWrapper data = new eventWrapper();
                                         data.status = par.Status__c;
                                         data.eventId = par.Event__c;
                                         system.debug('StartTime'+par.Event__r.Start_Date_Time__c);
                                         system.debug('StartTime Format'+par.Event__r.Start_Date_Time__c.format('YYYY-MM-DD hh:mm:ss',strTZone));
                                         data.eventStart = DateTime.valueOf(par.Event__r.Start_Date_Time__c.format('YYYY-MM-DD hh:mm:ss',strTZone));
                                         system.debug('Data Start'+par.Event__r.Start_Date_Time__c.format('YYYY-MM-DD hh:mm:ss',strTZone));
                                         data.eventEnd = DateTime.valueOf(par.Event__r.End_Date_Time__c.format('YYYY-MM-DD hh:mm:ss',strTZone));
                                         data.name = par.Event__r.Name;
                                         data.timezone = par.Event__r.Time_Zone__c;
                                         eventListData.add(data);
                                         
                                     }
            
            for(Session_Participant__c sessPart :  [SELECT Id, Name, Status__c, Participant__c, Session__c, Session__r.Start_Date_Time__c, Event__c, 
                                                    Contact__c, Session_Start_Date__c, Session__r.End_Date_Time__c, Session__r.Time_Zone__c,
                                                    Session__r.Name
                                                    FROM Session_Participant__c
               										WHERE Status__c != null AND Event__c != null AND Session__r.Start_Date_Time__c != null 
                                                    AND Session__r.End_Date_Time__c != null AND Session__r.Time_Zone__c != null AND Session__c != null 
                                                    AND (Participant__r.Member_Contact__c =: contactId OR Contact__c =: contactId)]){
                                                        eventWrapper data = new eventWrapper();
                                                        data.status = sessPart.Status__c;
                                                        data.eventId = sessPart.Event__c;
                                                        data.eventStart = DateTime.valueOf(sessPart.Session__r.Start_Date_Time__c.format('YYYY-MM-DD hh:mm:ss',strTZone));
                                                        data.eventEnd = DateTime.valueOf(sessPart.Session__r.End_Date_Time__c.format('YYYY-MM-DD hh:mm:ss',strTZone));
                                                        //data.eventEnd = DateTime.valueOf(sessPart.Session__r.End_Date_Time__c.format('MM/dd/yyyy HH:mm:ss',strTZone));
                                                        data.timezone = sessPart.Session__r.Time_Zone__c;
                                                        data.name = sessPart.Session__r.Name;
                                                       eventListData.add(data);  
                                                    }
            
            if(eventListData.isEmpty()){
                throw new AuraHandledException('No events for the current user');
            }
       // }
       // catch(Exception e){
        //    throw new AuraHandledException('Calendar failed to load: '+e.getMessage());
        //}
        return eventListData;
    }
    public class eventWrapper{
        @AuraEnabled
        public String eventId;
        @AuraEnabled
        public DateTime eventStart;
        @AuraEnabled
        public DateTime eventEnd;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String timezone;
    }
}