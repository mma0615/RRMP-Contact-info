/**
 * NCC_InvoiceControllerExtensionTest
 * @author Minh Ma 
 * @date 02/28/2021
 * @description Test class
 *
 * Update History:
 * 02/28/2021 - Initial Version
 */
@isTest (SeeAllData=True)
public inherited sharing class NCC_InvoiceControllerExtensionTest 
{
    @istest
    public static void NCC_InvoiceControllerTest() 
    {
        Krow__Invoice__c inv = [select id, name from Krow__Invoice__c where name='IN000029'];

        Test.startTest();
        NCC_InvoiceControllerExtension st = new NCC_InvoiceControllerExtension();
        ApexPages.currentPage().getParameters().put('Id', inv.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(inv); 
        st = new NCC_InvoiceControllerExtension(sc);
        
        st.invId = inv.Id;
        st.getinvoiceFieldSet();
        
        NCC_InvoiceControllerExtension.defaultFontSize = '12';
        
        for (NCC_InvoiceControllerExtension.summaryBy sBy : st.projectRoleAndRate)
        {
            sBy.getItemSubNumber();
            sBy.getName();
            sBy.getBillRate();
            sBy.getUnitOfIssue();
            sBy.getTotalAmount();
            sBy.getTotalCost();
            sBy.getTotalHours();
        }

        Test.stopTest();

    }
}