@isTest
public class Test_GanttData 
{
    @TestSetup
    static void createInventory()
    {
        Date myDate = Date.newInstance(2020, 04, 01);
        List<VA_EHRM_SG_Inventory__c> listofVAEHRMSGInventory=new  List<VA_EHRM_SG_Inventory__c>();
        //List<String> stepString =new List<String>{'1-Initiate','2-Prepare','3-Preview','4-Draft','5-Package','6-Hand Off','7-Receive'};
        List<String> stepString =new List<String>{'1-Propose','2-Confirm','3-Prepare','4-Preview','5-Validate','6-Package'};
        
        for(String newData:stepString)  
        {
		VA_EHRM_SG_Inventory__c newVAEHRMSGInventory =new VA_EHRM_SG_Inventory__c();
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Status__c='On Track';
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Step__c=newData;
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Initiate_Start_Date__c=myDate;
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Initiate_Due_Date__c=myDate.addDays(1);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Prepare_Start_Date__c=myDate.addDays(3);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Prepare_Due_Date__c=myDate.addDays(5);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Preview_Start_Date__c=myDate.addDays(7);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Preview_Due_Date__c=myDate.addDays(9);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Draft_Start_Date__c=myDate.addDays(11);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Draft_Due_Date__c=    myDate.addDays(13);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Package_Start_Date__c=myDate.addDays(15);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Package_Due_Date__c=myDate.addDays(17);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c=myDate.addDays(19);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Hand_Off_Due_Date__c=myDate.addDays(21);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Receive_Start_Date__c=myDate.addDays(23);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Receive_Due_Date__c=myDate.addDays(25);
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Title__c='Testing Data'+newData;
        newVAEHRMSGInventory.VA_EHRM_SG_Inventory_Update_Priority__c='High';
        newVAEHRMSGInventory.VA_EHRM_SG_Council_Workgroup__c='Case Management';
        listofVAEHRMSGInventory.add(newVAEHRMSGInventory);
        }

        insert listofVAEHRMSGInventory;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];  
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com');    
        insert u;
      
    }
    @isTest
    public static void test_constructor_when_not_null()
    {
        String inventoryStep = '1-Initiate';
        String inventoryStatus = 'On Track';
        FilteredData__c insertCustom = new FilteredData__c(Name='Object' ,Filter_Field__c = 'VA_EHRM_SG_Inventory_Step__c =\'' + inventoryStep + '\' AND VA_EHRM_SG_Inventory_Status__c = \'' + inventoryStatus + '\'',
                                                           Filtered_Label__c = 'VA EHRM SG Inventory Step Equals 1-Initiate AND VA EHRM SG Inventory Status Equals Off Track');
        insert insertCustom;
        GanttData newGanttData=new GanttData();
        
    }
    
    
    @isTest
    public static void test_ganttChart()
    {
        GanttData newGanttData=new GanttData();
        VA_EHRM_SG_Inventory__c getInventoryData = [Select Id ,VA_EHRM_SG_Inventory_Update_Priority__c from VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Inventory_Update_Priority__c='High' Limit 1];
        newGanttData.Idofnm =getInventoryData.Id+' Intiate';
        newGanttData.StartDate1='2020-04-02';
        newGanttData.EndDate1 ='2020-04-04';
        newGanttData.UpToDate();
    }
      
    @isTest
    public static void test_ganttChartPrepare()
    {
        GanttData newGanttData=new GanttData();
        VA_EHRM_SG_Inventory__c getInventoryData = [Select Id ,VA_EHRM_SG_Inventory_Update_Priority__c from VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Inventory_Update_Priority__c='High' Limit 1];
        newGanttData.Idofnm =getInventoryData.Id+' Prepare';
        newGanttData.StartDate1='2020-04-06';
        newGanttData.EndDate1 ='2020-04-08';
        newGanttData.UpToDate();
    }
        @isTest
    public static void test_ganttChartPreview()
    {
        GanttData newGanttData=new GanttData();
        VA_EHRM_SG_Inventory__c getInventoryData = [Select Id ,VA_EHRM_SG_Inventory_Update_Priority__c from VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Inventory_Update_Priority__c='High' Limit 1];
        newGanttData.Idofnm =getInventoryData.Id+' Preview';
        newGanttData.StartDate1='2020-04-10';
        newGanttData.EndDate1 ='2020-04-12';
        newGanttData.UpToDate();
    }
        @isTest
    public static void test_ganttChartDraft()
    {
        GanttData newGanttData=new GanttData();
        VA_EHRM_SG_Inventory__c getInventoryData = [Select Id ,VA_EHRM_SG_Inventory_Update_Priority__c from VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Inventory_Update_Priority__c='High' Limit 1];
        newGanttData.Idofnm =getInventoryData.Id+' Draft';
        newGanttData.StartDate1='2020-04-14';
        newGanttData.EndDate1 ='2020-04-16';
        newGanttData.UpToDate();
    }
        @isTest
    public static void test_ganttChartPackage()
    {
        GanttData newGanttData=new GanttData();
        VA_EHRM_SG_Inventory__c getInventoryData = [Select Id ,VA_EHRM_SG_Inventory_Update_Priority__c from VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Inventory_Update_Priority__c='High' Limit 1];
        newGanttData.Idofnm =getInventoryData.Id+' Package';
        newGanttData.StartDate1='2020-04-18';
        newGanttData.EndDate1 ='2020-04-20';
        newGanttData.UpToDate();
    }
        @isTest
    public static void test_ganttChartHandOff()
    {
        GanttData newGanttData=new GanttData();
        VA_EHRM_SG_Inventory__c getInventoryData = [Select Id ,VA_EHRM_SG_Inventory_Update_Priority__c from VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Inventory_Update_Priority__c='High' Limit 1];
        newGanttData.Idofnm =getInventoryData.Id+' Hand';
        newGanttData.StartDate1='2020-04-22';
        newGanttData.EndDate1 ='2020-04-24';
        newGanttData.UpToDate();
    }
        @isTest
    public static void test_ganttChartReceive()
    {
        GanttData newGanttData=new GanttData();
        VA_EHRM_SG_Inventory__c getInventoryData = [Select Id ,VA_EHRM_SG_Inventory_Update_Priority__c from VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Inventory_Update_Priority__c='High' Limit 1];
        newGanttData.Idofnm =getInventoryData.Id+' Receive';
        newGanttData.StartDate1='2020-04-26';
        newGanttData.EndDate1 ='2020-04-28';
        newGanttData.UpToDate();
    }

}