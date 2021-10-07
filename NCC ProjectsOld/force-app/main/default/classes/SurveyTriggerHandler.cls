public with sharing class SurveyTriggerHandler implements ITriggerHandler{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getInstance().SurveyTriggerDisabled__c)
            return true;
        else
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) {
        // Check if Active__c is checked
        List<Survey__c> surveysToProcess = new List<Survey__c>();
        for (Survey__c s : (List<Survey__c>)newItems){
            if (s.Active__c) surveysToProcess.add(s);
        }
        SurveyTriggerHelper.checkExistingActiveSurveys(surveysToProcess);
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // Check if the Active__c field has been updated and checked
        Map<Id, Survey__c> newSurveys = (Map<Id, Survey__c>)newItems;
        Map<Id, Survey__c> oldSurveys = (Map<Id, Survey__c>)oldItems;
        List<Survey__c> surveysToProcess = new List<Survey__c>();
        for (Survey__c s : newSurveys.values()){
            if ((s.Active__c == true) && (s.Active__c != oldSurveys.get(s.Id).Active__c)){
                surveysToProcess.add(s);
            }
        }
        SurveyTriggerHelper.checkExistingActiveSurveys(surveysToProcess);
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {}
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}