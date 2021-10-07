// Testing survey Id: a3l030000004G2eAAE / eventId: a4q03000000H01lAAC
// 

public with sharing class reportCategory {

    private static List<id> surveyIds {get; set;}
    private static List<Report_Category__mdt> reportCategoryList {get; set;}
    private static List<Survey_Question__c> surveyQuestionList {get; set;}
    private static List<Survey_Answer__c > surveyAnswerList {get; set;}

    public static void init()
    {
        getCustomMetaData();
        getSurveyQuestions();
        getSurveyAnswers();
    }

    private static void getCustomMetaData()
    {
        reportCategoryList = [select label from Report_Category__mdt];
        System.debug('reportCategory ==> reportCategoryList: ' + reportCategoryList.size());
        System.debug('reportCategory ==> reportCategoryList: ' + reportCategoryList);
    }

    private static void getSurveyQuestions()
    {
        surveyQuestionList = [select id, Survey__c, Question_Type__c, Report_Category__c,
            Options__c
            from Survey_Question__c 
            where Question_Type__c = 'Radio' and survey__c in :surveyIds];
        
            System.debug('reportCategory ==> surveyQuestionList: ' + surveyQuestionList.size());
    }

    private static void getSurveyAnswers()
    {
        surveyAnswerList = [select id, Question__c, Answer__c, Survey_Question__c, 
            Survey_Question__r.survey__c, Survey_Question__r.Options__c,
            Survey_Question__r.Question_Type__c
            from Survey_Answer__c  
            where Survey_Question__r.Question_Type__c = 'Radio' and 
                Survey_Question__r.survey__c in :surveyIds];
        
            System.debug('reportCategory ==> surveyAnswerList: ' + surveyQuestionList.size());
    }

    /*********** upReportCategory ***********/
    @AuraEnabled
    public static String upReportCategory(id recordId) 
    {
        List<survey__c> surveyList = new List<survey__c>();
        if (recordId.getSObjectType().getDescribe().getName() == 'Event__c')
            surveyList = [select id from Survey__c where Event__c = :recordId];
        else if (recordId.getsobjecttype().getDescribe().getName() == 'Journey__c')
            surveyList = [select id from Survey__c where Journey__c = :recordId];
        else if (recordId.getsobjecttype().getDescribe().getName() == 'Campaign__c')
            surveyList = [select id from Survey__c where Campaign_1__c = :recordId];

        surveyIds = new List<id>();
        for (survey__c oSurvey : surveyList)
            surveyIds.add(oSurvey.id);

        if(surveyIds.size() <> 0)
        {
            init();

            // set up report category
            for (Survey_Question__c oSurvey_Question : surveyQuestionList)
            {
                oSurvey_Question.Report_Category__c = setRptCategory(oSurvey_Question.Options__c);
            }

            if (surveyQuestionList.size() > 0)
                update surveyQuestionList;

            // set sort order
            for (Survey_Answer__c oSurveyAnswer : surveyAnswerList)
            {
                oSurveyAnswer.Report_Answer__c = 
                    setSortOrder(oSurveyAnswer.Survey_Question__r.Options__c, 
                        oSurveyAnswer.Answer__c);
            }

            if (surveyAnswerList.size() > 0)
                update surveyAnswerList;

        }

        return '';
    }

    private static string setRptCategory(string optionsStr)
    {
        string category = '';

        for (Report_Category__mdt mdtRptCat : reportCategoryList)
        {
            if (optionsStr.startsWithIgnoreCase(mdtRptCat.label) )
                category = mdtRptCat.label;
        }
        System.debug('reportCategory ==> setRptCategory: ' + category + ' / ' + optionsStr);
        return category;
    }

    private static string setSortOrder(string optionsStr, string answerStr)
    {
        string sortOrder = '';
        Integer cnt = 1;
        Map<string,string> answerMap = new Map<string,string>();
        answerStr = answerStr.replaceAll('[^a-zA-Z0-9]', '');

        for (string opt : optionsStr.split('\n') )
        {
            //System.debug('reportCategory ==> opt: ' + opt);
            opt = opt.replaceAll('[^a-zA-Z0-9]', '');
            answerMap.put(opt, cnt + '. ' + opt);
            cnt += 1;
        }

        //System.debug('reportCategory ==> setSortOrder: ' + answerStr + ' / ' + answerMap); 
        if (answerMap.get(answerStr) == null)
            sortOrder = answerStr;
        else 
            sortOrder = answerMap.get(answerStr);

        System.debug('reportCategory ==> setSortOrder: ' + sortOrder);   
        return sortOrder;
    }
}