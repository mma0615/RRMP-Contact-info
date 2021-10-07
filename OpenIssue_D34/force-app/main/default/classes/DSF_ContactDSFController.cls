public without sharing class DSF_ContactDSFController {
    @AuraEnabled
    public static String getQueueId(){ 
        List<QueueSobject> queuesList = [SELECT QueueId FROM QueueSobject WHERE Queue.Name = 'Scholarship Team Student Queue'];
        return queuesList != null && queuesList.size() > 0 ? queuesList[0].QueueId : null; 
    }

    @AuraEnabled
    public static String createCase(Case newCase){ 
        newCase.OwnerId = getQueueId();   
        insert newCase;
        return newCase.Id;
    }
    
    @AuraEnabled
    public static void updateFileTitle(String contendDocumentId){
        ContentDocument contentDoc = [SELECT Id, Title FROM ContentDocument WHERE Id = :contendDocumentId];
        contentDoc.Title = contentDoc.Title + '_' + Date.today();
        update contentDoc;
    }
}