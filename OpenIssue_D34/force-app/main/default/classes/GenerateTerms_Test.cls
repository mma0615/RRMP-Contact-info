@isTest
private class GenerateTerms_Test {
    private static list<Contact> createTestContacts(list<Account> accList) {
        Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id genRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId();
        list<Contact> objList = new list<Contact>();
        for(integer i = 0; i < accList.size(); i++) {
            Contact obj = new Contact();
            obj.lastName = 'Contact ' + i;
            obj.firstName = 'Test';
            obj.recordTypeId = stRT;
            objList.add(obj);
        }
        for(integer i = 0; i < accList.size(); i++) {
            Contact obj = new Contact();
            obj.lastName = 'Uni User ' + i;
            obj.firstName = 'Test';
            obj.accountId = accList[i].Id;
            obj.recordTypeId = genRT;
            objList.add(obj);
        }
        insert objList;
        return objList;
    }
    
    private static list<Account> createTestAccounts(integer testSize) {
        Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
        list<Account> objList = new list<Account>();
        for(integer i = 0; i < testSize; i++) {
            Account obj = new Account();
            obj.recordTypeId = collRT;
            obj.name = 'Test Account ' + i;
            objList.add(obj);
        }
        //create a single test account for previous student term -for code coverage
        Account obj1 = new Account();
        obj1.recordTypeId = collRT;
        obj1.name = 'StudentTerm Account' ;
        objList.add(obj1);  
        insert objList;
        return objList;
    }
    
    private static list<Application__c> createTestApplications(list<Contact> conList, list<Account> acctlist) {
        Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Integer yearToCreate = Date.today().month() > 4 ? Date.today().year() : Date.today().addYears(-1).year();
        list<Application__c> objList = new list<Application__c>();
        for(integer i = 0; i < conList.size(); i++) {
            if(conList[i].recordTypeId == stRT) {
                Application__c obj = new Application__c();
                obj.student_name__c = conList[i].Id;
                obj.application_status__c = 'Finalist';
                obj.Application_Submission_Year__c = String.valueOf(yearToCreate);
                obj.School_Name__c = acctlist[i].Id;
                objList.add(obj);
            }
        }
        insert objList;
        return objList;
    }

    //the test student terms is for code coverage for the logic with the previous student term    
    private static List<Student_Term__c> createTestStudent_Terms(List<Application__c> appList, List<Account> uniList) {
        Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
        List<Student_Term__c> objList = new List<Student_Term__c>();
        for (Integer i = 0; i < appList.size(); i++) {
            Student_Term__c obj = new Student_Term__c();
            obj.college_or_university__c = uniList[i].Id;
            obj.Application__c = appList[i].Id;
            obj.Term_Semester__c = Math.mod(i, 2) == 0 ? 'Fall' : 'Spring';
            obj.Term_Eligibility_Status__c = 'Finalist';
            obj.student_id_at_college__c = String.valueOf(Math.round(Math.random() * 10000));
            obj.Rec_d_Pymt_Previous_Term__c = 'Yes';
            obj.Term_End_Date__c = Date.Today() - 365;
            objList.add(obj);
        }
        insert objList;
        return objList;
    } 
        
    @isTest
    static void testGenerateStudentTermsForUniversities() {
        integer testSize = 5;
        Set<Id>accIdset =  new Set<Id>();
        String TermName = 'Spring';
        
        list<Account> accList = createTestAccounts(testSize);
        list<Contact> conList = createTestContacts(accList);
        list<Application__c> appList = createTestApplications(conList,accList);
        List<Student_Term__c> stList = createTestStudent_Terms(appList, accList);
        list<Id> accIds = new list<Id>();
       
        for(Application__c app : appList) {
            accIds.add(app.School_Name__c);
        }
        accIdset.addAll(accIds);
                
        Test.startTest();
        GenerateTerms.generatebatchjob(accIdset, termName);
        system.debug([Select School_Name__c,Id,DPSID__c,iscurrentapplication__c,Application_Submission_Year__c,application_status__c From Application__c Where School_Name__c In :accIds]);
        Test.stopTest();
        List<Student_Term__c> StudentTermResult = [Select Id from Student_Term__c Where college_or_university__c In :accIds and Rec_d_Pymt_Previous_Term__c = 'No'];
        System.assertEquals(accIds.size(), StudentTermResult.size());
    }
}