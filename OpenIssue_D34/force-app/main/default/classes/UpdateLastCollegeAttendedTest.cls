@isTest
public class UpdateLastCollegeAttendedTest
{
    @testSetup
    static void setup()
    {
        List<Contact> lstcontact = new List<Contact>();
        List<PSI_Enrollment_Record__c> psicontactlist1= new List<PSI_Enrollment_Record__c>();
        List<PSI_Enrollment_Record__c> psicontactlist2 = new List<PSI_Enrollment_Record__c>();
        for(Integer i=0 ;i <20;i++)
        {
           Contact ct = new Contact();

            ct.LastName ='LastName'+ i;
            ct.FirstName = 'FirstName' + i ;
            ct.Student_Status__c = 'Scholar';
            lstcontact.add(ct);
        }
        insert lstcontact;
        system.debug('Contact records -' + lstcontact);
        
        for(Contact con :lstcontact) {
            PSI_Enrollment_Record__c psi= new PSI_Enrollment_Record__c();
            psi.Fall_Enrollment__c = '001j000000W7QZ8AAN';
            psi.Spring_Enrollment__c ='001j000000W7QYzAAN';
            psi.Academic_Year__c = '2018-19';
            psi.Student__c= con.Id;
            psicontactlist1.add(psi);

            
            
            
        }
        
         insert psicontactlist1;
        system.debug('PSI records -' + psicontactlist1);
     /*   for(Integer j=0; j<10;j++){
            PSI_Enrollment_Record__c psi= new PSI_Enrollment_Record__c();
            psi.Fall_Enrollment__c = '001j000000W7QZ8AAN';
            psi.Spring_Enrollment__c ='001j000000W7QYzAAN';
            psi.Academic_Year__c = '2018-19';
            psi.Student__c= 
            psicontactlist1.add(psi);
          
        }
        insert psicontactlist1;
        
        for (integer k=0; k<10; k++){
            PSI_Enrollment_Record__c psi2= new PSI_Enrollment_Record__c();
            psi2.Fall_Enrollment__c = '001j000000W7QYzAAN';
            psi2.Spring_Enrollment__c ='001j000000W7QYzAAN';
            psi2.Academic_Year__c = '2019-20';
            psicontactlist2.add(psi2);
          
        }
        insert psicontactlist2;*/
    }
        
        static testmethod void test(){

        Test.startTest();

            UpdateLastCollegeAttended obj = new UpdateLastCollegeAttended();

            DataBase.executeBatch(obj);

        Test.stopTest();
            system.assertEquals(20, [select count() from Contact where Last_College_Attended__c != null]);

    }

}