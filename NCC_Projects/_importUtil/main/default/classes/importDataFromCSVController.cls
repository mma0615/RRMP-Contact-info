/**
 * importDataFromCSVController
 * @author          Minh Ma 
 * @date            07/10/2021
 * @description     this is to import survey questions & answers into Survey_Question__c, Survey_Response__c, Survey_Answer__c
 *      input files is from ONLY csv file format.
 *  
 *      Testing survey Id: a3l1F000000UUWrQAO      
 *      select id, Survey__c, Survey__r.Name, Description__c, Sorting_Order__c, Question_Type__c, Options__c from Survey_Question__c where Survey__c in ('a3l1F000000UUWrQAO', 'a3l1F000000cKgLQAU') order by Survey__c 
 * 
 *      select id, name, Survey__c, Survey__r.Name, Session__c, Response_Number__c from Survey_Response__c where Survey__c in ('a3l1F000000UUWrQAO', 'a3l1F000000cKgLQAU') order by Survey__c, Response_Number__c 
 * 
 *      select id, name, Question__c, Survey_Question__c, Survey_Question__r.Name, Survey_Response__c, Survey_Response__r.Name, Answer__c, Report_Answer__c from Survey_Answer__c where Survey_Question__r.Survey__c in ('a3l1F000000UUWrQAO', 'a3l1F000000cKgLQAU') order by Survey_Question__r.Survey__c
 * 
 *      select id, name, Survey_Answer__c, createddate from Survey_Answer_Sentiment__c
 * 
 * Update History:
 * 07/10/2021 - Initial Version
 * 08/25/2021 - Added routines for loading answers with multiple events
 */

