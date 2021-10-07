public without sharing class CommunityProjectIssueController {
    @AuraEnabled 
    public static string getProjectDetails(String eventId){
        
        Map<String,Object> returnMap = new Map <String,Object>();
        String eventRecordId = '';
        Event__c campaignRecord;
        try{
            campaignRecord =  [SELECT  Id, Name,
                               Subtitle__c,
                               Event_Id__c,
                               Hero_Image_URL__c,
                               Campaign_Logo_URL__c, 
                               Description__c,
                               Parking_Lot_Tag_Line__c,
                               Parking_Lot_Message__c,
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
                               FROM Event__c WHERE Event_Id__c =: eventId LIMIT 1];
            eventRecordId =  campaignRecord.Id;
            returnMap.put('campaignRecord',campaignRecord);
        }
        catch(QueryException e){
            if(eventRecordId == ''){
                throw new AuraHandledException('Invalid Event Id');     
            }
        }
        /*
        List<Krow__Project__c> projectList = [SELECT Id, Name FROM Krow__Project__c 
                                              WHERE Custom_Event__r.Id =:eventRecordId 
                                              ORDER By Name ASC];
        if(projectList.isEmpty()){
            throw new AuraHandledException('No available project for event ' + campaignRecord.Name);   
        }
        returnMap.put('projectList',projectList);
		*/
        
        String sessionId;
        try{
            Session__c session =  [SELECT Name, Id,
                                   Subtitle__c,  
                                   Start_Date_Time__c, 
                                   End_Date_Time__c, 
                                   Description__c, 
                                   Time_Zone__c
                                   FROM Session__c 
                                   WHERE Event__r.Id =:eventRecordId AND IsActive__c = true LIMIT 1 ];
            sessionId = session.Id;
            returnMap.put('session',session);
        }
        catch(QueryException e){
            throw new AuraHandledException('The event has no active session');
        }
        
         List<Session__c> sessionList =  [SELECT Name, Id,
                                         Subtitle__c,  
                                         Start_Date_Time__c, 
                                         End_Date_Time__c, 
                                         Description__c, 
                                         Time_Zone__c
                                         FROM Session__c 
                                         WHERE Event__r.Id =:eventRecordId 
                                         AND IsActive__c = true ORDER By Name ASC, Start_Date_Time__c ASC];
        
        String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        //wrap sessionList
        List<CustomParkingLotFormController.SessionWrapper> sessionWrapper = new List<CustomParkingLotFormController.SessionWrapper>();
        for(Session__c session: sessionList){
            CustomParkingLotFormController.SessionWrapper wrapper = new CustomParkingLotFormController.SessionWrapper();
            String sessionName = '';
            DateTime startDT = session.Start_Date_Time__c;
            DateTime endDT = session.End_Date_Time__c;
            if(startDT.date() == endDT.date()){
                sessionName = session.Name+' - '+startDT.format('MMMMM dd, yyyy', strTZone)+ ', '
                    			+startDT.format('hh:mm aaa', strTZone)
                    			+' to '+endDT.format('hh:mm aaa', strTZone) + ' ' + session.Time_Zone__c;
            }
            else{
                sessionName = session.Name+' - '+startDT.format('MMMMM dd, yyyy', strTZone)+ ', '
                    			+startDT.format('hh:mm aaa', strTZone) 
                    			+' to '+endDT.format('MMMMM dd, yyyy', strTZone)+ ', ' + endDT.format('hh:mm aaa', strTZone) + ' ' + session.Time_Zone__c;
            }
            
            wrapper.recordId = session.Id;
            wrapper.sessionName = session.Name;
            wrapper.sessionFullName = sessionName;
            wrapper.startdatetime = startDT;
            wrapper.enddatetime = endDT;
            wrapper.description = session.Description__c;
            wrapper.timezone = session.Time_Zone__c;
            sessionWrapper.add(wrapper);
        }
        returnMap.put('sessionWrapper',sessionWrapper);
        returnMap.put('sessionList',sessionList);
        
        
        
        //Get Project issues list List
        List<Project_Issue__c> projIssueList = [SELECT Id, Name, CreatedDate, Date_Raised__c, Raised_By__c, Likelihood__c, Impact__c, Status__c, Due_Date__c,
                                                Assigned_To__c, Resolution__c, Notes__c, Raised_By_Email__c, Description__c, Type__c, Session__r.Name, Session__c
                                                FROM Project_Issue__c
                                                WHERE Custom_Event__r.Id =: eventRecordId ORDER BY NAME DESC];
        returnMap.put('projIssueList',projIssueList);
        if(sessionList.isEmpty()){
            throw new AuraHandledException('Event has no active session');
        }
        
        List<String> typeList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Project_Issue__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            typeList.add(pickListVal.getLabel());
        }    
        returnMap.put('typeList',typeList);    
        
        
        return JSON.serialize(returnMap);                                    
    }
    
    @AuraEnabled
    // Create project issue
    public static void createProjectIssue(String eventId, String session, String email, String description, String type){
        
        if (String.isBlank(session) || String.isBlank(eventId) || String.isBlank(email) || String.isBlank(description) || String.isBlank(type)){ throw new AuraHandledException('Error on creating project raid: Required fields missing');}

        Project_Issue__c newProjectIssue = new Project_Issue__c(
            Session__c = session,
            Custom_Event__c = [SELECT ID FROM Event__c WHERE Event_Id__c = :eventId LIMIT 1].Id,
            Raised_By_Email__c = email,
            Description__c = description,
            Status__c = 'New',
            Type__c = type,
            Date_Raised__c = date.today()
        );
        try{
            insert newProjectIssue;
        }
        catch(DmlException e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
     public class SessionWrapper{
        @AuraEnabled public Id recordId         		{get; set;}
        @AuraEnabled public String  sessionName     	{get; set;}
        @AuraEnabled public String  sessionFullName     {get; set;}
        @AuraEnabled public DateTime  startdatetime     {get; set;}
        @AuraEnabled public DateTime  enddatetime     	{get; set;}
        @AuraEnabled public String  description			{get; set;}
        @AuraEnabled public String  timezone			{get; set;}
    }
}