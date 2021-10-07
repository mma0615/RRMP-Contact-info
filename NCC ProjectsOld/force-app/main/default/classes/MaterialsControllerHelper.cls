public without sharing class MaterialsControllerHelper {
    
    // Retrieve the files that belong to the record Ids
    public static String getMaterialsHelper(String eventId){
        system.debug('Hello');
        List<MaterialWrapper> materials = new List<MaterialWrapper>();
        //eventId = '7RvETWUOkMc';
        Set<Id> campaignIds = new Set<Id>();
        // Retrieve the event's Salesforce recordId
        Event__c eventrec = [SELECT Id, Name FROM Event__c WHERE Event_Id__c =: eventId AND IsActive__c = true LIMIT 1];
        campaignIds.add(eventrec.Id);

        //for (Session__c sessionRec : [SELECT Id, Name FROM Session__c WHERE Event__c =: eventrec.Id AND IsActive__c = true]){
        //    campaignIds.add(sessionRec.Id);
        //}

        // Retrieve a map of contentDocumentId and Title
        Map<Id, ContentDocumentLink> contentDocumentLinkTitleMap = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink cdl : ([SELECT ContentDocument.Id, ContentDocument.Title, ContentDocument.Description FROM ContentDocumentLink WHERE LinkedEntityId IN: campaignIds ORDER BY ContentDocument.Title])){
            contentDocumentLinkTitleMap.put(cdl.ContentDocument.Id, cdl);
        }

        system.debug('------- ' + contentDocumentLinkTitleMap.keySet());

        // Retrieive a map of contentDocumentId and DistributionPublicUrl
        Map<ID, String> contentDistributionMap = new Map<Id, String>();
        if (contentDocumentLinkTitleMap.size() > 0){
            for (ContentDistribution cd : [SELECT ID, DistributionPublicUrl, ContentDocumentId, ContentDownloadURL FROM ContentDistribution 
                                           WHERE ContentDocumentId IN: contentDocumentLinkTitleMap.keySet()]){
                if (!String.isBlank(cd.DistributionPublicURL)){
                    contentDistributionMap.put(cd.ContentDocumentId, cd.DistributionPublicURL);
                }
            }
        }

        // From the 2 maps above, construct a list of material wrappers to return to the component
        for (String key : contentDocumentLinkTitleMap.keySet()){
            if (!String.isBlank(contentDistributionMap.get(key))){
                MaterialWrapper mw = new MaterialWrapper();
                mw.Title = contentDocumentLinkTitleMap.get(key).ContentDocument.Title;
                mw.Description = contentDocumentLinkTitleMap.get(key).ContentDocument.Description;
                mw.DownloadURL = contentDistributionMap.get(key);
                mw.Id = key;
                materials.add(mw);
            }
        }
         
        return JSON.serialize(materials); 

    }

    public class MaterialWrapper{
        public String Title;
        public String Description;
        public String DownloadURL;
        public String Id;
    }
}