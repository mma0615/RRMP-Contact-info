/**
 *  CGSRestAPIHelper loads the map of CGS_Rest_API__mdt and CGS_Rest_Data_Mapping__mdt
 *  CGS 02/2021
 * 
 *  to use these methods:
 * 
 *  Map<String, CGS_Rest_API__mdt> mapRESTApi = CGSRestAPIHelper.getRESTApi();
 *  mapRESTApi.get('Open Weather Map');
 *
 *  Map<String, CGS_Rest_Data_Mapping__mdt> mapRESTApiDataMap = CGSRestAPIHelper.getRESTApiDataMap();
 *  getRESTApiDataMap.get('Open Weather Map');
 * */
public class CGSRestAPIHelper {
    //create static map of CGS_Rest_API__mdt
    private static Map <String, CGS_Rest_API__mdt> mapRESTApi = new Map<String, CGS_Rest_API__mdt>();
    static{
        for (CGS_Rest_API__mdt api :[SELECT Label, Method__c, Parameters__c, requestEndPoint__c,
                                     API_Key__c, User_Name__c, Password__c
                                     FROM CGS_Rest_API__mdt]){
        mapRESTApi.put(api.Label, api);
        }
    }
    //get the map outside the helper class
    public static Map<String, CGS_Rest_API__mdt> getRESTApi(){
        return mapRESTApi;
    }
    
    //create static map of CGS_Rest_Data_Mapping__mdt
    private static Map <String, CGS_Rest_Data_Mapping__mdt> mapRESTApiDataMap = new Map<String, CGS_Rest_Data_Mapping__mdt>();
    static{
        for (CGS_Rest_Data_Mapping__mdt adm :[SELECT Rest_API_Name__c, Rest_API_Name__r.Object_API_Name__c, Field_API_Name__c, Response_Field_Name__c
                                     FROM CGS_Rest_Data_Mapping__mdt]){
        mapRESTApiDataMap.put(adm.Rest_API_Name__c, adm);
        }
    }
    //get the map outside the helper class
    public static Map<String, CGS_Rest_Data_Mapping__mdt> getRESTApiDataMap(){
        return mapRESTApiDataMap;
    }
    
    
}