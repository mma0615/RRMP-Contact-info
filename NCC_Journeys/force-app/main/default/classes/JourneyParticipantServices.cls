/**
* @description Service Class for Journey_Participant__c
* @revision
*           10.09.2020 - APRivera - Initial Creation
**/

public class JourneyParticipantServices {

    public static JourneyCommunitySettings__c UserJourneyCommunitySettings {
        get {
            if(UserJourneyCommunitySettings == null) UserJourneyCommunitySettings = JourneyCommunitySettings__c.getOrgDefaults();
            return UserJourneyCommunitySettings;
        }
        set;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         11.09.2020
    * @description  Returns the Community URL
    * @param        communityName - List of User Milestones to be processed
    * @revision     11.09.2020 - APRivera - Created
    * @return       siteUrl - URL of the Community
    *******************************************************************************/
    public static String getCommunityURL(String communityName){
        if (!Test.isRunningTest()){
            Network myNetwork = [SELECT Id FROM Network WHERE Name =: communityName];
            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.Id);
            return myCommunity.siteUrl ;
        } else {
            return 'some random url';
        }
    }

    @AuraEnabled
    public static String generateMilestones(Id journeyId) {
        String strResult ='';

        if(journeyId!=null){
            Journey__c journey = [SELECT Id, Event__c, Event__r.Name, Status__c, Campaign__c,
                                    (SELECT Id, Name FROM Milestones__r)
                                    FROM  Journey__c WHERE Id=: journeyId];

            if(journey.Campaign__c != null){

                List<Milestone__c> lstMilestones = new List<Milestone__c>();
                List<Event__c> lstEvents = new List<Event__c>();
                List<Survey__c> lstSurveys = new List<Survey__c>();
                List<Communication__c> lstCommunications = new List<Communication__c>();
                List<Session__c> lstSessions = new List<Session__c>();
                Set<Id> setExistingIds = new Set<Id>();

                for(Event__c evtRecord : [SELECT Id, Name, Campaign__c,
                                                (SELECT Id, Name FROM Surveys__r WHERE Milestone__c = TRUE),
                                                (SELECT Id, Name FROM CC_Sessions__r WHERE Milestone__c = TRUE)
                                            FROM Event__c
                                            WHERE Campaign__c =: journey.Campaign__c
                                            AND Journey__c =: journey.Id
                                            AND Milestone__c = TRUE]){
                    lstEvents.add(evtRecord);
                    lstSurveys.addAll(evtRecord.Surveys__r);
                    lstSessions.addAll(evtRecord.CC_Sessions__r);

                    //store all IDs so it wont be duplicated when created Milestones
                    if(!evtRecord.Surveys__r.isEmpty()){
                        for(Survey__c s :evtRecord.Surveys__r){
                            setExistingIds.add(s.Id);
                        }
                    }
                    if(!evtRecord.CC_Sessions__r.isEmpty()){
                        for(Session__c s :evtRecord.CC_Sessions__r){
                            setExistingIds.add(s.Id);
                        }
                    }
                }

                for(Communication__c comms : [SELECT Id, Journey__c, Campaign__c, Name
                                                    FROM Communication__c
                                                    WHERE  Journey__c =: journey.Id
                                                    AND Campaign__c =: journey.Campaign__c
                                                    AND Milestone__c = TRUE]){
                    lstCommunications.add(comms);
                }

                for(Survey__c surv : [SELECT Id, Campaign_1__c, Journey__c, Name
                                                FROM Survey__c
                                                WHERE Campaign_1__c =: journey.Campaign__c
                                                AND Journey__c =: journey.Id
                                                AND Milestone__c = TRUE]){
                    if(!setExistingIds.contains(surv.Id)) lstSurveys.add(surv);
                }

                if(!lstSurveys.isEmpty()){
                    createMilestones(lstMilestones, journey, lstSurveys);
                }

                if(!lstCommunications.isEmpty()){
                    createMilestones(lstMilestones, journey, lstCommunications);
                }

                if(!lstEvents.isEmpty()){
                    createMilestones(lstMilestones, journey, lstEvents);
                }

                if(!lstSessions.isEmpty()){
                    createMilestones(lstMilestones, journey, lstSessions);
                }

                if(!lstMilestones.isEmpty()){
                    Database.insert(lstMilestones);
                    strResult = lstMilestones.size() + ' milestones created.';
                }else{
                    strResult = 'No new milestones to be added.';
                }
            }else{
                strResult = 'Make sure that a campaign is linked to the journey before adding milestones.';
            }
        }

        return strResult;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         07.10.2020
    * @description  Generates New milestones
    * @param        lstMilestones list of user milestones to be added
    * @param        journey Journey record
    * @param        lstSObjectsType list of SObjects (Campaign, Survey or Communication)
    * @revision     07.10.2020 - APRivera - Created
    *******************************************************************************/
    public static void createMilestones(List<Milestone__c> lstMilestones, Journey__c journey, List<SObject> lstSObjectsType){
        List<SObject> lstSobjects = (List<SObject>)lstSObjectsType;
        Set<String> setMilestoneName = new Set<String>();
        for(Milestone__c m : journey.Milestones__r){
            setMilestoneName.add(m.Name);
        }

        for(SObject sObj : lstSobjects){
            Milestone__c milestone = new Milestone__c();
            if(sObj.getSObjectType() == Survey__c.getSObjectType()){
                milestone.Type__c = 'Survey';
            }else if(sObj.getSObjectType() == Event__c.getSObjectType()){
                milestone.Type__c = 'Event';
            }else if(sObj.getSObjectType() == Session__c.getSObjectType()){
                milestone.Type__c = 'Event';
            }else if(sObj.getSObjectType() == Communication__c.getSObjectType()){
                milestone.Type__c = 'Communication';
            }
            milestone.Name = (String)sObj.get('Name');
            milestone.Journey__c = journey.Id;
            milestone.Sort_Order__c = journey.Milestones__r.size() + lstMilestones.size() + 1;
            if(!setMilestoneName.contains((String)sObj.get('Name'))) lstMilestones.add(milestone);
            System.debug(LoggingLevel.DEBUG, '!@# Object Type: ' + sObj.Id.getSobjectType());
        }
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         15.10.2020
    * @description  Logic that fires when new Milestones are created
    * @param        setJourneyIds set of journey ids
    * @param        lstMilestones List of milestones
    * @revision     15.10.2020 - APRivera - Created
    *******************************************************************************/
    public static void processNewMilestones(Set<Id> setJourneyIds, List<Milestone__c> lstMilestones){
        List<Participant_Milestone__c> lstUserMilestones = new List<Participant_Milestone__c>();
        List<Journey_Participant__c> lstJourneyParticipants = new List<Journey_Participant__c>();
        Map<Id, Journey__c> mapJourneysByIds = new Map<Id, Journey__c>();
        mapJourneysByIds = getJourneyParticipantsByJourneyIds(setJourneyIds);

        for(Id jId : setJourneyIds){
            // check if journey has exiting journey participants
            if(!mapJourneysByIds.get(jId).Journey_Participants__r.isEmpty()){
                lstJourneyParticipants.addAll(mapJourneysByIds.get(jId).Journey_Participants__r);
            }
        }
        // if yes, insert new user milestones to these journey participants
        if(!lstJourneyParticipants.isEmpty()){
            for(Journey_Participant__c uj : lstJourneyParticipants){
                createUserMilestones(lstMilestones, uj, lstUserMilestones);
            }
            try {
                if(!lstUserMilestones.isEmpty()) Database.insert(lstUserMilestones);
            }catch (Exception ex){
                System.debug(LoggingLevel.DEBUG, '!@# ERROR IN INSERT: ' + ex.getMessage());
            }
        }
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         31.03.2021
    * @description  Logic that fires when new Milestones are created
    * @param        setJourneyIds set of journey ids
    * @param        lstMilestones List of milestones
    * @revision     15.10.2020 - APRivera - Created
    *******************************************************************************/
    public static void processUpdatedMilestones(Set<Id> setJourneyIds, List<Milestone__c> lstMilestones){
        Id milestoneRecordTypeId = Schema.SObjectType.Milestone__c.getRecordTypeInfosByName().get('Milestone').getRecordTypeId();
        List<Journey_Participant__c> lstJourneyParticipants = new List<Journey_Participant__c>();
        lstJourneyParticipants = getJourneyParticipantsWithMilestones(setJourneyIds);
        if(!lstJourneyParticipants.isEmpty()){
            List<Participant_Milestone__c> lstParticipantMilestones = new List<Participant_Milestone__c>();
            List<Milestone__c> lstMilestonesToUpdate = new List<Milestone__c>();
            List<Participant_Milestone__c> lstParticipantMilestonesToCreateMetrics = new List<Participant_Milestone__c>();
            Set<Id> setUserJourneyId = new Set<Id>();
            Set<Id> setParticipantMilestoneIds = new Set<Id>();
            for(Milestone__c m : lstMilestones){
                Milestone__c tempMilestone = new Milestone__c();
                if(m.RecordTypeId != milestoneRecordTypeId) { //if recordtype != Milestone
                    // Updates the parent Checkpoint to null
                    tempMilestone.Id = m.Id;
                    tempMilestone.Parent__c = null;
                    lstMilestonesToUpdate.add(tempMilestone);
                }
                for(Journey_Participant__c jp : lstJourneyParticipants){
                    if(!jp.Participant_Milestones__r.isEmpty()){
                        for(Participant_Milestone__c pm : jp.Participant_Milestones__r){
                            if(pm.Milestone__c == m.Id){
                                pm.Sort_Order__c = m.Sort_Order__c;
                                pm.Is_Active__c = m.Is_Active__c;
                                if(m.RecordTypeId == milestoneRecordTypeId){ //if recordtype = Milestone
                                    pm.Type__c =  m.Type__c;
                                    pm.Checkpoint__c = false;
                                    pm.Checkpoint_Name__c = m.Parent__c;
                                    lstParticipantMilestonesToCreateMetrics.add(pm);
                                    setUserJourneyId.add(pm.Journey__c);
                                }else{
                                    pm.Type__c = 'Checkpoint';
                                    pm.Checkpoint__c = true;
                                    pm.Checkpoint_Name__c = null;
                                    setParticipantMilestoneIds.add(pm.Id);
                                }
                                lstParticipantMilestones.add(pm);
                            }
                        }
                    }
                }
            }

            try {
                if(!lstParticipantMilestones.isEmpty()) Database.update(lstParticipantMilestones);
                if(!lstMilestonesToUpdate.isEmpty()) Database.update(lstMilestonesToUpdate);
                if(!lstParticipantMilestonesToCreateMetrics.isEmpty()) processNewUserMilestones(lstParticipantMilestonesToCreateMetrics, setUserJourneyId);
            }catch (Exception ex){
                System.debug(LoggingLevel.DEBUG, '!@# ERROR IN UPDATE: ' + ex.getMessage());
            }

            try {
                if(!setParticipantMilestoneIds.isEmpty()){
                    List<Participant_Milestone_Metric__c> lstParticipantMetrics = new List<Participant_Milestone_Metric__c>();
                    lstParticipantMetrics = [SELECT Id FROM Participant_Milestone_Metric__c WHERE Milestone__c IN: setParticipantMilestoneIds];
                    if(!lstParticipantMetrics.isEmpty()) Database.delete(lstParticipantMetrics);
                }
            }catch (Exception ex){
                System.debug(LoggingLevel.DEBUG, '!@# ERROR IN DELETE: ' + ex.getMessage());
            }
        }
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         19.03.2021
    * @description  Logic that fires when new Milestones are deleted
    * @param        setJourneyIds set of journey ids
    * @param        lstMilestones List of milestones
    * @revision     19.03.2021 - APRivera - Created
    *******************************************************************************/
    public static void processDeletedMilestones(Set<Id> setJourneyIds, List<Milestone__c> lstMilestones){
        List<Journey_Participant__c> lstJourneyParticipants = new List<Journey_Participant__c>();
        lstJourneyParticipants = getJourneyParticipantsWithMilestones(setJourneyIds);

        if(!lstJourneyParticipants.isEmpty()){
            List<Participant_Milestone__c> lstParticipantMilestones = new List<Participant_Milestone__c>();
            for(Milestone__c m : lstMilestones){
                for(Journey_Participant__c jp : lstJourneyParticipants){
                    if(!jp.Participant_Milestones__r.isEmpty()){
                        for(Participant_Milestone__c pm : jp.Participant_Milestones__r){
                            if(pm.Milestone__c == m.Id){
                                lstParticipantMilestones.add(pm);
                            }
                        }
                    }
                }
            }
            try {
                if(!lstParticipantMilestones.isEmpty()) Database.delete(lstParticipantMilestones);
            }catch (Exception ex){
                System.debug(LoggingLevel.DEBUG, '!@# ERROR IN DELETE: ' + ex.getMessage());
            }
        }
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         15.10.2020
    * @description  method used in CreateJourneyParticpants Aura component
    * @param        journeyId - journey Id
    * @return       strResult
    * @revision     15.10.2020 - APRivera - Created
    *******************************************************************************/
    @AuraEnabled
    public static String generateJourneyParticipants(Id journeyId) {
        String strResult ='';
        if(journeyId!=null){
            Journey__c journey = [SELECT Id, Event__c, Event__r.Name, Status__c, Campaign__c,
                                    (SELECT Id, Contact__c FROM Journey_Participants__r)
                                    FROM  Journey__c WHERE Id=: journeyId];
            if(journey.Status__c == 'Approved'){
                if(journey.Campaign__c != null){
                    List<Journey_Participant__c> lstJourneyParticipants = new List<Journey_Participant__c>();
                    Set<Id> setEventIds = new Set<Id>();
                    Set<Id> setContactIds = new Set<Id>();
                    Set<Id> setContactIdsWithUserJourneys = new Set<Id>();

                    for(Event__c e : [SELECT Id, Campaign__c FROM Event__c WHERE Campaign__c =: journey.Campaign__c]){
                        setEventIds.add(e.Id);
                    }

                    // get the existing contacts that are journey participants already
                    if(!journey.Journey_Participants__r.isEmpty()) {
                        for (Journey_Participant__c jp : journey.Journey_Participants__r) {
                            setContactIdsWithUserJourneys.add(jp.Contact__c);
                        }
                    }
                    // get contacts from session where Event's campaign = Journey.Campaign
                    for(Session_Participant__c session : getSessionParticipants(journey, setEventIds)){
                        if(!setContactIdsWithUserJourneys.contains(session.Contact__c)) setContactIds.add(session.Contact__c);
                    }

                    //get Participants of Events  where campaign = Journey.Campaign
                    for(Participant__c cm : getParticipants(journey, setEventIds)){
                        if(!setContactIdsWithUserJourneys.contains(cm.Member_Contact__c) && !setContactIds.contains(cm.Member_Contact__c)){
                            setContactIds.add(cm.Member_Contact__c);
                        }
                    }

                    //get communication recipients where communication.Journey = journey.id and communication.campaign = journey.campaign
                    for(Communication_Recipient__c cr : getCommunicationRecipients(journey)){
                        if(!setContactIdsWithUserJourneys.contains(cr.Contact__c) && !setContactIds.contains(cr.Contact__c)){
                            setContactIds.add(cr.Contact__c);
                        }
                    }

                    //get contacts from survey responses
                    for(Survey_Response__c sr : getSurveyResponses(journey)){
                        if(!setContactIdsWithUserJourneys.contains(sr.Contact__c) && !setContactIds.contains(sr.Contact__c)){
                            setContactIds.add(sr.Contact__c);
                        }
                    }

                    if(!setContactIds.isEmpty()){
                        generateJourneyParticipants(setContactIds, lstJourneyParticipants, journeyId);
                        try {
                            if(!lstJourneyParticipants.isEmpty()){
                                Database.insert(lstJourneyParticipants);
                                strResult = lstJourneyParticipants.size() + ' contacts added as journey participants.';
                                System.debug(LoggingLevel.DEBUG, '!@# lstJourneyParticipants: ' + lstJourneyParticipants.size());
                            }
                        }catch (Exception ex){
                            System.debug(LoggingLevel.DEBUG, '!@# ERROR IN INSERT: ' + ex.getMessage());
                        }
                    }else{
                        strResult = ' No New Participant/Contact to be added as new Journey participants.';
                    }
                }else{
                    strResult = 'Make sure that a campaign is linked to the journey before adding journey participants.';
                }
            }else{
                strResult = 'You can only add journey participants on Approved Journey.';
            }
        }
        return strResult;
    }


    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         03.10.2020
    * @description  Generates User Journey participants
    * @param        setContactIds -Set of contact ids
    * @param        lstJourneyParticipants - List of Journey participants
    * @param        journeyId - journey Id
    * @revision     03.10.2020 - APRivera - Created
    *******************************************************************************/
    public static void generateJourneyParticipants(Set<Id> setContactIds, List<Journey_Participant__c> lstJourneyParticipants, Id journeyId){
        for(Id conId : setContactIds){
            Journey_Participant__c jp = new Journey_Participant__c( Contact__c = conId, Journey__c = journeyId);
            lstJourneyParticipants.add(jp);
        }
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.09.2020
    * @description  Process User Journeys to be inserted.
    *               Copies values from Journey Template.
    *               Inserts User Milestones from Journey Template - Milestones.
    * @param        lstUserJourneys - List of User Journeys to be processed
    * @param        setJourneyIds - Journey template set of Ids
    * @revision     10.09.2020 - APRivera - Created
    *******************************************************************************/
    public static void processNewUserJourneys(List<Journey_Participant__c> lstUserJourneys, Set<Id> setJourneyIds){
        List<Journey_Participant__c> lstUserJourneysToProcess = new List<Journey_Participant__c>();
        List<Participant_Milestone__c> lstUserMilestonesToInsert = new List<Participant_Milestone__c>();
        Set<Id> setMilestoneIds = new Set<Id>();
        Map<Id,Journey__c> mapJourneysByIds = getJourney(setJourneyIds);

        if(!mapJourneysByIds.isEmpty()){
            //retrieves the User Journey Community URL
            System.debug('!@# UserJourneyCommunitySettings: ' + UserJourneyCommunitySettings.Community_Name__c);
            String strJourneyCommunityURL = getCommunityURL(UserJourneyCommunitySettings.Community_Name__c);

            if(strJourneyCommunityURL != null){
                for(Journey_Participant__c userJourney: lstUserJourneys){
                    //retrieves Journey details to be copied over to user journey
                    Journey__c journey = mapJourneysByIds.get(userJourney.Journey__c);
                    Journey_Participant__c uj = new Journey_Participant__c();
                    uj = updateUserJourney(userJourney, journey, strJourneyCommunityURL);
                    lstUserJourneysToProcess.add(uj);

                    System.debug(LoggingLevel.DEBUG, '!@# MILESTONES: ' + journey.Milestones__r.size());
                    //checks if there are Milestones from the Journey Template
                    if(!journey.Milestones__r.isEmpty()){
                        createUserMilestones(journey.Milestones__r, uj, lstUserMilestonesToInsert);
                        System.debug(LoggingLevel.DEBUG, '!@# USER MILESTONES: ' + lstUserMilestonesToInsert.size());
                    }
                }
            }else{
                System.debug(LoggingLevel.DEBUG, '!@# Missing or invalid UserJourneyCommunitySetting__c.');
            }
        }

        try {
            if(!lstUserJourneysToProcess.isEmpty()){
                Database.update(lstUserJourneysToProcess);
            }
            if(!lstUserMilestonesToInsert.isEmpty()){
                Database.insert(lstUserMilestonesToInsert);
            }
        }catch (Exception ex){
            System.debug(LoggingLevel.DEBUG, '!@# ERROR IN INSERT: ' + ex.getMessage());
        }

    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.09.2020
    * @description  Process System generated User Milestones
    * @param        lstUserMilestones - List of User Milestones to be processed
    * @param        setUserJourneyId - Set of User Journey Ids
    * @revision     10.09.2020 - APRivera - Created
    *******************************************************************************/
    public static void processNewUserMilestones(List<Participant_Milestone__c> lstUserMilestones, Set<Id> setUserJourneyId){
        Map<Id, Id> mapJourneyIdsByUserJourneyIds = getJourneyIds(setUserJourneyId);
        Set<Id> setJourneyIds = new Set<Id>();
        for(Id jId : mapJourneyIdsByUserJourneyIds.values()){
            setJourneyIds.add(jId);
        }

        if(!lstUserMilestones.isEmpty()){
            //retrieves Journey records
            Map<Id,Journey__c> mapJourneysByIds = getJourney(setJourneyIds);

            //get the milestone metrics of each journey, mapped by Milestone Type
            Map<Id, Map<String, List<String>>> mapMilestoneMetricByTypeByJourneyId = new Map<Id, Map<String, List<String>>>();
            mapMilestoneMetricByTypeByJourneyId = getMilestoneMetricsByJourneyId(mapJourneysByIds);

            //Creates User Milestone Metric to be inserted
            List<Participant_Milestone_Metric__c> lstUserMilestoneMetrics = new List<Participant_Milestone_Metric__c>();
            createUserMilestoneMetric(lstUserMilestoneMetrics, lstUserMilestones, mapJourneyIdsByUserJourneyIds, mapMilestoneMetricByTypeByJourneyId);

            try {
                if(!lstUserMilestoneMetrics.isEmpty()){
                    Database.insert(lstUserMilestoneMetrics);
                }
            }catch (Exception ex){
                System.debug(LoggingLevel.DEBUG, '!@# ERROR IN INSERT: ' + ex.getMessage());
            }
        }
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         20.09.2020
    * @description  creates User Milestone Metric
    * @param        mapJourneysByIds - User Milestone Metric to be inserted
     * @return      mapMilestoneMetricByTypeByJourneyId - map of Milestone Metrics by Type by Journey Id
    * @revision     20.09.2020 - APRivera - Created
    *******************************************************************************/
    public static Map<Id, Map<String, List<String>>> getMilestoneMetricsByJourneyId(Map<Id,Journey__c> mapJourneysByIds){
        Map<Id, Map<String, List<String>>> mapMilestoneMetricByTypeByJourneyId = new Map<Id, Map<String, List<String>>>();
        for(Journey__c journey : mapJourneysByIds.values()){
            if(!journey.Milestone_Metrics__r.isEmpty()){
                Map<String, List<String>> mapMilestoneMetricByType = new Map<String, List<String>>();
                for(Milestone_Metric__c mm : journey.Milestone_Metrics__r){
                    if(!mapMilestoneMetricByType.containsKey(mm.Type__c)){
                        List<String> lstTrackedField = new List<String>();
                        lstTrackedField.add(mm.Tracked_Field__c);
                        mapMilestoneMetricByType.put(mm.Type__c, lstTrackedField);
                    }else{
                        mapMilestoneMetricByType.get(mm.Type__c).add(mm.Tracked_Field__c);
                    }
                }

                if(!mapMilestoneMetricByTypeByJourneyId.containsKey(journey.Id)){
                    mapMilestoneMetricByTypeByJourneyId.put(journey.Id, mapMilestoneMetricByType);
                }else{
                    mapMilestoneMetricByTypeByJourneyId.get(journey.Id).putAll(mapMilestoneMetricByType);
                }
            }
        }
        return  mapMilestoneMetricByTypeByJourneyId;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         20.09.2020
    * @description  creates User Milestone Metric
    * @param        lstUserMilestoneMetrics - User Milestone Metric to be inserted
    * @param        lstUserMilestones - List of User Milestones
    * @param        mapJourneyIdsByUserJourneyIds - Map of Journey ids by User Journey ids
    * @param        mapMilestoneMetricByTypeByJourneyId - Map of Milestone Metric by Type by Journey Id
    * @revision     20.09.2020 - APRivera - Created
    *******************************************************************************/
    public static void createUserMilestoneMetric(List<Participant_Milestone_Metric__c> lstUserMilestoneMetrics, List<Participant_Milestone__c> lstUserMilestones,
            Map<Id, Id> mapJourneyIdsByUserJourneyIds, Map<Id, Map<String, List<String>>> mapMilestoneMetricByTypeByJourneyId) {
        for(Participant_Milestone__c userMilestone : lstUserMilestones){
            Id journeyId = mapJourneyIdsByUserJourneyIds.get(userMilestone.Journey__c);
            if(mapMilestoneMetricByTypeByJourneyId.containsKey(journeyId)){
                Map<String, List<String>> mapMilestoneMetricByType = mapMilestoneMetricByTypeByJourneyId.get(journeyId);
                System.debug(LoggingLevel.DEBUG, '!@# mapMilestoneMetricByType: '+ JSON.serializePretty(mapMilestoneMetricByType));
                if(mapMilestoneMetricByType.containsKey(userMilestone.Type__c)){
                    for(String strField : mapMilestoneMetricByType.get(userMilestone.Type__c)){
                        Participant_Milestone_Metric__c umm = new Participant_Milestone_Metric__c();
                        umm.Metric_Used__c = strField;
                        umm.Milestone__c = userMilestone.Id;
                        lstUserMilestoneMetrics.add(umm);
                    }
                }
            }
        }
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.09.2020
    * @description  Retrieves User Journey Template (from Journey Object)
    * @param        userJourney - User Journey being inserted
    * @param        journey - Journey template
    * @param        strJourneyCommunityURL - User Journey Community URL
    * @return       mapJourneysByIds - Map<Id,Journey__c>
    * @revision     10.09.2020 - APRivera - Created
    * 				05.02.2020 - ADFrancisco - Added contact Id
    *******************************************************************************/
    public static Journey_Participant__c updateUserJourney(Journey_Participant__c userJourney, Journey__c journey, String strJourneyCommunityURL){
        Journey_Participant__c uj = new Journey_Participant__c();
        uj.Id = userJourney.Id;
        uj.Description__c = userJourney.Description__c != null ? userJourney.Description__c : journey.Description__c;
        uj.Contact__c = userJourney.Contact__c;
        if(userJourney.Contact__c != null){
            uj.Journey_URL__c = strJourneyCommunityURL + '/s/journey?journeyId=' + userJourney.Id;
        }
//        else{
//            uj.Journey_URL__c = strJourneyCommunityURL + '/s/journey?journeyId=' + userJourney.Id;
//        }
        
        return uj;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.09.2020
    * @description  Creates Journey's User Milestones
    * @param        lstMilestones - List of Milestones from the Journey template
    * @param        userJourney - User Journey
    * @param        lstUserMilestonesToInsert - List of User Milestones to be inserted
    * @revision     10.09.2020 - APRivera - Created
    *******************************************************************************/
    public static void createUserMilestones(List<Milestone__c> lstMilestones, Journey_Participant__c userJourney,
            List<Participant_Milestone__c> lstUserMilestonesToInsert){
        for(Milestone__c milestone : lstMilestones){
            Participant_Milestone__c userMilestone = new Participant_Milestone__c();
            System.debug(LoggingLevel.DEBUG, '!@# Milestone Record Type : ' + milestone.RecordType.Name);
            if(milestone.RecordType.Name == 'Checkpoint'){ //if recordtype = Checkpoint
                userMilestone.Type__c = 'Checkpoint';
                userMilestone.Checkpoint__c = true;
            }else{
                userMilestone.Type__c = milestone.Type__c;
                userMilestone.Checkpoint_Name__c = milestone.Parent__c;
            }
            userMilestone.Journey__c = userJourney.Id;
            userMilestone.Description__c = milestone.Description__c;
            userMilestone.Sort_Order__c = milestone.Sort_Order__c;
            userMilestone.Milestone_URL__c = milestone.Milestone_URL__c;
            userMilestone.System_Generated__c =  true;
            userMilestone.Contact__c = userJourney.Contact__c;
            userMilestone.Milestone__c = milestone.Id;
            lstUserMilestonesToInsert.add(userMilestone);
        }
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         19.03.2021
    * @description  Creates Participant Milestone Metrics
    * @param        setJourneyIds - Set Journey Ids
    * @param        lstMetrics - List of Milestone Metrics inserted in the system
    * @param        setMetricType - set of milestone metric types
    * @param        evt - trigger event
    * @revision     19.03.2021 - APRivera - Created
    *******************************************************************************/
    public static void processMilestoneMetric(Set<Id> setJourneyIds, List<Milestone_Metric__c> lstMetrics, Set<String> setMetricType, String evt){
        List<Participant_Milestone__c> lstParticipantMilestones = new List<Participant_Milestone__c>();
        lstParticipantMilestones = getParticipantMilestones(setJourneyIds, setMetricType);
        List<Participant_Milestone_Metric__c> lstParticipantMilestoneMetricsToInsert = new List<Participant_Milestone_Metric__c>();
        List<Participant_Milestone_Metric__c> lstParticipantMilestoneMetricsToDelete = new List<Participant_Milestone_Metric__c>();

        for(Milestone_Metric__c milestoneMetric : lstMetrics){
            if(!lstParticipantMilestones.isEmpty()){
                for(Participant_Milestone__c pm : lstParticipantMilestones){
                    if(milestoneMetric.Type__c == pm.Type__c ){
                        if(evt == 'INSERT'){ // When Milestone metric is created, insert new Participant_Milestone_Metric__c
                            Participant_Milestone_Metric__c umm = new Participant_Milestone_Metric__c();
                            umm.Metric_Used__c = milestoneMetric.Tracked_Field__c;
                            umm.Milestone__c = pm.Id;
                            lstParticipantMilestoneMetricsToInsert.add(umm);
                        }else if(evt == 'DELETE'){ // When Milestone metric is deleted, delete Participant_Milestone_Metric__c
                            if(!pm.Participant_Milestone_Metrics__r.isEmpty()){
                                for(Participant_Milestone_Metric__c pmm : pm.Participant_Milestone_Metrics__r){
                                    if(pmm.Metric_Used__c == milestoneMetric.Tracked_Field__c){
                                        lstParticipantMilestoneMetricsToDelete.add(pmm);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        try {
            if(!lstParticipantMilestoneMetricsToInsert.isEmpty()){
                Database.insert(lstParticipantMilestoneMetricsToInsert);
            }
        }catch (Exception ex){
            System.debug(LoggingLevel.DEBUG, '!@# ERROR IN INSERT: ' + ex.getMessage());
        }

        try {
            if(!lstParticipantMilestoneMetricsToDelete.isEmpty()){
                Database.delete(lstParticipantMilestoneMetricsToDelete);
            }
        }catch (Exception ex){
            System.debug(LoggingLevel.DEBUG, '!@# ERROR IN DELETE: ' + ex.getMessage());
        }
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.09.2020TheProviderJourney
    * @description  Retrieves User Journey
    * @param        setUserJourneyId - Set of User Journey Ids
    * @return       mapUserJourneysByIds - Map<Id, User_Journey__c>
    * @revision     10.09.2020 - APRivera - Created
    *******************************************************************************/
    public static Map<Id, Journey_Participant__c> getUserJourneys(Set<Id> setUserJourneyId){
        System.debug('!@# setUserJourneyId: ' + setUserJourneyId);
        Map<Id, Journey_Participant__c> mapUserJourneysByIds = new Map<Id, Journey_Participant__c>();
        for(Journey_Participant__c usrJourney : [SELECT Id, Name, Contact__c, Contact__r.FirstName, Is_Active__c, Description__c, Journey__r.Name, Journey__c,
                                                    (SELECT Id, Name, Description__c, Sort_Order__c, Milestone_URL__c, Type__c, Completion__c,
                                                        Is_Active__c, Contact__c, Milestone__c, Milestone__r.Name, Milestone_Progress__c,
                                                        System_Generated__c, Total_Completed_Metrics__c, Total_Number_Of_Metrics__c, Checkpoint__c
                                                        FROM Participant_Milestones__r ORDER BY Sort_Order__c ASC)
                                                FROM Journey_Participant__c WHERE Id IN: setUserJourneyId]){
            System.debug('!@# usrJourney: ' + JSON.serializePretty(usrJourney));
              mapUserJourneysByIds.put(usrJourney.Id, usrJourney);                                         
            //mapUserJourneysByIds.put(usrJourney.Contact__c, usrJourney);
        }
        return mapUserJourneysByIds;
    }
    /*******************************************************************************
    * @author       Allen Francisco
    * @date         08.02.2021
    * @description  Retrieves all milestone from journey
    * @param        journeyId - Set of User Journey Ids
    * @return       Journey__c
    * @revision     08.02.2021 - ADFrancisco - Created
    *******************************************************************************/

    public static Journey__c getMilestoneFromJourney(Set<Id> journeyId){
   		Journey__c journeyData = [SELECT Id, Name, Description__c,
                                  (SELECT Id, Name, Checkpoint__c, Type__c, Milestone_URL__c, Sort_Order__c 
                                   FROM Milestones__r ORDER BY Sort_Order__c ASC) 
                                  FROM Journey__c WHERE Id =: journeyId LIMIT 1];
        /*List<Milestone__c> journeyMilestoneList = [SELECT Id, Name, Checkpoint__c, Type__c, Milestone_URL__c, Sort_Order__c
                                                    FROM Milestone__c WHERE Journey__c =: journeyId ORDER BY Sort_Order__c ASC];*/
        return journeyData;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         11.09.2020
    * @description  Retrieves User Journey
    * @param        setMilestoneIds - Set of User Milestone Ids
    * @return       mapMilestoneByIds - Map<Id, User_Milestone__c>
    * @revision     11.09.2020 - APRivera - Created
    *******************************************************************************/
    public static Map<Id,Participant_Milestone__c> getUserMilestones(Set<Id> setMilestoneIds){
        Map<Id,Participant_Milestone__c> mapMilestoneByIds = new Map<Id, Participant_Milestone__c>();
        for(Participant_Milestone__c ma : [SELECT Id, Name, Description__c, Sort_Order__c, Milestone_URL__c, Type__c, Completion__c,
                                                    Is_Active__c, Contact__c, Milestone__c, Milestone__r.Name, Milestone_Progress__c,
                                                    System_Generated__c, Total_Completed_Metrics__c, Total_Number_Of_Metrics__c, Checkpoint__c,
                                                (SELECT Id, Name, Milestone__c, Metric_Used__c, Completion_Date__c FROM Participant_Milestone_Metrics__r),
                                                (SELECT Id, Subject, Description, Sort_Order__c FROM Tasks WHERE Type = 'Related Information' ORDER BY Sort_Order__c ASC)
                                            FROM Participant_Milestone__c WHERE Id IN: setMilestoneIds
                                            ORDER BY Sort_Order__c ASC]){
            mapMilestoneByIds.put(ma.Id, ma);
        }

        return mapMilestoneByIds;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         19.03.2021
    * @description  Retrieves list of Journey Participant Milestones
    * @param        setJourneyIds - Set of User Journey Ids
    * @param        setMetricType - Set of milestone metric types
    * @return       lstParticipantMilestones -  Map<Id, Id>
    * @revision     19.03.2021 - APRivera - Created
    *******************************************************************************/
    public static List<Participant_Milestone__c> getParticipantMilestones(Set<Id> setJourneyIds, Set<String> setMetricType){
        List<Participant_Milestone__c> lstParticipantMilestones = new List<Participant_Milestone__c>();
        lstParticipantMilestones = [SELECT Id, Type__c, Milestone__c,
                                    (SELECT Id, Metric_Used__c FROM Participant_Milestone_Metrics__r)
                                    FROM Participant_Milestone__c
                                    WHERE Journey__r.Journey__c IN: setJourneyIds
                                    AND Type__c IN: setMetricType];
        return lstParticipantMilestones;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         19.03.2021
    * @description  Retrieves Journey participants and related Participant milestones
    * @param        setJourneyIds - Journey set of Ids
    * @return       lstParticipantMilestonesByIds - List<Journey_Participant__c>
    * @revision     19.03.2021 - APRivera - Created
    *******************************************************************************/
    public static List<Journey_Participant__c> getJourneyParticipantsWithMilestones(Set<Id> setJourneyIds){
        List<Journey_Participant__c> lstParticipantMilestonesByIds = new List<Journey_Participant__c>();

        lstParticipantMilestonesByIds = [SELECT Id, (SELECT Id, Milestone__c, Sort_Order__c, Is_Active__c, Type__c, Journey__c,
                                            Checkpoint__c, Checkpoint_Name__c, Milestone__r.Journey__c FROM Participant_Milestones__r)
                                            FROM Journey_Participant__c
                                                WHERE  Journey__c IN: setJourneyIds];
        return lstParticipantMilestonesByIds;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.09.2020
    * @description  Retrieved the ma of Journey Ids by User Journey Ids
    * @param        setUserJourneyId - Set of User Journey Ids
    * @return       mapJourneyIdsByUserJourneyIds -  Map<Id, Id>
    * @revision     10.09.2020 - APRivera - Created
    *******************************************************************************/
    public static Map<Id, Id> getJourneyIds(Set<Id> setUserJourneyId){
        Map<Id, Id> mapJourneyIdsByUserJourneyIds = new Map<Id, Id>();
        for(Journey_Participant__c usrJourney : [SELECT Id, Name, Journey__c FROM Journey_Participant__c WHERE Id IN: setUserJourneyId]){
            mapJourneyIdsByUserJourneyIds.put(usrJourney.Id, usrJourney.Journey__c);
        }
        return mapJourneyIdsByUserJourneyIds;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         10.09.2020
    * @description  Retrieves Journey
    * @param        setJourneyIds - Journey set of Ids
    * @return       mapJourneysByIds - Map<Id,Journey__c>
    * @revision     10.09.2020 - APRivera - Created
    *******************************************************************************/
    public static Map<Id,Journey__c> getJourney(Set<Id> setJourneyIds){
        Map<Id,Journey__c> mapJourneysByIds = new Map<Id, Journey__c>();

        for(Journey__c journey : [SELECT Id, Name, Description__c, Status__c, Event__c,
                                    (SELECT Id, RecordTypeId, RecordType.Name, Name, Sort_Order__c, Description__c,
                                            Milestone_URL__c, Is_Active__c, Type__c, Checkpoint__c, Parent__c
                                            FROM Milestones__r WHERE Is_Active__c = TRUE),
                                    (SELECT Id, Name, Type__c, Tracked_Field__c FROM Milestone_Metrics__r)
                                    FROM Journey__c WHERE Id IN: setJourneyIds]){
            mapJourneysByIds.put(journey.Id, journey);
        }
        return mapJourneysByIds;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         15.10.2020
    * @description  Retrieves Journey and Journey participants
    * @param        setJourneyIds - Journey set of Ids
    * @return       mapJourneysByIds - Map<Id,Journey__c>
    * @revision     15.10.2020 - APRivera - Created
    *******************************************************************************/
    public static Map<Id, Journey__c> getJourneyParticipantsByJourneyIds(Set<Id> setJourneyIds){
        Map<Id, Journey__c> mapJourneysByIds = new Map<Id, Journey__c>();

        for(Journey__c j : [SELECT Id,
                            (SELECT Id, Contact__c FROM Journey_Participants__r)
                            FROM Journey__c WHERE Id IN : setJourneyIds]){
            mapJourneysByIds.put(j.Id, j);
        }
        return mapJourneysByIds;
    }




    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         11.02.2021
    * @description  Retrieves Session Participants
    * @param        journey - journey record
    * @param        setEventIds - Set Event Ids
    * @return       lstSessionParticipants - List<Session_Participant__c>
    * @revision     03.10.2020 - APRivera - Created
    *******************************************************************************/
    public static List<Session_Participant__c> getSessionParticipants(Journey__c journey, Set<Id> setEventIds){
        List<Session_Participant__c> lstSessionParticipants = new List<Session_Participant__c>();
        lstSessionParticipants =  [SELECT Id, Event__c, Event__r.Campaign__c, Contact__c
                                    FROM Session_Participant__c
                                    WHERE Event__r.Campaign__c =: journey.Campaign__c
                                    AND Event__r.Journey__c =: journey.Id
                                    AND Event__c IN: setEventIds AND Contact__c != NULL];
        return lstSessionParticipants;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         11.02.2021
    * @description  Retrieves Events Participants
    * @param        journey - journey record
    * @param        setEventIds - Set Event Ids
    * @return       lstParticipants - List<Participant__c>
    * @revision     03.10.2020 - APRivera - Created
    *******************************************************************************/
    public static List<Participant__c> getParticipants(Journey__c journey, Set<Id> setEventIds){
        List<Participant__c> lstParticipants = new List<Participant__c>();
        lstParticipants =  [SELECT Id, Event__c, Member_Contact__c, Event__r.Campaign__c
                            FROM Participant__c
                            WHERE Event__r.Campaign__c =: journey.Campaign__c
                            AND Event__r.Journey__c =: journey.Id
                            AND Event__c IN: setEventIds
                            AND Member_Contact__c !=: null];
        return lstParticipants;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         11.02.2021
    * @description  Retrieves Communication_Recipient__c
    * @param        journey - journey record
    * @return       lstCommunicationRecipients - List<Communication_Recipient__c>
    * @revision     03.10.2020 - APRivera - Created
    *******************************************************************************/
    public static List<Communication_Recipient__c> getCommunicationRecipients(Journey__c journey){
        List<Communication_Recipient__c> lstCommunicationRecipients = new List<Communication_Recipient__c>();
        lstCommunicationRecipients =  [SELECT Id, Contact__c, CC_Communication__r.Campaign__c, CC_Communication__r.Journey__c
                                        FROM Communication_Recipient__c
                                        WHERE CC_Communication__r.Campaign__c =: journey.Campaign__c
                                        AND CC_Communication__r.Journey__c =: journey.Id];
        return lstCommunicationRecipients;
    }

    /*******************************************************************************
    * @author       Angelo Rivera
    * @date         11.02.2021
    * @description  Retrieves Survey_Response__c
    * @param        journey - journey record
    * @return       lstSurveyResponses - List<Survey_Response__c>
    * @revision     03.10.2020 - APRivera - Created
    *******************************************************************************/
    public static List<Survey_Response__c> getSurveyResponses(Journey__c journey){
        List<Survey_Response__c> lstSurveyResponses = new List<Survey_Response__c>();
        lstSurveyResponses = [SELECT Id, Survey__r.Journey__c, Survey__r.Campaign__c, Survey__r.Active__c, Contact__c
                                FROM Survey_Response__c
                                WHERE Survey__r.Journey__c =: journey.Id
                                AND Survey__r.Campaign__c =: journey.Campaign__c
                                AND Survey__r.Active__c = TRUE];
        return lstSurveyResponses;
    }
}