global class CampaignHierarchyPage {
    
    @AuraEnabled     
    public static String objectType(Id recordIdVal){
        Schema.SObjectType objType = recordIdVal.getSobjectType(); 
        system.debug('objType'+objType);
        return String.valueOf(objType);
    }
    
    @AuraEnabled     
    public static List<Campaign__c> searchForCampaign(Id recordIdVal){
        Schema.SObjectType objType = recordIdVal.getSobjectType(); 
        List<Campaign__c> campList;
        if(string.valueOf(objType) == 'Campaign__c'){
            campList = [SELECT Id, Name FROM Campaign__c WHERE Id =: recordIdVal];
        }
        system.debug('Campaign record>>>' + campList);
        return campList;
    }
    
    @AuraEnabled     
    public static List<Event__c> searchForEvent(Id recordIdVal){
        Schema.SObjectType objType = recordIdVal.getSobjectType(); 
        List<Event__c> eventList;
        if(string.valueOf(objType) == 'Campaign__c'){
            eventList = [SELECT Id, Name, Campaign__c, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c FROM Event__c WHERE Campaign__c =: recordIdVal];
        }
        else if(string.valueOf(objType) == 'Event__c'){
            eventList = [SELECT Id, Name, Campaign__c, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c FROM Event__c WHERE Id =: recordIdVal];
        }
        system.debug('Event record>>>' + eventList);
        return eventList;
    }
    
    @AuraEnabled 
    public static List<Session__c> searchForSession(List<Id> eventList, Id recordIdVal){
        system.debug('eventList>>>'+eventList);
        List<Session__c> sessionList;
        if(eventList.size() > 0){
            sessionList = [SELECT Id, Name, Event__c, Event__r.Campaign__c, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c FROM Session__c WHERE Event__c IN: eventList];
        }
        else if(recordIdVal != null){
            sessionList = [SELECT Id, Name, Event__c, Event__r.Campaign__c, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c FROM Session__c WHERE Id =: recordIdVal];
        }
        system.debug('Session record>>>' + sessionList);
        return sessionList;
    }
}