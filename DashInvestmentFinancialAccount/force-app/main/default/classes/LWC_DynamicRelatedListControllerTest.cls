/*********************
*   LWC_DynamicRelatedListControllerTest
*   @author:        Minh H Ma
*   @date:          11/25/2020
*   descrtiption:   This is the test class for LWC_DynamicRelatedListController
*
*   Update History:
*   11/25/2020  Intial Version
*********************/
@istest
public with sharing class LWC_DynamicRelatedListControllerTest 
{
    @istest
    public static void DynamicRelatedListControllerTest()
    {
        Account oAccount = new Account(Name='TestAccount');
        Insert oAccount;
        
        FSTR__Business_Process__c oBusiness_Process = new FSTR__Business_Process__c(FSTR__Business_Account__c=oAccount.Id);
        insert oBusiness_Process;

        Task oTask1 = new Task(Subject='Test Subject', whatid=oAccount.Id);
        insert oTask1;
        
        Task oTask2 = new Task(Subject='Test Subject', whatid=oBusiness_Process.Id);
        insert oTask2;

        Task oTask3 = new Task(Subject='Test Subject');
        insert oTask3;
        
        OASP__Registration__c oRegistration = new OASP__Registration__c(name='Test Registration', 
                                                                        OASP__OAS_Last_Name__c='Test LastName');
        insert oRegistration;

        OASP__Financial_Account__c oFinancial_Account = new OASP__Financial_Account__c (name='FA Test', 
                                                                                        OASP__OAS_Household__c=oAccount.Id, 
                                                                                        OASP__OAS_Registration__c=oRegistration.Id);
        insert oFinancial_Account;

        Test.startTest();
        LWC_DynamicRelatedListController LWC_DynamicRelatedList = new LWC_DynamicRelatedListController();
        
        LWC_DynamicRelatedListController.lwcData theData1 = LWC_DynamicRelatedListController.getRecords(
            oTask1.Id, 
            'Account', 
            'OASP__Financial_Account__c', 
            'OASP__OAS_Household__c', 
            'FA_Set');
        System.assertEquals(1, theData1.listRecord.size(), 'Financial Account Record List - Account');

        LWC_DynamicRelatedListController.lwcData theData2 = LWC_DynamicRelatedListController.getRecords(
                    oTask2.Id, 
                    'Account', 
                    'OASP__Financial_Account__c', 
                    'OASP__OAS_Household__c', 
                    'FA_Set');
        System.assertEquals(1, theData2.listRecord.size(), 'Financial Account Record List - Bussiness Process');

        LWC_DynamicRelatedListController.lwcData theData3 = LWC_DynamicRelatedListController.getRecords(
                    oTask3.Id, 
                    'Account', 
                    'OASP__Financial_Account__c', 
                    'OASP__OAS_Household__c', 
                    'FA_Set');
        System.assertEquals(0, theData3.listRecord.size(), 'Task with no WhatId');
        
        /**** Test Custom IconName */
        //string iconName = FinancialAccountController.getIconName('OASP__Financial_Account__c');
        //system.debug('*****Custom iconName: ' + iconName);
        //System.assert(iconName != null, 'Custom iconName not found');
        
        /**** Test Standard IconName */
        //iconName = FinancialAccountController.getIconName('Account');
        //system.debug('***** Standard iconName: ' + iconName);
        //System.assert(iconName != null, 'Standard iconName not found');

        Test.stopTest();
    }
}