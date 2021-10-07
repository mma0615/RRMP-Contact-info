@isTest
public class DSF_MyToDoList_FAFSAProof_TopicTest {
    @isTest 
    public static void saveFAFSATest() {
		Contact c = new Contact();
		c.LastName = 'Test';
        insert c;

        FAFSA_Detail__c f = new FAFSA_Detail__c();
        f.Academic_Year__c = '2020-2021';
        f.Student__c = c.Id;

        Id i = DSF_MyToDoList_FAFSAProof_Topic.saveFafsa(f);

        System.Assert(i != null );

        Boolean b = DSF_MyToDoList_FAFSAProof_Topic.updateFafsa(f);
        System.assertEquals(true, b);
    }
}