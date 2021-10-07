public with sharing class ChangeCloudController {
private static WithoutSharingClass withoutShare = new WithoutSharingClass(); 
private static final String ATTENDED = 'Attended';

@AuraEnabled
public static CCEEventWrapper getEventDetails(String eventId) { 
    //eventId = '7RvETWUOkMc';
    Event__c campaignRecord;
    CCEEventWrapper eventRecord = new CCEEventWrapper();
    
    try {
        if(FlsUtils.isAccessible('Event__c', new List<String>{'Name','Subtitle__c','Event_Id__c','Hero_Image_URL__c','Campaign_Logo_URL__c',
            'Description__c','Contact_Us_Tag_Line__c','Contact_Us_Message__c', 'OwnerId', 'Start_Date_Time__c','Contact_Us_User__c',
            'Time_Zone__c','Status__c','End_Date_Time__c'}) 
            && FlsUtils.isAccessible('Account', new List<String>{'BillingStreet','BillingCity',
                'BillingPostalCode','BillingState','BillingCountry','Name'})){
                    
                    campaignRecord = withoutShare.getEvent(eventId);
                }
        
        eventRecord = setEventWrapperValues(campaignRecord, null);
        
    } catch(QueryException ex) {
        throw new AuraHandledException('Invalid event Id');
    }
    
    return eventRecord;
}

@AuraEnabled
public static CCEEventWrapper getEventDetailsHeader(String eventId, String pm) { 
    
    CCEEventWrapper eventRecord = new CCEEventWrapper();
    
    try {
        //eventId = '7RvETWUOkMc';
        Event__c campaignRecord = new Event__c();
        if(FlsUtils.isAccessible('Event__c', new List<String>{'Name','Subtitle__c','Event_Id__c','Hero_Image_URL__c','Campaign_Logo_URL__c',
            'Description__c','Contact_Us_Tag_Line__c','Contact_Us_Message__c', 'OwnerId', 'Start_Date_Time__c','Contact_Us_User__c',
            'Time_Zone__c','Status__c','End_Date_Time__c'}) 
            && FlsUtils.isAccessible('Account', new List<String>{'BillingStreet','BillingCity',
                'BillingPostalCode','BillingState','BillingCountry','Name'})){
                    
                    campaignRecord = withoutShare.getEvent(eventId);
                }
        
        List<Participant__c> contactRec;
        
        if(FlsUtils.isAccessible('Contact', new List<String>{'FirstName'})){
            contactRec = withoutShare.getParticipant(pm);
        }
        
        eventRecord = setEventWrapperValues(campaignRecord, (!contactRec.isEmpty()) ? contactRec[0] : null);
        
    } catch (QueryException ex) {
        throw new AuraHandledException('Invalid event Id');
    }
    
    return eventRecord;
}

@AuraEnabled
public static CCEEventWrapper getEventSession(String eventId, String participantNumber, Boolean pstrue) {
    //eventId = 'pwB1UJeYAyh';
    
    List<Session_Participant__c> sessions = new List<Session_Participant__c>();
    Map<Id,Session_Participant__c> sessionMap = new Map<Id,Session_Participant__c>();
    
    if(FlsUtils.isAccessible('Session_Participant__c', new List<String>{'Session__c','Status__c'}) 
        && FlsUtils.isAccessible('Participant__c', new List<String>{'Name'}) 
        && String.isNotBlank(participantNumber)){

            sessions = withoutShare.getSessionParticipant(participantNumber);
        }
    
    for(Session_Participant__c sp : sessions){
        sessionMap.put(sp.Session__c,sp);
    }
    
    Event__c campaignRecord = new Event__c();
    
    try {
        if(FlsUtils.isAccessible('Event__c', new List<String>{'OwnerId','Contact_Us_User__c'})){
            campaignRecord = withoutShare.getEvent(eventId);
        }
    } catch (QueryException ex) {
        throw new AuraHandledException('Invalid event Id');
    }
    
    Id userIdToBaseTimezone = campaignRecord.Contact_Us_User__c != null 
        ? campaignRecord.Contact_Us_User__c
        : campaignRecord.OwnerId;
    String timezone = withoutShare.getUserTimezone(userIdToBaseTimezone);
    //String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization LIMIT 1].TimeZoneSidKey;
    String strTZone = timezone;
    
    List<Session__c> campaignList = new List<Session__c>();
    if(FlsUtils.isAccessible('Session__c', new List<String>{'Name','Subtitle__c','Start_Date_Time__c','End_Date_Time__c','Description__c','Time_Zone__c'})){
        campaignList = withoutShare.getSessions(eventId); 
    }

    CCEEventWrapper returnResult = new CCEEventWrapper();
    returnResult.SessionsWithGeneralMaterial = campaignRecord.Sessions_with_General_Materials__c;
    returnResult.SessionList = new List<CCEEventWrapper.SessionDetail>();

    Map<String,CCEEventWrapper.SessionDetail> sessionDateHeaderMap = new Map<String,CCEEventWrapper.SessionDetail>();
    Map<String,List<CCEEventWrapper.SessionDetailrec>> sessionDateMap = new Map<String,List<CCEEventWrapper.SessionDetailrec>>();

    Set<Id> sessionIds = (new Map<Id,SObject>(campaignList)).keySet();
    
    Map<Id,List<CCEEventWrapper.MaterialWrapper>> materialMap = MaterialsControllerHelper.getSessionMaterialsHelper(sessionIds);
    returnResult.eventmaterialstr = MaterialsControllerHelper.getMaterialsHelper(eventId);


        for(Session__c CampaignRec : campaignList){
            String startDate =  CampaignRec.Start_Date_Time__c.format('MMM d', strTZone);

            if(sessionMap.containsKey(CampaignRec.Id) || !pstrue){

                CCEEventWrapper.SessionDetailrec sessionRec = new CCEEventWrapper.SessionDetailrec();
                String sessTimezone = withoutShare.getUserTimezone(CampaignRec.lastModifiedById);
                sessionRec.title  = CampaignRec.Name;
                sessionRec.sessionId = CampaignRec.Id;
                sessionRec.subtitle  = CampaignRec.Description__c;
                sessionRec.StartTime  = CampaignRec.Start_Date_Time__c.format('h:mm a', sessTimezone);
                sessionRec.EndTime  = CampaignRec.End_Date_Time__c.format('h:mm a', sessTimezone);
                sessionRec.unformattedStartDate = CampaignRec.Start_Date_Time__c;
                sessionRec.unformattedEndDate = CampaignRec.End_Date_Time__c;
                sessionRec.TimeZone  = CampaignRec.Time_Zone__c;
                sessionRec.materialList = materialMap.get(CampaignRec.Id);

                if (sessionMap.containsKey(CampaignRec.Id)){
                    sessionRec.participantSessionId = sessionMap.get(CampaignRec.Id).Id;
                    sessionRec.isAttended = sessionMap.get(CampaignRec.Id).Status__c == ATTENDED;
                }

                if(sessionDateMap.get(startDate) == null){
                    List<CCEEventWrapper.SessionDetailrec> SessionDetailList = new List<CCEEventWrapper.SessionDetailrec>();

                    SessionDetailList.add(sessionRec);
                    sessionDateMap.put(startDate, SessionDetailList);
                    
                } else {
                    List<CCEEventWrapper.SessionDetailrec> SessionDetailList = sessionDateMap.get(startDate);

                    SessionDetailList.add(sessionRec);
                    sessionDateMap.put(startDate, SessionDetailList);
                }

                CCEEventWrapper.SessionDetail SessionHeaderRec = new CCEEventWrapper.SessionDetail();
                SessionHeaderRec.isHeader = true;
                //SessionHeaderRec.SessionDate = String.valueOf(CampaignRec.Start_Date_Time__c.day());
                //SessionHeaderRec.SessionMonth = (String.valueOf(CampaignRec.Start_Date_Time__c.format('MMM'))).toUpperCase();
                //SessionHeaderRec.SessionMonthName = String.valueOf(CampaignRec.Start_Date_Time__c.format('MMMM'));
                //SessionHeaderRec.SessionYear = String.valueOf(CampaignRec.Start_Date_Time__c.year());
                SessionHeaderRec.SessionDate = String.valueOf(CampaignRec.Start_Date_Time__c.format('dd',sessTimezone));
                SessionHeaderRec.SessionMonth = (String.valueOf(CampaignRec.Start_Date_Time__c.format('MMM',sessTimezone))).toUpperCase();
                SessionHeaderRec.SessionMonthName = String.valueOf(CampaignRec.Start_Date_Time__c.format('MMMM',sessTimezone));
                SessionHeaderRec.SessionYear = String.valueOf(CampaignRec.Start_Date_Time__c.format('yyyy',sessTimezone));
                SessionHeaderRec.sessionPageTitle = CampaignRec.Event__r.Sessions_Page_Title__c;
                sessionDateHeaderMap.put(startDate,SessionHeaderRec);
            }
            
        }
    
  
    
    for(String startDate : sessionDateHeaderMap.keySet()){ 

        CCEEventWrapper.SessionDetail sessionresult = new CCEEventWrapper.SessionDetail();
        sessionresult = sessionDateHeaderMap.get(startDate);
        sessionresult.SessionDetailList = sessionDateMap.get(startDate);
        returnResult.SessionList.add(sessionresult);
   
    }
    
    return returnResult;
}

@AuraEnabled
public static String getEventMaterials(String eventId) {
    return MaterialsControllerHelper.getMaterialsHelper(eventId);
}


@AuraEnabled
public static List<CCESpeakerWrapper> getSpeakerDetails(String eventId) {
    
    //eventId = '7RvETWUOkMc';
    List<CCESpeakerWrapper> speakerList = new List<CCESpeakerWrapper>();
    Event__c campaignRecord = new Event__c();
    
    try {
        if(FlsUtils.isAccessible('Event__c', new List<String>{'Name'})){
            campaignRecord = withoutShare.getEventName(eventId);
        }
    }catch (QueryException ex) {
        throw new AuraHandledException('Invalid event Id');
    }
    
    List<Event_Role__c> eventRoleList = new List<Event_Role__c>();
    if(FlsUtils.isAccessible('Contact', new List<String>{'FirstName','LastName','Title','Profile_Description__c','Profile_Picture_URL__c'})){
        eventRoleList = withoutShare.getEventRole(campaignRecord.Id); 
    }
    
    for(Event_Role__c er : eventRoleList){
        CCESpeakerWrapper speaker = new CCESpeakerWrapper();
        speaker.FirstName = er.Contact__r.FirstName;
        speaker.lastName = er.Contact__r.lastName;
        speaker.Title = er.Contact__r.Title;
        speaker.Description = er.Contact__r.Profile_Description__c;
        speaker.ProfilePicUrl = er.Contact__r.Profile_Picture_URL__c;
        speaker.isHideProfilePic = String.isEmpty(speaker.ProfilePicUrl) ? true : false;
        speakerList.add(speaker);
    }
    
    return speakerList;
}

@AuraEnabled
// Create task for each request sent from the custom contact support form
public static void createTask(String eventId, String firstname, String lastname, String email, String phone, String subject, String comments){
    
    if (String.isBlank(eventId) || String.isBlank(firstname) || String.isBlank(lastname) || String.isBlank(email) 
        || String.isBlank(subject) || String.isBlank(comments)) {
            
            return;   
        }
    
    CustomContactSupportFormHelper.createTaskHelper(eventId, firstname, lastname, email, phone, subject, comments);
}

@AuraEnabled
public static List<compass_session_wrapper> getParticipantSession(String participantNumber) {
    List<Session_Participant__c> sessions = new List<Session_Participant__c>();
    
    //participantNumber = 'EM-000070';
    if(FlsUtils.isAccessible('Session_Participant__c', new List<String>{'Status__c','Session__c'})
        && FlsUtils.isAccessible('Session__c', new List<String>{'Start_Date_Time__c','End_Date_Time__c'})){
            
            sessions = withoutShare.getSessionParticipant(participantNumber);
        }
    
    List<compass_session_wrapper> participantsessions = new List<compass_session_wrapper>();
    
    for(Session_Participant__c session : sessions){
        compass_session_wrapper participantsession = new compass_session_wrapper();
        
        participantsession.selected =  false;
        participantsession.status =  session.Status__c;
        participantsession.participantSessionId =  session.Id;
        participantsession.title =  session.Session__r.Name;
        
        participantsessions.add(participantsession);
    }
    
    return participantsessions;
}

@AuraEnabled
public static Boolean updateAttendance(String ParticipantSessionId) {
    
    Session_Participant__c sp = new Session_Participant__c();
    sp.Id = ParticipantSessionId;
    sp.Attendance_Date__c = DateTime.now();
    sp.Status__c = ATTENDED;
    
    try{
        //used iscreateable instead since we can't grant edit access for Session Participant in object-level
        if(FlsUtils.isCreateable(sp, new List<String>{'Status__c'})){
            withoutShare.updateSessionParticipant(sp);
        } else {
            return false;  
        }
        
        return true;   
    }
    
    catch(DmlException e){
        return false;   
    }
}

/** Utility Classes */
private static CCEEventWrapper setEventWrapperValues(Event__c campaignRecord, Participant__c participantRec){
    CCEEventWrapper eventRecord = new CCEEventWrapper();
    
    Id userIdToBaseTimezone = campaignRecord.Contact_Us_User__c != null 
        ? campaignRecord.Contact_Us_User__c
        : campaignRecord.OwnerId;
    String timezone = withoutShare.getUserTimezone(userIdToBaseTimezone);
    String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization LIMIT 1].TimeZoneSidKey;
    //String strTZone = timezone;
    
    if(participantRec != null){
        eventRecord.firstName = participantRec.Member_Contact__r.FirstName;
    }
    
    eventRecord.EventExternalId = campaignRecord.Event_Id__c;
    eventRecord.title = campaignRecord.Name;
    eventRecord.subtitle = campaignRecord.Subtitle__c;
    eventRecord.HeroUrl = campaignRecord.Hero_Image_URL__c;
    eventRecord.CampaignLogoUrl= campaignRecord.Campaign_Logo_URL__c;
    eventRecord.Street = campaignRecord.Location__r.BillingStreet;
    eventRecord.City = campaignRecord.Location__r.BillingCity;
    eventRecord.PostalCode = campaignRecord.Location__r.BillingPostalCode;
    eventRecord.State = campaignRecord.Location__r.BillingState;
    eventRecord.Country = campaignRecord.Location__r.BillingCountry;
    eventRecord.LocationName = campaignRecord.Location__r.Name;
    eventRecord.Description = campaignRecord.Description__c; 
    eventRecord.contactTag = campaignRecord.Contact_Us_Tag_Line__c; 
    eventRecord.contactMessage = campaignRecord.Contact_Us_Message__c; 
    eventRecord.StartDateTime = campaignRecord.Start_Date_Time__c.format('MMMM d, yyyy h:mm a', strTZone) + ' ' + campaignRecord.Time_Zone__c;
    eventRecord.EndDateTime = campaignRecord.End_Date_Time__c.format('MMMM d, yyyy h:mm a', strTZone) + ' ' + campaignRecord.Time_Zone__c;
    eventRecord.CampaignStatus = campaignRecord.Status__c;
    eventRecord.LocationName = campaignRecord.Location__r.Name;
    eventRecord.homePageTitle = campaignRecord.Home_Page_Title__c;
    eventRecord.sessionPageTitle = campaignRecord.Sessions_Page_Title__c;
    eventRecord.materialsPageTitle = campaignRecord.Materials_Page_Title__c;
    eventRecord.issueTrackerPageTitle = campaignRecord.Issue_Tracker_Page_Title__c;
    eventRecord.parkingPageTitle = campaignRecord.Parking_Lot_Page_Title__c;
    eventRecord.surveyPageTitle = campaignRecord.Survey_Page_Title__c;
    eventRecord.contactUsPageTitle = campaignRecord.Contact_Us_Page_Title__c;
    eventRecord.learnMorePageTitle = campaignRecord.Learn_More_Page_Title__c;
    eventRecord.eventPages = campaignRecord.Event_Pages__c;
    eventRecord.showLogin = campaignRecord.Personalized_Event_Page_Login_Button__c;
    eventRecord.SessionsWithGeneralMaterial = campaignRecord.Sessions_with_General_Materials__c;
    
    
    return eventRecord;
}

