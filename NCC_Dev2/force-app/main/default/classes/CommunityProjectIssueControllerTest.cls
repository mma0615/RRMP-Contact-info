@isTest (SeeAllData = false)
public class CommunityProjectIssueControllerTest {
    
    @testSetup static void createData() {
        List<Apex_Trigger_Switch__c> switchRecs = TestDataFactory.createAllTriggerSwitch();
        insert switchRecs;
        
        TestFactory.ParkingLotTestDataFactory df = new TestFactory.ParkingLotTestDataFactory();
        df.make();
        df.persist(); 
        
    
        
        Event__c evt = [SELECT Id, Event_Id__c FROM Event__c LIMIT 1];
        Session__c sess = [SELECT Id FROM Session__c WHERE Event__c =: evt.Id];
        
        //Create Existing Contact
        String email = 'test@email.com';
        String token = '123';
        Contact con = new Contact();
        con.LastName = email;
        con.Email = email;
        insert con;
        
        List<String> emailList = new List<String>{'test@email.com','test2@email.com','test3@email.com','test4@email.com','test5@email.com'};
            List<Issue__c> piList = new List<Issue__c>();
        for(String emailStr : emailList){
            Issue__c pi = new Issue__c();
            pi.Session__c = sess.Id;
            pi.Raised_By_Email__c = emailStr;
            pi.Event__c = evt.Id;
            piList.add(pi);
        }
        insert piList;
    }
    
    @isTest static void getProjectRaidDetailsTest(){
        Event__c evt = [SELECT Id, Event_Id__c FROM Event__c LIMIT 1];
        test.startTest();
        String results = CommunityProjectIssueController.getProjectDetails(evt.Event_Id__c);
        test.stopTest();
        
        //Assert
        system.assert(String.isNotBlank(results));
        
    }
    
    @isTest static void createProjectIssueTest(){
          Event__c evt = [SELECT Id, Event_Id__c FROM Event__c LIMIT 1];
         Session__c sess = [SELECT Id FROM Session__c WHERE Event__c =: evt.Id];
        List<String> typeList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Issue__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            typeList.add(pickListVal.getLabel());
        }  
        test.startTest();
        CommunityProjectIssueController.createProjectIssue(evt.Event_Id__c, sess.Id, 'test@email.com', 'Description', typeList[0]);
        test.stopTest();
        
        //Assert
        List<Issue__c> results = [SELECT Id, Raised_By_Email__c FROM Issue__c WHERE Raised_By_Email__c = 'test@email.com'];
        system.assert(!results.isEmpty());
    }
    
    @isTest static void createProjectIssueErrorTest(){
		  Event__c evt = [SELECT Id, Event_Id__c FROM Event__c LIMIT 1];
         Session__c sess = [SELECT Id FROM Session__c WHERE Event__c =: evt.Id];        
        try{
            CommunityProjectIssueController.createProjectIssue(evt.Event_Id__c, sess.Id, 'test@email.com', 'description', 'type');
        }
        catch(Exception e){
            system.assert(String.isNotBlank(e.getMessage()));
        }
    }
    
    @isTest static void getProjectIssueDetailsErrorTest(){
        try{
            CommunityProjectIssueController.getProjectDetails('evtId');
        }
        catch(Exception e){
            system.assert(String.isNotBlank(e.getMessage()));
        }
    }
    
    @isTest static void getProjectIssueDetailsErrorTest2(){
        try{
            Event__c evt = TestFactory.createEvent('TestEvent2');
            Event__c evtRec = [SELECT Id, Event_Id__c FROM Event__c WHERE Name = 'TestEvent2' LIMIT 1];
            CommunityProjectIssueController.getProjectDetails(evtRec.Event_Id__c);
        }
        catch(Exception e){
            system.assert(String.isNotBlank(e.getMessage()));
        }
    } 
    
}