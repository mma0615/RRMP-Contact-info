public with sharing class SurveyQuestionTriggerHandler implements ITriggerHandler{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getInstance().SurveyQuestionTriggerDisabled__c)
            return true;
        else
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) {
        SurveyQuestionTriggerHelper.checkDuplicateSortingOrder((List<Survey_Question__c>)newItems);
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // Check if the sorting order has been updated
        Map<Id, Survey_Question__c> newQuestions = (Map<Id, Survey_Question__c>)newItems;
        Map<Id, Survey_Question__c> oldQuestions = (Map<Id, Survey_Question__c>)oldItems;
        List<Survey_Question__c> questionsToProcess = new List<Survey_Question__c>();
        for (Survey_Question__c sq : newQuestions.values()){
            if (sq.Sorting_Order__c != oldQuestions.get(sq.Id).Sorting_Order__c){
                questionsToProcess.add(sq);
            }
        }
        SurveyQuestionTriggerHelper.checkDuplicateSortingOrder(questionsToProcess);
    }
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {}
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}