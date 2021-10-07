/**
 * invoiceLineTriggerHandler
 * @author Minh Ma 
 * @date 02/18/2021
 * @description invoice line handler for Invoice_Line__c trigger
 *
 * Update History:
 * 02/18/2021 - Initial Version
 */
public with sharing class invoiceLineTriggerHandler 
{
    public void onBeforeInsert( List<Invoice_Line__c> newList )
    {
        invoiceLineRollup(newList);   
    }

    public void invoiceLineRollup(List<Invoice_Line__c> newList)
    {

        // BEGIN TEMP
        map<string, string> roleMap = new  map<string, string>();
        for (Krow__Krow_Role__c role : [select id, name, Ext_Id__c from Krow__Krow_Role__c])
        {
            roleMap.Put(role.Ext_Id__c, role.id);
        }
        // END TETMP
        set<id> invoiceIds = new set<id>();
        for (Invoice_Line__c invLine : newList)
        {
            invoiceIds.add(invLine.Invoice__c);
        }
        
        List<Krow__Invoice_Line_Item__c> invLineItemList = 
            [select id, Krow__Invoice__c, Krow__Timesheet_Split__r.Krow__Project_Role__c, 
            Krow__Bill_Rate__c, Krow__Hours__c, Krow__Amount_Total__c, Krow__Cost_Amount__c
                from Krow__Invoice_Line_Item__c 
                where Krow__Invoice__c in :invoiceIds];

        for (Invoice_Line__c invLine : newList)
        {
            invLine.Quantity__c = 0;
            invLine.Total_Amount__c = 0;
            invLine.Total_Cost_Amount__c = 0;
            string invLineKey = String.valueOf(invLine.Invoice__c) + 
                String.valueOf(invLine.Project_Role__c) +
                String.valueof(invLine.Unit_Price__c);
            System.debug('invoiceLineRollup ==> invLineKey: ' + invLineKey);
            for (Krow__Invoice_Line_Item__c invLineItem : invLineItemList)
            {
                string invLineItemKey = String.valueOf(invLineItem.Krow__Invoice__c) + 
                    // XXXXXX String.valueOf(invLineItem.Krow__Timesheet_Split__r.Krow__Project_Role__c) +
                    String.valueOf(roleMap.get(invLineItem.Krow__Timesheet_Split__r.Krow__Project_Role__c)) +
                    String.valueof(invLineItem.Krow__Bill_Rate__c);
                System.debug('invoiceLineRollup ==> invLineItem.Krow__Timesheet_Split__r.Krow__Project_Role__c:     ' + invLineItem.Krow__Timesheet_Split__r.Krow__Project_Role__c);
                System.debug('invoiceLineRollup ==> invLineItemKey:     ' + invLineItemKey);
                if (invLineKey == invLineItemKey)
                {
                    invLine.Quantity__c += invLineItem.Krow__Hours__c;
                    invLine.Total_Amount__c += invLineItem.Krow__Amount_Total__c;
                    invLine.Total_Cost_Amount__c += invLineItem.Krow__Cost_Amount__c;
                }
            }
        }
    }

}