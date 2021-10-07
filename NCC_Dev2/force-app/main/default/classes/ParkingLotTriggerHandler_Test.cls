@isTest(SeeAllData=false)
private class ParkingLotTriggerHandler_Test {
    @testSetup 
    static void setUp() {
        
        List<Apex_Trigger_Switch__c> switchRecs = TestDataFactory.createAllTriggerSwitch();
        insert switchRecs;
        TestFactory.ParkingLotTestDataFactory df = new TestFactory.ParkingLotTestDataFactory();
        df.make();
        df.persist();
    }
    @isTest
    static void testParkingLotUser(){
        Contact con = [SELECT Id, Email FROM Contact WHERE Name = 'Test Con' LIMIT 1];
        con.Email = 'updatedemail@test.com';
        update con;
        Event__c evt = [SELECT Id, Event_Id__c FROM Event__c LIMIT 1];
        evt.Parking_Lot_User__c = con.Id;
        update evt;
        Parking_Lot__c parkingLot = [SELECT Id, Description__c FROM Parking_Lot__c WHERE Event__c =: evt.Id LIMIT 1];
        parkingLot.Description__c = 'Update to Change Email';
        test.startTest();
        update parkingLot;
        test.stopTest();
        Parking_Lot__c result = [SELECT Id, Tech_Notification_Email__c FROM Parking_Lot__c WHERE Event__c =: evt.Id AND Id =: parkingLot.Id LIMIT 1];
        system.AssertEquals(con.Email, result.Tech_Notification_Email__c);
    }
    
    
}