public with sharing class importDataFromCSVController 
{
    private static Id surveyId  {get; set;}
    private static survey__c survey  {get; set;}
    private static List<string> errMessage {get; set;}

    private static set<string> errorSet {get;set;}
    private static set<string> surveyIdSet {get;set;}
    private static set<string> surveyNameSet {get; set;}
    private static set<string> eventIdSet {get; set;}
    private static set<string> eventNameSet {get;set;}
    private static set<string> surveyResponseNumberSet {get;set;}
    
    private static map<string, Survey__c> surveyEventNameMap {get; set;}
    private static map<string, Survey__c> surveyMap {get; set;}
    private static map<string, Event__c> eventMap {get; set;}
    private static map<string, Session__c> sessionMap {get; set;}

    private static list<answerRow> answerRowList {get; set;}
    private static list<Survey_Question__c> Survey_QuestionToInsert {get; set;}
    private static list<Survey_Response__c> Survey_ResponseToInsert {get; set;}
    private static list<Survey_Answer__c> Survey_AnswerToInsert {get; set;}
    

    @AuraEnabled
    public static list<string> saveFile(String fileDataQ, string fileDataA, string recordId) 
    {
        errMessage = new list<string>();

        System.debug('***** recordId: ' + recordId);
        System.debug('***** Questions: ' + fileDataQ);
        System.debug('***** Answers: ' + fileDataA);

        surveyId = recordId;
        survey = [select id, name, event__c from survey__c where id= :recordId];

        List<Survey_Question__c> Survey_QuestionList = 
            [select id, name from Survey_Question__c where Survey__c = :recordId];

        /**** Process Survey Answer */
        if (errMessage.size() == 0 &&
            !String.isEmpty(fileDataA) )
        {
            if (Survey_QuestionList.size() == 0 &&
                String.isEmpty(fileDataQ))
                errMessage.add('MUST enter Survey Questions first...');
        }

        /**** Process Survey Questions */
        if (errMessage.size() == 0 )
            if (!String.isEmpty(fileDataQ) )
            {
                if (Survey_QuestionList.size() != 0)
                    errMessage.add('Questions were already entered for this Survey...');
                else 
                    prepSurvey(fileDataQ, 'Questions');    
            }

        /**** Process Survey Answers */
        if (errMessage.size() == 0 )
            if (!String.isEmpty(fileDataA) )
                prepSurvey(fileDataA, 'Answers'); 

        System.debug('errMessage: ' + errMessage);

        if (errMessage.size() == 0 )
            return null;
        else
            return errMessage;
    }

    @AuraEnabled
    public static list<string> loadAnswersAll(string fileDataA) 
    {
        errMessage = new list<string>();
        errorSet = new set<string>();

        System.debug('***** Answers: ' + fileDataA);

        /**** Process Survey Answers */
        if (errMessage.size() == 0 )
            if (!String.isEmpty(fileDataA) )
                prepSurvey(fileDataA, 'AnswersAll'); 

        System.debug('errMessage: ' + errMessage);

        if (errMessage.size() == 0 )
            return null;
        else
            return errMessage;
    }

    private static void prepSurvey(string fileData, string surveyQorA)
    {
        Survey_QuestionToInsert = new list<Survey_Question__c>();
        Survey_ResponseToInsert = new list<Survey_Response__c>();
        Survey_AnswerToInsert = new list<Survey_Answer__c>();

        answerRowList = new list<answerRow>();
        surveyNameSet = new set<string>();
        eventNameSet = new set<string>();
        surveyIdSet = new set<string>();

        System.debug('fileData: ' + fileData);
        String myFile = JSON.deserializeUntyped(fileData).toString();
        System.debug('myFile: ' + myFile);
        list<String> lstCSVLines = myFile.split('\r\n');
        //System.debug('myFile: ' + myFile);
        
        for(Integer i = 1; i < lstCSVLines.size(); i++)
        {
            String csvLine = lstCSVLines[i];
            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;

            while(csvLine.indexOf('"') > -1)
            {            
                if(startIndex == null)
                {
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                }
                else
                {
                    if(endIndex == null)
                    {
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                    }
                }
                
                if(startIndex != null && endIndex != null)
                {
                    String sub = csvLine.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                    startIndex = null;
                    endIndex = null;
                }
            }

            List<String> csvRowData = new List<String>();
            for(String column : csvLine.split(','))
            {
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                csvRowData.add(column);
            }

            if (surveyQorA == 'Questions')
            {
                System.debug('Question ==> csvRowData.size(): ' + csvRowData.size());
                loadSurveyQuestions(csvRowData);
            }
            /* 
            else if (surveyQorA == 'Answers')
            {
                System.debug('Answer ==> csvRowData.size(): ' + csvRowData.size());
                loadSurveyAnswers(csvRowData);
            }
            */
            else if (surveyQorA == 'AnswersAll')
            {
                /* Load all answers into answerRowList */
                System.debug('***** Answer ==> csvRowData.size(): ' + csvRowData.size());
                loadAnswerRow(csvRowData);
                System.debug('***** Answer ==> answerRowList1: ' + answerRowList.size() );
            }  

            System.debug('csvLine: ' + csvLine);
            System.debug('------------------------------');
        }

        if (surveyQorA == 'AnswersAll')
        {
            loadSurveyAnswersAll();
        }

        try 
        {
            System.debug('***** Survey_QuestionToInsert: ' + Survey_QuestionToInsert.size() );
            if (Survey_QuestionToInsert.size() > 0)
                Insert Survey_QuestionToInsert;

            System.debug('***** Survey_ResponseToInsert: ' + Survey_ResponseToInsert.size() );
            if (Survey_ResponseToInsert.size() > 0)
                Insert Survey_ResponseToInsert;

            System.debug('***** Survey_AnswerToInsert: ' + Survey_AnswerToInsert.size() );
            if (Survey_AnswerToInsert.size() > 0)
            {
                prepQuestionAnswers();
                //Update Survey_ResponseToInsert;
                Insert Survey_AnswerToInsert;
            }
        } 
        catch (Exception e) 
        {
            System.debug('***** e.getMessage(): ' + e.getMessage() );
            errMessage.add(e.getMessage());

        }            
    }

    private static void loadSurveyQuestions(List<String> csvRowData)
    {
        Survey_Question__c Survey_QuestionObj = new Survey_Question__c();
        Survey_QuestionObj.Description__c = csvRowData[0];
        Survey_QuestionObj.Sorting_Order__c = decimal.valueOf(csvRowData[1]);
        Survey_QuestionObj.Question_Type__c = csvRowData[2];
        if (csvRowData.size() == 4)
            Survey_QuestionObj.Options__c = csvRowData[3];
        Survey_QuestionObj.Survey__c = surveyId;
        Survey_QuestionToInsert.add(Survey_QuestionObj);
        if (Survey_QuestionObj.Question_Type__c == 'Radio')
            Survey_QuestionObj.Report_Category__c = 
            getString(Survey_QuestionObj.Options__c,'\n');
        System.debug('Survey_QuestionObj: ' + Survey_QuestionObj);

    }

    /* Load all answers into answerRowList */
    private static void loadAnswerRow(List<String> csvRowData)
    {
        answerRow answerRowObj = new answerRow();
        answerRowObj.responseNumber = csvRowData[0];
        answerRowObj.surveyName = csvRowData[1];
        surveyNameSet.add(csvRowData[1]);
        answerRowObj.eventName = csvRowData[2];
        if (!eventNameSet.contains(answerRowObj.eventName))
            eventNameSet.add(answerRowObj.eventName);
        answerRowObj.sessionName = csvRowData[3];
        answerRowObj.rowAnswers = csvRowData;
        answerRowList.add(answerRowObj);
    }


    private static void loadSurveyAnswersAll()
    {
        getSurveyMap();
        getEventMap();
        surveyResponseNumber();
        getSessionMap();

        validateAnswer();
        if (errMessage.size() == 0)
        {
            validateSurveyEventName();
            validateSurveyQuestionExist();
        }

        if (errMessage.size() == 0)
        {
            //System.debug('surveyResponseNumberSet: ' + surveyResponseNumberSet);
            for(answerRow answerRowO : answerRowList)
            {
                /* Check if responseNumber already migrated */
                //System.debug('surveyResponseNumberSet: ' + surveyResponseNumberSet);
                if (!surveyResponseNumberSet.contains(answerRowO.responseNumber))
                {
                    //System.debug('surveyResponseNumberSet: ' + answerRowO.responseNumber);
                    loadSurveyAnswers(answerRowO);
                }
            }
        }

    }

    private static void loadSurveyAnswers(answerRow answerRowObj)
    {
        list<string> csvRowData = answerRowObj.rowAnswers;
        
        System.debug('Survey_QuestionObj: ');
        Survey_Response__c Survey_ResponseObj = new Survey_Response__c();
        Survey_Answer__c Survey_AnswerObj;

        Survey__c SurveyO = surveyEventNameMap.get(answerRowObj.surveyName + 
                ',,,' + answerRowObj.eventName);

        Survey_ResponseObj.Survey__c = SurveyO.Id;
        if (!String.isEmpty(answerRowObj.sessionName) &&
            sessionMap.get(SurveyO.Event__c + answerRowObj.sessionName) != null)
            Survey_ResponseObj.Session__c = sessionMap.get(SurveyO.Event__c + answerRowObj.sessionName).Id;
        Survey_ResponseObj.Response_Number__c = csvRowData[0];
        System.debug('Survey_QuestionObj ==> Survey_ResponseObj ' + Survey_ResponseObj);
        Survey_ResponseToInsert.Add(Survey_ResponseObj);
        Integer ix = 0;
        for (Integer i = 4; i < csvRowData.size(); i++) 
        {
            ix += 1;
            Survey_AnswerObj = new Survey_Answer__c();
            Survey_AnswerObj.Answer__c = getString(csvRowData[i],',');
            System.debug('Survey_QuestionObj ==> csvRowData[i]: ' + Survey_AnswerObj.Answer__c );
            if (!String.isEmpty(Survey_AnswerObj.Answer__c) )
            {
                Survey_AnswerObj.Question__c = String.valueOf(ix);
                Survey_AnswerObj.Survey_Question__c = Survey_ResponseObj.Survey__c; // Place holder Survey Id
                Survey_AnswerObj.Survey_Response__c = null;
                Survey_AnswerObj.Report_Answer__c = csvRowData[0];                  // place holder Response number
                Survey_AnswerToInsert.Add(Survey_AnswerObj);
            }
            System.debug('Survey_QuestionObj ==> csvRowData[0]: ' + csvRowData[0]);
        }
    }

    private static void getSurveyMap()
    {
        eventIdSet = new set<string>();
        surveyEventNameMap = new map<string, Survey__c>();
        surveyMap = new map<string, Survey__c>();
        for (Survey__c surveyO : [select id, name, Event__c, Event__r.Name from survey__c where name in :surveyNameSet])
        {
            surveyIdSet.add(surveyO.Id);
            eventIdSet.add(surveyO.event__c);
            surveyEventNameMap.put(surveyO.Name + ',,,' + surveyO.Event__r.Name, surveyO);
            surveyMap.put(surveyO.Name, surveyO);
        }
    }

    private static void getEventMap()
    {
        eventMap = new map<string, Event__c>();
        for (Event__c eventO : [select id, name from event__c where name in :eventNameSet])
        {
            eventMap.put(eventO.Name, eventO);
        }
    }

    private static void surveyResponseNumber()
    {
        surveyResponseNumberSet = new set<string>();
        for (Survey_Response__c Survey_ResponseO : 
            [select id, name, Survey__c, Survey__r.Name, Event__c, Event__r.Name, Response_Number__c 
                from Survey_Response__c where Survey__r.Name in :surveyNameSet])
        {
            surveyResponseNumberSet.Add(Survey_ResponseO.Response_Number__c);
        }
        
    }

    private static void getSessionMap()
    {
        SessionMap = new map<string, Session__c>();
        for (Session__c SessionO : [select id, name, Event__c, Event__r.Name
            from Session__c where Event__r.Name in :eventMap.keyset()])
        {
            SessionMap.put(SessionO.Event__c + SessionO.Name, SessionO);
        }
    }

    /* Iterate through each answer validating Survey & Event name */
    private static void validateAnswer()
    {
        for(answerRow answerRowO : answerRowList) 
        {
            if (surveyMap.get(answerRowO.surveyName) == null &&
                !errorSet.contains(answerRowO.surveyName))
                {
                    errorSet.add(answerRowO.surveyName);
                    errMessage.Add('Error: Survey ==> \'' + answerRowO.surveyName + '\' not found. Please add survey...');
                }
                
            if (eventMap.get(answerRowO.eventName) == null &&
                !errorSet.contains(answerRowO.eventName))
                {
                    errorSet.add(answerRowO.eventName);
                    errMessage.Add('Error: Event ==> \'' + answerRowO.eventName + '\' not found. Please add Event...');
                } 
        }
    }

    /* Iterate through each answer validating Survey & Event name */
    private static void validateSurveyEventName()
    {
        System.debug('*** validateSurveyEventName: ');
        for(answerRow answerRowO : answerRowList) 
        {
            if (surveyEventNameMap.get(answerRowO.surveyName + ',,,' + answerRowO.eventName) == null &&
                !errorSet.contains(answerRowO.surveyName + ',,,' + answerRowO.eventName))
                {
                    errorSet.add(answerRowO.surveyName + ',,,' + answerRowO.eventName);
                    errMessage.Add('Error: No Survey \'' + answerRowO.surveyName +
                        '\' created for Event \'' + answerRowO.eventName + 
                        '\' Please add Survey and link to the event.');
                }    
        }
    }

    private static void validateSurveyQuestionExist()
    {
        System.debug('*** validateSurveyQuestionExist: ');
        set<id> responseSurveySet = new set<id> ();
        AggregateResult[] groupedResults = 
            [select Survey__c, count(id) from Survey_Question__c 
                where Survey__c in :surveyIdSet
                group by Survey__c];
        for (AggregateResult ar : groupedResults)  
        {
            responseSurveySet.add((id)ar.get('Survey__c'));
        }

        System.debug('*** responseSurveySet: ' + responseSurveySet);

        for(survey__c surveyO : surveyEventNameMap.values()) 
        {
            System.debug('*** surveyO.Name: ' + surveyO.Name);
            if (!responseSurveySet.contains(surveyO.Id) &&
                !errorSet.contains(surveyO.Id))
                {
                    errorSet.add(surveyO.Id);
                    errMessage.Add('Error: Questions are not entered for Survey \'' + surveyO.Name +
                        '\' and Event \'' + surveyO.event__r.Name + 
                        '\' Please load Questions first.');
                }    
        }
    }


    private static void prepQuestionAnswers()
    {
        // populating survey question map
        map<string, Survey_Question__c> Survey_QuestionMap = new map<string, Survey_Question__c>();
        for (Survey_Question__c Survey_QuestionObj : 
            [select id, Survey__c, Survey__r.Name, Description__c, Question_Type__c, Sorting_Order__c, Options__c
                from Survey_Question__c where Survey__r.Name = :surveyNameSet])
        {
            Survey_QuestionMap.put(Survey_QuestionObj.Survey__c + 
                String.valueOf(Survey_QuestionObj.Sorting_Order__c), 
                Survey_QuestionObj);
        }

        // populating survey response map
        map<String, Survey_Response__c> Survey_ResponseMap = new map<String, Survey_Response__c>();
        for (Survey_Response__c Survey_ResponseObj : Survey_ResponseToInsert)
        {
            Survey_ResponseMap.put(Survey_ResponseObj.Response_Number__c, Survey_ResponseObj);
            //Survey_ResponseObj.Response_Number__c = null;
            System.debug('*** Obj Survey_ResponseObj: ' + Survey_ResponseObj);
        }


        /*
        Survey_AnswerObj.Question__c = String.valueOf(ix);
        Survey_AnswerObj.Survey_Question__c = Survey_ResponseObj.Survey__c; // Place holder Survey Id
        Survey_AnswerObj.Report_Answer__c = csvRowData[0];                  // place holder Response number
        */

        // preparing survey answer
        for (Survey_Answer__c Survey_AnswerObj : Survey_AnswerToInsert)
        {
            System.debug('**** Obj Survey_AnswerObj.Report_Answer__c: ' + Survey_AnswerObj.Report_Answer__c);
            
            Survey_Question__c Survey_QuestionObj = 
                Survey_QuestionMap.get(Survey_AnswerObj.Survey_Question__c + Survey_AnswerObj.Question__c);
            System.debug('**** Obj Survey_QuestionObj: ' + Survey_QuestionObj);

            Survey_Response__c Survey_ResponseObj = 
                Survey_ResponseMap.get(Survey_AnswerObj.Report_Answer__c);
            System.debug('**** Obj Survey_ResponseObj: ' + Survey_ResponseObj);

            Survey_AnswerObj.Question__c = Survey_QuestionObj.Description__c;
            Survey_AnswerObj.Survey_Question__c = Survey_QuestionObj.Id;
            Survey_AnswerObj.Survey_Response__c = Survey_ResponseObj.Id;
            Survey_AnswerObj.Report_Answer__c = setSortOrder(Survey_QuestionObj.Options__c,
                                                            Survey_AnswerObj.Answer__c);
            System.debug('**** Obj Survey_AnswerObj: ' + Survey_AnswerObj);
            //Survey_AnswerObj.Report_Answer__c = csvRowData[0];
        }

    }

    private static string getString (string rptOptions, string separator)
    {
        string option;
        return option = rptOptions.split(separator)[0];
    }

    private static string setSortOrder(string optionsStr, string answerStr)
    {
        System.debug('reportCategory ==> optionsStr: ' + optionsStr);
        System.debug('reportCategory ==> answerStr: ' + answerStr);

        string sortOrder = null;
        if (!String.isEmpty(optionsStr))
        {
            Integer cnt = 1;
            Map<string,string> answerMap = new Map<string,string>();
            answerStr = answerStr.replaceAll('[^a-zA-Z0-9 ]', '').trim();

            for (string opt : optionsStr.split('\n') )
            {
                //System.debug('reportCategory ==> opt: ' + opt);
                opt = opt.replaceAll('[^a-zA-Z0-9 ]', '').trim();
                answerMap.put(opt, cnt + '. ' + opt);
                cnt += 1;
            }

            //System.debug('reportCategory ==> setSortOrder: ' + answerStr + ' / ' + answerMap); 
            if (answerMap.get(answerStr) == null)
                sortOrder = answerStr;
            else 
                sortOrder = answerMap.get(answerStr);
        }

        System.debug('reportCategory ==> setSortOrder: ' + sortOrder);   
        return sortOrder;
    }
    


    /*****
     * answerRow
    */
    public with sharing class answerRow
    {
        private string responseNumber;
        private string surveyName;
        private string eventName;
        private string sessionName;
        private List<String> rowAnswers;

        public answerRow() {}
    }

}