public without sharing class MyAdvisorMonthlyReportController {
	public list<Advisor_Monthly_Report__c> reportList {get; set;}
  public MyAdvisorMonthlyReportController() {
    list<String> accIds = new list<String>();
    list<User> userList = [SELECT contact.accountId FROM User WHERE Id = :UserInfo.getUserId()];
    if(!userList.isEmpty()) {
      reportList = new list<Advisor_Monthly_Report__c>();
      reportList.addAll([SELECT Id,Name,LastModifiedBy.Name,LastModifiedDate,CreatedDate,CreatedBy.Name,School_Organization__c,School_Organization__r.Name,Academic_Year__c,Month__c FROM Advisor_Monthly_Report__c WHERE School_Organization__c IN (SELECT Id FROM Account WHERE parentId = :userList[0].contact.accountId)]);
      reportList.addAll([SELECT Id,Name,LastModifiedBy.Name,LastModifiedDate,CreatedDate,CreatedBy.Name,School_Organization__c,School_Organization__r.Name,Academic_Year__c,Month__c FROM Advisor_Monthly_Report__c WHERE School_Organization__c = :userList[0].contact.accountId]);
    }
	}
}