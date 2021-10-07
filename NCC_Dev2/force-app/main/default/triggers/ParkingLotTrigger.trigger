trigger ParkingLotTrigger on Parking_Lot__c (before insert, before update) {
    if(Trigger.isBefore && Trigger.isInsert){
        ParkingLotTriggerHandler.updateEmail(Trigger.new,null,null,null);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        ParkingLotTriggerHandler.updateEmail(Trigger.new,Trigger.newmap,Trigger.old,trigger.oldmap);
    }
}