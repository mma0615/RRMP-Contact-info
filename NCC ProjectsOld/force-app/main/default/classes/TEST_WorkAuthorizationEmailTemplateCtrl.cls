@isTest
public class TEST_WorkAuthorizationEmailTemplateCtrl {
    @isTest static void testController(){
        Test.startTest();
        Krow__Krow_Role__c projectRole = new Krow__Krow_Role__c(Name='test role', Krow__Active__c = true);
        insert projectRole;
        Krow__Project_Resources__c projectResource = new Krow__Project_Resources__c(Name='Test Resource',
                                                                                   Krow__External_Resource__c = false,
                                                                                   Krow__Project_Role__c = projectRole.id);
        insert projectResource;
        User usr = TestFactory.createInteralUser('testF','testL','test@Ncc231100test.com','System Administrator');  
        System.runAs(usr){
            Krow__Project__c project = new Krow__Project__c(Name = 'Test project',
                                                       Krow__Project_Status__c = 'In Progress',
                                                       ownerId = usr.Id,
                                                       Krow__Archived__c = false);
            insert project;
            Krow__Task__c task = new Krow__Task__c(Name='test task');
            insert task;
            List<Krow__Task_Assignment__c> taskAssignments = new List<Krow__Task_Assignment__c>();
            for (Integer index = 0; index < 2; index++) {
                Krow__Task_Assignment__c taskAssignment = new Krow__Task_Assignment__c(Krow__Status__c = 'Booked',
                                                                              Krow__Project__c = project.id,
                                                                              Krow__Project_Resource__c = projectResource.Id,
                                                                              Krow__Billable_Hours_Logged__c = 1,
                                                                              Krow__Krow_Task__c = task.id);
                taskAssignments.add(taskAssignment);
            }
            insert taskAssignments;
        }
        Test.stopTest();
        WorkAuthorizationEmailTemplateController.projectResourceId = projectResource.id;     
        WorkAuthorizationEmailTemplateController.getProjectResource();
        WorkAuthorizationEmailTemplateController.getProjectWrappers();
        
    }
}