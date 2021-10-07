public with sharing class SurveyTriggerHelper {
    
    public static void checkExistingActiveSurveys(List<Survey__c> surveys){
        //UPDATED BY JL 20201224 as per 00608: https://ulapp-developers.force.com/projects/s/detail/a0x3k00001UqIyAAAV
        //OLD
        /*
        Map<Id, Survey__c> campaignIdSurveyMap = new Map<Id, Survey__c>();
        for (Survey__c s : surveys){
            campaignIdSurveyMap.put(s.Campaign__c, s);
        }

        Map<Id, Integer> campaignCountChildrenSurveyMap = new Map<Id, Integer>();
        for (Event__c c: [SELECT Id, (SELECT Id FROM Surveys__r WHERE Active__c = TRUE) FROM Event__c WHERE Id IN: campaignIdSurveyMap.keySet()]){
            campaignCountChildrenSurveyMap.put(c.Id, c.Surveys__r.size());
        }

        for (Id campaignId : campaignCountChildrenSurveyMap.keySet()){
            if (campaignCountChildrenSurveyMap.get(campaignId) > 0){
                campaignIdSurveyMap.get(campaignId).Active__c.addError('This event/session already has an active survey. Each event/session can only have 1 active survey at a time. Please check again.');
            }
        }
        */
        //NEW
        Map<Id, Survey__c> eventnIdSurveyMap = new Map<Id, Survey__c>();
        for (Survey__c s : surveys){
            eventnIdSurveyMap.put(s.Event__c, s);
        }
        system.debug('*****JL[SurveyTriggerHelper](checkExistingActiveSurveys)eventnIdSurveyMap-->'+eventnIdSurveyMap);

        Map<Id, Integer> eventCountChildrenSurveyMap = new Map<Id, Integer>();
        for (Event__c c: [SELECT Id, (SELECT Id FROM Surveys__r WHERE Active__c = TRUE) FROM Event__c WHERE Id IN: eventnIdSurveyMap.keySet()]){
            eventCountChildrenSurveyMap.put(c.Id, c.Surveys__r.size());
        }
        system.debug('*****JL[SurveyTriggerHelper](checkExistingActiveSurveys)eventCountChildrenSurveyMap-->'+eventCountChildrenSurveyMap);

        for (Id eventId : eventCountChildrenSurveyMap.keySet()){
            if (eventCountChildrenSurveyMap.get(eventId) > 0){
                eventnIdSurveyMap.get(eventId).Active__c.addError('This event/session already has an active survey. Each event/session can only have 1 active survey at a time. Please check again.');
            }
        }
    }
}