public class ParkingLotTriggerHandler {
    public static void updateEmail(List<Parking_Lot__c> newList, Map<Id,Parking_Lot__c> newMap,List<Parking_Lot__c> oldList, Map<Id,Parking_Lot__c> oldMap){
        Set<Id> evtIds = new Set<Id>();
        for(Parking_Lot__c parkingLot : newList){
            evtIds.add(parkingLot.Event__c);
        }
        Map<Id,Event__c> eventMap = new Map<Id,Event__c> ([SELECT Id, OwnerId, Parking_Lot_User__c,Parking_Lot_User__r.Email,Owner.Email,Event_Id__c 
                                                           FROM Event__c 
                                                           WHERE Id IN: evtIds]);
        for(Parking_Lot__c parkingLot : newList){
            if(eventMap.get(parkingLot.Event__c).Parking_Lot_User__r.Email != null && eventMap.get(parkingLot.Event__c).Parking_Lot_User__r.Email != ''){
                 parkingLot.Tech_Notification_Email__c =  eventMap.get(parkingLot.Event__c).Parking_Lot_User__r.Email;
            }
            else{
                parkingLot.Tech_Notification_Email__c =  eventMap.get(parkingLot.Event__c).Owner.Email;
            }
            parkingLot.Parking_Lot_Page_URL__c =  getCommunityURL('Compass') + '/s/parking-lot?id=' + eventMap.get(parkingLot.Event__c)?.Event_Id__c;
        }
        
    }
     
    public static String getCommunityURL(string communityName){
        if (!Test.isRunningTest()){
            Network myNetwork = [SELECT Id FROM Network WHERE Name = :communityName];
            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
            return myCommunity.siteUrl ;
        } else {
            return 'some random url';   
        }
    }
}