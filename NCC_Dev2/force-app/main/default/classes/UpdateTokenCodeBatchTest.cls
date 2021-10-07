@isTest
public class UpdateTokenCodeBatchTest {
    @isTest static void testUpdateToken(){
        //Create Contact    
        Contact newContact = new Contact();
        newContact.Firstname = 'firstname';
        newContact.Lastname = 'lastname';
        newContact.Email = 'email@email.com';
        newContact.Contact_Type__c = 'Client';
        insert newContact;
        
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('Test Update Token', CRON_EXP, new UpdateTokenCodeBatch_Schedule());   
        Test.stopTest();
        System.assert(!String.isBlank(jobId));
    }
}