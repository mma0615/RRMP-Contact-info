// This schedular class run at 12:01 AM every day
global class UpdateStatusField implements Schedulable 
{
   global void execute(SchedulableContext ctx) 
   {
       
      List<VA_EHRM_SG_Inventory__c> UpdateLisytOfInventory = new List<VA_EHRM_SG_Inventory__c>();
       
      // Get the list of record that match the criteria and update the status to Off Track 
      List<VA_EHRM_SG_Inventory__c>ListOfALLInventory = [Select id,VA_EHRM_SG_Inventory_Status__c from VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Inventory_Phase__c = 'Phase 2' AND VA_EHRM_SG_Inventory_Active_Status__c = 'Active' AND VA_EHRM_SG_Inventory_Status__c != 'Determined No Update Required' AND VA_EHRM_SG_Inventory_Status__c != 'N/A' AND VA_EHRM_SG_Inventory_Status__c != 'Completed' AND ((VA_EHRM_SG_Inventory_Step__c = '1-Initiate' AND VA_EHRM_SG_Inventory_Initiate_Due_Date__c < TODAY) OR (VA_EHRM_SG_Inventory_Step__c = '2-Prepare' AND VA_EHRM_SG_Inventory_Prepare_Due_Date__c < TODAY ) OR (VA_EHRM_SG_Inventory_Step__c = '3-Preview' AND 	VA_EHRM_SG_Inventory_Preview_Due_Date__c < TODAY ) OR (VA_EHRM_SG_Inventory_Step__c = '4-Draft' AND VA_EHRM_SG_Inventory_Draft_Due_Date__c < TODAY ) OR (VA_EHRM_SG_Inventory_Step__c = '5-Package' AND VA_EHRM_SG_Inventory_Package_Due_Date__c < TODAY ) OR (VA_EHRM_SG_Inventory_Step__c = '6-Hand-Off' AND VA_EHRM_SG_Inventory_Hand_Off_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '2.1' AND VA_EHRM_SG_Inventory_Step_2_1_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '2.2' AND VA_EHRM_SG_Inventory_Step_2_2_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '2.3' AND VA_EHRM_SG_Inventory_Step_2_3_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '2.4' AND VA_EHRM_SG_Inventory_Step_2_4_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '2.5' AND VA_EHRM_SG_Inventory_Step_2_5_Due_Date__c < TODAY) OR (SG_Inventory_sub_step__c = '2.6' AND VA_EHRM_SG_Inventory_Step_2_6_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '2.7' AND VA_EHRM_SG_Inventory_Step_2_7_Due_Date__c < TODAY) OR (SG_Inventory_sub_step__c = '5.1' AND VA_EHRM_SG_Inventory_Step_5_1_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '5.2' AND VA_EHRM_SG_Inventory_Step_5_2_Due_Date__c < TODAY) OR (SG_Inventory_sub_step__c = '5.3' AND VA_EHRM_SG_Inventory_Step_5_3_Due_Date__c < TODAY) OR (SG_Inventory_sub_step__c = '5.4' AND VA_EHRM_SG_Inventory_Step_5_4_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '5.5' AND VA_EHRM_SG_Inventory_Step_5_5_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '5.6' AND VA_EHRM_SG_Inventory_Step_5_6_Due_Date__c < TODAY ) OR (SG_Inventory_sub_step__c = '5.7' AND VA_EHRM_SG_Inventory_Step_5_6_Due_Date__c < TODAY ))];
      for(VA_EHRM_SG_Inventory__c vm : ListOfALLInventory)
      {
          vm.VA_EHRM_SG_Inventory_Status__c = 'Off Track';
          UpdateLisytOfInventory.add(vm);
      }
     update UpdateLisytOfInventory;
   }   
}