@AuraEnabled
public static Participant__c getParticipantDetail(String emailstr,String eventId) { 
    Participant__c participantRec = new Participant__c();
    participantRec =  withoutShare.getParticipant(emailstr,eventId);
    return participantRec;
}

@AuraEnabled
public static Participant__c getParticipantDetailByNumber(String participantNumber) { 
    Participant__c participantRec = new Participant__c();
    participantRec =  withoutShare.getParticipantByNumber(participantNumber);
    return participantRec;
}



//Needs inner class declared without sharing for guest users to retrieve relevant records
private without sharing class WithoutSharingClass {
    
    public Participant__c getParticipant(String emailstr,String eventId){
        return [SELECT Member_Contact__r.FirstName, Member_Contact__r.Profile_Picture_URL__c,Member_Contact__r.LastName,Name From Participant__c Where Event__r.Event_Id__c = :eventId AND Member_Contact__r.Email = :emailstr];
    }
    public Participant__c getParticipantByNumber(String participantNumber){
        return [SELECT Member_Contact__r.FirstName, Member_Contact__r.Profile_Picture_URL__c,Member_Contact__r.LastName,Member_Contact__c,Name From Participant__c  WHERE Name = :participantNumber];
    }

    public void updateSessionParticipant(Session_Participant__c sessionPartipant){
        update sessionPartipant;
    }
    
    public List<Session__c> getSessions(String eventId){
        return [SELECT Id,Name,
                lastModifiedById,
                Subtitle__c,  
                Start_Date_Time__c, 
                End_Date_Time__c, 
                Description__c, 
                Time_Zone__c,
                Event__r.Sessions_Page_Title__c  
                FROM Session__c 
                WHERE Event__r.Event_Id__c = :eventId 
                AND IsActive__c = true 
                ORDER BY Start_Date_Time__c];
    }
    
    public List<Session_Participant__c> getSessionParticipant(String participantNumber){
        return [SELECT Id, Status__c,Session__c, Session__r.Name, Session__r.Start_Date_Time__c, Session__r.End_Date_Time__c 
                FROM Session_Participant__c WHERE Participant__r.Name = :participantNumber];
    }
    
    public List<Participant__c> getParticipant(String participantNumber){
        return [SELECT Id, Member_Contact__r.FirstName, Member_Contact__r.Profile_Picture_URL__c,Member_Contact__r.LastName FROM Participant__c WHERE Name = :participantNumber];
    }
    
    public Event__c getEventName(String eventCode){
        return [SELECT Id, Name FROM Event__c WHERE Event_Id__c =: eventCode];
    }
    
    public Event__c getEvent(String eventCode){
        return [SELECT Name,
                Subtitle__c,
                Event_Id__c,
                Hero_Image_URL__c,
                Campaign_Logo_URL__c, 
                Description__c,
                Contact_Us_Tag_Line__c,
                Contact_Us_Message__c,
                Location__r.BillingStreet,
                Location__r.BillingCity, 
                Location__r.BillingPostalCode,
                Location__r.BillingState,
                Location__r.BillingCountry,
                Location__r.Name,
                OwnerId,
                Start_Date_Time__c, 
                Contact_Us_User__c,
                Time_Zone__c,
                Status__c,
                End_Date_Time__c,
                Home_Page_Title__c,
                Sessions_Page_Title__c,
                Materials_Page_Title__c,
                Issue_Tracker_Page_Title__c,
                Parking_Lot_Page_Title__c,
                Survey_Page_Title__c,
                Contact_Us_Page_Title__c,
                Learn_More_Page_Title__c,
                Event_Pages__c,
                Personalized_Event_Page_Login_Button__c,
                Sessions_with_General_Materials__c                    
                FROM Event__c WHERE Event_Id__c =: eventCode];
    }
    
    public String getUserTimezone(Id userId){
        return [SELECT ID, TimeZoneSidKey FROM User WHERE ID = :userId LIMIT 1][0].TimeZoneSidKey;
    }
    
    public List<Event_Role__c> getEventRole(Id eventId){
        return [SELECT Contact__r.FirstName ,
                Contact__r.lastName,
                Contact__r.Title,
                Contact__r.Profile_Description__c,
                Contact__r.Profile_Picture_URL__c 
                FROM Event_Role__c WHERE Event__r.Id = :eventId AND Show_in_Event_Site__c = true AND Role__c = 'Speaker'];
    }
}
}