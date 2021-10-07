@isTest
/**
 * calculateExpensesTest
 * @author Minh Ma 
 * @date 02/12/2021
 * @description This tests:
 *      calculateExpenses
 *      expenseHandler
 *      expenseTrigger
 *      projectAssignmentHandler
 *      projectAssignmentTrigger
 *
 * Update History:
 * 02/12/2021 - Initial Version
 */
public inherited sharing class calculateExpensesTest 
{
    static testMethod void testcalculateExpenses()
    {
        Krow__Billing_Type__c billType = new Krow__Billing_Type__c();
        billType.Name = 'Cash';
        billType.Krow__Billing_Method__c = 'Cash';
        insert billType;

        Date todayDate = Date.today();
        Krow__Project__c testProject1 = new Krow__Project__c(
            Krow__Project_Start_Date__c = todayDate,
            Krow__Project_End_Date__c = todayDate.addDays(8),
            Krow__Billing_Type__c = billType.Id,
            Krow__Expected_Revenue__c = 1500.00);
        insert testProject1;

        Krow__Project__c testProject2 = new Krow__Project__c(
            Krow__Project_Start_Date__c = todayDate,
            Krow__Project_End_Date__c = todayDate.addDays(8),
            Krow__Billing_Type__c = billType.Id,
            Krow__Expected_Revenue__c = 1500.00);
        insert testProject2;
        
        Krow__Organization__c org = new Krow__Organization__c(
            Name = 'testOrg',
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

        Krow__Krow_Role__c devRole = new Krow__Krow_Role__c(
            Name='Developer Manager', Krow__Active__c = true);
        insert devRole;
            
        Krow__Project_Resources__c projRes1 = new Krow__Project_Resources__c(
            Name = 'projResource1',
            Krow__Active__c = true,
            Krow__Vendor__c = org.Id,
            Krow__External_Resource__c = true,
            Krow__Project_Role__c = devRole.Id);
        insert projRes1;

        Krow__Project_Resources__c projRes2 = new Krow__Project_Resources__c(
            Name = 'projResource2',
            Krow__Active__c = true,
            Krow__Vendor__c = org.Id,
            Krow__External_Resource__c = true,
            Krow__Project_Role__c = devRole.Id);
        insert projRes2;
        
        Krow__Project_Assignment__c projAssign1 = new Krow__Project_Assignment__c(
            Krow__Krow_Project__c = testProject1.Id,
            Krow__Project_Resource__c = projRes1.Id);
        insert projAssign1;

        Krow__Project_Assignment__c projAssign2 = new Krow__Project_Assignment__c(
            Krow__Krow_Project__c = testProject2.Id,
            Krow__Project_Resource__c = projRes2.Id);
        insert projAssign2;

        Krow__Expense_Krow__c expKrow = new Krow__Expense_Krow__c(
            Krow__Krow_Project__c = testProject1.Id,
            Krow__Approval_Status__c = 'Approved',
            Krow__Project_Resource__c = projRes1.Id);
        insert expKrow;
        
        Krow__Expense_Type__c expType = new Krow__Expense_Type__c(
            Name = 'testExpanceType');
        insert expType;
        
        Krow__Expense_Line__c expLine = new Krow__Expense_Line__c(
            Krow__Expense_Date__c = Date.today(),
            Krow__Expense_Amount__c = 100, 
            Krow__Expense__c = expKrow.Id,
            Krow__Billable__c = true,
            Krow__Expense_Type__c = expType.Id);
        insert expLine;

        Test.startTest();

        System.assertEquals(100, getAmount(projAssign1.Id), 'After Krow__Project_Assignment__c Inserted');
        
        // initial calculateExpenses on Project Assigment
        ApexPages.currentPage().getParameters().put('Id', projAssign1.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(projAssign1); 
        calculateExpenses st = new calculateExpenses(sc);
        System.assertEquals(st.Id, projAssign1.Id);
        
        st.projectAssignmentCalcExpenseActual();
        System.assertEquals(100, getAmount(projAssign1.Id));
        
        // initial calculateExpenses on Project
        ApexPages.currentPage().getParameters().put('Id', testProject1.Id);
        ApexPages.StandardController scProj = new ApexPages.StandardController(projAssign1); 
        calculateExpenses stProj = new calculateExpenses(scProj);
        System.assertEquals(stProj.Id, testProject1.Id);

        // project assignment
        projAssign1.Krow__Project_Resource__c = projRes2.Id;
        update projAssign1;

        System.assertEquals(0, getAmount(projAssign1.Id), 'After Krow__Project_Assignment__c Updated');

        delete projAssign1;
        System.assertEquals(null, getAmount(projAssign1.Id), 'After Krow__Project_Assignment__c Deleted');

        undelete projAssign1;
        System.assertEquals(0, getAmount(projAssign1.Id), 'After Krow__Project_Assignment__c Undeleted');
                
        // Resource
        expKrow.Krow__Krow_Project__c = testProject2.Id;
        expKrow.Krow__Project_Resource__c = projRes2.Id;
        update expKrow;
        System.assertEquals(100, getAmount(projAssign2.Id), 'After Krow__Expense_Krow__c Updated');
        
        expKrow.Krow__Approval_Status__c = 'Recalled';
        update expKrow;
        System.assertEquals(0, getAmount(projAssign2.Id), 'After Krow__Expense_Krow__c Status Recalled Updated');
        
        expKrow.Krow__Approval_Status__c = 'Approved';
        update expKrow;
        System.assertEquals(100, getAmount(projAssign2.Id), 'After Krow__Expense_Krow__c Status Approved Updated');

        delete expKrow;
        System.assertEquals(0, getAmount(projAssign2.Id), 'After Krow__Expense_Krow__c Deleted');

        undelete expKrow;
        System.assertEquals(100, getAmount(projAssign2.Id), 'After Krow__Expense_Krow__c Undeleted');

        Test.stopTest();
    }

    static Decimal getAmount(id inId)
    {
        Decimal amount;
        
        for (Krow__Project_Assignment__c proj : [select Expense_Actuals__c 
                from Krow__Project_Assignment__c where id = :inId] )
        {
            amount = proj.Expense_Actuals__c;
        }
        
        return amount;
    }
}