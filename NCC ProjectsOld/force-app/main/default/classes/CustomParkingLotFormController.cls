/**
* Description: This is the controller class for communityEventParkingLot, which creates a parking lot record and display exisiting records
* Author: Jester Cabantog
* Version: 1.0
* Last modified date: 12/16/2020
**/
public without sharing class CustomParkingLotFormController {
    //PT-00333 Event Parking Lot
    @AuraEnabled 
    public static string getParkingLotDetails(String eventId, String contactId){
        
        Map<String,Object> returnMap = new Map <String,Object>();
        String eventRecordId;
        try{
            Event__c campaignRecord =  [SELECT  Id, Name,
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
        
        List<Contact> contactDetails = [SELECT Id, Name, Email from Contact WHERE Id =: contactId];
        if(!contactDetails.isEmpty()){
            returnMap.put('contact',contactDetails[0]);
        }
        
        List<Session__c> sessionList;
        List<Parking_Lot__c> parkingLotList;
        if(String.isBlank(contactId)){
            sessionList =  [SELECT Name, Id,
                                         Subtitle__c,  
                                         Start_Date_Time__c, 
                                         End_Date_Time__c, 
                                         Description__c, 
                                         Time_Zone__c
                                         FROM Session__c 
                                         WHERE Event__r.Id =:eventRecordId 
                                         AND IsActive__c = true ORDER By Name ASC, Start_Date_Time__c ASC];

            parkingLotList = [SELECT Id, Name, Description__c, Escalated_To__c, Event__c, Event__r.Name,
                              Raised_By__c, Raised_By__r.FirstName, Raised_By__r.LastName, Raised_By__r.Email, Raised_By__r.Name, 
                              Addressed_By__c, Addressed_By__r.FirstName, Addressed_By__r.LastName, Addressed_By__r.Email, Addressed_By__r.Name, 
                              Resolution_Answer__c, Session__c, Session__r.Name,
                              Site__c, Status__c, Type__c FROM Parking_Lot__c WHERE Event__c =: eventRecordId /*AND Session__c=:sessionId*/ ORDER BY Name];
        }
        else{
            sessionList =  [SELECT Name, Id,
                                         Subtitle__c,  
                                         Start_Date_Time__c, 
                                         End_Date_Time__c, 
                                         Description__c, 
                                         Time_Zone__c
                                         FROM Session__c 
                                         WHERE Event__r.Id =:eventRecordId 
                                         AND Id IN (SELECT Session__c FROM Session_Participant__c
                                                   WHERE Contact__c =: contactId 
                                                   AND Event__c =: eventRecordId)
                                         AND IsActive__c = true ORDER By Name ASC, Start_Date_Time__c ASC];

            parkingLotList = [SELECT Id, Name, Description__c, Escalated_To__c, Event__c, Event__r.Name,
                              Raised_By__c, Raised_By__r.FirstName, Raised_By__r.LastName, Raised_By__r.Email, Raised_By__r.Name, 
                              Addressed_By__c, Addressed_By__r.FirstName, Addressed_By__r.LastName, Addressed_By__r.Email, Addressed_By__r.Name, 
                              Resolution_Answer__c, Session__c, Session__r.Name,
                              Site__c, Status__c, Type__c FROM Parking_Lot__c WHERE Event__c =: eventRecordId /*AND Session__c=:sessionId*/ AND Raised_By__c =: contactId ORDER BY Name];
        }
        
        //20201230 JL bug fix#00601:Session Picklist(https://ulapp-developers.force.com/projects/s/detail/a0x3k00001UqIwYAAV)
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
        returnMap.put('parkingLotList',parkingLotList);

        if(sessionList.isEmpty()){
            throw new AuraHandledException('Participant is not registered on any session');
        }
        
        
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
                List<String> typeList= new List<String>();
                Schema.DescribeFieldResult fieldResult = Parking_Lot__c.Type__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    typeList.add(pickListVal.getLabel());
                }    
                throw new AuraHandledException('Invalid Type value: '+typeList.toString());
            }
            else if(e.getMessage().contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST') && e.getMessage().contains('Status__c')){
                List<String> statusList= new List<String>();
                Schema.DescribeFieldResult fieldResult = Parking_Lot__c.Status__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    statusList.add(pickListVal.getLabel());
                }    
                throw new AuraHandledException('Invalid Status value: '+statusList.toString());
            }
            else{
                throw new AuraHandledException(e.getMessage());
            }
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