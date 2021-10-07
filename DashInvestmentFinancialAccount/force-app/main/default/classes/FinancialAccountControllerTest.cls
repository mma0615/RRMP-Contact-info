/*****
*   FinancialAccountControllerTest
*   @author:        Minh H Ma
*   @date:          11/15/2020
*   descrtiption:   This is the test class for FinancialAccountController
*
*   Update History:
*   11/15/2020  Intial Version
*/
@isTest
public with sharing class FinancialAccountControllerTest 
{
    @isTest static void FinancialAccountControllerTest() 
    {
        Account oAccount = new Account(Name='TestAccount');
        Insert oAccount;
        
        FSTR__Business_Process__c oBusiness_Process = new FSTR__Business_Process__c(FSTR__Business_Account__c=oAccount.Id);
        insert oBusiness_Process;

        Task oTask1 = new Task(Subject='Test Subject', whatid=oAccount.Id);
        insert oTask1;
        
        Task oTask2 = new Task(Subject='Test Subject', whatid=oBusiness_Process.Id);
        insert oTask2;
        
        OASP__Registration__c oRegistration = new OASP__Registration__c(name='Test Registration', 
                                                                        OASP__OAS_Last_Name__c='Test LastName');
        insert oRegistration;

        OASP__Financial_Account__c oFinancial_Account = new OASP__Financial_Account__c (name='FA Test', 
                                                                                        OASP__OAS_Household__c=oAccount.Id, 
                                                                                        OASP__OAS_Registration__c=oRegistration.Id);
        insert oFinancial_Account;
        
        string CONST_FIELDS = 'Id, Name ';

        Test.startTest();
        FinancialAccountController classFinancialAccountController = new FinancialAccountController();

        List<OASP__Financial_Account__c> listFinancial_Account;
        FinancialAccountController.lwcData oLWCData;
        
        oLWCData = FinancialAccountController.getRecords(oTask1.Id, CONST_FIELDS);
        listFinancial_Account = oLWCData.FinancialAccounts;
        System.assertEquals(1, listFinancial_Account.size(), 'Financial Account Record List - Account');
        
        oLWCData = FinancialAccountController.getRecords(oTask2.Id, CONST_FIELDS);
        listFinancial_Account = oLWCData.FinancialAccounts;
        System.assertEquals(1, listFinancial_Account.size(), 'Financial Account Record List - Business Process');

        Test.stopTest();
    }

}