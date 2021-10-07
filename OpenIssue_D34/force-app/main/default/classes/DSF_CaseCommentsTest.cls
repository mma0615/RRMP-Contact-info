@isTest
public class DSF_CaseCommentsTest {
	@isTest
    public static void addCaseCommentsTest () {

		Contact cont = new Contact ();
		cont.LastName = 'Test LastName';
		cont.Email = 'test@test.com';
		insert cont;
		
		Case pc = new Case();
		pc.Status = 'New';
		pc.Origin = 'Student Community';
		pc.ContactId = cont.Id;
		insert pc;
		
		String testComment = 'Test Comment';

		CaseComment cc = DSF_CaseCommentsController.addCaseComment(testComment, pc.Id);
		System.assert(cc != null);
	}
}