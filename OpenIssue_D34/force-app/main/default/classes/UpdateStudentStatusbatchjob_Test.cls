@isTest
public class UpdateStudentStatusbatchjob_Test
{
    @testSetup
    static void setup()
    {
        List<Contact> lstcontact = new List<Contact>();
        Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        for(Integer i=0 ;i <=10;i++)
        {
            Contact ct = new Contact();
            ct.LastName ='LastName'+ i;
            ct.FirstName = 'FirstName' + i ;
            ct.Student_Status__c = 'Non-Applicant';
            ct.recordTypeId = stRT;
            if(i > 5 ){
                ct.Total_Payments_Amount_to_Date__c = 1400;
            }
            lstcontact.add(ct);
        }
        insert lstcontact;
    }
    
    static testmethod void test(){
        Test.startTest();
        
        UpdateStudentStatusbatchjob obj = new UpdateStudentStatusbatchjob();
        DataBase.executeBatch(obj);
        
        Test.stopTest();
        system.assertEquals(5, [select count() from Contact where Student_Status__c = 'Scholar']);
    }
}