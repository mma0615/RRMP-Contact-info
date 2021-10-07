/**
 * leadTriggerHandler
 * @author Minh Ma 
 * @date 09/02/2021
 * @description handle LeadConversion:
 *      1. Create household account.
 *      2. Create household vs personAccount relation 
 *      3. Associate meeting note(s) to household.
 * 
 * Update History:
 * 09/02/2021 - Initial Version
 */
public with sharing class leadTriggerHandler 
{
    set<id> leadIdSet {get;set;}
    map<id,lead> leadMap {get;set;}

    /*
    public void onBeforeInsert( List<lead> newLeadsIn )
    {
    }

    public void onBeforeUpdate( List<lead> newLeadsIn, Map<Id, lead> oldLeadsMapIn )
    { 
    }

    public void onAfterInsert( List<lead> newLeadsIn )
    {
    }
	*/

    public void onAfterUpdate( List<lead> newLeadsIn, Map<Id, lead> oldLeadsMapIn )
    {
        leadIdSet = new set<id>();
        leadMap = new map<id,lead> ();

        list<Lead> leadList = new list<lead>();
        for (lead leadO : newLeadsIn)
        {
            if (leadO.IsConverted &&
                !oldLeadsMapIn.get(leadO.id).IsConverted)
                {
                    leadIdSet.add(leadO.id);
                    leadMap.put(leadO.Id,leadO);
                    leadList.add(leadO);
                }
    
        }

        try
        {
            if (leadList.size() > 0)
                actionAfterLeadConversion(leadList);
        }
        catch (Exception e) 
        {
            System.debug('***** e.getMessage(): ' + e.getMessage() );
            newLeadsIn[0].addError(e.getMessage());
        }  
        

    }
    
    private void actionAfterLeadConversion( List<lead> newLeadsIn )
    {
        // Getting hh Record Id type
        id hhRecordId;
        id personRecordid; 
        for (recordType oRecType : [select id, name, developername, sobjecttype from recordtype 
                where sobjecttype='account'])
        {
            if (oRecType.developername=='IndustriesHousehold')
                hhRecordId=oRecType.Id;
            if (oRecType.developername=='PersonAccount')
                personRecordid=oRecType.Id;
        }

        // Creating household Accounts
        list<account> hhAccountToInsert = new list<account>();
        list<account> personAccountToUpdate = new list<account>();        
        for (lead leadO : newLeadsIn)
        {
            // prep Household Account
            account personAccount = new account();
            personAccount.id = leadO.ConvertedAccountId;
            personAccount.recordTypeId = personRecordid;
            personAccountToUpdate.add(personAccount);

            // prep Household Account
            account hhAccount = new account();
            hhAccount.Name = leadO.FirstName + ' ' + leadO.LastName;
            hhAccount.recordTypeId = hhRecordId;
            hhAccount.OwnerId = leadO.OwnerId;
            hhAccount.OASP_FSC__Email__c = leadO.Email;
            hhAccount.OASP_FSC__Rep__c = null;
            hhAccount.BillingStreet = leadO.Street;
            hhAccount.BillingCity = leadO.City;
            hhAccount.BillingState = leadO.State;
            hhAccount.BillingPostalCode = leadO.PostalCode;
            hhAccount.BillingCountry = leadO.Country;
            hhAccount.ShippingStreet = leadO.Street;
            hhAccount.ShippingCity = leadO.City;
            hhAccount.ShippingState = leadO.State;
            hhAccount.ShippingPostalCode = leadO.PostalCode;
            hhAccount.ShippingCountry = leadO.Country;
            hhAccount.Description = leadO.Id;
            
            hhAccountToInsert.add(hhAccount);
        }

        map<id,id> leadAccountMap = new map<id,id>();
        if (hhAccountToInsert.size() > 0)
        {
            insert hhAccountToInsert;

            list<AccountContactRelation> acctContRelToInsert = new list<AccountContactRelation>();
            for (account accountO : hhAccountToInsert)
            {
                AccountContactRelation acctContRelO = new AccountContactRelation();
                lead leadO = leadMap.get(accountO.Description);
                leadAccountMap.put(accountO.Description, accountO.Id);
                acctContRelO.AccountId = accountO.Id;
                acctContRelO.ContactId = leadO.ConvertedContactId;
                acctContRelO.FinServ__PrimaryGroup__c = true;
                acctContRelO.FinServ__Primary__c = true;
                acctContRelO.FinServ__Rollups__c = 'All';
                acctContRelO.Roles  = 'Client';               
                acctContRelToInsert.add(acctContRelO);

                accountO.Description = null;
            }
            if (acctContRelToInsert.size() > 0)
                insert acctContRelToInsert;
            update hhAccountToInsert;
        }

        /* meeting notes link household*/
        list<Meeting_Notes__c> meetingNotesToUpdate = new list<Meeting_Notes__c>();
        for (Meeting_Notes__c meetingNoteO :
                [select id, Household__c, Lead_Name__c from Meeting_Notes__c
                    where Lead_Name__c in :leadIdSet])
        {
            meetingNoteO.Household__c = leadAccountMap.get(meetingNoteO.Lead_Name__c);
            meetingNotesToUpdate.add(meetingNoteO);
        }

        if (meetingNotesToUpdate.size() > 0)
            update meetingNotesToUpdate;

        if (personAccountToUpdate.size() > 0)
            update personAccountToUpdate;
    }   
    

}