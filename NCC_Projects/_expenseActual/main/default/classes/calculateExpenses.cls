/**
 * calculateExpenses
 * @author Minh Ma 
 * @date 02/12/2021
 * @description This is a utility class that is used to roll up Expense Actual amount from
 *          Krow__Expense_Krow__c to Krow__Project_Assignment__c
 *
 * Update History:
 * 02/12/2021 - Initial Version
 */
public without sharing class calculateExpenses 
{
    public Id Id { get; set; }
    public list<id> projectIds {get; set;}
    public list<id> resourceIds {get; set;}
    public Krow__Project_Assignment__c projectAssignment {get; set;}
    //public Krow__Project__c project {get; set;}

    //constructor to get the Krow__Project_Assignment__c record
    public calculateExpenses(ApexPages.StandardController controller) 
    {
        projectIds = new list<id>();
        resourceIds = new list<id>();

        Id = ApexPages.currentPage().getParameters().get('id');

        string objType =  String.Valueof(Id.getsobjecttype());
        System.debug('object is '+ Id.getsobjecttype());

        if (objType == 'Krow__Project_Assignment__c')
        {
            projectAssignment = [select id, Krow__Krow_Project__c, Krow__Project_Resource__c
                from Krow__Project_Assignment__c where id = :Id limit 1];

            projectIds.add(projectAssignment.Krow__Krow_Project__c);
            resourceIds.add(projectAssignment.Krow__Project_Resource__c);
        }
        else if (objType == 'Krow__Project__c') 
        {
            projectIds.Add(Id);
            List<Krow__Project_Assignment__c> Project_AssignmentList = 
                [select id, Krow__Krow_Project__c, Krow__Project_Resource__c, Expense_Actuals__c 
                    from Krow__Project_Assignment__c where Krow__Krow_Project__c = :Id];
            for (Krow__Project_Assignment__c oProject_Assignment : Project_AssignmentList)
            {
                resourceIds.Add(oProject_Assignment.Krow__Project_Resource__c);
            }
        }
        
        System.debug('calculateExpenses ==> projectIds: ' + projectIds);
        System.debug('calculateExpenses ==> resourceIds: ' + resourceIds);
    }

    //Method that can is called from the Visual Force page action attribute
    public PageReference projectAssignmentCalcExpenseActual() 
    {
        System.debug('projectAssignmentCalcExpenseActual ==> projectIds: ' + projectIds);
        System.debug('projectAssignmentCalcExpenseActual ==> resourceIds: ' + resourceIds);
        calculateExpenseActual(projectIds, resourceIds);

         //build your code logic here
        PageReference pageRef = new PageReference('/'+Id);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the project assignment page
    }

    public static void calculateExpenseActual(list<id> projectIds, list<id> resourceIds) 
    {
        // get list of billable expenses
        List<Krow__Expense_Krow__c> expenseList = new List<Krow__Expense_Krow__c>();
        expenseList = [select id, Krow__Billable_Total__c, Krow__Krow_Project__c, Krow__Project_Resource__c
            from Krow__Expense_Krow__c
            where (Krow__Krow_Project__c in :projectIds and
                    Krow__Project_Resource__c in :resourceIds) and
                Krow__Approval_Status__c = 'Approved' and
                Krow__Billable_Total__c <> 0];
        system.debug('expenseList: ' + expenseList.size());

        // get list of project assignment
        List<Krow__Project_Assignment__c> projectAssignmentList = new List<Krow__Project_Assignment__c>();
        projectAssignmentList = [select id, Krow__Krow_Project__c, Krow__Project_Resource__c
            from Krow__Project_Assignment__c
            where Krow__Krow_Project__c  in :projectIds and
                    Krow__Project_Resource__c in :resourceIds];
        system.debug('projectAssignmentList: ' + projectAssignmentList.size());

        // Prep for list of project assignment to update
        List<Krow__Project_Assignment__c> projectAssignmentToUpdate = new List<Krow__Project_Assignment__c>();
        for (Krow__Project_Assignment__c proj : projectAssignmentList)
        {
            proj.Expense_Actuals__c = 0;
            for (Krow__Expense_Krow__c exp : expenseList)
            {
                if (proj.Krow__Krow_Project__c == exp.Krow__Krow_Project__c &&
                    proj.Krow__Project_Resource__c == exp.Krow__Project_Resource__c)
                    proj.Expense_Actuals__c += exp.Krow__Billable_Total__c;
            }
            projectAssignmentToUpdate.add(proj);

            system.debug('proj.Expense_Actuals__c: ' + proj.Expense_Actuals__c);
            system.debug('proj: ' + proj);
        }
        system.debug('projectAssignmentToUpdate: ' + projectAssignmentToUpdate.size());

        // updating project assigment
        if (projectAssignmentToUpdate.size() > 0)
        {
            update(projectAssignmentToUpdate);
            system.debug('Done Updating');
        }    
    }
}