@istest
public with sharing class batchCampaignsScheduleTest 
{
	static testmethod void test() {
		
   		Test.startTest();
		batchCampaignsSchedule sh1 = new batchCampaignsSchedule();     	
		String sch = '0 0 23 * * ?'; 
		system.schedule('Test', sch, sh1); 
		Test.stopTest();
   }
   
}