@isTest
public class DSF_ContactDSFControllerTest {
	@isTest
    public static void createCaseTest () {

		Contact cont = new Contact ();
		cont.LastName = 'Test LastName';
		cont.Email = 'test@test.com';
		insert cont;
		
		Case pc = new Case();
		pc.Status = 'New';
		pc.Origin = 'Student Community';
		pc.ContactId = cont.Id;
		/*insert pc;*/
		
		String cc = DSF_ContactDSFController.createCase(pc);
		System.assert(cc != null);
	}
}