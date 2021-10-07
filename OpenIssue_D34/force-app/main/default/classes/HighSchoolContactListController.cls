public with sharing class HighSchoolContactListController {
	public list<Contact> contactList {get; set;}
  public HighSchoolContactListController() {
    list<String> accIds = new list<String>();
		list<User> userList = [SELECT contact.accountId FROM User WHERE Id = :UserInfo.getUserId()];
    if(!userList.isEmpty()) {
      contactList = new list<Contact>();
      contactList.addAll([SELECT Id,Name,Email,MobilePhone,MailingStreet,MailingState,MailingCity,MailingPostalCode,Account.Name,AccountId FROM Contact WHERE Last_High_School_Attended__c IN (SELECT Id FROM Account WHERE parentId = :userList[0].contact.accountId)]);
      contactList.addAll([SELECT Id,Name,Email,MobilePhone,MailingStreet,MailingState,MailingCity,MailingPostalCode,Account.Name,AccountId FROM Contact WHERE Last_High_School_Attended__c = :userList[0].contact.accountId]);
    }
	}
}