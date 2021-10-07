@isTest
public with sharing class ProjectIssueTriggerHandler_Test {
    @TestSetup
    static void makeData(){
        Event__c evt = TestFactory.createEvent('TestEvent');
        //Create Project
        Krow__Project__c project = new Krow__Project__c(
            Name = 'Test Project',
            Krow__Project_Status__c = 'In Progress',
            Krow__Archived__c = false,
            Custom_Event__c = evt.Id
        );
        insert project;
        //Create Existing Contact
        String email = 'test@email.com';
        String token = '123';
        Contact con = new Contact();
        con.LastName = email;
        con.Email = email;
        //con.Login_Token__c = token;
        insert con;
    }

    @isTest
    static void testShouldDefault(){
        List<Project_Issue__c> issues = new List<Project_Issue__c>();
        Krow__Project__c project = [SELECT ID FROM Krow__Project__c LIMIT 1];
        Event__c evt = [SELECT ID FROM Event__c LIMIT 1];
        issues.add(new Project_Issue__c(
            //Project__c = project.Id,
            Custom_Event__c = evt.Id,
            Raised_By_Email__c = 'test@email.com',
            Description__c = 'description',
            Status__c = 'New',
            Type__c = 'Domain Access Issue/User Sign-on Issues',
            Date_Raised__c = date.today()
        ));
        issues.add(new Project_Issue__c(
            //Project__c = project.Id,
            Custom_Event__c = evt.Id,
            Raised_By_Email__c = 'test@test.com',
            Description__c = 'description',
            Status__c = 'New',
            Type__c = 'Domain Access Issue/User Sign-on Issues',
            Date_Raised__c = date.today()
        ));
        Test.startTest();
            insert issues;
        Test.stopTest();
        for (Project_Issue__c projIssue : [
            SELECT ID,
            Raised_By__c
            FROM Project_Issue__c
        ]){
            System.assertNotEquals(null, projIssue.Raised_By__c, 'the raised_by did not default');
        }
        System.assertEquals(2, [SELECT ID FROM Project_Issue__c].size(), 'the number of issues inserted is not equal');
        Update issues;
    }

    @isTest
    static void testShouldDefaultDuringUpdate(){
        List<Project_Issue__c> issues = new List<Project_Issue__c>();
        Krow__Project__c project = [SELECT ID FROM Krow__Project__c LIMIT 1];
        Event__c evt = [SELECT ID FROM Event__c LIMIT 1];
        issues.add(new Project_Issue__c(
            //Project__c = project.Id,
            Custom_Event__c = evt.Id,
            Raised_By_Email__c = 'test@email.com',
            Description__c = 'description',
            Status__c = 'New',
            Type__c = 'Domain Access Issue/User Sign-on Issues',
            Date_Raised__c = date.today()
        ));
        issues.add(new Project_Issue__c(
            //Project__c = project.Id,
            Custom_Event__c = evt.Id,
            Raised_By_Email__c = 'test@test.com',
            Description__c = 'description',
            Status__c = 'New',
            Type__c = 'Domain Access Issue/User Sign-on Issues',
            Date_Raised__c = date.today()
        ));
        insert issues;
        Test.startTest();
            for (Project_Issue__c issue : issues){
                issue.Raised_By__c = null;
            }
            Update issues;
        Test.stopTest();
        for (Project_Issue__c projIssue : [
            SELECT ID,
            Raised_By__c
            FROM Project_Issue__c
        ]){
            System.assertNotEquals(null, projIssue.Raised_By__c, 'the raised_by did not default');
        }
        System.assertEquals(2, [SELECT ID FROM Project_Issue__c].size(), 'the number of issues inserted is not equal');
    }
}