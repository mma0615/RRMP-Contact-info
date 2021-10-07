/**
 * Created by angelorivera on 10/12/20.
 */

public class MilestoneTriggerHandler {
    /*******************************************************************************
        * @description  handles all after insert events.
        * @param        newMap - Trigger.newMap context variable
        * @revision     10.09.2020 - APRivera - Created
        *******************************************************************************/
    public static void handleAfterInsert(Map<Id, Milestone__c> newMap) {
        processMilestones(null, newMap, 'INSERT');
    }

    /*******************************************************************************
        * @description  handles all after update events.
        * @param        newMap - Trigger.newMap context variable
        * @revision     31.03.2021 - APRivera - Created
        *******************************************************************************/
    public static void handleBeforeUpdate(Map<Id, Milestone__c> newMap) {
        //processMilestones(null, newMap, 'UPDATE');
    }
    /*******************************************************************************
        * @description  handles all after update events.
        * @param        oldMap - Trigger.oldMap context variable
        * @param        newMap - Trigger.newMap context variable
        * @revision     31.03.2021 - APRivera - Created
        *******************************************************************************/
    public static void handleAfterUpdate(Map<Id, Milestone__c> oldMap, Map<Id, Milestone__c> newMap) {
        processMilestones(oldMap, newMap, 'UPDATE');
    }

    /*******************************************************************************
       * @description  handles all after delete events.
       * @param        oldMap - Trigger.oldMap context variable
       * @revision     10.09.2020 - APRivera - Created
       *******************************************************************************/
    public static void handleBeforeDelete(Map<Id, Milestone__c> oldMap) {
        processMilestones(oldMap,null, 'DELETE');
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.10.2020
    * @description  Process Milestones
    * @param        oldMap - map of the old records
    * @param        newMap - map of the new records
    * @param        evt - trigger event
    * @revision     10.10.2020 - APRivera - Created
    *******************************************************************************/
    public static void processMilestones(Map<Id, Milestone__c> oldMap, Map<Id, Milestone__c> newMap, String evt){
        List<Milestone__c> lstMilestones = new List<Milestone__c>();
        Set<Id> setJourneyIds = new Set<Id>();

        if(evt == 'INSERT'){
            for(Milestone__c mStones : newMap.values()){
                if(mStones.Journey__c != null){
                    setJourneyIds.add(mStones.Journey__c);
                    lstMilestones.add(mStones);
                }
            }
            if(!setJourneyIds.isEmpty()) JourneyParticipantServices.processNewMilestones(setJourneyIds, lstMilestones);
        }else if (evt == 'DELETE') {
            for(Milestone__c mStones : oldMap.values()){
                if(mStones.Journey__c != null){
                    setJourneyIds.add(mStones.Journey__c);
                    lstMilestones.add(mStones);
                }
            }
            if(!setJourneyIds.isEmpty()) JourneyParticipantServices.processDeletedMilestones(setJourneyIds, lstMilestones);
        }else if(evt == 'UPDATE'){
            for(Milestone__c mStones : newMap.values()){
                if(oldMap != null){
                    Milestone__c mStonesOld = oldMap.get(mStones.Id);
                    if(mStones.Journey__c != null){
                        if(mStones.RecordTypeId != mStonesOld.RecordTypeId || mStones.Sort_Order__c != mStonesOld.Sort_Order__c
                                || mStones.Parent__c != mStonesOld.Parent__c || mStones.Is_Active__c != mStonesOld.Is_Active__c ){
                            setJourneyIds.add(mStones.Journey__c);
                            lstMilestones.add(mStones);
                        }
                    }
                }else{
                    setJourneyIds.add(mStones.Journey__c);
                    lstMilestones.add(mStones);
                }
            }
            if(!setJourneyIds.isEmpty()) JourneyParticipantServices.processUpdatedMilestones(setJourneyIds, lstMilestones);
        }

    }
}