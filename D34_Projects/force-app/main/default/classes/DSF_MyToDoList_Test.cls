@isTest
public with sharing class DSF_MyToDoList_Test {

	@isTest
	static void getFAFSADetails(){

		Current_Application_Season__c curAppSeas = new Current_Application_Season__c();
		curAppSeas.Name = 'Current Application Year';
		curAppSeas.Application_Year__c = '2020-21';
		insert curAppSeas;

		Contact c = new Contact();
		c.LastName = 'Test';
		insert c;

		FAFSA_Detail__c fDetail = new FAFSA_Detail__c();
        fDetail.Student__c = c.Id;
        fDetail.Academic_Year__c = '2020-21';
        insert fDetail;
 
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
			DSF_MyToDoList.getFafsaDetail();
		}
	}

	@isTest
	static void getEmptyFAFSADetails(){
		DSF_MyToDoList.getFafsaDetail();
	}
}