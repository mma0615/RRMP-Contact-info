@istest
public with sharing class importDataFromCSVControllerTest 
{
    @isTest	
    static void importDataSaveFileTest() 
    {
		Survey__c surveyO = new Survey__c(name='Test Survey');
        insert surveyO;
        
        string surveyQuestions = '\"Name,Sorting_Order__c,Question_Type__c,Options__c\\r\\n' +
            'I was able to attend the entire scenario block.,1,Radio,\\"Yes\\nNo\\"\\r\\n\"';
        string surveyAnswers ='\"Response #,1\\r\\n249,Yes\\r\\n\"';
        
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new FlowCallout_Test.ValidCallout());
        
        // Test survey Answers w/o questions
        importDataFromCSVController.saveFile(null,surveyAnswers,surveyO.id);
        
        // Test survey Answers & questions
        importDataFromCSVController.saveFile(surveyQuestions,surveyAnswers,surveyO.id);
        
        // Test survey Answers w/o questions
        importDataFromCSVController.saveFile(surveyQuestions,null,surveyO.id);
        
        Test.stopTest();
        
    }
}