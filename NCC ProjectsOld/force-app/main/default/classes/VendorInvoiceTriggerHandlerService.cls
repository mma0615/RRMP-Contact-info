public without sharing class VendorInvoiceTriggerHandlerService {

    private static final Map<String, Integer> daysByPaymentSchedule = new Map<String, Integer>{'Net 15' => 15, 'Net 30' => 30,'Net 45' => 45,'Net 60' => 60};
    public static Id ledgerIdTest;
    public static Id testGlAccount;

    public static void afterUpdateVendorInvoice(Map<Id, Krow__Vendor_Payment__c> newVendorPaymentMap, Map<Id, Krow__Vendor_Payment__c> oldVendorPaymentMap){
        Map<Id, Krow__Vendor_Payment__c> vendorPaymentPosted = new Map<Id, Krow__Vendor_Payment__c>();
        Map<Id, Krow__Vendor_Payment__c> vendorPaymentDrafted = new Map<Id, Krow__Vendor_Payment__c>();
        for(Krow__Vendor_Payment__c vendorPayment : newVendorPaymentMap.values()){
            if(vendorPayment.Krow__Status__c == 'Posted' && oldVendorPaymentMap.get(vendorPayment.Id).Krow__Status__c != 'Posted'){
                vendorPaymentPosted.put(vendorPayment.Id, vendorPayment);
            }

            if(vendorPayment.Krow__Status__c == 'Draft' && oldVendorPaymentMap.get(vendorPayment.Id).Krow__Status__c == 'Posted'){
                vendorPaymentDrafted.put(vendorPayment.Id, vendorPayment);
            }
        }

        if(!vendorPaymentPosted.isEmpty()){
            createAccountPayables(vendorPaymentPosted);
        }

        if(!vendorPaymentDrafted.isEmpty()){
            deleteAccountPayables(vendorPaymentDrafted);
        }
    }
    
    public static void createAccountPayables(Map<Id, Krow__Vendor_Payment__c> vendorPaymentPosted){
        Map<Id, List<Krow__Vendor_Expense_Item__c>> expenseItemsByVendorPaymentId = getVendorExpenseItems(vendorPaymentPosted);
        Map<Id, AcctSeed__Account_Payable__c> accountPayableByInvoiceId = new Map<Id, AcctSeed__Account_Payable__c>();
        //System.debug('VendorInvoiceTriggerHandlerService.createAccountPayables.vendorPaymentPosted '+vendorPaymentPosted);
        for(Krow__Vendor_Payment__c vendorPayment : vendorPaymentPosted.values()){
            //System.debug('VendorInvoiceTriggerHandlerService.createAccountPayables.vendorPayment '+vendorPayment);
            AcctSeed__Account_Payable__c accountPayable = createAccountPayable(vendorPayment);
            accountPayableByInvoiceId.put(accountPayable.VendorInvoice__c, accountPayable);
        }

        if(!accountPayableByInvoiceId.isEmpty()){
            insert accountPayableByInvoiceId.values();
            createAccountPayableLines(accountPayableByInvoiceId, expenseItemsByVendorPaymentId);
            postPayables(accountPayableByInvoiceId.values());
        }
    }

    public static void deleteAccountPayables(Map<Id, Krow__Vendor_Payment__c> vendorPaymentDrafted){
        List<AcctSeed__Account_Payable__c> accountPayablesToDelete = [SELECT Id, Name FROM AcctSeed__Account_Payable__c WHERE VendorInvoice__c IN : vendorPaymentDrafted.keySet()];
        unpostPayables(accountPayablesToDelete);
        DELETE accountPayablesToDelete;
    }

    @TestVisible 
    private static void createAccountPayableLines(Map<Id, AcctSeed__Account_Payable__c> accountPayableByInvoiceId, 
                        Map<Id, List<Krow__Vendor_Expense_Item__c>> expenseItemsByVendorPaymentId){

        List<AcctSeed__Account_Payable_Line__c> payableLinesToCreate = new List<AcctSeed__Account_Payable_Line__c>();
        for(Id invoiceId : expenseItemsByVendorPaymentId.keyset()){
            payableLinesToCreate.addAll(createAccountPayableLines(accountPayableByInvoiceId.get(invoiceId), expenseItemsByVendorPaymentId.get(invoiceId)));
        }

        if(!payableLinesToCreate.isEmpty()){
            insert payableLinesToCreate;
        }
    }

    @TestVisible
    private static List<AcctSeed__Account_Payable_Line__c> createAccountPayableLines(AcctSeed__Account_Payable__c accountPayable, List<Krow__Vendor_Expense_Item__c> invoiceExpenseItems){
        List<AcctSeed__Account_Payable_Line__c> payableLinesToCreate = new List<AcctSeed__Account_Payable_Line__c>();
        for(Krow__Vendor_Expense_Item__c expenseItem : invoiceExpenseItems){
            payableLinesToCreate.add(createPayableLine(expenseItem, accountPayable));
        }
        return payableLinesToCreate;
    }

    @TestVisible
    private static AcctSeed__Account_Payable_Line__c createPayableLine(Krow__Vendor_Expense_Item__c expenseItem, AcctSeed__Account_Payable__c accountPayable){
        AcctSeed__Account_Payable_Line__c payableLine = new AcctSeed__Account_Payable_Line__c();
        payableLine.AcctSeed__Date__c = expenseItem.Krow__Date__c;
        payableLine.AcctSeed__Amount__c = expenseItem.Krow__Amount__c;
        System.debug('To Test '+expenseItem.GLAccount__c);
        if(Test.isRunningTest()){
            payableLine.AcctSeed__Expense_GL_Account__c = testGlAccount;    
        }else{
            payableLine.AcctSeed__Expense_GL_Account__c = expenseItem.GLAccount__c;
        }
        if(expenseItem.Krow__Expense_Item__r.Krow__Task__c != null){
            if(expenseItem.Krow__Expense_Item__r.Krow__Project__c !=  null){
                payableLine.AcctSeed__Project__c = expenseItem.Krow__Expense_Item__r.Krow__Project__r.Krow__Accounting_seed_Id__c;
            }
            payableLine.AcctSeed__Project_Task__c = expenseItem.Krow__Expense_Item__r.Krow__Task__r.Krow__Accounting_seed_Id__c;
        }
        payableLine.AcctSeed__GL_Account_Variable_1__c = expenseItem.GL_Account_Variable_1__c;
        payableLine.AcctSeed__GL_Account_Variable_2__c = expenseItem.GL_Account_Variable_2__c;
        payableLine.AcctSeed__GL_Account_Variable_3__c = expenseItem.GL_Account_Variable_3__c;
        payableLine.AcctSeed__Account_Payable__c = accountPayable.Id;
        return payableLine;
    }

    @TestVisible
    private static AcctSeed__Account_Payable__c createAccountPayable(Krow__Vendor_Payment__c vendorPayment){
        AcctSeed__Account_Payable__c accountPayable = new AcctSeed__Account_Payable__c();
        accountPayable.AcctSeed__Vendor__c = vendorPayment.Vendor_Account__c;
        if(vendorPayment.Krow__Expense_Notes__c != null && vendorPayment.Krow__Expense_Notes__c != ''){
            accountPayable.AcctSeed__Payee_Reference__c = vendorPayment.Krow__Expense_Notes__c;
        }else{
            accountPayable.AcctSeed__Payee_Reference__c = 'Test Reference';
        }
        accountPayable.AcctSeed__Date__c = vendorPayment.Krow__Vendor_Payment_Date__c;
        accountPayable.AcctSeed__Accounting_Period__c = vendorPayment.AccountingPeriod__c;
        accountPayable.File_Folder_URL__c = vendorPayment.FileFolderUrl__c;
        Integer days = 0;
        if(vendorPayment.Krow__Payment_Schedule__c != null){
            days = daysByPaymentSchedule.get(vendorPayment.Krow__Payment_Schedule__c);
        }
        if(vendorPayment.Krow__Vendor_Payment_Date__c != null){

            accountPayable.AcctSeed__Due_Date__c = vendorPayment.Krow__Vendor_Payment_Date__c.addDays(days);
        }
        if(Test.isRunningTest()){
            accountPayable.AcctSeed__Ledger__c = ledgerIdTest;
        }
        accountPayable.VendorInvoice__c = vendorPayment.Id;
        return accountPayable;
    }

    @TestVisible
    private static Map<Id, List<Krow__Vendor_Expense_Item__c>> getVendorExpenseItems(Map<Id, Krow__Vendor_Payment__c> vendorPaymentPosted){
        Map<Id, List<Krow__Vendor_Expense_Item__c>> expenseItemsByVendorPaymentId = new Map<Id, List<Krow__Vendor_Expense_Item__c>>();
        List<Krow__Vendor_Expense_Item__c> vendorExpenseItems = [SELECT Id, Krow__Amount__c, Krow__Date__c, Krow__Expense_Item__c,
                    GLAccount__c, GL_Account_Variable_1__c, GL_Account_Variable_2__c, GL_Account_Variable_3__c,
                    Krow__Expense_Item__r.Krow__Task__c, Krow__Expense_Item__r.Krow__Project__c, 
                    Krow__Expense_Item__r.Krow__Task__r.Krow__Accounting_seed_Id__c,
                    Krow__Expense_Item__r.Krow__Project__r.Krow__Accounting_seed_Id__c, Krow__Vendor_Expense_Item__c.Account_Code__c, 
                    Krow__Vendor_Payment__c  
                FROM Krow__Vendor_Expense_Item__c WHERE Krow__Vendor_Payment__c IN : vendorPaymentPosted.keySet()];
                
        for(Krow__Vendor_Expense_Item__c vendorExpenseItem : vendorExpenseItems){
            if(expenseItemsByVendorPaymentId.containsKey(vendorExpenseItem.Krow__Vendor_Payment__c)){
                List<Krow__Vendor_Expense_Item__c> temp = expenseItemsByVendorPaymentId.get(vendorExpenseItem.Krow__Vendor_Payment__c);
                temp.add(vendorExpenseItem);
                expenseItemsByVendorPaymentId.put(vendorExpenseItem.Krow__Vendor_Payment__c, temp);
            }else{
                expenseItemsByVendorPaymentId.put(vendorExpenseItem.Krow__Vendor_Payment__c, new List<Krow__Vendor_Expense_Item__c>{vendorExpenseItem});
            }           
        }
        return expenseItemsByVendorPaymentId;
    }

    @TestVisible
    private static void postPayables(List<AcctSeed__Account_Payable__c> payables){
        // Call the post service
        AcctSeed.PostResult[] postResults = AcctSeed.AccountPayablePostService.postAccountPayables(payables);
        // Loop through post results
        for (AcctSeed.PostResult theResult : postResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully posted account payable: ' + theResult.id);
            } 
            else {
                System.debug('Error posting account payable ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }
    }

    @TestVisible
    private static void unpostPayables(List<AcctSeed__Account_Payable__c> payables){
        // Call the unpost service
        AcctSeed.PostResult[] unpostResults = AcctSeed.AccountPayablePostService.unpostAccountPayables(payables);
        // Loop through unpost results
        for (AcctSeed.PostResult theResult : unpostResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully unposted account payable: ' + theResult.id);
            } 
            else {
                System.debug('Error unposting account payable ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }
    }
}