public without sharing class ChangeCloudController { 
        
        @AuraEnabled
        public static String getParticipantName(String ParticipantNumber) { 
            Session_Participant__c Participant = [SELECT Id, Session__c,Status__c,Contact__r.Name FROM Session_Participant__c WHERE Participant__r.Name = :  ParticipantNumber Limit 1];
        	return Participant.Contact__r.Name;
        }
        
        @AuraEnabled
        public static CCEEventWrapper getEventDetails(String eventId) { 
            
            //eventId = '7RvETWUOkMc';
            CCEEventWrapper eventRecord = new CCEEventWrapper();
            Event__c campaignRecord =  [SELECT   Name,
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
                                        End_Date_Time__c
                                        FROM Event__c WHERE Event_Id__c =: eventId];
            
            String timezone;
            if (campaignRecord.Contact_Us_User__c != null){
                timezone = [SELECT ID, TimeZoneSidKey FROM User WHERE ID =: campaignRecord.Contact_Us_User__c LIMIT 1][0].TimeZoneSidKey;
            } else {
                timezone = [SELECT ID, TimeZoneSidKey FROM User WHERE ID =: campaignRecord.OwnerId LIMIT 1][0].TimeZoneSidKey;
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
            String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
            eventRecord.StartDateTime = campaignRecord.Start_Date_Time__c.format('MMMM d, yyyy h:mm a', strTZone) + ' ' + campaignRecord.Time_Zone__c;
            eventRecord.EndDateTime = campaignRecord.End_Date_Time__c.format('MMMM d, yyyy h:mm a', strTZone) + ' ' + campaignRecord.Time_Zone__c;
            eventRecord.CampaignStatus = campaignRecord.Status__c;
            eventRecord.LocationName = campaignRecord.Location__r.Name;
            
            system.debug(eventRecord);
            
            return eventRecord;
        }
        
        @AuraEnabled
        public static CCEEventWrapper getEventSession(String eventId,String ParticipantNumber,Boolean pstrue) {
            //eventId = '7RvETWUOkMc';
            //pstrue= true;
            //ParticipantNumber = 'EM-000070';
            Map<Id,Session_Participant__c> sessionMap = new Map<Id,Session_Participant__c>();
            
            List<Session_Participant__c> sessions = [SELECT Id, Session__c,Status__c,Participant__r.Name FROM Session_Participant__c WHERE Participant__r.Name = :  ParticipantNumber];
            for(Session_Participant__c sp : sessions){
                sessionMap.put(sp.Session__c,sp);
            }
            
            CCEEventWrapper eventRecord = new CCEEventWrapper();
            Event__c campaignRecord =  [SELECT Id, 
                                        OwnerId, 
                                        Contact_Us_User__c 
                                        FROM Event__c 
                                        WHERE Event_Id__c =: eventId];
            
            String timezone;
            if (campaignRecord.Contact_Us_User__c != null){
                timezone = [SELECT ID, TimeZoneSidKey FROM User WHERE ID =: campaignRecord.Contact_Us_User__c LIMIT 1][0].TimeZoneSidKey;
            } else {
                timezone = [SELECT ID, TimeZoneSidKey FROM User WHERE ID =: campaignRecord.OwnerId LIMIT 1][0].TimeZoneSidKey;
            }
            
            String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
            
            List<Session__c> campaignList =  [SELECT Id,Name, 
                                              Subtitle__c,  
                                              Start_Date_Time__c, 
                                              End_Date_Time__c, 
                                              Description__c, 
                                              Time_Zone__c
                                              FROM Session__c 
                                              WHERE Event__r.Event_Id__c =:eventId AND IsActive__c = true ORDER BY Start_Date_Time__c ];
            
            eventRecord.SessionList = new List<CCEEventWrapper.SessionDetail>();
            
            String SessionDateMatch = '';
            
            for(Session__c CampaignRec : campaignList){ 
                
                if(sessionMap.get(CampaignRec.Id) != null || pstrue == false ){
                    
                    
                    
                    String SessionDateMatchCompare = '';
                    if (CampaignRec.Start_Date_Time__c != null){
                        SessionDateMatchCompare = CampaignRec.Start_Date_Time__c.format('MMM d', strTZone);
                    }
                    
                    if(SessionDateMatch != SessionDateMatchCompare){
                        CCEEventWrapper.SessionDetail sessionRecHeader = new CCEEventWrapper.SessionDetail();
                        sessionRecHeader.isHeader = true;
                        sessionRecHeader.SessionDate = CampaignRec.Start_Date_Time__c.format('EEEE, MMMM d, yyyy');
                        sessionRecHeader.SessionMonth = String.valueOf(CampaignRec.Start_Date_Time__c.month());
                        eventRecord.SessionList.add(sessionRecHeader);
                        SessionDateMatch = SessionDateMatchCompare;
                    }
                    
                    CCEEventWrapper.SessionDetail sessionRec = new CCEEventWrapper.SessionDetail();
                    sessionRec.isHeader = false;
                    sessionRec.title  = CampaignRec.Name;
                    sessionRec.subtitle = CampaignRec.Description__c;
                    
                    if(pstrue){
                        sessionRec.participantSessionId = sessionMap.get(CampaignRec.Id).Id;
                        
                        if(sessionMap.get(CampaignRec.Id).Status__c == 'Attended'){
                            sessionRec.isAttended = true;   
                        }else{
                            sessionRec.isAttended = false;   
                        }
                        
                    }
                    
                    
                    
                    
                    if (CampaignRec.Start_Date_Time__c != null && CampaignRec.End_Date_Time__c != null){
                        sessionRec.SessionDate = CampaignRec.Start_Date_Time__c.format('MMM d, yyyy', strTZone);
                        sessionRec.StartTime = CampaignRec.Start_Date_Time__c.format('h:mm a', strTZone);
                        sessionRec.EndTime = CampaignRec.End_Date_Time__c.format('h:mm a', strTZone);
                        sessionRec.TimeZone = CampaignRec.Time_Zone__c;
                    }
                    
                    eventRecord.SessionList.add(sessionRec);
                }
            }
            
            return eventRecord;
        }
        
        @AuraEnabled
        public static List<CCESpeakerWrapper> getSpeakerDetails(String eventId) {
            
            //eventId = '7RvETWUOkMc';
            List<CCESpeakerWrapper> speakerList = new List<CCESpeakerWrapper>();
            system.debug('eventId ---- ' +eventId);
            Event__c campaignRecord =  [SELECT Name FROM Event__c WHERE Event_Id__c =: eventId];
            system.debug('eventId ---- ' +eventId);
            system.debug('campaignRecord ---- ' +campaignRecord.Id);
            
            List<Event_Role__c> eventRoleList =  [SELECT Contact__r.FirstName ,
                                                  Contact__r.lastName,
                                                  Contact__r.Title,
                                                  Contact__r.Profile_Description__c,
                                                  Contact__r.Profile_Picture_URL__c 
                                                  FROM Event_Role__c WHERE Event__r.Id =: campaignRecord.Id AND Show_in_Event_Site__c = true AND Role__c = 'Speaker'];
            
            for(Event_Role__c er : eventRoleList){
                CCESpeakerWrapper speaker = new CCESpeakerWrapper();
                speaker.FirstName = er.Contact__r.FirstName;
                speaker.lastName = er.Contact__r.lastName;
                speaker.Title = er.Contact__r.Title;
                speaker.Description = er.Contact__r.Profile_Description__c;
                speaker.ProfilePicUrl = er.Contact__r.Profile_Picture_URL__c;
                speakerList.add(speaker);
            }
            
            system.debug('speakerList ---- ' +speakerList);
            return speakerList;
        }
        
        @AuraEnabled
        // Create task for each request sent from the custom contact support form
        public static void createTask(String eventId, String firstname, String lastname, String email, String phone, String subject, String comments){
            if (String.isBlank(eventId) || String.isBlank(firstname) || String.isBlank(lastname) || String.isBlank(email) || String.isBlank(subject) || String.isBlank(comments)) return;
            CustomContactSupportFormHelper.createTaskHelper(eventId, firstname, lastname, email, phone, subject, comments);
        }
        /* 
    //PT-00333 Event Parking Lot
    @AuraEnabled 
    public static string getParkingLotDetails(String eventId, String contactId){
    
    Map<String,Object> returnMap = new Map <String,Object>();
    Event__c campaignRecord =  [SELECT  Id, Name,
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
    End_Date_Time__c
    FROM Event__c WHERE Event_Id__c =: eventId];
    returnMap.put('campaignRecord',campaignRecord);
    
    String eventRecordId =  campaignRecord.Id;
    
    List<Session__c> sessionList =  [SELECT Name, Id,
    Subtitle__c,  
    Start_Date_Time__c, 
    End_Date_Time__c, 
    Description__c, 
    Time_Zone__c
    FROM Session__c 
    WHERE Event__r.Id =:eventRecordId AND IsActive__c = true ];
    returnMap.put('sessionList',sessionList);
    
    Session__c session =  [SELECT Name, Id,
    Subtitle__c,  
    Start_Date_Time__c, 
    End_Date_Time__c, 
    Description__c, 
    Time_Zone__c
    FROM Session__c 
    WHERE Event__r.Id =:eventRecordId AND IsActive__c = true LIMIT 1 ];
    returnMap.put('session',session);
    
    List<Contact> contactDetails = [SELECT Id, Name, Email from Contact WHERE Id =: contactId];
    if(!contactDetails.isEmpty()){
    returnMap.put('contact',contactDetails[0]);
    }
    
    
    List<Parking_Lot__c> parkingLotList;
    if(String.isBlank(contactId)){
    parkingLotList = [SELECT Id, Name, Description__c, Escalated_To__c, Event__c, Event__r.Name,
    Raised_By__c, Raised_By__r.FirstName, Raised_By__r.LastName, Raised_By__r.Email, Raised_By__r.Name, 
    Addressed_By__c, Addressed_By__r.FirstName, Addressed_By__r.LastName, Addressed_By__r.Email, Addressed_By__r.Name, 
    Resolution_Answer__c, Session__c, Session__r.Name,
    Site__c, Status__c, Type__c FROM Parking_Lot__c WHERE Event__c =: eventRecordId AND Session__c=:session.Id ORDER BY Name];
    }
    else{
    parkingLotList = [SELECT Id, Name, Description__c, Escalated_To__c, Event__c, Event__r.Name,
    Raised_By__c, Raised_By__r.FirstName, Raised_By__r.LastName, Raised_By__r.Email, Raised_By__r.Name, 
    Addressed_By__c, Addressed_By__r.FirstName, Addressed_By__r.LastName, Addressed_By__r.Email, Addressed_By__r.Name, 
    Resolution_Answer__c, Session__c, Session__r.Name,
    Site__c, Status__c, Type__c FROM Parking_Lot__c WHERE Event__c =: eventRecordId AND Session__c=:session.Id AND Raised_By__c =: contactId ORDER BY Name];
    }
    returnMap.put('parkingLotList',parkingLotList);
    
    
    List<String> typeList= new List<String>();
    Schema.DescribeFieldResult fieldResult = Parking_Lot__c.Type__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple){
    typeList.add(pickListVal.getLabel());
    }    
    returnMap.put('typeList',typeList);    
    
    
    return JSON.serialize(returnMap);                                    
    }
    
    //PT-00333 Event Parking Lot
    @AuraEnabled
    // Create parkinglot for each request sent from the custom parking lot form
    public static void createParkingLot(String eventId, String session, String email, String phone, String description, String type){
    
    if (String.isBlank(eventId) || String.isBlank(session) || String.isBlank(email) || String.isBlank(description) || String.isBlank(type)) throw new AuraHandledException('Error on creating parking lot: Required fields missing');
    CustomParkingLotFormHelper.createParkingLotHelper(eventId, session,  email, phone, description, type);
    
    }
    
    //PT-00333 Event Parking Lot
    @AuraEnabled
    // Update parking lot from parking lot data table below parking lot form
    public static void updateParkingLots(String parkingLots){
    
    List<Parking_Lot__c> editedParkingLots = (List<Parking_lot__c>)JSON.deserialize(parkingLots,List<Parking_lot__c>.Class);
    try{
    update editedParkingLots;
    }
    catch(DmlException e){
    if(e.getMessage().contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST') && e.getMessage().contains('Type__c')){
    throw new AuraHandledException('Invalid Type value: Issue, Question, Comment, Statement BH');
    }
    else if(e.getMessage().contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST') && e.getMessage().contains('Status__c')){
    throw new AuraHandledException('Invalid Status value: Open, Closed');
    }
    else{
    throw new AuraHandledException(e.getMessage());
    }
    }
    }
    */
        
        @AuraEnabled
        public static List<compass_session_wrapper> getParticipantSession(String ParticipantNumber) {
            
            //ParticipantNumber = 'EM-000070';
            List<Session_Participant__c> sessions = [SELECT Id, Status__c,Session__c, Session__r.Name, Session__r.Start_Date_Time__c,Session__r.End_Date_Time__c FROM Session_Participant__c WHERE Participant__r.Name = :  ParticipantNumber];
            
            system.debug('sessions---------- '+ sessions);
            
            List<compass_session_wrapper> participantsessions = new List<compass_session_wrapper>();
            
            for(Session_Participant__c session : sessions){
                compass_session_wrapper participantsession = new compass_session_wrapper();
                
                participantsession.selected =  false;
                participantsession.status =  session.Status__c;
                participantsession.participantSessionId =  session.Id;
                participantsession.title =  session.Session__r.Name;
                
                participantsessions.add(participantsession);
            }
            system.debug('participantsessions---------- '+ participantsessions);
            return participantsessions;
        }
        
        @AuraEnabled
        public static Boolean updateAttendance(String ParticipantSessionId) {
            
            Session_Participant__c sp = new Session_Participant__c();
            sp.Id = ParticipantSessionId;
            sp.Status__c = 'Attended';
            try{
                update sp;
                return true;   
            }
            catch(DmlException e){
                return false;   
            }
            
        }
        
    }