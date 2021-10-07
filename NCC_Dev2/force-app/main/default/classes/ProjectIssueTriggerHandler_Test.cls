@isTest
public class ProjectIssueTriggerHandler_Test {
   
    @TestSetup
    static void makeData(){
        List<Apex_Trigger_Switch__c> switchRecs = TestDataFactory.createAllTriggerSwitch();
        insert switchRecs;
        Event__c evt = TestFactory.createEvent('TestEvent');
        
        //Create Existing Contact
        String email = 'test@email.com';
        String token = '123';
        Contact con = new Contact();
        con.LastName = email;
        con.Email = email;
        con.Login_Token__c = token;
        insert con;
    }

    @isTest
    static void testShouldDefault(){
        List<Issue__c> issues = new List<Issue__c>();  
        Event__c evt = [SELECT ID FROM Event__c LIMIT 1];
        issues.add(new Issue__c(
            Event__c = evt.Id,
            Raised_By_Email__c = 'test@email.com',
            Description__c = 'description',
            Status__c = 'New',
            Type__c = 'Domain Access Issue/User Sign-on Issues',
            Date_Raised__c = date.today()
        ));
        issues.add(new Issue__c(
            Event__c = evt.Id,
            Raised_By_Email__c = 'test@test.com',
            Description__c = 'description',
            Status__c = 'New',
            Type__c = 'Domain Access Issue/User Sign-on Issues',
            Date_Raised__c = date.today()
        ));
        Test.startTest();
            insert issues;
        Test.stopTest();
        for (Issue__c projIssue : [
            SELECT ID,
            Raised_By__c
            FROM Issue__c
        ]){
            System.assertNotEquals(null, projIssue.Raised_By__c, 'the raised_by did not default');
        }
        System.assertEquals(2, [SELECT ID FROM Issue__c].size(), 'the number of issues inserted is not equal');
        Update issues;
    }

    @isTest
    static void testShouldDefaultDuringUpdate(){
        List<Issue__c> issues = new List<Issue__c>();
    
        Event__c evt = [SELECT ID FROM Event__c LIMIT 1];
        issues.add(new Issue__c(
            Event__c = evt.Id,
            Raised_By_Email__c = 'test@email.com',
            Description__c = 'description',
            Status__c = 'New',
            Type__c = 'Domain Access Issue/User Sign-on Issues',
            Date_Raised__c = date.today()
        ));
        issues.add(new Issue__c(
            Event__c = evt.Id,
            Raised_By_Email__c = 'test@test.com',
            Description__c = 'description',
            Status__c = 'New',
            Type__c = 'Domain Access Issue/User Sign-on Issues',
            Date_Raised__c = date.today()
        ));
        insert issues;
        Test.startTest();
            for (Issue__c issue : issues){
                issue.Raised_By__c = null;
            }
            Update issues;
        Test.stopTest();
        for (Issue__c projIssue : [
            SELECT ID,
            Raised_By__c
            FROM Issue__c 
        ]){
            System.assertNotEquals(null, projIssue.Raised_By__c, 'the raised_by did not default');
        }
        System.assertEquals(2, [SELECT ID FROM Issue__c].size(), 'the number of issues inserted is not equal');
    }
     
}