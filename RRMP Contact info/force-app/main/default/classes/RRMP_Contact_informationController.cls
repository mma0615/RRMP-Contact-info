public with sharing class RRMP_Contact_informationController 
{
    
    @AuraEnabled(cacheable=true)
    public static RRMP_Contact_information__mdt getRRMP_Contact_information() 
    {
        List<RRMP_Contact_information__mdt> ListRRMP = 
            [SELECT Id, Contact_Email__c, Contact_Number__c, Fax_Number__c, Message__c
                FROM RRMP_Contact_information__mdt limit 1];
        return ListRRMP[0];
    }

    /**
     *@desc: A method to bulk update the custom metadata records . 
     **/
    @AuraEnabled
    public static void updateBulkMetadata(RRMP_Contact_information__mdt objMetadata)
    {
        try
        {
            objMetadata = new RRMP_Contact_information__mdt();
            objMetadata.Contact_Email__c = 'minh@abc.com';
            objMetadata.Message__c = 'Free message format';
            objMetadata.Contact_Number__c ='123-444-2222';
            objMetadata.Fax_Number__c = '333-444-5555';


            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            
            Metadata.CustomMetadata metadataRec =  new Metadata.CustomMetadata();
            metadataRec.fullName = 'RRMP_Contact_information__mdt.'+ objMetadata.DeveloperName;
            metadataRec.label = objMetadata.MasterLabel;

            Metadata.CustomMetadataValue customFieldtoUpdate = new Metadata.CustomMetadataValue();
            customFieldtoUpdate.field = 'Contact_Email__c';
            customFieldtoUpdate.value = objMetadata.Contact_Email__c;
            metadataRec.values.add(customFieldtoUpdate);

            customFieldtoUpdate = new Metadata.CustomMetadataValue();
            customFieldtoUpdate.field = 'Contact_Number__c';
            customFieldtoUpdate.value = objMetadata.Contact_Number__c;
            metadataRec.values.add(customFieldtoUpdate);

            customFieldtoUpdate = new Metadata.CustomMetadataValue();
            customFieldtoUpdate.field = 'Fax_Number__c';
            customFieldtoUpdate.value = objMetadata.Fax_Number__c;
            metadataRec.values.add(customFieldtoUpdate);

            customFieldtoUpdate = new Metadata.CustomMetadataValue();
            customFieldtoUpdate.field = 'Message__c';
            customFieldtoUpdate.value = objMetadata.Message__c;
            metadataRec.values.add(customFieldtoUpdate);

            mdContainer.addMetadata(metadataRec);
            
            system.debug('mdContainer**'+mdContainer);            
            // Enqueue custom metadata deployment
            // jobId is the deployment ID
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
            system.debug('jobId***'+jobId);                                   
        }
        catch(exception ex)
        {
            system.debug('exception '+ex.getMessage());                                 
        }       
    } 
    
    
    @AuraEnabled
    public static void updateLabel(string listLabel)
    {

        system.debug('listLabel: ' + listLabel);
        string strName;
        string strValue;
        List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>();
        MetadataService.CustomLabel csLabel;

        JSONParser parser = JSON.createParser(listLabel);
        while (parser.nextToken() != null) 
        {            
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
            {
                parser.nextValue();
                strName = parser.getCurrentName();
                strValue = parser.getText();
                csLabel = new MetadataService.CustomLabel();
                csLabel.fullName = strName;
                csLabel.language = 'en_US';
                csLabel.protected_x = true;
                csLabel.shortDescription = strName;
                csLabel.value=strValue;
                allMetadataList.add(csLabel);
                
                System.Debug('strName: ' + strName);
             	System.Debug('strValue: ' + strValue);
            }
        }
        if (allMetadataList != null)
            updateCustomLabel(allMetadataList);

        //MetadataAPIUtility.updateCustomLabel('Message','null','en_US','Test Updating Message abc',false);
        //updateCustomLabel('Message','My test label from metadata api','en_US','Test Updating Message ABC xxx',false);
    }
    
    public static boolean updateCustomLabel(List<MetadataService.Metadata> allMetadataList)
    {
        
        MetadataService.MetadataPort service = createService();
        
        List<MetadataService.SaveResult> results = service.updateMetadata(allMetadataList);
        for(MetadataService.SaveResult result: results)
        {
            system.debug('update custom label results success='+result.success);
        }
        return results[0].success;
    }
    
    private static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        //service.SessionHeader.sessionId = UserInfo.getSessionId();
          service.SessionHeader.sessionId = getSessionIdFromVFPage(Page.SessionId);
        return service;     
    }

    private static String getSessionIdFromVFPage(PageReference visualforcePage)
    {
        String content = visualforcePage.getContent().toString();
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        return content.substring(s, e);
    }
}

