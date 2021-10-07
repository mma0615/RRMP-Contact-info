@isTest
public class DSF_SchoolDetailsControllerTest {
	@isTest
    static void getUniversitiesTest() {
		DSF_SchoolDetailsController.getUniversities();
	}
	
	@isTest
    static void updateAppTest () {
		Contact c = new Contact();
		c.LastName = 'Test';
		insert c;

		Application__c app = new Application__c();
		app.Student_Name__c = c.Id;
		insert app;

		Account school = new Account();
		school.Name = 'Test school';
		school.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
		insert school;
 
		DSF_SchoolDetailsController.updateApplication(app.Id, school.Id);
	}

	@isTest
	static void getCurrentApplication(){

		Contact c = new Contact();
		c.LastName = 'Test';
		insert c;

		Application__c app = new Application__c();
		app.Student_Name__c = c.Id;
		app.Application_Submission_Year__c = Label.DSF_App_Season_End_Date.right(4);
		insert app;

        Profile studentProfile = [SELECT Id FROM Profile WHERE Name =: Label.DSF_Active_Portal_Student_Community_Profile_Name LIMIT 1];

		User user = new User();
		user.Username = 'dsf@testmail.com';
		user.ContactId = c.Id;
		user.ProfileId = studentProfile.Id;
		user.Alias = 'dsfAlias';
		user.Email = 'dsf@testmail.com';
		user.EmailEncodingKey =  'UTF-8';
		user.LastName = c.LastName;
		user.CommunityNickname = 'testUsr';
		user.TimeZoneSidKey = 'America/Los_Angeles';
		user.LocaleSidKey = 'en_US';
		user.LanguageLocaleKey = 'en_US';
		insert user;

		System.runAs(user) {
			DSF_SchoolDetailsController.getCurrentApplication();
		}
	}

	@isTest
	static void getEmptyApplication(){
		DSF_SchoolDetailsController.getCurrentApplication();
	}
}