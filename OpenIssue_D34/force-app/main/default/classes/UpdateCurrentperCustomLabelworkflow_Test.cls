@isTest
public class UpdateCurrentperCustomLabelworkflow_Test {
    
    @testSetup
    static void setup()
    {
        integer testSize = 5;
        //create 5 contacts
        List<Contact> lstcontact = new List<Contact>();
        for(Integer i=0 ;i <=testsize ;i++)
        {
            Contact ct = new Contact();
            ct.LastName ='LastName'+ i;
            ct.FirstName = 'FirstName' + i ;
            ct.Student_Status__c = 'Scholar';
            ct.Cohort__c = 'a240a0000003yKrAAI';
            lstcontact.add(ct);
        }
        insert lstcontact;
       
        //create 5 accounts
        Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
        list<Account> acctList = new list<Account>();
        for(integer i = 0; i <= testSize; i++) {
            Account obj = new Account();
            obj.recordTypeId = collRT;
            obj.name = 'Test Account ' + i;
            acctList.add(obj);
        }
        insert acctList;
       
        //Create applications with Previous application year and Status of Finalist
        String vprevappyear = String.valueof(System.today().year() - 1);
        list<Application__c> Applist = new list<Application__c>();
        for(integer i = 0; i < lstcontact.size(); i++) {
            Application__c app = new Application__c();
            app.student_name__c = lstcontact[i].Id;
            app.application_status__c = 'Finalist';
            app.Application_Submission_Year__c = vprevappyear;
            app.Current_per_Custom_Label_WORKFLOW__c = true;
            app.School_Name__c = acctlist[i].Id;
            Applist.add(app);
            //}
        }
        insert Applist;
      }
    
    static testmethod void test(){
        Test.startTest();
        
        UpdateCurrentperCustomLabelworkflow updcustom = new UpdateCurrentperCustomLabelworkflow();
        DataBase.executeBatch(updcustom);
        
        Test.stopTest();
        system.assertEquals(6, [select count() from Application__c where Current_per_Custom_Label_WORKFLOW__c = false]);
     
    }
    
}