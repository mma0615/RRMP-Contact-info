trigger SurveyQuestionTrigger on Survey_Question__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    TriggerDispatcher.Run(new SurveyQuestionTriggerHandler());
}