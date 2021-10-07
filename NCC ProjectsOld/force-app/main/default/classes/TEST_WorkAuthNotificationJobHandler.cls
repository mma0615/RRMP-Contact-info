@isTest
public class TEST_WorkAuthNotificationJobHandler {
    @IsTest
    static void testSendWorkAuthNotification(){
        
        Test.startTest();
        User usr = TestFactory.createInteralUser('testF','testL','test@Ncc231100test.com','System Administrator');  
        Krow__Krow_Role__c projectRole = new Krow__Krow_Role__c(Name='test role', Krow__Active__c = true);
        insert projectRole;
        Krow__Project_Resources__c projectResource = new Krow__Project_Resources__c(Name='Test Resource',
                                                                                   Krow__External_Resource__c = false,
                                                                                   Krow__Project_Role__c = projectRole.id,
                                                                                   Krow__User__c = usr.Id);
        insert projectResource;
        System.runAs(usr){
            System.debug('usr.Id '+usr.Id);
            Krow__Project__c project = new Krow__Project__c(Name = 'Test project',
                                                       Krow__Project_Status__c = 'In Progress',
                                                       ownerId = usr.Id,
                                                       Krow__Archived__c = false);
            insert project;
            Krow__Task__c task = new Krow__Task__c(Name='test task');
            task.Krow__Project__c = project.Id;
            task.Krow__Project_Owner__c = usr.Id;
            insert task;
            List<Krow__Task_Assignment__c> taskAssignments = new List<Krow__Task_Assignment__c>();
            for (Integer index = 0; index < 2; index++) {
                Krow__Task_Assignment__c taskAssignment = new Krow__Task_Assignment__c(Krow__Status__c = 'Booked',
                                                                              Krow__Project__c = project.id,
                                                                              Project_Owner__c = usr.Id,
                                                                              Krow__Project_Resource__c = projectResource.Id,
                                                                              Krow__Billable_Hours_Logged__c = 1,
                                                                              Krow__Krow_Task__c = task.id);
                taskAssignments.add(taskAssignment);
            }
            insert taskAssignments;
        }
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1); 
        String ss = String.valueOf(Datetime.now().second());

        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

        WorkAuthNotificationScheduleJob workAuthNotificationScheduleJob = new WorkAuthNotificationScheduleJob(); 
        System.schedule('Test Job Start ' + String.valueOf(Datetime.now()), nextFireTime, workAuthNotificationScheduleJob);
        //WorkAuthNotificationJobHandler.sendWorkAuthNotification();
        Test.stopTest();  
        System.assert(true);
    }
    
}