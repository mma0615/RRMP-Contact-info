/*********************
*   FinancialAccountControllerTest
*   @author:        Minh H Ma
*   @date:          11/15/2020
*   descrtiption:   This is the test class for FinancialAccountController
*
*   Update History:
*   11/15/2020  Intial Version
*********************/
@istest
public with sharing class LWC_DynamicRelatedListControllerTest 
{
    public LWC_DynamicRelatedListControllerTest() 
    {
        Account oAccount = new Account(Name='TestAccount');
        Insert oAccount;

        Task oTask = new Task(Subject='Test Subject', whatid=oAccount.Id);
        insert oTask;
        /*************** 
        OASP__Registration__c oRegistration = new OASP__Registration__c(name='Test Registration', 
                                                                        OASP__OAS_Last_Name__c='Test LastName');
        insert oRegistration;

        OASP__Financial_Account__c oFinancial_Account = new OASP__Financial_Account__c (name='FA Test', 
                                                                                        OASP__OAS_Household__c=oAccount.Id, 
                                                                                        OASP__OAS_Registration__c=oRegistration.Id);
        insert oFinancial_Account;

        Test.startTest();
        FinancialAccountController classFinancialAccountController = new FinancialAccountController();

        List<OASP__Financial_Account__c> listFinancial_Account;

        listFinancial_Account = FinancialAccountController.getRecords(oTask.Id);
        System.assertEquals(1, listFinancial_Account.size(), 'Financial Account Record List');

        string fieldType = FinancialAccountController.getFieldTypes('OASP__Financial_Account__c');
        System.assert(fieldType != null, 'FieldSet not found');

        listFinancial_Account = FinancialAccountController.getRecords(null);
        System.assertEquals(0, listFinancial_Account.size(), 'Financial Account Record List');
        
        /**** Test Custom IconName */
        //string iconName = FinancialAccountController.getIconName('OASP__Financial_Account__c');
        //system.debug('*****Custom iconName: ' + iconName);
        //System.assert(iconName != null, 'Custom iconName not found');
        
        /**** Test Standard IconName */
        //iconName = FinancialAccountController.getIconName('Account');
        //system.debug('***** Standard iconName: ' + iconName);
        //System.assert(iconName != null, 'Standard iconName not found');

        //Test.stopTest();
    }
}
