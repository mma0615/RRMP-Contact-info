public class ParticipantTriggerHandler{

    public static Boolean firstCall = false;
    public static void onAfterInsert(List<Participant__c> newParticipantList, Map<Id,Participant__c> newParticipantMap, List<Participant__c> oldParticipantList, Map<Id,Participant__c> oldParticipantMap){      
        /*List<Participant__c> participantInvited = new List<Participant__c>();
        Map<String, List<Participant__c>> participantMap =  new Map<String, List<Participant__c>>();
        Set<Id> eventIds = new Set<Id>();
        
        for(Participant__c participant: newParticipantMap.values()){
            if(participant.Status__c == UtilityConstant.PARTICIPANT_STATUS_INVITED) {
                if(participantMap.containsKey(UtilityConstant.PARTICIPANT_STATUS_INVITED)){
                    List<Participant__c> dataList = participantMap.get(UtilityConstant.PARTICIPANT_STATUS_INVITED);
                    dataList.add(participant);
                    eventIds.add(participant.Event__c);
                    participantMap.put(UtilityConstant.PARTICIPANT_STATUS_INVITED, dataList);
                }
                else{
                    List<Participant__c> dataList = new List<Participant__c>();
                    dataList.add(participant);
                    eventIds.add(participant.Event__c);
                    participantMap.put(UtilityConstant.PARTICIPANT_STATUS_INVITED, dataList);
                    system.debug('PARTICIPANT MAP');
                }
            }
            else if(participant.Status__c == UtilityConstant.PARTICIPANT_STATUS_RESPONDED){
                if(participantMap.containsKey(UtilityConstant.PARTICIPANT_STATUS_RESPONDED)){
                    List<Participant__c> dataList = participantMap.get(UtilityConstant.PARTICIPANT_STATUS_RESPONDED);
                    dataList.add(participant);
                    eventIds.add(participant.Event__c);
                    participantMap.put(UtilityConstant.PARTICIPANT_STATUS_RESPONDED, dataList);
                }
                else{
                    List<Participant__c> dataList = new List<Participant__c>();
                    dataList.add(participant);
                    eventIds.add(participant.Event__c);
                    participantMap.put(UtilityConstant.PARTICIPANT_STATUS_RESPONDED, dataList);
                }
            }
        }
        
        if(!participantMap.isEmpty()){
            system.debug('BEFORE SENDING:');
            ParticipantTriggerUtility.sendEmailToParticipant(participantMap, eventIds);
        }*/
    }
    
    public static void onAfterUpdate(List<Participant__c> newParticipantList, Map<Id,Participant__c> newParticipantMap, List<Participant__c> oldParticipantList, Map<Id,Participant__c> oldParticipantMap){
        /*List<Participant__c> participantInvited = new List<Participant__c>();
        Map<String, List<Participant__c>> participantMap =  new Map<String, List<Participant__c>>();
        Set<Id> eventIds = new Set<Id>();
        system.debug('IS HERE');
        for(Participant__c participant: newParticipantMap.values()){
            if(participant.Status__c == UtilityConstant.PARTICIPANT_STATUS_INVITED) {
                if(participantMap.containsKey(UtilityConstant.PARTICIPANT_STATUS_INVITED)){
                    List<Participant__c> dataList = participantMap.get(UtilityConstant.PARTICIPANT_STATUS_INVITED);
                    dataList.add(participant);
                    eventIds.add(participant.Event__c);
                    participantMap.put(UtilityConstant.PARTICIPANT_STATUS_INVITED, dataList);
                }
                else{
                    List<Participant__c> dataList = new List<Participant__c>();
                    dataList.add(participant);
                    eventIds.add(participant.Event__c);
                    participantMap.put(UtilityConstant.PARTICIPANT_STATUS_INVITED, dataList);
                }
            }
            else if(participant.Status__c == UtilityConstant.PARTICIPANT_STATUS_RESPONDED){
                if(participantMap.containsKey(UtilityConstant.PARTICIPANT_STATUS_RESPONDED)){
                    List<Participant__c> dataList = participantMap.get(UtilityConstant.PARTICIPANT_STATUS_RESPONDED);
                    dataList.add(participant);
                    eventIds.add(participant.Event__c);
                    participantMap.put(UtilityConstant.PARTICIPANT_STATUS_RESPONDED, dataList);
                }
                else{
                    List<Participant__c> dataList = new List<Participant__c>();
                    dataList.add(participant);
                    eventIds.add(participant.Event__c);
                    participantMap.put(UtilityConstant.PARTICIPANT_STATUS_RESPONDED, dataList);
                }
            }
        }
        
        if(!participantMap.isEmpty()){
            ParticipantTriggerUtility.sendEmailToParticipant(participantMap, eventIds);
        }*/
    }
    
    /*
public static void onBeforeInsert(List<Participant__c> newParticipantList, Map<Id,Participant__c> newParticipantMap, List<Participant__c> oldParticipantList, Map<Id,Participant__c> oldParticipantMap){
} 
public static void onBeforeUpdate(List<Participant__c> newParticipantList, Map<Id,Participant__c> newParticipantMap, List<Participant__c> oldParticipantList, Map<Id,Participant__c> oldParticipantMap){
}
public static void onBeforeDelete(List<Participant__c> newParticipantList, Map<Id,Participant__c> newParticipantMap, List<Participant__c> oldParticipantList, Map<Id,Participant__c> oldParticipantMap){
}
public static void onAfterDelete(List<Participant__c> newParticipantList, Map<Id,Participant__c> newParticipantMap, List<Participant__c> oldParticipantList, Map<Id,Participant__c> oldParticipantMap){
}  
public static void onAfterUndelete(List<Participant__c> newParticipantList, Map<Id,Participant__c> newParticipantMap, List<Participant__c> oldParticipantList, Map<Id,Participant__c> oldParticipantMap){
}  
*/
    
}