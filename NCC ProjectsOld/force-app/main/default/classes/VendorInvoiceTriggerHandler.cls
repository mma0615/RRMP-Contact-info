public without sharing class VendorInvoiceTriggerHandler implements ITriggerHandler{
    
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled(){
        if (TriggerSettings__c.getInstance().VendorPaymentTriggerDisabled__c)
            return true;
        else
            return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) {}
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {}
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        VendorInvoiceTriggerHandlerService.afterUpdateVendorInvoice((Map<Id, Krow__Vendor_Payment__c>)newItems, (Map<Id, Krow__Vendor_Payment__c>)oldItems);
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}