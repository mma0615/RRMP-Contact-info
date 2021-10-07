/**
 * Created by angelorivera on 10/12/20.
 */

public class ParticipantMilestoneTriggerHandler {
    /*******************************************************************************
        * @description  handles all before insert events. Filter event criteria here
        * @param        newMap - Trigger.newMap context variable
        * @revision     10.09.2020 - APRivera - Created
        *******************************************************************************/
    public static void handleAfterInsert(Map<Id, Participant_Milestone__c> newMap) {
        processNewUserMilestones(newMap);

    }
    /*******************************************************************************
        * @description  handles all before insert events. Filter event criteria here
        * @param        newMap - Trigger.newMap context variable
        * @revision     10.09.2020 - APRivera - Created
        *******************************************************************************/
    public static void handleAfterUpdate(Map<Id, Participant_Milestone__c> newMap) {
        processNewUserMilestones(newMap);
    }


    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.09.2020
    * @description  Process User Journeys
    * @param        newMap - map of the new records
    * @revision     10.09.2020 - APRivera - Created
    *******************************************************************************/
    public static void processNewUserMilestones(Map<Id, Participant_Milestone__c> newMap){
        List<Participant_Milestone__c> lstUserMilestones = new List<Participant_Milestone__c>();
        Set<Id> setUserJourneyId = new Set<Id>();

        for(Participant_Milestone__c usrMilestone : newMap.values()){
            System.debug(LoggingLevel.DEBUG, '!@# System Generated?: ' + usrMilestone.System_Generated__c);
            if(usrMilestone.System_Generated__c){
                lstUserMilestones.add(usrMilestone);
                setUserJourneyId.add(usrMilestone.Journey__c);
            }
        }

        if(!lstUserMilestones.isEmpty()){
            JourneyParticipantServices.processNewUserMilestones(lstUserMilestones, setUserJourneyId);
        }
    }
}