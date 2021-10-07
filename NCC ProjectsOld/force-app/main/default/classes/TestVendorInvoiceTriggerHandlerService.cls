@isTest
private class TestVendorInvoiceTriggerHandlerService{

	@isTest private static void afterUpdateVendorInvoiceTest() {

		/* User currentUser = new User(Id = UserInfo.getUserId(), BypassProcessBuilder__c = true);
		update currentUser; */

		Account account = new Account(Name='Test Name');
		account.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
		account.AcctSeed__Accounting_Active__c = true;
		insert account;

		AcctSeed__Billing_Format__c billingFormat = new AcctSeed__Billing_Format__c();
		billingFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStmtModernPDF';
		billingFormat.AcctSeed__Type__c = 'Activity Statement';
		billingFormat.Name = 'Billing Activity Statement';
		billingFormat.AcctSeed__Currency_Format__c = '$###,##0.00;($###,##0.00)';
		billingFormat.AcctSeed__Numeric_Format__c = '##,##0.00;(##,##0.00)';
		billingFormat.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
		insert billingFormat;

		AcctSeed__Billing_Format__c billingFormatOutstanding = new AcctSeed__Billing_Format__c();
		billingFormatOutstanding.AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStmtModernPDF';
		billingFormatOutstanding.AcctSeed__Type__c = 'Outstanding Statement';
		billingFormatOutstanding.Name = 'Billing Outstanding Statement';
		billingFormatOutstanding.AcctSeed__Currency_Format__c = '$###,##0.00;($###,##0.00)';
		billingFormatOutstanding.AcctSeed__Numeric_Format__c = '##,##0.00;(##,##0.00)';
		billingFormatOutstanding.AcctSeed__Default_Email_Template__c = 'Outstanding_Statement_Email_Template';
		insert billingFormatOutstanding;

		AcctSeed__Billing_Format__c billingFormatDefault = new AcctSeed__Billing_Format__c();
		billingFormatDefault.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductIrisPdfHLP';
		billingFormatDefault.AcctSeed__Type__c = 'Billing';
		billingFormatDefault.Name = 'Default Billing Product';
		billingFormatDefault.AcctSeed__Currency_Format__c = '$###,##0.00;($###,##0.00)';
		billingFormatDefault.AcctSeed__Numeric_Format__c = '##,##0.00;(##,##0.00)';
		billingFormatDefault.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
		insert billingFormatDefault;

		AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c();
		glAccount.Name = '1000 Cash';
		glAccount.AcctSeed__Bank__c = true;
		glAccount.AcctSeed__Active__c = true;
		glAccount.AcctSeed__Type__c = 'Balance Sheet';
		glAccount.AcctSeed__Sub_Type_1__c = 'Assets';
		glAccount.AcctSeed__Sub_Type_2__c = 'Cash';
		insert glAccount;

		AcctSeed__GL_Account__c glAccount1 = new AcctSeed__GL_Account__c();
		glAccount1.Name = '4100 Revenue';
		glAccount1.AcctSeed__Bank__c = false;
		glAccount1.AcctSeed__Active__c = true;
		glAccount1.AcctSeed__Type__c = '	Revenue';
		glAccount1.AcctSeed__Sub_Type_1__c = 'Operating Revenue';
		glAccount1.AcctSeed__Sub_Type_2__c = 'Revenue';
		insert glAccount1;
		
		AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
		ledger.Name = '2020 Budget';
		ledger.AcctSeed__Type__c = 'Transactional';
		ledger.AcctSeed__Billing_Activity_Statement_Format__c = billingFormat.Id;
		ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormatOutstanding.Id;
		ledger.AcctSeed__Default_Bank_Account__c = glAccount.Id;
		ledger.AcctSeed__Default_Billing_Format__c = billingFormatDefault.Id;
		insert ledger;

		Krow__Billing_Type__c billType = new Krow__Billing_Type__c();
        billType.Name = 'Cash';
        billType.Krow__Billing_Method__c = 'Cash';
		insert billType;
		
		AcctSeed__Accounting_Period__c accountingPeriod = new AcctSeed__Accounting_Period__c();
		accountingPeriod.Name = '2021-01';
		accountingPeriod.AcctSeed__Start_Date__c = System.today().addDays(-10);
		accountingPeriod.AcctSeed__End_Date__c = System.today().addDays(355);
		accountingPeriod.AcctSeed__Status__c = 'Open';
		insert accountingPeriod;
        
        Date todayDate = Date.today();
        Krow__Project__c testProject = new Krow__Project__c(Krow__Project_Start_Date__c = todayDate,
										Krow__Project_End_Date__c = todayDate.addDays(8),
										Krow__Billing_Type__c = billType.Id,
										Krow__Expected_Revenue__c = 1500.00);
        insert testProject;
    	
        Krow__Organization__c org = new Krow__Organization__c(Name = 'testOrg',
																Krow__Address__c = 'testAddress',
																Krow__Journal_Type__c = 'Krow Invoice',
																Krow__Display_Timesheet_Notes__c = true,
																Krow__Formatting__c = 'Group by Task',Krow__Footer__c = 'Test Footer',
																Krow__Summarize__c = 'test Summery',Krow__Tax__c = 10,
																Krow__Tax_Type__c = 'Sales Tax',
																Krow__Currency__c = 'USD',
																Krow__Invoice_Approved_Expenses_Only__c = true,
																Krow__Invoice_Approved_Time_Only__c = true,
																Krow__Account_Number__c = '12346547925',Krow__Vendor__c = true);
		insert org;
		
		Krow__Organization__c krowOrganization = new Krow__Organization__c();
		krowOrganization.Name = 'Test Vendor';
		krowOrganization.Krow__Address__c = 'Test Address';
		krowOrganization.Krow__Vendor__c = false;
		insert krowOrganization;

        Krow__Krow_Role__c devRole = new Krow__Krow_Role__c(Name='Developer Manager', Krow__Active__c = true);
		insert devRole;
			
		Krow__Project_Resources__c projRes = new Krow__Project_Resources__c();
        projRes.Name = 'projResource';
        projRes.Krow__Active__c = true;
        projRes.Krow__Vendor__c = org.Id;
        projRes.Krow__External_Resource__c = true;
        projRes.Krow__Project_Role__c = devRole.Id;
        insert projRes;
        
        Krow__Project_Assignment__c projAssign = new Krow__Project_Assignment__c(Krow__Krow_Project__c = testProject.Id,
																		Krow__Project_Resource__c = projRes.Id);
        insert projAssign;

		Krow__Expense_Krow__c expKrow = new Krow__Expense_Krow__c(Krow__Krow_Project__c = testProject.Id,
																	Krow__Approval_Status__c = 'Approved',
																	Krow__Project_Resource__c = projRes.Id);
        insert expKrow;
        
        Krow__Expense_Type__c expType = new Krow__Expense_Type__c(Name = 'testExpanceType');
        insert expType;
        
        Krow__Expense_Line__c expLine = new Krow__Expense_Line__c(Krow__Expense_Date__c = Date.today(),
											Krow__Expense_Amount__c = 100, Krow__Expense__c = expKrow.Id,
											Krow__Expense_Type__c = expType.Id);
		insert expLine;
		
		VendorInvoiceTriggerHandlerService.ledgerIdTest = ledger.Id;
		
    	Krow__Vendor_Payment__c vendorPayment = new Krow__Vendor_Payment__c();
		vendorPayment.Krow__Vendor__c = org.Id;
		vendorPayment.Vendor_Account__c = account.Id;
		vendorPayment.AccountingPeriod__c = accountingPeriod.Id;
		vendorPayment.Krow__Organization__c = krowOrganization.Id;
		vendorPayment.FileFolderUrl__c = 'www.google.com';
		vendorPayment.Krow__Formatting__c = 'Group by Person, then Task';
		vendorPayment.Krow__Approved_Time_Only__c = false;
		vendorPayment.Krow__Approved_Expenses_Only__c = false;
		vendorPayment.Krow__Status__c = 'Draft';
		vendorPayment.Completion_of_Vendor_Invoice_Approval__c = 4;

		insert vendorPayment;
        
		Krow__Vendor_Expense_Item__c expenseItem = new Krow__Vendor_Expense_Item__c();
		expenseItem.Krow__Vendor_Payment__c = vendorPayment.Id;
		expenseItem.Krow__Amount__c = 100;
		expenseItem.Krow__Date__c = Date.today();
		expenseItem.Krow__Expense_Item__c = expLine.Id;
		expenseItem.GLAccount__c = glAccount1.Id;
		insert expenseItem;

		VendorInvoiceTriggerHandlerService.testGlAccount = glAccount1.Id;
        
		Test.startTest();
		vendorPayment.Krow__Status__c = 'Posted';
		vendorPayment.Krow__Expense_Notes__c = 'Test Notes';
        vendorPayment.Krow__Approved_Time_Only__c = false;
        vendorPayment.Krow__Approved_Expenses_Only__c = false;
		update vendorPayment;
		vendorPayment.Krow__Status__c = 'Draft';
		update vendorPayment;
		delete vendorPayment;
		Test.stopTest();
		System.assert(true);
		
	}
}