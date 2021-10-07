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
public with sharing class PDFViewControllerTest 
{
    @istest
    public static void TestFlowVariablesWrapper() 
    {
        FlowVariablesWrapper oW = new FlowVariablesWrapper();
        oW.field1 = 'TestField1';
        oW.field2 = 'TestField2';
        oW.field3 = 'TestField3';
        oW.field4 = 'TestField4';
        oW.field5 = 'TestField5';
        oW.field6 = 'TestField6';
    }
    
    @istest
    public static void TestPDFViewController() 
    {       
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser )  
        {
            Account oAccount = new Account(Name='TestAccount');
        	Insert oAccount;
        	System.debug('Account Inserted');
            
			EmailTemplate oTemplate = new EmailTemplate();
        	oTemplate.Name = 'Testform';
        	oTemplate.DeveloperName = 'Testform';
            oTemplate.TemplateType = 'custom';
            oTemplate.FolderId = UserInfo.getUserId();
        	oTemplate.HtmlValue = '<html style="overflow-y: hidden;"><head><title></title></head>' +
                '<body style="height: auto; min-height: auto;">contactname: {contactname}<br />' + 
                '<br />repname: {repname}<br /><br />Batter: {batterlist}</body></html>';
        	insert oTemplate;

        	System.debug('EmailTemplate Inserted');
        
        	string formParameters = '{"contactname":"Jim","repname":"Matt","batterlist":[{"type" : "Chocolate","id" : "123"},{"type" : "Vanilla","id" : "456"}]}';
        
        	Test.startTest();
            
            ApexPages.currentPage().getParameters().put('displayText', oTemplate.HtmlValue);
            PDFViewController p = new PDFViewController();
            
            PDFViewController.generatePDF(oTemplate.Name, oAccount.Id, formParameters);
            
            PDFViewController.generatePDF('oTemplate.Name', oAccount.Id, formParameters);
                    
        	Test.stopTest();
    	}

    }
}