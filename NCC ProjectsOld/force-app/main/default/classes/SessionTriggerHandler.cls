public class SessionTriggerHandler {
    public static void populateSessionDetails(List<Session__c> newList, Map<Id,Session__c > newMap,List<Session__c > oldList, Map<Id,Session__c > oldMap){
        String strTZone = [SELECT Id, TimeZoneSidKey FROM Organization].TimeZoneSidKey;
        for(Session__c session : newList){
            String sessionName = '';
            String sessionDetailsFull = '';
            if(session.Start_Date_Time__c != null && session.End_Date_Time__c != null){
                DateTime startDT = session.Start_Date_Time__c;
                DateTime endDT = session.End_Date_Time__c;
                if(startDT.date() == endDT.date()){
                    sessionName = startDT.format('MMM dd, yyyy', strTZone)+ ', '
                        +startDT.format('hh:mm aaa', strTZone)
                        +' to '+endDT.format('hh:mm aaa', strTZone) + ' ' + session.Time_Zone__c; 
                    //00707 1/21/2020 - Parking Lot Email notification - JC
                    sessionDetailsFull = startDT.format('MMMMM dd, yyyy', strTZone)+ ', '
                        +startDT.format('hh:mm aaa', strTZone)
                        +' to '+endDT.format('hh:mm aaa', strTZone) + ' ' + session.Time_Zone__c; 
                }
                else{
                    sessionName = startDT.format('MMM dd, yyyy', strTZone)+ ', '
                        +startDT.format('hh:mm aaa', strTZone) + ' ' 
                        +' to '+endDT.format('MMM dd, yyyy', strTZone)+', '+endDT.format('hh:mm aaa', strTZone) + ' ' + session.Time_Zone__c;
                    
                    //00707 1/21/2020 - Parking Lot Email notification - JC
                    sessionDetailsFull = startDT.format('MMMMM dd, yyyy', strTZone)+ ', '
                        +startDT.format('hh:mm aaa', strTZone) + ' ' 
                        +' to '+endDT.format('MMMMM dd, yyyy', strTZone)+', '+endDT.format('hh:mm aaa', strTZone) + ' ' + session.Time_Zone__c;
                    
                }
            }
            else{
                if(session.End_Date_Time__c == null && session.Start_Date_Time__c != null){
                    DateTime startDT = session.Start_Date_Time__c;
                    sessionName = startDT.format('MMM dd, yyyy', strTZone)+ ', '
                        +startDT.format('hh:mm aaa', strTZone)+ ' ' + session.Time_Zone__c;     
                    //00707 1/21/2020 - Parking Lot Email notification - JC
                    sessionDetailsFull = startDT.format('MMMMM dd, yyyy', strTZone)+ ', '
                        +startDT.format('hh:mm aaa', strTZone)+ ' ' + session.Time_Zone__c;     
                }
                if(session.Start_Date_Time__c == null && session.End_Date_Time__c != null ){
                    DateTime endDT = session.End_Date_Time__c;
                    sessionName = endDT.format('MMM dd, yyyy', strTZone)+ ', '
                        +endDT.format('hh:mm aaa', strTZone)+ ' ' + session.Time_Zone__c;
                    //00707 1/21/2020 - Parking Lot Email notification - JC
                    sessionDetailsFull = endDT.format('MMMMM dd, yyyy', strTZone)+ ', '
                        +endDT.format('hh:mm aaa', strTZone)+ ' ' + session.Time_Zone__c;
                }
            }
            session.Session_Details__c = sessionName;
            //00707 1/21/2020 - Parking Lot Email notification - JC
            session.Session_Details_Full__c = sessionDetailsFull;
        }
    }
}