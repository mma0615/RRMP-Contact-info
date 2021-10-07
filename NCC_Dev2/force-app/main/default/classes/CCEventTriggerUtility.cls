public class CCEventTriggerUtility {
    public static void generateOrdWideEmail(List<Event__c> eventList){
        try{
            //Get the compass summary record for the Default Settings
            Compass_Setting__c compRec = [Select Id, Name, Email_Sender_Id__c, Email_Sender_Name__c FROM Compass_Setting__c WHERE Name =: 'Default Settings' LIMIT 1];
            
            for(Event__c  eventRec : eventList){
                //if the email sender id of event is null, always copy from the default settings.
                if(eventRec.Email_Sender_Id__c == NULL){
                    eventRec.Email_Sender_Id__c = compRec.Email_Sender_Id__c;
                }
                if(eventRec.Email_Sender_Name__c == NULL){
                    eventRec.Email_Sender_Name__c = compRec.Email_Sender_Name__c;
                }
            }  
        }catch(exception e){
            
        }
              
    }
}