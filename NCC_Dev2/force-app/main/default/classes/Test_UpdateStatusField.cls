@isTest
public class Test_UpdateStatusField 
{
	@TestSetup
    static void createInventory()
    {
        Date myDate = Date.newInstance(2020, 04, 01);
		VA_EHRM_SG_Inventory__c newVAEHRMSGInventory =new VA_EHRM_SG_Inventory__c();
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Status__c='On Track';
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Step__c='1-Initiate';
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Initiate_Start_Date__c=myDate;
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Initiate_Due_Date__c=myDate.addDays(1);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Prepare_Start_Date__c=myDate.addDays(2);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Prepare_Due_Date__c=myDate.addDays(3);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Preview_Start_Date__c=myDate.addDays(4);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Preview_Due_Date__c=myDate.addDays(5);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Draft_Start_Date__c=myDate.addDays(6);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Draft_Due_Date__c=    myDate.addDays(7);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Package_Start_Date__c=myDate.addDays(8);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Package_Due_Date__c=myDate.addDays(9);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c=myDate.addDays(10);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Hand_Off_Due_Date__c=myDate.addDays(11);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Receive_Start_Date__c=myDate.addDays(12);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Receive_Due_Date__c=myDate.addDays(13);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Title__c='Testing Data';
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Update_Priority__c='High';
        newVAEHRMSGInventory.VA_EHRM_SG_Council_Workgroup__c='Case Management';
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Active_Status__c='Active';
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Phase__c='Phase 2';
        


        insert newVAEHRMSGInventory;     
    }
    
    @isTest
    public static void scheduleUpdateJob()
    {
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('AutomaticFieldUpdate', CRON_EXP, new UpdateStatusField());
    }
}