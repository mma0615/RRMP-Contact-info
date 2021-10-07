public with sharing class linktreeController {
    public linktreeController() {

    }

    @AuraEnabled (cacheable = true)
    public static String getcampaignName(String id){
        if (String.isBlank(id)){
            return null;
        }

        List<Campaign__c> CampaignList = [SELECT Id, name FROM Campaign__c WHERE (id = :id)  LIMIT 1];

        if (CampaignList.size() == 0)
            return null;
        else
            return CampaignList[0].Name;
    }
}
