public class countdowntimercontroller { 
    @AuraEnabled
    public static TeleMeet__c fetchTelemeetStartDate(String recId){
        TeleMeet__c tel = [select Meeting_URL2__c, Start_Date_Time__c, End_Date_Time__c, Time_Zone__c, Encounter__c, Encounter__r.Reason__c, Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.Profile_Picture_URL__c, Resource_Contact__c, Resource_Contact__r.Name, Resource_Contact__r.Profile_Picture_URL__c, Show_in_Lobby__c  from TeleMeet__c where id =: recId];
        
        return tel;
    }
    
    @AuraEnabled
    public static List<Connect_Agenda__c> fetchConnectAgenda(String recId){
        List<Connect_Agenda__c> conAge = [select Completed__c, Connect__c, Contact__c, Contact__r.Name, Description__c, End_Time__c, Start_Time__c from Connect_Agenda__c where Connect__c =: recId AND Start_Time__c != null AND End_Time__c != null order by Start_Time__c];
        return conAge;
    }
    
    @AuraEnabled
    public static List<TeleMeet_Participant__c> fetchConnectParticipant(String recId){
        List<TeleMeet_Participant__c> conPart = [select Contact__c, Contact__r.Name, Contact__r.Profile_Picture_URL__c, Optional__c, Role__c from TeleMeet_Participant__c  where TeleMeet__c =: recId order by Role__c ASC];
        return conPart;
    }
    
    
    @AuraEnabled
    public static Connect_Agenda__c searchForConAgeRecord(String recordId){
    	Connect_Agenda__c conAge = [SELECT Completed__c, Contact__c, Description__c, End_Time__c, Start_Time__c FROM Connect_Agenda__c WHERE Id =: recordId];
        
        return conAge;
    }
    
    @AuraEnabled
    public static String completeConnectAgenda(String recordId){
    	Connect_Agenda__c conAge = [SELECT Completed__c, Contact__c, Description__c, End_Time__c, Start_Time__c FROM Connect_Agenda__c WHERE Id =: recordId];
        conAge.Completed__c = true;
        update conAge;
        return 'success';
    }
    
    
    
    
    @AuraEnabled
    public static String getTimeZoneSidKey(){
        
    	String TimeZoneSidKey =  [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        
    	return TimeZoneSidKey;
    }
    
    
    @AuraEnabled
    public static Map<String, String> getConvertedDates(DateTime StartDate, String TelTimeZone){
        Map<String, String> dates = new Map<String, String>();
        
    	String TimeZoneSidKey =  [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        
        dates.put('TimeZoneSidKey', TimeZoneSidKey);
        
        
		DateTime startDT;
        Timezone tz;
        String startDTGMT = StartDate.format('MM/dd/yyyy/HH/mm/ss', TimeZoneSidKey);
        
        system.debug('Date Time Now >>>'+system.now() );
        system.debug('startDTGMT >>>'+startDTGMT );
        
        List<String> startDTtz = startDTGMT.split('/');
        
        DateTime startDTNew = DateTime.newInstanceGMT(Integer.valueOf(startDTtz[2]), Integer.valueOf(startDTtz[0]), Integer.valueOf(startDTtz[1]),  Integer.valueOf(startDTtz[3]), 
                                                      Integer.valueOf(startDTtz[4]), Integer.valueOf(startDTtz[5]));
        
        /*tz = Timezone.getTimeZone(TelTimeZone);
        startDT = startDTNew.addHours(-(tz.getOffset(startDTNew)/3600000));*/
        
        
        system.debug('startDT Converted >>>'+startDTNew );
        
		dates.put('StartDate', String.valueOf(startDTNew));        
        
        
    	return dates;
    }
}