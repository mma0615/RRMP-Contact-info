@isTest
public class PreferredName1Test
{
    static testMethod void testMethod1()
    {
        List<Contact> lstcontact = new List<Contact>();
        for(Integer i=0 ;i <20;i++)
        {
           Contact ct = new Contact();

            ct.LastName ='LastName'+ i;
            ct.FirstName = 'FirstName' + i ;
            lstcontact.add(ct);
        }
        insert lstcontact;

        Test.startTest();

            PreferredName1 obj = new PreferredName1();

            DataBase.executeBatch(obj);

        Test.stopTest();

    }

}