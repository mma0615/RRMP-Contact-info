public without sharing class CCESurveyController {
    // GET SURVEY RECORD DETAILS
    @AuraEnabled (cacheable = true)
    public static String getSurvey(string eventId){
        if (String.isBlank(eventId)) return null;
        String surveyStr = CCESurveyControllerHelper.getSurveyHelper(eventId);
        return surveyStr;
    }

    // CREATE SURVEY RESPONSE RECORD
    @AuraEnabled
    public static void createResponse(String eventId, String campaignId, String contactDetails, String result, String dateOfSession){
        if (String.isBlank(contactDetails) || String.isBlank(result) || String.isBlank(eventId) || String.isBlank(dateOfSession)) return;
        CCESurveyControllerHelper.createResponseHelper(eventId, campaignId, contactDetails, result, dateOfSession);
    }

    // GET SURVEY ANSWERS
    @AuraEnabled (cacheable = true)
    public static String getSurveyAnswers(String surveyResponseId){
        if (String.isBlank(surveyResponseId)) return null;
        return CCESurveyControllerHelper.getSurveyAnswersHelper(surveyResponseId);
    }

    // GET FOOTER CONTENT
    /*@AuraEnabled (cacheable = true)
    public static String getFooterContent(){
        Community_Setting__mdt cs = [SELECT Value__c FROM Community_Setting__mdt WHERE DeveloperName = 'CCE_Survey_Footer' LIMIT 1];
        return cs.Value__c;
    }*/
}