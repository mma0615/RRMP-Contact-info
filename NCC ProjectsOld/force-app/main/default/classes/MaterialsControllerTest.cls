@isTest
public with sharing class MaterialsControllerTest {
    
    @TestSetup
    static void makeData(){
        Event__c parentCampaign = TestFactory.createEvent('Event');
        parentCampaign.Event_Id__c = 'AZJNzaeyah';
        parentCampaign.IsActive__c = true;
        update parentCampaign;
        ContentVersion material1 = TestFactory.createContentVersion('Material1', 'Test Material 1');
        String contentDocumentId1 = getContentDocumentId(material1);
        ContentDocumentLink cdl1 = TestFactory.createContentDocumentLink(contentDocumentId1, parentCampaign.Id, 'V', 'AllUsers');
        ContentDistribution cd1 = TestFactory.createContentDistribution(material1);

    }


    @isTest
    public static void testGetMaterials(){
        Event__c parentCampaign = [SElECT Id, Event_Id__c FROM Event__c WHERE Event_Id__c = 'AZJNzaeyah' LIMIT 1];
        Test.startTest();
        String result = MaterialsController.getMaterials(parentCampaign.Event_Id__c);
        Test.stopTest();
        
        List<MaterialsControllerHelper.MaterialWrapper> resultList = (List<MaterialsControllerHelper.MaterialWrapper>)JSON.deserializeStrict(result, List<MaterialsControllerHelper.MaterialWrapper>.class);
        System.assertEquals('Material1', resultList[0].Title);
        System.assertEquals('Test Material 1', resultList[0].Description);
        System.assertNotEquals(null, resultList[0].DownloadURL);

    }

    public static String getContentDocumentId(ContentVersion cv){
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
    }
}