public with sharing class screenConfigurationController 
{
    public screenConfigurationController() 
    {

    }


    @AuraEnabled(Cacheable = true)
    public static lwcData getRecords(string screenName)
    {
        System.debug('getRecords ==> screenName: '+ screenName);

        id screenId = null;
        List<Screen__mdt> listScreen_MDT = [select id, MasterLabel from Screen__mdt where MasterLabel = :screenName];
        
        System.debug('getRecords ==> listScreen_MDT.size(): '+ listScreen_MDT.size());
        if (listScreen_MDT.size() > 0)
        {
            screenId = listScreen_MDT[0].Id;
        }
        System.debug('getRecords ==> screenId: '+ screenId);
            
        lwcData oLWCData = new lwcData();
        oLWCData.screenName = screenName;
        oLWCData.listScreenElement =  
            [select id, MasterLabel, Label_Text__c, Type__c, Sequence__c, Required__c,  Editable__c
                from Screen_Element__mdt where form__c = :screenId order by Sequence__c DESC];
        System.debug('getRecords ==> oLWCData.listScreenElement.size(): '+ oLWCData.listScreenElement.size());
        return oLWCData;

    }


    /*****
     * lwcData
    */
    public with sharing class lwcData 
    {
        @AuraEnabled public string screenName;
        @AuraEnabled public List<Screen_Element__mdt> listScreenElement;
        
        
        //@AuraEnabled public List<screenElement> listscreenElement;

        //@AuraEnabled public string objectLabel;
        //@AuraEnabled public string relationshipName;
        //@AuraEnabled public List<sObject> listRecord;
        //@AuraEnabled public string listColumn;

        public lwcData() {}
    }


    /*****
     * data column Class
     */
    public with sharing class screenElement 
    {
        public String label;
        public string fieldName;
        public String type;
        public Boolean editable;
        public Boolean sortable;


        public Attributes typeAttributes;
        public String relationshipName;

        public screenElement() { }
    }

    public with sharing class attributes 
    {
        public label label;
        public string target;

        public attributes() { }
    }

    public with sharing class label
    {
        public string fieldName;

        public label() { }
    }
}