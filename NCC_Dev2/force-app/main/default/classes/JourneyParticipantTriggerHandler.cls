/**
* @description TriggerHandler Class for Journey_Participant__c Object Trigger
* @revision
*           10.09.2020 - APRivera - Initial Creation
**/

public class JourneyParticipantTriggerHandler {

    /*******************************************************************************
    * @description  handles all before insert events. Filter event criteria here
    * @param        newMap - Trigger.newMap context variable
    * @revision     10.09.2020 - APRivera - Created
    *******************************************************************************/
    public static void handleAfterInsert(Map<Id, Journey_Participant__c> newMap) {
        processNewJourneyParticipants(newMap);

    }




    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.09.2020
    * @description  Process User Journeys
    * @param        newMap - map of the new records
    * @revision     10.09.2020 - APRivera - Created
    *******************************************************************************/
    public static void processNewJourneyParticipants(Map<Id, Journey_Participant__c> newMap){
        List<Journey_Participant__c> lstUserJourneys = new List<Journey_Participant__c>();
        Set<Id> setJourneyTemplateId = new Set<Id>();

        for(Journey_Participant__c usrJourney : newMap.values()){
            System.debug(LoggingLevel.DEBUG, '!@# Journey Id: ' + usrJourney.Journey__c);
            if(usrJourney.Journey__c != null){
                setJourneyTemplateId.add(usrJourney.Journey__c);
                lstUserJourneys.add(usrJourney);
            }
        }

        if(!lstUserJourneys.isEmpty()){
            JourneyParticipantServices.processNewUserJourneys(lstUserJourneys, setJourneyTemplateId);
        }
    }
}