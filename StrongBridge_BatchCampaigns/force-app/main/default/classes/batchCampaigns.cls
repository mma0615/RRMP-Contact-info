/**
 * Class: batchCampaigns
 *
 * Purpose: Batch job to be launched 1st day of the month to create campaign(s) from Config_Campaign__c &
 *          Config_Campaign_User__c objects.
 * 
 *          1.	A Campaign for each Patient Account Owner for Active Patients determined by the Current Status field
 *          2.	Tasks associated with each of those Campaigns and the Patient

 * 
 *          Path using: 
 *          Users --> Account Object using Account's Owner --> Contact Object using AccountId (only active patients)
 * 
 * Where Referenced:
 *   apex class: batchCampaignsSchedule
 *
 * Change History:
 *
 * Developer        Date            Description
 * -----------------------------------------------------------------------
 * Minh Ma          04/30/2020      Initial Development
 * 
 */
global class batchCampaigns implements Database.Batchable<SObject>
{
    String strQuery;
    
    global batchCampaigns(string q)
    {            
        this.strQuery = q;
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {    
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Config_Campaign__c> pCCList)
    {           
    
        System.debug('****** Query String *****' + this.strQuery);
        
        /* Populating: 
            list of campaigns to insert
            set of campaigns     */            
        Set<id> ccIdSet = new Set<id>();
        List<Campaign> campaignToInsert = new List<Campaign>();

        try 
        {
            for (Config_Campaign__c CCObj : pCCList)
            {
                DateTime dt = Datetime.now();

                ccIdSet.Add(CCObj.Id);

                /* Populating: 
                    set of userId from Config_User__c      */
                Set<id> userIdSet = new Set<id>();    
                for (Config_User__c CUObj : [select Config_Campaign__c, User__c from Config_User__c where Config_Campaign__c in :ccIdSet] )
                {
                    userIdSet.Add(CUObj.User__c);
                }
    
                /* Populating: 
                    set of accountId & map of (accountid,ownerid) from set of userid     */    
                set<id> accountIdSet = new set<id>();
                set<id> accountOwnerIdSet = new set<id>();
                map<id,id> accountOwnerMap = new map<id,id>();
                for (Account accountObj :[select Id, recordtypeId, OwnerId, Current_Status__c 
                            from account where Ownerid in :userIdSet and Current_Status__c='Active'])
                {
                    if (CCObj.Record_Type__c == null ||
                        CCObj.Record_Type__c == accountObj.RecordTypeId)
                        {
                            accountIdSet.Add(accountObj.Id);
                            accountOwnerIdSet.Add(accountObj.OwnerId);
                            accountOwnerMap.put(accountObj.Id, accountObj.OwnerId);
                        }
                    
                }

                Campaign campaignObj = new Campaign();
                campaignObj.Name = dt.format('MMM') + ' ' +  CCObj.Name;
                campaignObj.OwnerId = CCObj.OwnerId;
                campaignObj.IsActive = true;
                campaignToInsert.Add(campaignObj );

                /* Populated list of campaing to insert from related Onwers */
                Map<id,string> ownerNameMap = new Map<id,string>();
                for (User userObject : [select id, name from user where id in :accountOwnerIdSet])
                {
                    ownerNameMap.Put(userObject.Id,userObject.Name);
                }

                /* Insert campaign */
                System.debug('****** campaignToInsert.size() *****' + campaignToInsert.size() );
                System.debug('****** accountIdSet.size() *****' + accountIdSet.size() );
                if (campaignToInsert.size() > 0 &&
                    accountIdSet.size() <> 0)
                    Insert campaignToInsert;

                /* Populate map of Owner and Campaign Ids */
                //map<id,id> ownerCampaignMap = new map<id,id>();
                //for (campaign campaignObj : campaignToInsert)
                //{
                //    ownerCampaignMap.put(campaignObj.OwnerId, campaignObj.Id);
                //}

                /* Popululating Task to Insert */
                List<Task> taskToInsert = new List<Task>();
                List<CampaignMember> campaignMemberToInsert = new List<CampaignMember>();
                for (Contact contactObj : [select id, accountId, ownerId from Contact 
                        where accountid in :accountIdSet])
                {
                    Task taskObj = new Task();
                    taskObj.Priority = CCObj.Task_Priority__c;
                    taskObj.Type = CCObj.Task_Type__c;
                    taskObj.Task_Type__c = CCObj.Task_Type__c;
                    taskObj.CallDisposition = CCObj.Task_Disposition__c;
                    
                    if (CCObj.Task_Assigned_To__c == 'Account Owner')
                        taskObj.OwnerId = accountOwnerMap.get(contactObj.accountId);
                    else if (CCObj.Task_Assigned_To__c == 'Contact Owner')
                        taskObj.OwnerId = contactObj.OwnerId;
                    else if (CCObj.Task_Assigned_To__c == 'Campaign Owner')
                        taskObj.OwnerId = campaignToInsert[0].OwnerId;

                    taskObj.ActivityDate = date.today().toStartOfMonth().addDays(integer.valueof(CCObj.Task_Due_Date__c) - 1);
                    //taskObj.ActivityDate = date.today().addMonths(0).toStartOfMonth().addDays(integer.valueof(CCObj.Task_Due_Date__c) - 1);

                    //taskObj.Subject = ownerNameMap.get(accountOwnerMap.get(contactObj.accountId)) + ' ' +
                    //    dt.format('MMM') + ' ' +
                    //    CCObj.Task_Subject__c;
                    taskObj.Subject = CCObj.Task_Subject__c;

                    taskObj.WhoId = contactObj.Id;
                    taskObj.WhatId = campaignToInsert[0].Id;
                    taskObj.Campaign__c = campaignToInsert[0].Id;
                    
                    taskToInsert.Add(taskObj);

                    CampaignMember campaignMemberObj = new CampaignMember();
                    campaignMemberObj.CampaignId = campaignToInsert[0].Id;
                    campaignMemberObj.ContactId = contactObj.Id;
                    campaignMemberToInsert.add(campaignMemberObj);

                }
    
                /* Insert Tasks */    
                System.debug('****** taskToInsert.size() *****' + taskToInsert.size() );
                if (taskToInsert.size() > 0)
                    Insert taskToInsert;
                    
                /* Insert campaignMember */    
                System.debug('****** campaignMemberToInsert.size() *****' + campaignMemberToInsert.size() );
                if (campaignMemberToInsert.size() > 0)
                    Insert campaignMemberToInsert;  
            }
            
        } 
        catch (Exception e) 
        {
            System.Debug ('***** Error: ' + e.getMessage() );
        }
    }
        
    global void finish(Database.BatchableContext BC)
    {
    
    }           

}