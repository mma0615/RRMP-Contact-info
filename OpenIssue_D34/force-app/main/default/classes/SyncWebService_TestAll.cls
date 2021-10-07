@IsTest
private class SyncWebService_TestAll {
    
    static Date yest = Date.today().addDays(-1);
    static string thisYear = String.valueOf(yest.year());
    
    static void createLog(String objName) {
        External_Access_Log__c log = new External_Access_Log__c(Status__c='Successful',Access_Date__c=yest,
          	Access_Server_Process__c='SyncWebService_TestAll',Rows_pulled__c=5,Authentication__c='Test Auth',
          	Object_Queried__c=objName);
        Insert log;
    }

    @isTest static void createTestData(){
        
        Cohort__c coh = new Cohort__c(Name=thisYear);
		insert coh;
        
        Contact c = new Contact(FirstName='Testron',LastName='Testarino',ApplydID__c='TestApplydID',
                                DPSID__c='TestDPSID',Birthdate=Date.valueOf('2000-01-12 9:30:00'),
                                Eligible_to_Apply_as__c='Test Eligible_to_Apply_as__c',
                                Applyd_Student_Notes__c='Test Notes',Cohort__c=coh.Id);
        insert c;
        FAFSA_Detail__c f = new FAFSA_Detail__c(FAFSA_Completed_Date__c=yest,
                                FAFSA_Proof_Submission_Date__c=yest,Student__c=c.Id);
        insert f;
        Application__c a = new Application__c(Application_Approval_Status__c='Complete',
                                     Student_Application_Submission_Notes__c='Test Notes',
                                     Application_Submission_Year__c='2018',
                                     On_Track_for_DSF_Award__c='On track for upcoming term',
                                     Lawful_Presence_Doc_Submission_Date__c=yest,
                                     Student_Name__c=c.Id);
        Insert a;
        Appeal__c p = new Appeal__c(Status__c='Approved',Appeal_Form_notes__c='Test notes',
                                    Application__c=a.Id);
        Student_Term__c st = new Student_Term__c(Student_Award_Status__c='Not Yet Determined',
                                       Part_Time_Enrollment_Form_Notes__c='Test Notes',
                                       isCurrentTerm__c=TRUE, Application__c=a.Id);
        insert st;
        Student_Term_Payments__c stp = new Student_Term_Payments__c(Student_Term__c=st.Id,
                                       Payment_Date__c=yest);
        insert stp;

    }
    
    @isTest static void testGetScholar(){
        createLog('Contacts');
        createTestData();
        RestRequest request = new RestRequest();
        request.requestURI = 'https://cs95.salesforce.com/services/apexrest/Scholars/v0.1/';
        request.remoteAddress = '127.0.0.1';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<Contact> scholars = SyncWebService_Scholar.getScholar();
        System.assert(scholars != null);
    }

    @isTest static void testGetFAFSA(){
        createLog('FAFSA Details');
        createTestData();
        RestRequest request = new RestRequest();
        request.requestURI = 'https://cs95.salesforce.com/services/apexrest/FAFSA/v0.1/';
        request.remoteAddress = '127.0.0.1';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<FAFSA_Detail__c> fafsaList = SyncWebService_FAFSA.getFAFSA();
        System.assert(fafsaList != null);
    }
    
    @isTest static void testGetApplication(){
        createLog('Applications');
        createTestData();
        RestRequest request = new RestRequest();
        request.requestURI = 'https://cs95.salesforce.com/services/apexrest/Applications/v0.1/';
        request.remoteAddress = '127.0.0.1';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<Application__c> apps = SyncWebService_Application.getApplication();
        System.assert(apps != null);
    }
    @isTest static void testGetAppeal(){
        createLog('Appeals');
        createTestData();
        RestRequest request = new RestRequest();
        request.requestURI = 'https://cs95.salesforce.com/services/apexrest/Appeal/v0.1/';
        request.remoteAddress = '127.0.0.1';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<Appeal__c> appeals = SyncWebService_Appeal.getAppeal();
        System.assert(appeals != null);
    }
    
    @isTest static void testGetStudentTerm(){
        createLog('Student Terms');
        createTestData();
        RestRequest request = new RestRequest();
        request.requestURI = 'https://cs95.salesforce.com/services/apexrest/StudentTerms/v0.1/';
        request.remoteAddress = '127.0.0.1';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<Student_Term__c> stList = SyncWebService_StudentTerm.getStudentTerm();
        System.assert(stList != null);
    }
    
    @isTest static void testGetStudentTermPayments(){
        createLog('Student Term Payments');
        createTestData();
        RestRequest request = new RestRequest();
        request.requestURI = 'https://cs95.salesforce.com/services/apexrest/TermPayments/v0.1/';
        request.remoteAddress = '127.0.0.1';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<Student_Term_Payments__c> stpList = SyncWebService_TermPayment.getTermPayments();
        System.assert(stpList != null);
    }
    
}