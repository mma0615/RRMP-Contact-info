@isTest 

public class CopyOriginalOrderIDTest {

    @isTest static void updateOrder(){
        Account acct = new Account(Name = 'test');
        insert acct;
    
        Order myOrder = new Order();
        myOrder.Name = 'Order Name';
        myOrder.AccountID = acct.Id;
        myOrder.EffectiveDate = Date.newInstance(2018, 1, 9);
        myOrder.Status = 'Draft';
        insert myOrder;

        Order myOrder2 = new Order();
        myOrder2.Name = 'Order Name2';
        myOrder2.AccountID = acct.Id;
        myOrder2.EffectiveDate = Date.newInstance(2018, 1, 9);
        myOrder2.Original_Order_ID__c = myOrder.Id;
        myOrder2.Status = 'Draft';
        insert myOrder2;
        
        /****** 03/17/2021 BEGIN MHM Added these lines ******/
        system.debug('Pricebook2Id: ' + myOrder.Pricebook2Id);
        Order myOrder3 = myOrder.clone(false, false, false, false);
        Insert MyOrder3;
        /****** 03/17/2021 END MHM Added these lines ******/

        //System.assert([select Original_Order_Number__c from Order where Id = :myOrder2.Id].Original_Order_Number__c == myOrder.Id);
    }
}