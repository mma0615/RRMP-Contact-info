public class SessionParticipantTriggerHandler{
    
    public static void onAfterInsert(List<Session_Participant__c> newSessionParticipantList, Map<Id,Session_Participant__c> newSessionParticipantMap, List<Session_Participant__c> oldSessionParticipantList, Map<Id,Session_Participant__c> oldSessionParticipantMap){      
        for(Session_Participant__c sessionParticipant: newSessionParticipantList){
            if(sessionParticipant.Status__c == 'Registered')
                SessionParticipantTriggerUtility.sendCalendarInvite(newSessionParticipantList);
        }
    }

    /*
	public static void onBeforeInsert(List<Session_Participant__c> newSessionParticipantList, Map<Id,Session_Participant__c> newSessionParticipantMap, List<Session_Participant__c> oldSessionParticipantList, Map<Id,Session_Participant__c> oldSessionParticipantMap){
    }
    public static void onBeforeUpdate(List<Session_Participant__c> newSessionParticipantList, Map<Id,Session_Participant__c> newSessionParticipantMap, List<Session_Participant__c> oldSessionParticipantList, Map<Id,Session_Participant__c> oldSessionParticipantMap){
    }
    public static void onBeforeDelete(List<Session_Participant__c> newSessionParticipantList, Map<Id,Session_Participant__c> newSessionParticipantMap, List<Session_Participant__c> oldSessionParticipantList, Map<Id,Session_Participant__c> oldSessionParticipantMap){
    }
    public static void onAfterUpdate(List<Session_Participant__c> newSessionParticipantList, Map<Id,Session_Participant__c> newSessionParticipantMap, List<Session_Participant__c> oldSessionParticipantList, Map<Id,Session_Participant__c> oldSessionParticipantMap){
    }
    public static void onAfterDelete(List<Session_Participant__c> newSessionParticipantList, Map<Id,Session_Participant__c> newSessionParticipantMap, List<Session_Participant__c> oldSessionParticipantList, Map<Id,Session_Participant__c> oldSessionParticipantMap){
    }  
    public static void onAfterUndelete(List<Session_Participant__c> newSessionParticipantList, Map<Id,Session_Participant__c> newSessionParticipantMap, List<Session_Participant__c> oldSessionParticipantList, Map<Id,Session_Participant__c> oldSessionParticipantMap){
    }  
    */
}