/**
 * invoiceTriggerHandler
 * @author Minh Ma 
 * @date 02/16/2021
 * @description invoice handler for Krow__Invoice__c trigger
 *
 * Update History:
 * 02/12/2021 - Initial Version
 */
public with sharing class invoiceTriggerHandler 
{
    public void onAfterInsert( List<Krow__Invoice__c> newList )
    {
        // gather invoice with Krow__Formatting__c = 'Project Role & Rate'
        List<Krow__Invoice__c> objNewList = new List<Krow__Invoice__c>();
        for (Krow__Invoice__c inv : newList)
        {
            if (inv.Krow__Project__c != null &&
                inv.Krow__Formatting__c == 'Project Role & Rate')
                objNewList.Add(inv);
        }
        
        // if there's any invoice with Krow__Formatting__c = 'Project Role & Rate', create Invoiceline
        if (objNewList.size() > 0)
            createInvoiceLine(objNewList);
    }

    public void onAfterUpdate( List<Krow__Invoice__c> newList, 
                               Map<Id, Krow__Invoice__c> oldMap )
    {
        List<Krow__Invoice__c> objNewList = new List<Krow__Invoice__c>();
        List<Krow__Invoice__c> objDelList = new List<Krow__Invoice__c>();
        for (Krow__Invoice__c inv : newList)
        {
            Krow__Invoice__c oldInv = oldMap.get(inv.Id);
            // check if Krow__Formatting__c has changed
            if (inv.Krow__Project__c != null &&
                inv.Krow__Formatting__c <> oldInv.Krow__Formatting__c)
            {
                // if Krow__Formatting__c was changed TO 'Project Role & Rate'
                if (inv.Krow__Formatting__c == 'Project Role & Rate')
                    objNewList.Add(inv);
                // if Krow__Formatting__c was changed FROM 'Project Role & Rate'
                else if (oldInv.Krow__Formatting__c == 'Project Role & Rate')
                    objDelList.Add(inv);
            }
        }

        // if there's any Krow__Formatting__c changed TO 'Project Role & Rate', create Invoiceline
        if (objNewList.size() > 0)
            createInvoiceLine(objNewList);

        // if there's any Krow__Formatting__c changed FROM 'Project Role & Rate', delete Invoiceline
        if (objDelList.size() > 0)
            deleteInvoiceLine(objDelList);
    }

    // Create Invoice Line
    public void createInvoiceLine(List<Krow__Invoice__c> objList )
    {
        set<Id> projectIds = new set<Id>();
        Map<Id,Id> projectInvoiceMap = new  Map<Id,Id>();
        Map<Id, Krow__Invoice__c> invoiceMap = new  Map<Id, Krow__Invoice__c>();
        for (Krow__Invoice__c inv : objList)
        {
            projectIds.Add(inv.Krow__Project__c);
            projectInvoiceMap.put(inv.Krow__Project__c, inv.Id);
            invoiceMap.put(inv.Id, inv);
        }   
        // getting timesheet splits
        List<Krow__Timesheet_Split__c> tsSplitList = 
            [select id, name, Krow__Bill_Rate_New__c, Krow__Krow_Project__c, Krow__Date__c,
                Krow__Project_Role__c, Krow__Project_Role__r.name
                from Krow__Timesheet_Split__c 
                where Krow__Krow_Project__c in :projectIds and
                    Krow__Billable__c=true and Krow__Approval_Status__c='approved'];

        Set<string> invLineKeySet = new Set<string>();
        List<Invoice_Line__c> invLineToInsert = new List<Invoice_Line__c>();
        for (Krow__Timesheet_Split__c tsSplit : tsSplitList)
        {
            // get invoice from projectIds
            Krow__Invoice__c inv = invoiceMap.get(projectInvoiceMap.get(tsSplit.Krow__Krow_Project__c));
            // filtering through invoice start/end date
            if (tsSplit.Krow__Date__c >= inv.Krow__Start_Date__c &&
                tsSplit.Krow__Date__c <= inv.Krow__End_Date__c)
                {
                    // Populating Invoice Line unique key
                    string invLineKey = String.valueOf(inv.Id) + 
                        String.valueOf(tsSplit.Krow__Project_Role__c) + 
                        String.valueof(tsSplit.Krow__Bill_Rate_New__c);
                    System.debug('createInvoiceLine ==> invLineKey: ' + invLineKey);
                    // If there isn't an Invoice Line for the unique key, populating new Invoice Line and add the list
                    if (!invLineKeySet.contains(invLineKey))
                    {
                        invLineKeySet.Add(invLineKey);
                        Invoice_Line__c invLine = new Invoice_Line__c();
                        invLine.Invoice__c = inv.Id;
                        invLine.Project_Role__c = tempGetRoleId.getRoleId(tsSplit.Krow__Project_Role__c);
                        // XXXXXX invLine.Project_Role__c = tsSplit.Krow__Project_Role__c;
                        invLine.Unit_Price__c = tsSplit.Krow__Bill_Rate_New__c;
                        invLineToInsert.Add(invLine);
                    }
                }
        }

        // if there's any invLineToInsert
        if (invLineToInsert.size() > 0)
            Insert(invLineToInsert);
    }

    // Delete Invoice Line
    public void deleteInvoiceLine(List<Krow__Invoice__c> objList )
    {
        // populating set of invoiceIds
        set<Id> invoideIds = new set<Id>();
        for (Krow__Invoice__c inv : objList)
            invoideIds.Add(inv.Id);

        // get all invoice line in invoiceIds
        List<Invoice_Line__c> invLineToDelete = 
            [select id from Invoice_Line__c where Invoice__c in :invoideIds];

        // if there's any invLineToDelete
        if (invLineToDelete.size() > 0)
            Delete(invLineToDelete);
    }
}