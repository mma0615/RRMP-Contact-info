/**
 * projectAssignmentHandler
 * @author Minh Ma 
 * @date 02/12/2021
 * @description expense handler for Krow__Project_Assignment__c trigger
 *
 * Update History:
 * 02/12/2021 - Initial Version
 */
public with sharing class projectAssignmentHandler 
{
    public void onAfterInsert( List<Krow__Project_Assignment__c> newList )
    {
        calculateExpenses(newList);
    }

    public void onAfterUpdate( List<Krow__Project_Assignment__c> newList, 
                               Map<Id, Krow__Project_Assignment__c> oldMap )
    {
        List<Krow__Project_Assignment__c> objList = new List<Krow__Project_Assignment__c>();
        // Populating new values
        for (Krow__Project_Assignment__c newObj : newList)
        {
            Krow__Project_Assignment__c oldObj = oldMap.get(newObj.Id);
            if (newObj.Krow__Krow_Project__c != oldObj.Krow__Krow_Project__c || 
                newObj.Krow__Project_Resource__c != oldObj.Krow__Project_Resource__c)
                {
                    objList.Add(newObj);
                    objList.Add(oldObj);
                }
        }

        if (objList.size() > 0)
            calculateExpenses(objList);
    }

    public void onAfterDelete( Map<Id, Krow__Project_Assignment__c> oldMap )
    {
        system.debug('onAfterDelete');
        // re-calculate old values
        List<Krow__Project_Assignment__c> objList = new List<Krow__Project_Assignment__c>();
        for(Id idValue : oldMap.keyset())
        {
            objList.Add(oldMap.get(idValue));
        }
        if (objList.size() > 0)
            calculateExpenses(objList);
    }

    public void onAfterUnDelete( List<Krow__Project_Assignment__c> newList )
    {
        system.debug('onAfterUnDelete');
        calculateExpenses(newList);
    }

    // calculate Expense
    public void calculateExpenses(List<Krow__Project_Assignment__c> objList )
    {
        list<id> projectIds = new list<id>();
        list<id> resourceIds = new list<id>();

        for (Krow__Project_Assignment__c exp : objList)
        {
            projectIds.Add(exp.Krow__Krow_Project__c);
            resourceIds.Add(exp.Krow__Project_Resource__c);
        }

        system.debug('projectIds: ' + projectIds.size());
        system.debug('resourceIds: ' + resourceIds.size());

        calculateExpenses.calculateExpenseActual(projectIds, resourceIds);
    }
}