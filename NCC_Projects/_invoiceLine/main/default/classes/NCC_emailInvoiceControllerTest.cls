/**
 * NCC_emailInvoiceControllerTest
 * @author Minh Ma 
 * @date 02/28/2021
 * @description NCC_emailInvoiceController Test Class
 *
 * Update History:
 * 02/28/2021 - Initial Version
 */
@istest (SeeAllData=True)
public inherited sharing class NCC_emailInvoiceControllerTest 
{
    @istest
    public static void TestNCC_emailInvoiceController() 
    {
        Contact oCont = new Contact(FirstName='Test', LastName='LName', email='mma@abc.com');
        insert oCont;
        
		Krow__Invoice__c inv = [select id, name from Krow__Invoice__c where name='IN000029'];
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('Id', inv.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(inv); 
        NCC_emailInvoiceController st = new NCC_emailInvoiceController(sc);
        
        st.Init();   
        st.goBack();
        
        st.settingTemplateId = '00X1U000000pVP3UAM';
        st.selectedFromEmailId = oCont.Email;
        st.Project.Krow__Contact__c = oCont.Id;
        st.additionalToEmailAddress = 'abc@c.com, ddd@dd.com';
        st.ccEmailAddress = 'abc@c.com, ddd@dd.com';
        st.sendEmail();
        
        Test.stopTest();
    }
}