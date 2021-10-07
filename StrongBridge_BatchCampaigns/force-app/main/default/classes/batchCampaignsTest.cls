@IsTest
public with sharing class batchCampaignsTest 
{
	static testmethod void testAccountOwner() 		
	{
		Config_Campaign__c ccObj = new Config_Campaign__c();
		ccObj.Name = 'Test C';
		ccObj.Task_Assigned_To__c = 'Account Owner';
		ccObj.Task_Due_Date__c = '2';
		Insert ccObj;

		Config_User__c cuObj = new Config_User__c();
		cuObj.Config_Campaign__c = ccObj.Id;
		cuObj.User__c = UserInfo.getUserId();
		Insert cuObj;

		Account accountObj = new Account();
		accountObj.Name = 'Test Account';
		accountObj.Current_Status__c = 'Active';
		Insert accountObj;

		Contact contactObj = new Contact();
		contactObj.LastName = 'LName';
		contactObj.FirstName = 'FName';
		contactObj.AccountId = accountObj.Id;
		Insert contactObj;	
		
		string query = 'SELECT id, Name, Record_Type__c, OwnerId, ' +
			'Task_Assigned_To__c, Task_Due_Date__c, Task_Priority__c, Task_Subject__c, ' +
			'Task_Type__c, Task_Disposition__c FROM Config_Campaign__c order by id';
        batchCampaigns cBatch = new batchCampaigns(query );
        Database.executeBatch(cBatch); 
   }

   static testmethod void testContactOwner() 		
   {
	   Config_Campaign__c ccObj = new Config_Campaign__c();
	   ccObj.Name = 'Test C';
	   ccObj.Task_Assigned_To__c = 'Contact Owner';
	   //ccobj.Record_Type__c = 'test';
	   ccObj.Task_Due_Date__c = '2';
	   Insert ccObj;

	   Config_User__c cuObj = new Config_User__c();
	   cuObj.Config_Campaign__c = ccObj.Id;
	   cuObj.User__c = UserInfo.getUserId();
	   Insert cuObj;

	   Account accountObj = new Account();
	   accountObj.Name = 'Test Account';
	   accountObj.Current_Status__c = 'Active';
	   Insert accountObj;

	   Contact contactObj = new Contact();
	   contactObj.LastName = 'LName';
	   contactObj.FirstName = 'FName';
	   contactObj.AccountId = accountObj.Id;
	   Insert contactObj;	
	   
	   string query = 'SELECT id, Name, Record_Type__c, OwnerId, ' +
		   'Task_Assigned_To__c, Task_Due_Date__c, Task_Priority__c, Task_Subject__c, ' +
		   'Task_Type__c FROM Config_Campaign__c order by id';
	   batchCampaigns cBatch = new batchCampaigns(query );
	   Database.executeBatch(cBatch); 
  	}


	static testmethod void testCampaignOwner() 		
	{
		Config_Campaign__c ccObj = new Config_Campaign__c();
		ccObj.Name = 'Test C';
		ccObj.Task_Assigned_To__c = 'Campaign Owner';
		ccObj.Task_Due_Date__c = '2';
		Insert ccObj;

		Config_User__c cuObj = new Config_User__c();
		cuObj.Config_Campaign__c = ccObj.Id;
		cuObj.User__c = UserInfo.getUserId();
		Insert cuObj;

		Account accountObj = new Account();
		accountObj.Name = 'Test Account';
		accountObj.Current_Status__c = 'Active';
		Insert accountObj;

		Contact contactObj = new Contact();
		contactObj.LastName = 'LName';
		contactObj.FirstName = 'FName';
		contactObj.AccountId = accountObj.Id;
		Insert contactObj;	
		
		string query = 'SELECT id, Name, Record_Type__c, OwnerId, ' +
			'Task_Assigned_To__c, Task_Due_Date__c, Task_Priority__c, Task_Subject__c, ' +
			'Task_Type__c, Task_Disposition__c FROM Config_Campaign__c order by id';
        batchCampaigns cBatch = new batchCampaigns(query );
        Database.executeBatch(cBatch); 
   	}

  
  	static testmethod void testRecordType() 		
  	{
	  Config_Campaign__c ccObj = new Config_Campaign__c();
	  ccObj.Name = 'Test C';
	  ccObj.Task_Assigned_To__c = 'Contact Owner';
	  ccobj.Record_Type__c = 'test';
	  ccObj.Task_Due_Date__c = '2';
	  Insert ccObj;

	  Config_User__c cuObj = new Config_User__c();
	  cuObj.Config_Campaign__c = ccObj.Id;
	  cuObj.User__c = UserInfo.getUserId();
	  Insert cuObj;

	  Account accountObj = new Account();
	  accountObj.Name = 'Test Account';
	  accountObj.Current_Status__c = 'Active';
	  Insert accountObj;

	  Contact contactObj = new Contact();
	  contactObj.LastName = 'LName';
	  contactObj.FirstName = 'FName';
	  contactObj.AccountId = accountObj.Id;
	  Insert contactObj;	
	  
	  string query = 'SELECT id, Name, Record_Type__c, OwnerId, ' +
		  'Task_Assigned_To__c, Task_Due_Date__c, Task_Priority__c, Task_Subject__c, ' +
		  'Task_Type__c FROM Config_Campaign__c order by id';
	  batchCampaigns cBatch = new batchCampaigns(query );
	  Database.executeBatch(cBatch); 
 	}

}