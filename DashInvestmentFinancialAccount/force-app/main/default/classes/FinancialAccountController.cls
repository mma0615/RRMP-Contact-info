/*
*   FinancialAccountController
*   @author:        Minh H Ma
*   @date:          11/20/2020
*   descrtiption:   This is to display OASP__Financial_Account__c related list from TASK
*
*   Update History:
*   11/20/2020  Intial Version
*/
public with sharing class FinancialAccountController 
{
    public FinancialAccountController() { }

    /*****
     * Querying list of records
     */
    @AuraEnabled(Cacheable = true)
    public static lwcData getRecords(id parmId, string fields)
    {
        //parmId ='00T3i00000csrscEAA';
        System.debug('ParmId ====> ' + parmId);

        lwcData oLWCData = new lwcData();
        oLWCData.parentId = getParentId(parmId);

        if (oLWCData.parentId != null) 
        {            
            String query = 'SELECT ' + fields + 
                ' FROM OASP__Financial_Account__c ' +
                ' where OASP__OAS_Household__c=\'' + oLWCData.parentId + '\'' +
                ' limit 100';
            System.debug('query ====> '+ query);

            oLWCData.FinancialAccounts = Database.query(query);
        }

        System.debug('parentId ====> ' + oLWCData.ParentId);
        System.debug('record Count ====> ' + oLWCData.FinancialAccounts.size() );
        return oLWCData;
       
    }

    private static id getParentId (id parmId)
    {
        id parentId;
        List<Task> listTask = [select whatid from task where id = :parmId];
        if (listTask.size() > 0)
        {
            String stringId = listTask[0].whatId;
            if ( stringId.Mid(0,3) == '001')
                parentId = stringId;
            else 
            {    
                    List<FSTR__Business_Process__c> listBusiness_Process =
                        [select id, FSTR__Business_Account__c from FSTR__Business_Process__c
                            where id= :stringId];
                    parentId = listBusiness_Process[0].FSTR__Business_Account__c; 
            }
        }

        return parentId;
    }

    /*****
     * lwcData
    */
    public with sharing class lwcData 
    {
        @AuraEnabled public id parentId;
        @AuraEnabled public List<OASP__Financial_Account__c> FinancialAccounts;

        public lwcData() {}
    }

}