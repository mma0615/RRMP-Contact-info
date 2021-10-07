trigger CopyOriginalOrderIDtoLookupField on Order (before insert) {
         for(order a : Trigger.New)
       {
           /****** 09/06/2020 MHM Added this line ******/
           a.Original_Order_ID__c = a.getCloneSourceId();
           
           /****** 03/17/2021 BEGIN MHM Added these lines ******/
           if (a.Original_Order_ID__c != null &&
               a.Pricebook2Id == null)
           {
               order oOrder = [select Pricebook2Id from Order where id = : a.Original_Order_ID__c limit 1];
               a.Pricebook2Id = oOrder.Pricebook2Id;
           }
           /****** 03/17/2021 END MHM Added these lines ******/
           
            a.Original_Order_Number__c = a.Original_Order_ID__c;
       }
     }