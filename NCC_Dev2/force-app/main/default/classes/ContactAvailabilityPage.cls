global class ContactAvailabilityPage {
     @AuraEnabled        
    public static List<String> getFieldValues(){
        List<String> pickListValuesList = new List<String>(); 
        Schema.DescribeFieldResult fieldResult = Contact.Specialties__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        system.debug('pickListValuesList'+pickListValuesList);
        return pickListValuesList;
    }
    
    @AuraEnabled     
    public static Contact searchForContact(Id recordId){
        Contact cont = [SELECT Id, Name, AccountId, Account.Name, Contact_Type__c, Specialties__c, Social_Security_Number__c, Profile_Picture_URL__c,
                        Email
                        FROM Contact WHERE Id =: recordId];
        
        return cont;
    }
    
     @AuraEnabled     
    public static Contact_Availability__c searchForConAvaRecord(String recordId){
        Contact_Availability__c conava = [SELECT Id, Name, Specialties__c, Contact__r.Name, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c, Status__c
                        FROM Contact_Availability__c WHERE Id =: recordId];
        
        return conava;
    }
    
    @AuraEnabled     
    public static TeleMeet__c searchForTelemeet(String recordId){
        TeleMeet__c telemeet = [SELECT Id, Name, Resource_Contact__c, Resource_Contact__r.Name, Encounter__r.Encounter_Date__c, Encounter__r.Resource_Specialty__c, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c, Status__c
                        FROM TeleMeet__c WHERE Id =: recordId];
        
        return telemeet;
    }
    
    @AuraEnabled     
    public static List<Contact_Availability__c> searchForContactAvailability(String recordId, String specialty, Date startdate, Date enddate){
        system.debug('recordId>>>'+recordId);
        system.debug('specialty>>>'+specialty);
        system.debug('startdate>>>'+startdate);
        system.debug('enddate>>>'+enddate);
        
        List<Contact_Availability__c> conavaList = new List<Contact_Availability__c>();
        
        /*List<Contact_Availability__c> conavaList = [SELECT Id, Name, Contact__c, Contact__r.Name, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c, Specialties__c,  
                                                    Duration__c, Duration_minutes__c, Status__c,
                                                    TeleMeet__r.TeleMeet_URL__c
                                                    FROM Contact_Availability__c
                                                    WHERE Contact__c =: recordId];*/
        String query = 'SELECT Id, Name, Contact__c, Contact__r.Name, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c, Specialties__c,  ';
        query += 'Duration__c, Duration_minutes__c, Status__c, ';
        query += 'TeleMeet__r.Meeting_URL2__c ';
        query += 'FROM Contact_Availability__c ';
        
        String filter = '';
        List<String> filterList = new List<String>();
        Datetime startdateF;
        Datetime enddateF;
        String startDateFormat;
        String endDateFormat;
        
        if(recordId != ''){
            filterList.add('Contact__c =  \''+recordId+'\'');
        }
        if(specialty != ''){
            filterList.add('Specialties__c =  \''+specialty+'\'');
        }
        if(startdate != null){
            startdateF = datetime.newInstance(startdate.year(), startdate.month(), startdate.day(), 0, 0, 0);
            startDateFormat = startdateF.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            filterList.add('Start_Date_Time__c >=  '+startDateFormat);
        }
        if(enddate != null){
            enddateF = datetime.newInstance(enddate.year(), enddate.month(), enddate.day(), 23, 59, 59);
            endDateFormat = enddateF.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            filterList.add('End_Date_Time__c <= '+endDateFormat);
        }
        
        
        system.debug('startdateF>>>'+startDateFormat);
        system.debug('enddateF>>>'+endDateFormat);
        system.debug('filterList>>>>>'+filterList);
        if(filterList.size() > 0){
            filter += 'WHERE ';   
            for(Integer n = 0; filterList.size() > n; n++){
                
                if(filterList.size() == n+1){
                    filter += filterList[n];  
                }
                else if(filterList.size() > n-1){
                    filter += filterList[n] + ' AND ';  
                }
                
            }
        }
        else{
            filter += 'ORDER BY createddate desc ';
        }
        
        query += filter;
        
        system.debug('query>>>>>'+ query);
        
        conavaList = Database.query(query);
        
        system.debug('record count>>>>>'+ conavaList.size());
        system.debug('records>>>>>'+ conavaList);
        
        return conavaList;
    }
    
    
    @AuraEnabled     
    public static String scheduleMeeting(Id recordId, String area, String otherarea, String internalnotes, String contId){
        String error = '';
        try{
            Contact_Availability__c conava = [SELECT Id, Contact__c, Contact__r.Name, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c, Specialties__c,  
                                              Duration__c, Duration_minutes__c, Status__c
                                              FROM Contact_Availability__c
                                              WHERE Id =: recordId];
            
            TeleMeet__c tm = new TeleMeet__c();
            tm.Subject__c = conava.Specialties__c + ' - ' + conava.Contact__r.Name;
            tm.Start_Date_Time__c = conava.Start_Date_Time__c;
            tm.End_Date_Time__c = conava.End_Date_Time__c;
            tm.Status__c = 'Scheduled';
            tm.Time_Zone__c = conava.Time_Zone__c;
            tm.TeleMeet_URL__c = 'https://amazon-chime-app.herokuapp.com/?m=' +conava.Id;
            tm.Area__c = area;
            tm.Other_Area__c = otherarea;
            tm.Internal_Notes__c = internalnotes;
            tm.Resource_Specialty__c = conava.Specialties__c;
            if(contId != ''){
                tm.Resource_Contact__c = contId;
            }
            insert tm;   
            
            TeleMeet_Participant__c tp = new TeleMeet_Participant__c();
            tp.Contact__c = conava.Contact__c;
            tp.TeleMeet__c = tm.Id;
            
            insert tp;
            
            conava.TeleMeet__c = tm.Id;
            update conava;
            
        }
        catch(Exception ex){
            error = ex.getMessage();
            System.debug('ContactAvailability.scheduleMeeting Error: '+ex.getMessage());
        }
        
        return error;
    }
    
     @AuraEnabled     
    public static String updateTelemeet(Id contactAvailabilityId, String telemeetId){
        String error = '';
        
        Contact_Availability__c conava = [SELECT Id, Contact__c, Contact__r.Name, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c, Specialties__c,  
                                          Duration__c, Duration_minutes__c, Status__c
                                          FROM Contact_Availability__c
                                          WHERE Id =: contactAvailabilityId];
        
        TeleMeet__c telemeet = [SELECT Id, Name, Resource_Contact__c, Resource_Contact__r.Name, Encounter__r.Encounter_Date__c, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c, Status__c, Resource_Specialty__c
                        FROM TeleMeet__c WHERE Id =: telemeetId];
        
        if(telemeet != null){
            telemeet.Start_Date_Time__c = conava.Start_Date_Time__c;
            telemeet.End_Date_Time__c = conava.End_Date_Time__c;
            telemeet.Status__c = 'Scheduled';
            telemeet.Time_Zone__c = conava.Time_Zone__c;
            telemeet.Resource_Contact__c = conava.Contact__c;
            telemeet.Resource_Specialty__c = conava.Specialties__c;
            update telemeet;
        }
        
        if(conava != null){
            conava.TeleMeet__c = telemeet.Id;
            update conava;            
        }
        
        return error;
    }
}