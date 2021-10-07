/**
* Description: Test Class for CustomParkingLotFormHelper
* Author: Jester Cabantog
* Version: 1.0
* Last modified date: 12/16/2020
**/
@isTest (SeeAllData = false)
private class CustomParkingLotForm_Test {
    
    @testSetup 
    static void setUp() {
        TestFactory.ParkingLotTestDataFactory df = new TestFactory.ParkingLotTestDataFactory();
        df.make();
        df.persist();
    }
    
    @isTest
    static void getParkingLotDetailsTestNoSession(){
        
        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Con' LIMIT 1];
        Event__c evt = [SELECT Id, Event_Id__c FROM Event__c LIMIT 1];
        String evtId = evt.Event_Id__c;
        test.startTest();
        String result1 = CustomParkingLotFormController.getParkingLotDetails(evt.Event_Id__c, '');
        try{
            String result2 = CustomParkingLotFormController.getParkingLotDetails(evt.Event_Id__c, con.Id);
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Test.stopTest();
        System.assert(!String.isBlank(result1));
        
    }
    
    @isTest
    static void getParkingLotDetailsTest(){
        
        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Con' LIMIT 1];
        Event__c evt = [SELECT Id, Event_Id__c FROM Event__c LIMIT 1];
         Session__c sess = [SELECT Id FROM Session__c WHERE Event__c =: evt.Id];
        Session_Participant__c sesPart = new Session_Participant__c(
            Event__c = evt.Id,
            Session__c = sess.Id,
            Contact__c = con.Id
            );
        insert sesPart;
        
        String evtId = evt.Event_Id__c;
        test.startTest();
        String result1 = CustomParkingLotFormController.getParkingLotDetails(evt.Event_Id__c, '');
        String result2 = CustomParkingLotFormController.getParkingLotDetails(evt.Event_Id__c, con.Id);
        Test.stopTest();
        System.assert(!String.isBlank(result1));
        System.assert(!String.isBlank(result2));
    }
    
    @isTest
    static void createParkingLotTest(){
        
        Event__c evt = [SELECT Id, Event_Id__c FROM Event__c LIMIT 1];
        Session__c sess = [SELECT Id FROM Session__c WHERE Event__c =: evt.Id];
        test.startTest();
        CustomParkingLotFormController.createParkingLot(evt.Id, sess.Id, 'test@email.com', '', 'Question', 'Issue');
        CustomParkingLotFormController.createParkingLot(evt.Id, sess.Id, 'test2@email.com', '', 'Question', 'Issue');
        List<Parking_Lot__c> results = [SELECT Id FROM Parking_Lot__c];
        System.assert(results.size() == 3);
    }
    
    @isTest
    static void updateParkingLotsTest(){
        
        Parking_Lot__c pl = [SELECT Id FROM Parking_Lot__c LIMIT 1];
        test.startTest();
        CustomParkingLotFormController.updateParkingLots('[{"Status__c":"Open","Id":"'+pl.Id+'"}]');
        List<Parking_Lot__c> results = [SELECT Id FROM Parking_Lot__c];
        System.assert(results.size() == 1);
    }
    @isTest
    static void updateParkingLotsStatusErrTest(){
        
        Parking_Lot__c pl = [SELECT Id FROM Parking_Lot__c LIMIT 1];
        try{
            test.startTest();
            CustomParkingLotFormController.updateParkingLots('[{"Status__c":"err","Id":"'+pl.Id+'"}]');
        }
        catch(Exception e){
            System.Assert(e.getMessage().contains('Script-thrown exception'));
        }
    }
    
    @isTest
    static void updateParkingLotsTypeErrTest(){
        Parking_Lot__c pl = [SELECT Id FROM Parking_Lot__c LIMIT 1];
        try{
            test.startTest();
            CustomParkingLotFormController.updateParkingLots('[{"Type__c":"err","Id":"'+pl.Id+'"}]');
        }
        catch(Exception e){
            System.Assert(e.getMessage().contains('Script-thrown exception'));
        }
    }
    
    @isTest
    static void updateParkingLotsDmlErrTest(){
        Parking_Lot__c pl = [SELECT Id FROM Parking_Lot__c LIMIT 1];
        try{
            test.startTest();
            CustomParkingLotFormController.updateParkingLots('[{"Type__c":"err","Id":"'+pl.Id+'123'+'"}]');
        }
        catch(Exception e){
            System.Assert(e.getMessage().contains('Script-thrown exception'));
        }
    }
}