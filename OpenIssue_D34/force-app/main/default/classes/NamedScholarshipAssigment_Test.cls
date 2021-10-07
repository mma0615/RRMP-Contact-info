@isTest
public class NamedScholarshipAssigment_Test {
    
    @testSetup
    static void setup()
    {
        integer testSize = 7;
        
        //create 7 accounts
        Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
        list<Account> acctList = new list<Account>();
        for(integer i = 0; i < testSize ; i++) {
            Account obj = new Account();
            obj.recordTypeId = collRT;
            
            if ( i== 0 )
                obj.name  = 'Colorado School of Mines'; //School of Mines
            
            else if (i ==1)
                obj.name = 'Metropolitan State University of Denver'; //mSU
            
            else if(i ==2)
                obj.name = 'Community College of Denver'; //CCD
            
            else if(i ==3)
                obj.name = 'Colorado State University'; //CSU
            
            else if(i == 4 )
                obj.name = 'University of Colorado Denver'; //CU Denver
            
            else if (i == 5)
                obj.name = 'South High School';
            else 
                obj.name = 'Manual High School';
            
            acctList.add(obj);
        }
        insert acctList;
        //create 5 contacts
        List<Contact> lstcontact = new List<Contact>();
        for(Integer i=0 ;i < testsize ;i++)
        {
            Contact ct = new Contact();
            ct.LastName ='LastName'+ i;
            ct.FirstName = 'FirstName' + i ;
            ct.Student_Status__c = 'Scholar';
            ct.Cohort__c = 'a240a0000003yKrAAI';
            if (i == 0){
                ct.Race_Ethnicity__c = 'Hispanic/Latinx';
                ct.First_Generation_College_Student__c = 'Yes';
                ct.Gender__c = 'Female';
            }
            else if(i == 1){
                ct.Race_Ethnicity__c = 'Black/African American';
                ct.First_Generation_College_Student__c = 'Yes';
               /* ct.Last_High_School_Attended__c = '001j000000W7QVWAA3';  //Manual High School*/
                ct.Gender__c = 'Female';
                ct.US_Citizenship_Status__c = 'Have obtained lawful presence through Deferred Action';
                ct.MailingPostalCode = '80204';
            }
            else if (i == 2){
                ct.Race_Ethnicity__c = 'Asian';
                ct.Gender__c = 'Male';
                ct.First_Generation_College_Student__c = 'Yes';
                
            }
            else if(i ==3) {
                ct.Race_Ethnicity__c = 'Multi-Racial';
            }
            else if(i== 5 || i == 6){
                ct.Race_Ethnicity__c = 'White'; 
                ct.Last_High_School_Attended__c = acctlist[i].id; //Abraham Lincoln High School  
            }
			else 
            {
                ct.Race_Ethnicity__c = 'White'; 
            }
            lstcontact.add(ct);
        }
        insert lstcontact;
        
        /*Create term settings*/
        Map<String, DSF_Term_Settings__c> settings = new Map<String, DSF_Term_Settings__c>();
        DSF_Term_Settings__c setting2 = new DSF_Term_Settings__c();
        setting2.Name = 'Fall Default';
        setting2.Term_Name__c = 'Fall';
        setting2.Default_Setting__c = true;
        setting2.Term_Start_Date__c = Date.today().addDays(-20);
        setting2.Term_End_Date__c = Date.today().addDays(30);
        
        DSF_Term_Settings__c setting1 = new DSF_Term_Settings__c();
        setting1.Name = 'Spring Default';
        setting1.Term_Name__c = 'Spring';
        setting1.Default_Setting__c = true;
        setting1.Term_Start_Date__c = Date.today().addDays(90);
        setting1.Term_End_Date__c = Date.today().addDays(150);
        
        settings.put(setting1.Term_Name__c, setting1);
        settings.put(setting2.Term_Name__c, setting2);
        insert settings.values();
        
        
        //Create applications with application year and Status of Finalist
        
        list<Application__c> Applist = new list<Application__c>();
        for(integer i = 0; i < lstcontact.size(); i++) {
            Application__c app = new Application__c();
            app.student_name__c = lstcontact[i].Id;
            app.application_status__c = 'Finalist';
            app.Application_Submission_Year__c = String.Valueof(System.Today().Year());
            app.School_Name__c = acctList[i].id;
            if (i == 0){
                app.Major__c = 'Engineering' ;
            }
            else if (i == 1){
                app.Sub_major__c = 'Mathematics, General';
                app.Attended_Dora_Moore_K8_School__c = 'Yes';
            }
            else if(i ==2){
                app.Major__c = 'Arts: Visual & Performing';
            }
            else if(i == 3 ){
                app.Major__c = 'Health Sciences & Technologies';
            }
            else {
                app.Major__c = 'Business';
                app.Sub_major__c = 'Nursing, Practical/Vocational (LPN)';
            }
            Applist.add(app);
        }
        insert Applist;
        
        //create corresponding Spring Student Terms 
        List<Student_Term__c> stList = new List<Student_Term__c>();
        for (Integer i = 0; i < appList.size(); i++) {
            Student_Term__c st = new Student_Term__c();
            st.college_or_university__c = appList[i].School_Name__c;
            st.Application__c = appList[i].Id;
            st.Term_Semester__c =  'Fall';
            st.Term_Eligibility_Status__c = 'Finalist';
            st.Reason_for_Ineligibility__c = 'Eligible - Award Calculated';
            st.Program_Enrolled__c = 'Bachelor\'s';
            st.isCurrentTerm__c = true;
            if (i == 3){
                st.Program_Enrolled__c = 'Associate\'s';
            }
            else if(i == 4) {
                st.Program_Enrolled__c = 'Certificate';
            }
            else
                st.Program_Enrolled__c = 'Bachelor\'s';
            stList.add(st);
        }
        insert stList;
    }
    
    static testmethod void test(){
                
        Test.startTest();
        
        NamedScholarshipAssignment ns = new NamedScholarshipAssignment();
        DataBase.executeBatch(ns);
        
        Test.stopTest();
        system.assertEquals(7, [select count() from Named_Scholarships__c where Name = 'Wiegers Family Foundation Scholarship']);
        
    }
    
}