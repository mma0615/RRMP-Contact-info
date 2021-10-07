public with sharing class journeyParticipantMilestoneServices {
    /*******************************************************************************
    * @author       Minh Ma
    * @date         03/28/2021
    * @description  method used in updateParticipantMilestone Aura component
    * @param        journeyId - journey Id
    * @return       strResult
    * @revision     03/28/2021 - Minh Ma - Created
    *******************************************************************************/
    
    private static List<Id> journeyIds {get; set;}
    private static Map<string, string> objFieldMap { get;set; }
    private static List<Participant_Milestone__c> participantMilestoneList { get;set; }
    private static Map<Id, Participant_Milestone__c> participantMilestoneMap {get;set;}
    private static Set<Id> participantMilestoneSet {get;set;}
    private static Map<string, Participant__c> participantMap {get;set;}
    private static Map<string, Session_Participant__c> session_ParticipantMap {get;set;}
    private static Map<string, Communication_Recipient__c> communication_RecipientMap {get;set;}
    private static Map<string, Survey_Response__c> survey_ResponseMap {get;set;}
    private static List<Participant_Milestone_Metric__c> participant_Milestone_MetricToUpdate {get;set;}

    private static void init()
    {
        getObjFieldDescribed();
        getParticipantMilestone();
        getparticipantMap();
        getsession_ParticipantMap();
        getcommunication_RecipientMap();
        getsurvey_ResponseMap();

    }

    private static void getObjFieldDescribed()
    {
        // Loading object fields Described
        objFieldMap = new Map<string, string>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        objFieldDescribed('Participant__c', schemaMap);
        objFieldDescribed('Session_Participant__c', schemaMap);
        objFieldDescribed('Communication_Recipient__c', schemaMap);
        objFieldDescribed('Survey_Response__c', schemaMap);
        System.debug('updateParticipantMilestone ==> objFieldMap: ' + objFieldMap.size());
    }

    // Loading Participant Milestone
    private static void getParticipantMilestone()
    {

        participantMilestoneList = 
            new List<Participant_Milestone__c>
            (
            [select id, name, Journey__r.Journey__c, MileStone__c, MileStone__r.name,
                MileStone__r.Parent__c, contact__c, Type__c, Checkpoint__c, Sort_Order__c,
                (select id, name, Completion_Date__c, Metric_Used__c, 
                    Milestone__c, System_Generated__c from Participant_Milestone_Metrics__r)
                from Participant_Milestone__c 
                where Journey__r.Journey__c in :journeyIds
                /***** this below line is temporarily testing for 1 contact */
                    and contact__c = '003030000058RiHAAU'
                /***** this below line is temporarily testing for 1 contact */
                order by Journey__c, contact__c, Sort_Order__c]
            );
            System.debug('getParticipantMilestone ==> participantMilestoneList: ' + participantMilestoneList.size());
    
        participantMilestoneMap = new Map<Id, Participant_Milestone__c>(participantMilestoneList);
        System.debug('getParticipantMilestone ==> participantMilestoneMap: ' + participantMilestoneMap.size());

        participantMilestoneSet = New Set<Id>(participantMilestoneMap.keyset());
        System.debug('getParticipantMilestone ==> participantMilestoneSet: ' + participantMilestoneSet.size());
    }

    /*********** Populating Journeys related Participants ***********/
    private static void getparticipantMap()
    {
        participantMap = new Map<string, Participant__c>();

        // In case of multiple partipants - Which record is qualified for mapping? //
        for (Participant__c oParticipant :
                [select id, name, Event__c, Member_Contact__c, Invitation_Date__c, Registration_Date__c,
                    Attendance_Date__c, Event__r.Journey__c, Event__r.name
                    from Participant__c 
                    where Event__r.Journey__c in :journeyIds and 
                        Member_Contact__c <> null and
                        Event__r.milestone__c = true
                    order by lastmodifiedDate desc])
        {
            if (participantMap.get(string.valueOf(oParticipant.Event__r.Journey__c) +
                    oParticipant.Event__r.name +
                    string.valueOf(oParticipant.Member_Contact__c)) == null)
                participantMap.Put(string.valueOf(oParticipant.Event__r.Journey__c) +
                    oParticipant.Event__r.name +
                    string.valueOf(oParticipant.Member_Contact__c), 
                    oParticipant);
        }
        System.debug('getparticipantMap ==> participantMap: ' + participantMap.size());
    }

    /*********** Populating Journeys related Sessions ***********/
    public static void getsession_ParticipantMap()
    {
        session_ParticipantMap = new Map<string, Session_Participant__c>();

        for (Session_Participant__c oSession_Participant :
            [select id, name, Session__c, Event__c, Contact__c, Invitation_Date__c, Registration_Date__c,
                Attendance_Date__c, Session__r.Event__r.Journey__c, Session__r.Name
                from Session_Participant__c 
                where Session__r.Event__r.Journey__c in :journeyIds and 
                    Contact__c <> null and 
                    Session__r.Milestone__c=true])
        {
            if (session_ParticipantMap.get(string.valueOf(oSession_Participant.Session__r.Event__r.Journey__c) +
                oSession_Participant.Session__r.Name + 
                string.valueOf(oSession_Participant.Contact__c)) == null)
            session_ParticipantMap.Put(string.valueOf(oSession_Participant.Session__r.Event__r.Journey__c) +
                oSession_Participant.Session__r.Name + 
                    string.valueOf(oSession_Participant.Contact__c), 
                    oSession_Participant);
        }
        System.debug('getsession_ParticipantMap ==> session_ParticipantMap: ' + session_ParticipantMap.size());
    }

    /*********** Populating Journeys related Communications ***********/
    private static void getcommunication_RecipientMap()
    {
        communication_RecipientMap = new Map<string, Communication_Recipient__c>();

        for (Communication_Recipient__c oCommunication_Recipient :
            [select id, name, CC_Communication__c, Contact__c, Date_Read__c, Date_Sent__c,
                    CC_Communication__r.Journey__c, CC_Communication__r.name
                from Communication_Recipient__c 
                where CC_Communication__r.Journey__c in :journeyIds and 
                    contact__c <> null and 
                    CC_Communication__r.milestone__c = true])
        {
            if (communication_RecipientMap.get(string.valueOf(oCommunication_Recipient.CC_Communication__r.Journey__c) +
                oCommunication_Recipient.CC_Communication__r.name + 
                    string.valueOf(oCommunication_Recipient.contact__c)) == null)
                communication_RecipientMap.Put(string.valueOf(oCommunication_Recipient.CC_Communication__r.Journey__c) +
                    oCommunication_Recipient.CC_Communication__r.name + 
                    string.valueOf(oCommunication_Recipient.contact__c), 
                    oCommunication_Recipient);
        }
        System.debug('getcommunication_RecipientMap ==> communication_RecipientMap: ' + communication_RecipientMap.size());
    }

    /*********** Populating Journeys related Surveys ***********/
    public static void getsurvey_ResponseMap()
    {
        survey_ResponseMap = new Map<string, Survey_Response__c>();
        for (Survey_Response__c oSurvey_Response :
            [select id, name, Survey__c, Contact__c, Survey__r.createddate,
                Survey__r.Journey__c, Survey__r.Name, createddate
                from Survey_Response__c 
                where Survey__r.Journey__c in :journeyIds and 
                    contact__c <> null and
                    Survey__r.Milestone__c=true])
        {
            if (survey_ResponseMap.get(string.valueOf(oSurvey_Response.Survey__r.Journey__c) +
                oSurvey_Response.Survey__r.Name + 
                string.valueOf(oSurvey_Response.contact__c)) == null)
                survey_ResponseMap.Put(string.valueOf(oSurvey_Response.Survey__r.Journey__c) +
                    oSurvey_Response.Survey__r.Name + 
                    string.valueOf(oSurvey_Response.contact__c), 
                    oSurvey_Response);
        }
        System.debug('getsurvey_ResponseMap ==> survey_ResponseMap: ' + survey_ResponseMap.size());
    }
    
    /*********** Auto Populating Jouney Participant Milestone Mectrics ***********/
    @AuraEnabled
    public static String updateParticipantMilestoneMetrics(List<Id> jIds) 
    {
        System.debug('updateParticipantMilestone ==> jIds: ' + jIds);

        integer eventCount = 0;
        integer sessionCount = 0;
        integer communicationCount = 0;
        integer surveyCount = 0;
        integer totalCount = 0;

        id pmId;
        integer mectricCount = 0;
        integer completedCount = 0;
        integer milestoneCount = 0;
        Double milestonecompleted = 0;
        
        List<Participant_Milestone__c> Participant_MilestoneToUpdate = 
            new List<Participant_Milestone__c>();
        Participant_Milestone__c oPM;

        String strResult ='';
        if(jIds.size() > 0)
        {
            journeyIds = jIds;
            init();

            /***********    DO THE MATCHING   ***********/
            participant_Milestone_MetricToUpdate = new List<Participant_Milestone_Metric__c>();
            for (Participant_Milestone__c oParticipant_Milestone : participantMilestoneList)
            {
                string milestoneKey = string.valueOf(oParticipant_Milestone.Journey__r.Journey__c) +
                    oParticipant_Milestone.MileStone__r.name +
                    string.valueOf(oParticipant_Milestone.contact__c);
                System.debug('updateParticipantMilestone ==> milestoneKey: ' + milestoneKey +
                    ' / Type__c: ' +  oParticipant_Milestone.Type__c);
                
                // verify if Check point, then calculate Checkpoint progress
                if (oParticipant_Milestone.Checkpoint__c)
                {        
                    if (milestoneCount != 0)
                    {
                        oPM = new Participant_Milestone__c();
                        oPM.Id = pmId;
                        oPM.Checkpoint_Progress__c = milestonecompleted / milestoneCount;
                        Participant_MilestoneToUpdate.add(oPM);
                        System.debug('updateParticipantMilestone ==> oPM.Id: ' + 
                            oPM.Id +
                            ' / milestonecompleted: ' +  milestonecompleted +
                            ' / milestoneCount: ' + milestoneCount +
                            ' / oPM.Checkpoint_Progress__c: ' + oPM.Checkpoint_Progress__c);
                    }
                    pmId = oParticipant_Milestone.Id;
                    
                    milestoneCount = 0;
                    milestonecompleted = 0;

                }
                // if Milestone
                else 
                {
                    mectricCount = 0;
                    completedCount = 0;
                    
                    for (Participant_Milestone_Metric__c oParticipant_Milestone_Metric :
                            oParticipant_Milestone.Participant_Milestone_Metrics__r)
                    {
                        string fldName = null;
                        Datetime fldValue = null;

                        if (oParticipant_Milestone.Type__c == 'Event')
                        {
                            if (participantMap.get(milestoneKey) != null )
                            {
                                Participant__c oParticipant = participantMap.get(milestoneKey);
                                fldname = objFieldMap.get('Participant__c' + oParticipant_Milestone_Metric.Metric_Used__c);
                                if (fldName != null)
                                {
                                    fldValue = (Datetime) oParticipant.get(fldName);
                                    eventCount += 1;
                                    System.debug('****** oParticipant: ' + oParticipant);
                                }
                                    
                                System.debug('***updateParticipantMilestone ==> Event - fldname/value: ' + fldname + '/' + fldValue);
                            }
                            else if (session_ParticipantMap.get(milestoneKey) != null)
                            {
                                Session_Participant__c oSession_Participant = session_ParticipantMap.get(milestoneKey);
                                fldname = objFieldMap.get('Session_Participant__c' + oParticipant_Milestone_Metric.Metric_Used__c);
                                if (fldName != null)
                                {
                                    fldValue = (Datetime) oSession_Participant.get(fldName);
                                    sessionCount += 1;
                                    System.debug('****** oSession_Participant: ' + oSession_Participant);
                                }   
                                System.debug('***updateParticipantMilestone ==> Session - fldname/value: ' + fldname + '/' + fldValue);
                            }

                        }
                        else if (oParticipant_Milestone.Type__c == 'Survey')
                        {
                            if (survey_ResponseMap.get(milestoneKey) != null )
                            {
                                Survey_Response__c oSurvey_Response = survey_ResponseMap.get(milestoneKey);
                                /*
                                fldname = objFieldMap.get('Survey_Response__c' + oParticipant_Milestone_Metric.Metric_Used__c);
                                if (fldName != null)
                                {
                                    fldValue = (Datetime) oSurvey_Response.get(fldName);
                                    surveyCount += 1;
                                    System.debug('****** oSurvey_Response: ' + oSurvey_Response);
                                }
                                */
                                fldname = oParticipant_Milestone_Metric.Metric_Used__c;
                                if (oParticipant_Milestone_Metric.Metric_Used__c == 'Date Sent')
                                {
                                    fldValue = oSurvey_Response.Survey__r.createddate;
                                    surveyCount += 1;
                                    System.debug('****** oSurvey_Response: ' + oSurvey_Response);
                                }
                                else if (oParticipant_Milestone_Metric.Metric_Used__c == 'Date Responded')
                                {
                                    fldValue = oSurvey_Response.createddate;
                                    surveyCount += 1;
                                    System.debug('****** oSurvey_Response: ' + oSurvey_Response);
                                }
                                    
                                System.debug('***updateParticipantMilestone ==> Survey - fldname/value: ' + fldname + '/' + fldValue);
                            }
                        }
                        else if (oParticipant_Milestone.Type__c == 'Communication')
                        {
                            if (communication_RecipientMap.get(milestoneKey) != null )
                            {
                                Communication_Recipient__c oCommunication_Recipient = communication_RecipientMap.get(milestoneKey);
                                fldname = objFieldMap.get('Communication_Recipient__c' + oParticipant_Milestone_Metric.Metric_Used__c);
                                if (fldName != null)
                                {
                                    fldValue = (Datetime) oCommunication_Recipient.get(fldName);
                                    communicationCount += 1;
                                    System.debug('****** oCommunication_Recipient: ' + oCommunication_Recipient);
                                }
                                    
                                System.debug('***updateParticipantMilestone ==> Communication - fldname/value: ' + fldname + '/' + fldValue);
                            }
                        }

                        oParticipant_Milestone_Metric.Completion_Date__c = null;
                        if (String.isNotEmpty(fldName))
                            oParticipant_Milestone_Metric.Completion_Date__c = fldValue;
                        participant_Milestone_MetricToUpdate.Add(oParticipant_Milestone_Metric);
                        //System.debug('****** oParticipant_Milestone_Metric: ' + oParticipant_Milestone_Metric);

                        mectricCount += 1;
                        if (fldValue != null)
                            completedCount += 1;
                    }
                    
                    // Calculating Milestone progress
                    if (mectricCount != 0)
                    {
                        milestoneCount += 1;
                        System.debug('****** milestonecompleted: ' + completedCount + ' / ' + mectricCount);
                        milestonecompleted = milestonecompleted + (completedCount * 100 / mectricCount);

                    }
                        
                }
            }

            if (milestoneCount != 0)
            {
                oPM = new Participant_Milestone__c();
                oPM.Id = pmId;
                oPM.Checkpoint_Progress__c = milestonecompleted / milestoneCount;
                Participant_MilestoneToUpdate.add(oPM);
                System.debug('updateParticipantMilestone ==> oPM.Id: ' + 
                    oPM.Id +
                    ' / milestonecompleted: ' +  milestonecompleted +
                    ' / milestoneCount: ' + milestoneCount +
                    ' / oPM.Checkpoint_Progress__c: ' + oPM.Checkpoint_Progress__c);
            }

            System.debug('***updateParticipantMilestone ==> eventCount: ' + eventCount);
            System.debug('***updateParticipantMilestone ==> sessionCount: ' + sessionCount);
            System.debug('***updateParticipantMilestone ==> surveyCount: ' + surveyCount);
            System.debug('***updateParticipantMilestone ==> communicationCount: ' + communicationCount);
            System.debug('***updateParticipantMilestone ==> totalCount: ' + totalCount);
            System.debug('***updateParticipantMilestone ==> participant_Milestone_MetricToUpdate: ' + 
                participant_Milestone_MetricToUpdate.size());
            System.debug('***updateParticipantMilestone ==> Participant_MilestoneToUpdate: ' + 
                Participant_MilestoneToUpdate.size());

            try 
            {
                if (participant_Milestone_MetricToUpdate.size() > 0)
                    update participant_Milestone_MetricToUpdate;
    
                if (Participant_MilestoneToUpdate.size() <> 0)
                    update Participant_MilestoneToUpdate;
            }
            catch (Exception ex)
            {
                System.debug('updateParticipantMilestone ==> Update: ' + ex.getMessage());
                strResult = ex.getMessage();
            }
        }

        return strResult;
    }

    private static void objFieldDescribed (string objName, Map <String, Schema.SObjectType> schemaMap)
    {
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            objFieldMap.put(objName + dfield.getLabel (), dfield.getname());
        }
    }
}