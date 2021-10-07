public class ContactTriggerHandler {
    public static void setUpNavigatorFields(List<Contact> newList){
        for(Contact con : newList){
            if(con.Contact_Id__c == null){
            Integer len = 32;
            Blob blobKey = crypto.generateAesKey(128);
            con.Login_Token__c =  EncodingUtil.convertToHex(blobKey).substring(0, len);
            String conId =  getToken();
            con.Contact_Id__c = conId;
        }
            con.Navigator_Login_Page_URL__c = getCommunityURL('Compass')+'/s/navigatorlogin';
            if(con.Navigator__c != null){
            con.Navigator_Page_URL__c = getCommunityURL('Compass')+'/s/navigator?id='+ con.Navigator__c +'&contactId='+ con.Contact_Id__c +'&token='+ con.Login_Token__c;
            }
        }        
    }
    
    public static void updatePageUrl(Map<Id,Contact> newMap, Map<Id,Contact> oldMap){
        for(Contact con : newMap.values()){
            if((con.Login_Token__c != oldMap.get(con.Id).Login_Token__c || con.Navigator__c != oldMap.get(con.Id).Navigator__c) && con.Navigator__c != null){
                con.Navigator_Page_URL__c = getCommunityURL('Compass')+'/s/navigator?id='+ con.Navigator__c +'&contactId='+ con.Contact_Id__c +'&token='+ con.Login_Token__c;
            }
        }        
    }
    
    public static String getToken(){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        
        String token = '';
        while (token.length() <= 10) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            token += chars.substring(idx, idx+1);
        }
        
        return token;
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