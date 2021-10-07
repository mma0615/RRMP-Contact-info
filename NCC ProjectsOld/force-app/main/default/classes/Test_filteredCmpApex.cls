@isTest
public class Test_filteredCmpApex {
    
    @testSetup static void setup() 
    {
        List<VA_EHRM_SG_Inventory__c> inventoryList = new List<VA_EHRM_SG_Inventory__c>();
        VA_EHRM_SG_Inventory__c inventory = new VA_EHRM_SG_Inventory__c(VA_EHRM_SG_Inventory_Status__c = 'Off Track',VA_EHRM_SG_Inventory_Step__c = '1-Initiate',
                                                                        VA_EHRM_SG_Inventory_Title__c='custom Data');
        insert inventory;
        String inventoryStep = '1-Initiate';
        String inventoryStatus = 'Off Track';
        FilteredData__c insertCustom = new FilteredData__c(Name='Object' ,Filter_Field__c = 'VA_EHRM_SG_Inventory_Step__c =\'' + inventoryStep + '\'',
                                                           Filtered_Label__c = 'VA EHRM SG Inventory Step Equals 1-Initiate',Operator__c = 'AND');
        insert insertCustom;
        FilteredData__c insertCustom1 = new FilteredData__c(Name='Object Test' ,Filter_Field__c = 'VA_EHRM_SG_Inventory_Status__c = \'' + inventoryStatus + '\'',
                                                           Filtered_Label__c = 'VA EHRM SG Inventory Status Equals Off Track',Operator__c = 'AND');
        insert insertCustom1; 
    }
    
    @isTest static void Test_fieldReturn() {
        filteredCmpApex.fieldReturn();
    }
   
    @isTest static void Test_getCustomSetting() {
        
        filteredCmpApex.getCustomSetting();
        filteredCmpApex.getCountDataOnload('AND');
    }
    
    @isTest static void Test_fieldTypeReturn() {
        filteredCmpApex.fieldTypeReturn('VA_EHRM_SG_Inventory_Status__c ~ VA EHRM SG Inventory Status');
    }
    
    @isTest static void Test_getTimezone() {
        filteredCmpApex.getUserTimeZone();
    }

     /*
    @isTest static void Test_getRecordData1() {
        FilteredData__c updateObject=[SELECT Name,Filter_Field__c,Filtered_Label__c FROM FilteredData__c where Name='Object'];
        delete updateObject;
        List<String> Query = new List<String>();
        String inventoryStep1 = '1-Initiate';
        String inventoryStatus1 = 'Off Track';
        Query.add('VA_EHRM_SG_Inventory_Step__c  = \'' + inventoryStep1 + '\'' );
        Query.add('VA_EHRM_SG_Inventory_Status__c = \'' + inventoryStatus1 + '\'');
        List<String> Label = new List<String>();
        Label.add('VA EHRM SG Inventory Step  Equals  1-Initiate');
        Label.add('VA EHRM SG Inventory Status Equals Off Track');
        filteredCmpApex.getRecordData(Query,Label);
        
        String inventoryStep = '1-Initiate';
        String inventoryStatus = 'Off Track';
        FilteredData__c insertCustom = new FilteredData__c(Name='Object' ,Filter_Field__c = 'VA_EHRM_SG_Inventory_Step__c =\'' + inventoryStep + '\' OR VA_EHRM_SG_Inventory_Status__c = \'' + inventoryStatus + '\'',
                                                           Filtered_Label__c = 'VA EHRM SG Inventory Step Equals 1-Initiate OR VA EHRM SG Inventory Status Equals Off Track');
        insert insertCustom;      
    }
    */
   
    @isTest static void Test_getCountDataOnDone() {
        filteredCmpApex.getCountDataOnDone('AND');
    }
     
    @isTest static void Test_storeData() {
        List<String> Query = new List<String>();
        String inventoryStep1 = '1-Initiate';
        Query.add('VA_EHRM_SG_Inventory_Step__c  = \'' + inventoryStep1 + '\'' );
        String Label = 'VA EHRM SG Inventory Step  Equals  1-Initiate';
        filteredCmpApex.storeData(Query,Label);
    }
   
    @isTest static void Test_deleteCustomData() {
        String indexData = 'VA EHRM SG Inventory Step  Equals  1-Initiate';
        filteredCmpApex.deleteCustomData(indexData);
    }
    
    @isTest static void Test_AllLabels() {
        filteredCmpApex.AllLabels();
    }
    
    @isTest static void Test_getRecords() {
        filteredCmpApex.getRecords('status');
    }
    
     @isTest static void Test_UpdateCustomSettingwhenLoad() {
        filteredCmpApex.UpdateCustomSettingwhenLoad();
    }
   
     @isTest static void Test_UpdateCustomSetting() {
        filteredCmpApex.UpdateCustomSetting('AND');
    }
    
    @isTest static void Test_getRecordData() {
        filteredCmpApex.getRecordData('AND');
    }
    
     @isTest static void Test_getCustomSettingOnLoad() {
        filteredCmpApex.getCustomSettingOnLoad();
    }
    
}