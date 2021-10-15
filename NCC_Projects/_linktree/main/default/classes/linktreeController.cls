public without sharing class linktreeController {

    @AuraEnabled (cacheable = true)
    public static String getcampaignName(String campaignId){
        if (String.isBlank(campaignId)){
            return null;
        }

        List<Campaign__c> CampaignList = 
            [SELECT Id, name FROM Campaign__c WHERE id = :campaignId  LIMIT 1];

        if (CampaignList.size() == 0)
            return 'null';
        else
            return CampaignList[0].Name;
    }

    @AuraEnabled (cacheable = true)
    public static Campaign__c getcampaignDetail(String campaignId){
        
        System.debug('campaignId: ' + campaignId);

        if (String.isBlank(campaignId)){
            return null;
        }

        User u = [select id,Name from User where id =: userInfo.getUserId()];

        List<Campaign__c> CampaignList = 
            [SELECT Id, name, Logo_URL__c FROM Campaign__c WHERE id = :campaignId  LIMIT 1];        

        if (CampaignList.size() == 0)
            return new Campaign__c(name= u.name + ' - Invalid Campaign Id of ' + campaignId +
                ' or security issue. Please contact System Admin'
                , Logo_URL__c='https://ncc--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=0681U00000Iw7IU&operationContext=DELIVERY&contentId=05T1U00001kxDw8&page=0&d=/a/1U000000PsY0/B7tExGte9gjx3jk4FtE1icpF_aKdFnCa0C7Q4YoKWSs&oid=00D1U000000G62i&dpt=null&viewId=');
        else {
            CampaignList[0].Name = CampaignList[0].Name;
            return CampaignList[0];
        }
            
    }

    @AuraEnabled (cacheable = true)
    public static List<Event__c> getcampaignEvents(String campaignId){
        if (String.isBlank(campaignId)){
            return null;
        }
        List<Event__c> EventList = [SELECT Id, name, Event_Page_URL__c, Show_To_Links__c 
            FROM Event__c 
            WHERE Campaign__c = :campaignId
                and Show_To_Links__c=true 
                and Event_Page_URL__c<>null
            order by name];

        return EventList;
    }
}
