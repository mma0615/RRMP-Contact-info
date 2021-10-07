global class batchCampaignsSchedule implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {   		    		    			
    	// Run the batch job
        string query = 'SELECT id, Name, Record_Type__c, OwnerId, ' +
            'Task_Assigned_To__c, Task_Due_Date__c, Task_Priority__c, Task_Subject__c, ' +
            'Task_Type__c, Task_Disposition__c FROM Config_Campaign__c order by id';
            batchCampaigns cBatch = new batchCampaigns(query );

        /* batchsize MUST be 1 */
        Database.executeBatch(cBatch, 1); 
    }
         
}