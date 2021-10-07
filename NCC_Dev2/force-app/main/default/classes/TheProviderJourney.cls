/**
* @description Controller class for 'JourneyPage' Aura Component
* @revision
*           11.09.2020 - APRivera - Updated Class
**/
public class TheProviderJourney {
    
    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         11.09.2020
    * @description  Wrapper Class for User Journey, Milestone, Metrics and Actions
    * @revision     11.09.2020 - APRivera - Created
    *******************************************************************************/
    public class UserJourneyWrapperClass{
        @AuraEnabled  public Journey_Participant__c userJourney { get; set; }
        @AuraEnabled  public List<Participant_Milestone__c> lstUserMilestones { get; set; }
        @AuraEnabled  public Map<String, List<Participant_Milestone_Metric__c>> mapMetricsByMilestoneName { get; set; }
        @AuraEnabled  public Map<String, List<Task>> mapTasksByMilestoneName { get; set; }
        @AuraEnabled  public List<Milestone__c> journeyMilestoneList;
        @AuraEnabled  public Journey__c journeyData;
        @AuraEnabled  public Boolean urlFromJourney;
    }
  
    
    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         11.09.2020
    * @description  Retrieves User Journey Record with related User Milestone, Actions and Metrics
    * @param        strJourneyId - List of User Milestones to be processed
    * @revision     11.09.2020 - APRivera - Created
    * @return       journeyWrapper - instance of UserJourneyWrapperClass
    *******************************************************************************/
    @AuraEnabled
    public static UserJourneyWrapperClass getUserJourney(Id strJourneyId){
        UserJourneyWrapperClass journeyWrapper = new UserJourneyWrapperClass();
        
        Set<Id> setJourneyIds = new Set<Id>();
        Set<Id> setUserJourneyIds = new Set<Id>();
        String objectNameOfId = strJourneyId.getSObjectType().getDescribe().getName();
        System.debug(LoggingLevel.DEBUG, '!@# objectNameOfId: ' + objectNameOfId);
        setUserJourneyIds.add(strJourneyId);
        //retrieves User Journey Record
        Map<Id, Journey_Participant__c> mapUserJourneysByIds = new Map<Id, Journey_Participant__c>();
        if(objectNameOfId.equals('Journey_Participant__c')){
            mapUserJourneysByIds = JourneyParticipantServices.getUserJourneys(setUserJourneyIds);
            System.debug(LoggingLevel.DEBUG, '!@# mapUserJourneysByIds: ' + mapUserJourneysByIds.size());
            journeyWrapper.urlFromJourney = false;
            if(!mapUserJourneysByIds.isEmpty()){
                journeyWrapper.userJourney = new Journey_Participant__c();
                journeyWrapper.lstUserMilestones = new List<Participant_Milestone__c>();
                journeyWrapper.userJourney = mapUserJourneysByIds.get(strJourneyId);
                setJourneyIds.add(journeyWrapper.userJourney.Journey__c);
                if(!journeyWrapper.userJourney.Participant_Milestones__r.isEmpty()){
                    journeyWrapper.lstUserMilestones = journeyWrapper.userJourney.Participant_Milestones__r;
                    Set<Id> setMilestoneIds = new Set<Id>();
                    for(Participant_Milestone__c um : journeyWrapper.lstUserMilestones){
                        setMilestoneIds.add(um.Id);
                    }
                    System.debug('+++ setMilestoneIds' + setMilestoneIds);
                    
                    if(!setMilestoneIds.isEmpty()){
                        Map<Id,Participant_Milestone__c> mapMilestoneByIds = JourneyParticipantServices.getUserMilestones(setMilestoneIds);
                        journeyWrapper.mapMetricsByMilestoneName = new Map<String, List<Participant_Milestone_Metric__c>>();
                        journeyWrapper.mapTasksByMilestoneName = new Map<String, List<Task>>();
                        for(Participant_Milestone__c um : mapMilestoneByIds.values()){
                            //retrieves User Milestone Metrics
                            if(!um.Participant_Milestone_Metrics__r.isEmpty()){
                                journeyWrapper.mapMetricsByMilestoneName.put(um.Name, um.Participant_Milestone_Metrics__r);
                            }
                            //retrieves User Milestone Actions
                            if(!um.Tasks.isEmpty()){
                                journeyWrapper.mapTasksByMilestoneName.put(um.Name, um.Tasks);
                            }
                        }
                    }
                }
            }

            Journey__c jData = JourneyParticipantServices.getMilestoneFromJourney(setJourneyIds);
            journeyWrapper.journeyMilestoneList = jData.Milestones__r;
            journeyWrapper.journeyData = jData;
        } 
        else if(objectNameOfId.equals('Journey__c')) {
           Journey__c jData = JourneyParticipantServices.getMilestoneFromJourney(setJourneyIds);
           journeyWrapper.journeyMilestoneList = jData.Milestones__r;
           journeyWrapper.journeyData = jData;
           journeyWrapper.urlFromJourney = true;
        }

        //Map<Id, Journey_Participant__c> mapUserJourneysByIds  = JourneyParticipantServices.getUserJourneys(setJourneyIds);
        //System.debug('!@# mapUserJourneysByIds: ' + JSON.serializePretty(mapUserJourneysByIds));
        //journeyWrapper.userJourney = mapUserJourneysByIds.get(participantId);
        //journeyWrapper.lstUserMilestones = mapUserJourneysByIds.get(participantId).Participant_Milestones__r;
        
        
        System.debug(LoggingLevel.DEBUG, '!@# Data: ' + journeyWrapper); 
        return  journeyWrapper;
    }    
}