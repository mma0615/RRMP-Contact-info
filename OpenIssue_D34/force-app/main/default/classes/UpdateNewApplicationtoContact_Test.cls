@isTest
public class UpdateNewApplicationtoContact_Test {
    
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
       
        //Create applications with current application year and Status of Finalist
        String vappyear = String.valueof(System.today().year());
        list<Application__c> Applist = new list<Application__c>();
        for(integer i = 0; i < lstcontact.size(); i++) {
            Application__c app = new Application__c();
            app.student_name__c = lstcontact[i].Id;
            app.Race_Ethnicity__c = 'White';
            app.Gender__c = 'Male';
            app.Social_Security_Number__c = '12345678'+ i;
            app.Application_Submission_Year__c = vappyear;
            app.Current_per_Custom_Label_WORKFLOW__c = true;
            app.School_Name__c = acctlist[i].Id;
            Applist.add(app);
            //}
        }
        insert Applist;
      }
    
    static testmethod void test(){
        Test.startTest();
        
        UpdateNewApplicationtoContact updcustom = new UpdateNewApplicationtoContact();
        DataBase.executeBatch(updcustom);
        
        Test.stopTest();
        system.assertEquals(6, [select count() from Contact where SSN_On_File__c = true]);
     
    }
    


}