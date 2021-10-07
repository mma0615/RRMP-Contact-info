public with sharing class AppealService {
  public static void setStudentForAppeal(list<Appeal__c> appealList) {
    Set<Id> appIds = new Set<Id>();
    for(Appeal__c appeal : appealList) {
      appIds.add(appeal.application__c);
    }
    map<Id,Application__c> additionalFields = new map<Id,Application__c>([Select Id, student_name__c From Application__c Where Id IN :appIds]);
    for(Appeal__c appeal : appealList) {
      if(additionalFields.get(appeal.application__c) != null) {
        appeal.student__c = additionalFields.get(appeal.application__c).student_name__c;
      }
    }
  }
}