@isTest public with sharing class CCESurveyControllerTest {
    @TestSetup
    static void makeData(){
        List<Apex_Trigger_Switch__c> switchRecs = TestDataFactory.createAllTriggerSwitch();
        insert switchRecs;
        Event__c newCampaign = TestFactory.createEvent('Test Campaign');
        newCampaign.Event_Id__c = 'zhCoziiBzcb';
        update newCampaign;
        Survey__c newSurvey = TestFactory.createSurvey(newCampaign.Id, 'Test Survey');
        Survey_Question__c sq = TestFactory.createSurveyQuestion(newSurvey.Id, 'What is your name?', 'Text', 1);
        Account newPersonAccount = TestFactory.createPersonAccount('John', 'Doe', 'j.doe@gmail.com');
        
        
        
    }

    // Test retrieving a survey with an existing record
    @isTest
    public static void testGetSurveyWithRecord(){

        Survey__c sv = [SELECT Id, Name, Campaign__c, Event__r.Event_Id__c, (SELECT Id, Description__c, Question_Type__c, Min_Value__c, Max_Value__c, Step__c, Options__c FROM Survey_Questions__r ORDER BY Sorting_Order__c)
                        FROM Survey__c WHERE Name = 'Test Survey' LIMIT 1];
        Test.startTest();
        String result = CCESurveyController.getSurvey(sv.Event__r.Event_Id__c);
        Test.stopTest();
        CCESurveyControllerHelper.SurveyWrapper sw = new CCESurveyControllerHelper.SurveyWrapper();
        CCESurveyControllerHelper.SurveyWrapper resultObj = (CCESurveyControllerHelper.SurveyWrapper)JSON.deserializeStrict(result, CCESurveyControllerHelper.SurveyWrapper.class);
        System.assertEquals(sv.Name, resultObj.Survey.Name);
        //System.assertEquals(sv.Event__c, resultObj.Survey.Event__c);
        System.assertEquals(sv.Survey_Questions__r[0].Description__c, resultObj.Survey.Survey_Questions__r[0].Description__c);
        System.assertEquals(sv.Survey_Questions__r[0].Question_Type__c, resultObj.Survey.Survey_Questions__r[0].Question_Type__c);
    }

     // Test retrieving a survey without an existing record
    @isTest
    public static void testGetSurveyWithoutRecord(){
        String invalidId = 'ya27nfa8042';
        Test.startTest();
        String result = CCESurveyController.getSurvey(invalidId);
        Test.stopTest();
        System.assertEquals(null, result);
    }
    

    // Test creating response with an existing contact
    @isTest
    public static void testCreateResponseWithExistingContact(){
        Contact c = TestFactory.createContact('John', 'Doe', 'john.doe@gmail.com');
        Survey__c sv = [SELECT Id, Event__r.Event_Id__c FROM Survey__c WHERE Name = 'Test Survey'];
        Survey_Question__c sq = TestFactory.createSurveyQuestion(sv.Id, 'Question Description', 'Text', 12);
        String contactStr = '{"firstname":"John","lastname":"Doe","email":"john.doe@gmail.com"}';
        String resultStr = '{"' + sq.Id + '":{"Question":"Select a value between 1 to 5","Answer":"4"}}';
        Event__c cp = [SELECT Id FROM Event__c WHERE Name = 'Test Campaign'];
        Test.setMock(HTTPCalloutMock.class, new FlowCallout_Test.ValidCallout());
        Test.startTest();
        CCESurveyControllerHelper.testCreateContact = true;
        CCESurveyController.createResponse(sv.Event__r.Event_Id__c, cp.Id, contactStr, resultStr, String.valueOf(System.today()));
        Test.stopTest();
        //Account testAccount = [SELECT Id FROM Account WHERE PersonEmail = 'j.doe@gmail.com' AND isPersonAccount = true];
        List<Survey_Response__c> srList = [SELECT Id, Contact__c, (SELECT Survey_Question__c, Question__c, Answer__c FROM Survey_Answers__r) FROM Survey_Response__c];
        System.assertEquals(srList[0].Contact__c, c.Id);
        System.assertEquals('Select a value between 1 to 5', srList[0].Survey_Answers__r[0].Question__c);
        System.assertEquals('4', srList[0].Survey_Answers__r[0].Answer__c);
        System.assertEquals(sq.Id, srList[0].Survey_Answers__r[0].Survey_Question__c);
    }
    
    // Test creating response with a new contact
    @isTest
    public static void testCreateResponseWithNewContact(){
        Survey__c sv = [SELECT Id, Event__r.Event_Id__c FROM Survey__c WHERE Name = 'Test Survey'];
        Survey_Question__c sq = TestFactory.createSurveyQuestion(sv.Id, 'Question Description', 'Text', 10);
        String contactStr = '{"firstname":"Jane","lastname":"Doe","email":"jane.doe@gmail.com"}';
        String resultStr = '{"' + sq.Id + '":{"Question":"Select a value between 1 to 5","Answer":"4"}}';
        Event__c cp = [SELECT Id FROM Event__c WHERE Name = 'Test Campaign'];
        Test.setMock(HTTPCalloutMock.class, new FlowCallout_Test.ValidCallout());
        Test.startTest();
        CCESurveyControllerHelper.testCreateContact = true;
        CCESurveyController.createResponse(sv.Event__r.Event_Id__c, cp.Id, contactStr, resultStr, String.valueOf(System.today()));
        Test.stopTest();
        Contact testContact = [SELECT Id FROM Contact WHERE Email = 'jane.doe@gmail.com' LIMIT 1];
        List<Survey_Response__c> srList = [SELECT Id, Contact__c, (SELECT Survey_Question__c, Question__c, Answer__c FROM Survey_Answers__r) FROM Survey_Response__c];
        System.assertEquals(srList[0].Contact__c, testContact.Id);
        System.assertEquals('Select a value between 1 to 5', srList[0].Survey_Answers__r[0].Question__c);
        System.assertEquals('4', srList[0].Survey_Answers__r[0].Answer__c);
        System.assertEquals(sq.Id, srList[0].Survey_Answers__r[0].Survey_Question__c);
    }

    // Test creating response with exception thrown
    @isTest
    public static void testCreateResponseWithException(){
        String contactStr = '{"firstname":"Jane","lastname":"Doe","email":"jane.doe@gmail.com"}';
        String resultStr = '{"a1U5B000000VhelUAC":{"Question":"Select a value between 1 to 5","Answer":"4"}}';
        Survey__c sv = [SELECT Id FROM Survey__c WHERE Name = 'Test Survey'];
        Event__c cp = [SELECT Id FROM Event__c WHERE Name = 'Test Campaign'];
        CCESurveyControllerHelper.throwFakeException = true;
        Test.startTest();
        try{
            CCESurveyController.createResponse(sv.Id, cp.Id, contactStr, resultStr, String.valueOf(System.today()));
        } catch(Exception e){
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }

    // Test retrieving survey answers with result
    @isTest
    public static void testGetSurveyAnswersWithResult(){
        Event__c cp = [SELECT Id FROM Event__c WHERE Name = 'Test Campaign'];
        Survey__c sv = [SELECT Id FROM Survey__c WHERE Name = 'Test Survey'];
        Account a = [SELECT Id FROM Account WHERE PersonEmail = 'j.doe@gmail.com'];
        Test.setMock(HTTPCalloutMock.class, new FlowCallout_Test.ValidCallout());
        Test.startTest();
        Survey_Response__c testSR = TestFactory.createSurveyResponse(cp.Id, sv.Id, a.Id);
        Survey_Answer__c testSA = TestFactory.createSurveyAnswer(testSR.Id, 'Do you have a car? ', 'Yes');
        String result = CCESurveyController.getSurveyAnswers(testSR.Id);
        Test.stopTest();
        List<Survey_Answer__c> saList = (List<Survey_Answer__c>)JSON.deserializeStrict(result, List<Survey_Answer__c>.class);
        System.assertEquals(1, saList.size());
    }

    // Test retrieving survey answers without result
    @isTest
    public static void testGetSurveyAnswersWithoutResult(){
        Event__c cp = [SELECT Id FROM Event__c WHERE Name = 'Test Campaign'];
        Survey__c sv = [SELECT Id FROM Survey__c WHERE Name = 'Test Survey'];
        Account a = [SELECT Id FROM Account WHERE PersonEmail = 'j.doe@gmail.com'];
        Survey_Response__c testSR = TestFactory.createSurveyResponse(cp.Id, sv.Id, a.Id);
        Test.startTest();
        String result = CCESurveyController.getSurveyAnswers(testSR.Id);
        Test.stopTest();
        System.assertEquals(null, result);
    }
    
    // Test retrieving content version with result
    @isTest
    public static void testGetContentVersionDataWithResult(){
        ContentVersion cv = new ContentVersion();
        cv.Description = 'Test Content Version';
        cv.Title = 'Test Content Version';
        cv.PathOnClient ='test';
        Blob b = Blob.valueOf('Unit Test Attachment Body');
        cv.VersionData = EncodingUtil.base64Decode('U29tZSBDb250ZW50');
        insert cv;
        CCESurveyControllerHelper.BlobWrapper bw = new CCESurveyControllerHelper.BlobWrapper();
        Test.startTest();
        bw = CCESurveyControllerHelper.getContentVersionData(cv.Id);
        Test.stopTest();
        System.assertEquals('U29tZSBDb250ZW50', bw.VersionData);
    }
    
    // Test retrieving content version without result
    @isTest
    public static void testGetContentVersionDataWithoutResult(){
        CCESurveyControllerHelper.BlobWrapper bw = new CCESurveyControllerHelper.BlobWrapper();
        Test.startTest();
        bw = CCESurveyControllerHelper.getContentVersionData('somerandomID');
        Test.stopTest();
        System.assertEquals(null, bw);
    }
    
    // Test checking if a contact exists
    @isTest
    public static void testCheckingExistingContact(){
        Contact c = TestFactory.createContact('Jane', 'Doe', 'jane.doe@gmail.com');
        Test.startTest();
        System.assertEquals(1, CCESurveyControllerHelper.checkContactExist('jane.doe@gmail.com').size()); 
        Test.stopTest();
    }
    
    // Test creating contact
    @isTest
    public static void testCreatingContact(){
        Test.startTest();
        String contactId = CCESurveyControllerHelper.createContact('Jane', 'Doe', 'jane.doe@gmail.com', 'Surgery');
        Test.stopTest();
        Contact c = [SELECT Id FROM Contact WHERE Firstname = 'Jane' AND Lastname = 'Doe' AND Email = 'jane.doe@gmail.com' AND Facility__c = 'Surgery' LIMIT 1];
        System.assertEquals(c.Id, contactId);
    }
    
    // Test creating contact with exception
    @isTest
    public static void testCreatingContactException(){
        CCESurveyControllerHelper.throwFakeException = true;
        Test.startTest();
        try{
            String contactId = CCESurveyControllerHelper.createContact('Jane', 'Doe', 'jane.doe@gmail.com', 'Surgery');
        } catch (Exception e){
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
    
    // Test creating person account with exception
    @isTest
    public static void testCreatingPersonAccountException(){
        CCESurveyControllerHelper.throwFakeException = true;
        Test.startTest();
        try{
            String personAccountId = CCESurveyControllerHelper.createPersonAccount('Jane', 'Doe', 'jane.doe@gmail.com', 'Surgery');
        } catch (Exception e){
            System.assertNotEquals(null, e);
        }
        Test.stopTest();
    }
}