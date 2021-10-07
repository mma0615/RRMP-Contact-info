public without sharing class CCEHeroController {

    // Retrieve the files that belong to the record Ids
    @AuraEnabled
    public static String getMaterialsHelper(String eventId){
        system.debug('Hello');
        List<MaterialWrapper> materials = new List<MaterialWrapper>();
        //eventId = '7RvETWUOkMc';
        Set<Id> campaignIds = new Set<Id>();
        // Retrieve the event's Salesforce recordId
        Event__c eventrec = [SELECT Id, Name FROM Event__c WHERE Event_Id__c =: eventId AND IsActive__c = true LIMIT 1];
        campaignIds.add(eventrec.Id);

        //for (Session__c sessionRec : [SELECT Id, Name FROM Session__c WHERE Event__c =: eventrec.Id AND IsActive__c = true]){
        //    campaignIds.add(sessionRec.Id);
        //}

        // Retrieve a map of contentDocumentId and Title
        Map<Id, ContentDocumentLink> contentDocumentLinkTitleMap = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink cdl : ([SELECT ContentDocument.Id, ContentDocument.Title, ContentDocument.Description FROM ContentDocumentLink WHERE LinkedEntityId IN: campaignIds ORDER BY ContentDocument.Title])){
            contentDocumentLinkTitleMap.put(cdl.ContentDocument.Id, cdl);
        }

        system.debug('------- ' + contentDocumentLinkTitleMap.keySet());

        // Retrieive a map of contentDocumentId and DistributionPublicUrl
        Map<ID, String> contentDistributionMap = new Map<Id, String>();
        if (contentDocumentLinkTitleMap.size() > 0){
            for (ContentDistribution cd : [SELECT ID, DistributionPublicUrl, ContentDocumentId, ContentDownloadURL FROM ContentDistribution 
                                           WHERE ContentDocumentId IN: contentDocumentLinkTitleMap.keySet()]){
                if (!String.isBlank(cd.DistributionPublicURL)){
                    contentDistributionMap.put(cd.ContentDocumentId, cd.DistributionPublicURL);
                }
            }
        }

        // From the 2 maps above, construct a list of material wrappers to return to the component
        for (String key : contentDocumentLinkTitleMap.keySet()){
            if (!String.isBlank(contentDistributionMap.get(key))){
                MaterialWrapper mw = new MaterialWrapper();
                mw.Title = contentDocumentLinkTitleMap.get(key).ContentDocument.Title;
                mw.Description = contentDocumentLinkTitleMap.get(key).ContentDocument.Description;
                mw.DownloadURL = contentDistributionMap.get(key);
                mw.Id = key;
                materials.add(mw);
            }
        }
         system.debug('materials'+materials);
        return JSON.serialize(materials); 

    }

    public class MaterialWrapper{
        public String Title;
        public String Description;
        public String DownloadURL;
        public String Id;
    }
    
    @AuraEnabled
    public static CCEEventWrapper getEventDetails(String eventId) {
        
        system.debug('--- eventId ' + eventId);
        
        
        CCEEventWrapper eventRecord = new CCEEventWrapper();
        
        Campaign campaignRecord =  [SELECT 	Name,
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
                                    OwnerId,
                                    Start_Date_Time__c, 
								    Contact_Us_User__c,
									Time_Zone__c,
                                    Status,
                                    End_Date_Time__c
                                    FROM Campaign WHERE Event_Id__c =: eventId];

        
        // If Contact Us User is populated then use this user's timezone, otherwise use campaign owner's timezone
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
        eventRecord.Description = campaignRecord.Description__c; 
        eventRecord.contactTag = campaignRecord.Contact_Us_Tag_Line__c; 
        eventRecord.contactMessage = campaignRecord.Contact_Us_Message__c; 
        //eventRecord.StartDateTime = campaignRecord.Start_Date_Time__c.format('MMM d, yyyy h:mm a');
        //eventRecord.EndDateTime = campaignRecord.End_Date_Time__c.format('MMM d, yyyy h:mm a');
        String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        eventRecord.StartDateTime = campaignRecord.Start_Date_Time__c.format('MMMM d, yyyy h:mm a', strTZone) + ' ' + campaignRecord.Time_Zone__c;
        eventRecord.EndDateTime = campaignRecord.End_Date_Time__c.format('MMMM d, yyyy h:mm a', strTZone) + ' ' + campaignRecord.Time_Zone__c;
        eventRecord.CampaignStatus = campaignRecord.Status;
        system.debug(eventRecord);
        return eventRecord;
        
    }
    
    @AuraEnabled
    public static CCEEventWrapper getEventSession(String eventId) {
        
        CCEEventWrapper eventRecord = new CCEEventWrapper();
        Campaign campaignRecord =  [SELECT 	Id, OwnerId, Contact_Us_User__c FROM Campaign WHERE Event_Id__c =: eventId];
        // If Contact Us User is populated then use this user's timezone, otherwise use campaign owner's timezone
        String timezone;
        if (campaignRecord.Contact_Us_User__c != null){
            timezone = [SELECT ID, TimeZoneSidKey FROM User WHERE ID =: campaignRecord.Contact_Us_User__c LIMIT 1][0].TimeZoneSidKey;
        } else {
            timezone = [SELECT ID, TimeZoneSidKey FROM User WHERE ID =: campaignRecord.OwnerId LIMIT 1][0].TimeZoneSidKey;
        }

        String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;

        List<Campaign> campaignList =  [SELECT 	Name, Subtitle__c, Event_Id__c, Start_Date_Time__c, End_Date_Time__c, Description__c, Time_Zone__c
                                            FROM Campaign WHERE ParentId =: campaignRecord.Id ORDER BY Start_Date_Time__c];
        
        eventRecord.SessionList = new List<CCEEventWrapper.SessionDetail>();
        
        String SessionDateMatch = '';
        
        for(Campaign CampaignRec : campaignList){
            
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
            sessionRec.subtitle = CampaignRec.Subtitle__c;
            if (CampaignRec.Start_Date_Time__c != null && CampaignRec.End_Date_Time__c != null){
                sessionRec.SessionDate = CampaignRec.Start_Date_Time__c.format('MMM d, yyyy', strTZone);
                sessionRec.StartTime = CampaignRec.Start_Date_Time__c.format('h:mm a', strTZone);
                sessionRec.EndTime = CampaignRec.End_Date_Time__c.format('h:mm a', strTZone);
                sessionRec.TimeZone = CampaignRec.Time_Zone__c;
            }
            
            eventRecord.SessionList.add(sessionRec);
        }
        
        
        
        return eventRecord;
    }
    
    @AuraEnabled
    public static List<CCESpeakerWrapper> getSpeakerDetails(String eventId) {
        
        List<CCESpeakerWrapper> speakerList = new List<CCESpeakerWrapper>();
        system.debug('eventId ---- ' +eventId);
        Campaign campaignRecord =  [SELECT Name FROM Campaign WHERE Event_Id__c =: eventId];
        system.debug('eventId ---- ' +eventId);
        system.debug('campaignRecord ---- ' +campaignRecord.Id);
        
        List<Event_Role__c> eventRoleList =  [SELECT Contact__r.FirstName ,
                                              Contact__r.lastName,
                                              Contact__r.Title,
                                              Contact__r.Profile_Description__c,
                                              Contact__r.Profile_Picture_URL__c 
                                              FROM Event_Role__c WHERE Campaign__c =: campaignRecord.Id AND Show_in_Event_Site__c = true AND Role__c = 'Speaker'];
        
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
    
}