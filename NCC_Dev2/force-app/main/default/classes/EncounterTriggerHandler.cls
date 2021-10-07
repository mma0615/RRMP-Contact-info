public class EncounterTriggerHandler {

     public static void onBeforeInsert(List<Encounter__c> newEncounterList, Map<Id,Encounter__c> newEncounterMap, List<Encounter__c> oldEncounterList, Map<Id,Encounter__c> oldEncounterMap){
        
     }
    
     public static void onAfterInsert(List<Encounter__c> newEncounterList, Map<Id,Encounter__c> newEncounterMap, List<Encounter__c> oldEncounterList, Map<Id,Encounter__c> oldEncounterMap){
         List<TeleMeet__c> connectList = new List<TeleMeet__c>();
         List<Encounter__c> encounterList = [Select Id, Encounter_Date__c, Reason__c, Type__c, Resource__c, Contact__c, Contact__r.FirstName, Contact__r.LastName From Encounter__c WHERE Id IN :newEncounterList];
         for(Encounter__c e: encounterList){
             if(e.Contact__c != null){
                 e.Name = (String.valueOf(e.Encounter_Date__c)).LEFT(10) + ' ' + e.Contact__r.FirstName + ' ' + e.Contact__r.LastName +' ' + e.Type__c;
             }
             else{
                 e.Name = (String.valueOf(e.Encounter_Date__c)).LEFT(10) + ' ' + e.Type__c;
             }
             if(e.Type__c == 'Telehealth'){
                 TeleMeet__c tel = new TeleMeet__c();
                 tel.Contact__c = e.Contact__c;
                 tel.Resource_Contact__c = e.Resource__c;
                 tel.Encounter__c = e.Id;
                 tel.Status__c = 'Draft';
                 tel.Target_Appointment_Date__c = e.Encounter_Date__c;
                 tel.Start_Date_Time__c = e.Encounter_Date__c;
                 tel.End_Date_Time__c = e.Encounter_Date__c;
                 tel.Subject__c = e.Reason__c;
                 tel.Type__c = 'Telehealth Meet';
                 connectList.add(tel);
             }
         }
         if(!connectList.isEmpty()){
             insert connectList;
         }
         update encounterList;
     }
}