public class CCEventTriggerHandler {


    public void OnBeforeInsert(List<Event__c> eventList){
        for (Event__c eventRec: eventList) {
            generateTokenAndURL(eventRec);         
        }
        CCEventTriggerUtility.generateOrdWideEmail(eventList);
    }
    
    public void OnBeforeUpdate(List<Event__c> eventList){
        CCEventTriggerUtility.generateOrdWideEmail(eventList);
    }

    public void generateTokenAndURL(Event__c eventRec){
         
        String token =  getToken();
        eventRec.Event_Id__c = token;
        eventRec.Event_Page_URL__c =  getCommunityURL('Compass') + '/s/events?id=' + token;

    }

    public String getToken(){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        
        String token = '';
        while (token.length() <= 10) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            token += chars.substring(idx, idx+1);
        }
        
        return token;
    }


    public String getCommunityURL(string communityName){
        if (!Test.isRunningTest()){
            Network myNetwork = [SELECT Id FROM Network WHERE Name = :communityName];
            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
            return myCommunity.siteUrl ;
        } else {
            return 'some random url';   
        }
    }
}