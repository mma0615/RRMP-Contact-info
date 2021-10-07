@isTest
public class UpdateSpringCollegeAttended_Test {
    
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
            app.School_Name__c = acctlist[i].Id;
            Applist.add(app);
            //}
        }
        insert Applist;
     
        //create corresponding Spring Student Terms 
        List<Student_Term__c> stList = new List<Student_Term__c>();
        for (Integer i = 0; i < appList.size(); i++) {
            Student_Term__c st = new Student_Term__c();
            st.college_or_university__c = acctList[i].Id;
            st.Application__c = appList[i].Id;
            st.Term_Semester__c =  'Spring';
            st.Term_Eligibility_Status__c = 'Finalist';
            st.student_id_at_college__c = String.valueOf(Math.round(Math.random() * 10000));
            st.Term_End_Date__c = Date.Today() ;
            if (i < 2 ){
            st.Enrollment_Type__c = 'Full Time Plus (15 or more credit hours)';
            }
            else 
               st.Enrollment_Type__c = 'Half Time (6 - 8 credit hours)'; 
            stList.add(st);
        }
        insert stList;
        system.debug('stlist-' + stlist);
    }
    
    static testmethod void test(){
        Test.startTest();
        
        UpdateSpringCollegeAttended updspring = new UpdateSpringCollegeAttended();
        DataBase.executeBatch(updspring);
        
        Test.stopTest();
        system.assertEquals(6, [select count() from Contact where Spring_College_Selection__c != null]);
     
    }
    
}