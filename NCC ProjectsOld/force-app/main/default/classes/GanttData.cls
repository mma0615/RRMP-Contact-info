public with sharing class GanttData 
{  
    public String Idofnm{get;set;}
    public String StartDate1{get;set;}
    public String EndDate1{get;set;}
    public List<VA_EHRM_SG_Inventory__c> getInventory {get;set;}
    public List<VA_EHRM_SG_Inventory__c> InventoryList{get;set;}
    public List<VA_EHRM_SG_Inventory__c> ListOfInventory{get;set;}
    public set<String> setOfWorkGroup{get;set;}
    public Integer ForCheckUser{get;set;}
   
    
    public GanttData()
    {
        List<FilteredData__c> getObject=[SELECT Name,Filter_Field__c,Filtered_Label__c,Operator__c FROM FilteredData__c];
         String mainQuery;
        if(getObject.size() > 0)
        {
            mainQuery = getObject[0].Filter_Field__c;
            for(integer i = 1; i < getObject.size(); i++) 
            {
                mainQuery+= ' '+getObject[i].Operator__c+' ' + getObject[i].Filter_Field__c;
            }
        }
        
        System.debug('mainQuery'+mainQuery);
        string query;
        IF(getObject.size() > 0)
        {
            query = 'SELECT Id,VA_EHRM_SG_Inventory_Status__c,VA_EHRM_SG_Inventory_Step__c,VA_EHRM_SG_Inventory_Draft_Start_Date__c,VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c,VA_EHRM_SG_Inventory_Initiate_Start_Date__c,VA_EHRM_SG_Inventory_Package_Start_Date__c,VA_EHRM_SG_Inventory_Prepare_Start_Date__c,VA_EHRM_SG_Inventory_Preview_Start_Date__c,VA_EHRM_SG_Inventory_Receive_Start_Date__c,VA_EHRM_SG_Inventory_Draft_Due_Date__c,VA_EHRM_SG_Inventory_Hand_Off_Due_Date__c,VA_EHRM_SG_Inventory_Initiate_Due_Date__c,VA_EHRM_SG_Inventory_Package_Due_Date__c,VA_EHRM_SG_Inventory_Prepare_Due_Date__c,VA_EHRM_SG_Inventory_Preview_Due_Date__c,VA_EHRM_SG_Inventory_Receive_Due_Date__c,VA_EHRM_SG_Inventory_Title__c, VA_EHRM_SG_Inventory_Update_Priority__c,VA_EHRM_SG_Council_Workgroup__c FROM VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Council_Workgroup__c !=null AND ( '+mainQuery+') order by VA_EHRM_SG_Council_Workgroup__c,VA_EHRM_SG_Inventory_Update_Priority__c,VA_EHRM_SG_Inventory_Initiate_Start_Date__c,VA_EHRM_SG_Inventory_Prepare_Start_Date__c,VA_EHRM_SG_Inventory_Preview_Start_Date__c,VA_EHRM_SG_Inventory_Draft_Start_Date__c,VA_EHRM_SG_Inventory_Package_Start_Date__c,VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c,VA_EHRM_SG_Inventory_Receive_Start_Date__c';
        }
        else 
        {
        query = 'SELECT Id,VA_EHRM_SG_Inventory_Status__c,VA_EHRM_SG_Inventory_Step__c,VA_EHRM_SG_Inventory_Draft_Start_Date__c,VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c,VA_EHRM_SG_Inventory_Initiate_Start_Date__c,VA_EHRM_SG_Inventory_Package_Start_Date__c,VA_EHRM_SG_Inventory_Prepare_Start_Date__c,VA_EHRM_SG_Inventory_Preview_Start_Date__c,VA_EHRM_SG_Inventory_Receive_Start_Date__c,VA_EHRM_SG_Inventory_Draft_Due_Date__c,VA_EHRM_SG_Inventory_Hand_Off_Due_Date__c,VA_EHRM_SG_Inventory_Initiate_Due_Date__c,VA_EHRM_SG_Inventory_Package_Due_Date__c,VA_EHRM_SG_Inventory_Prepare_Due_Date__c,VA_EHRM_SG_Inventory_Preview_Due_Date__c,VA_EHRM_SG_Inventory_Receive_Due_Date__c,VA_EHRM_SG_Inventory_Title__c, VA_EHRM_SG_Inventory_Update_Priority__c,VA_EHRM_SG_Council_Workgroup__c FROM VA_EHRM_SG_Inventory__c where VA_EHRM_SG_Council_Workgroup__c !=null order by VA_EHRM_SG_Council_Workgroup__c,VA_EHRM_SG_Inventory_Update_Priority__c,VA_EHRM_SG_Inventory_Initiate_Start_Date__c,VA_EHRM_SG_Inventory_Prepare_Start_Date__c,VA_EHRM_SG_Inventory_Preview_Start_Date__c,VA_EHRM_SG_Inventory_Draft_Start_Date__c,VA_EHRM_SG_Inventory_Package_Start_Date__c,VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c,VA_EHRM_SG_Inventory_Receive_Start_Date__c';
        }
        System.debug('query is'+query);
        ListOfInventory = Database.query(query);
        for( VA_EHRM_SG_Inventory__c vm : ListOfInventory)
        {
            if(vm.VA_EHRM_SG_Inventory_Title__c != null)
            {
               vm.VA_EHRM_SG_Inventory_Title__c = vm.VA_EHRM_SG_Inventory_Title__c.replace('\r\n', ' ');
            }
        }
        
        setOfWorkGroup = new Set<String>();
      
        if(ListOfInventory.size() > 0)
        {
            for(VA_EHRM_SG_Inventory__c vm : ListOfInventory)
            {
                setOfWorkGroup.add(vm.VA_EHRM_SG_Council_Workgroup__c);
            } 
        }
        Group gro = [Select Id,Name From Group Where Name = 'RestrictedUser' LIMIT 1]; 
        List<GroupMember> ListOfGroupMember = [SELECT GroupId,Id,UserOrGroupId FROM GroupMember WHERE GroupId =: gro.id];
        List<Id>ListOfUSerId = new List<Id>();
        for(GroupMember gm : ListOfGroupMember)
        {
            ListOfUSerId.add(gm.UserOrGroupId);
        }
        Id CurrentUserId = UserInfo.getUserId(); 
        if(ListOfUSerId.contains(CurrentUserId))
        {
            ForCheckUser = 0;
        }
        else
        {
            ForCheckUser = 1; 
        }
    }
    
    public void UpToDate()
    {
        System.debug('DataId'+ApexPages.currentPage().getParameters().get('IdOfVm'));
        System.debug('Idofnm'+Idofnm);
        String s = Idofnm; // change variable name
        List<String> SpliteString = s.split(' ');
        String IdOfVmSobject = SpliteString[0];
        System.debug('IdOfVmSobject'+IdOfVmSobject);
        String StageName = SpliteString[1];
        VA_EHRM_SG_Inventory__c AllDateFields = [Select Id,VA_EHRM_SG_Inventory_Initiate_Start_Date__c,VA_EHRM_SG_Inventory_Initiate_Due_Date__c,
                                                 VA_EHRM_SG_Inventory_Prepare_Start_Date__c,VA_EHRM_SG_Inventory_Prepare_Due_Date__c,VA_EHRM_SG_Inventory_Preview_Start_Date__c,
                                                 VA_EHRM_SG_Inventory_Preview_Due_Date__c,VA_EHRM_SG_Inventory_Draft_Start_Date__c,VA_EHRM_SG_Inventory_Draft_Due_Date__c,
                                                 VA_EHRM_SG_Inventory_Package_Start_Date__c,VA_EHRM_SG_Inventory_Package_Due_Date__c,VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c,
                                                 VA_EHRM_SG_Inventory_Hand_Off_Due_Date__c,VA_EHRM_SG_Inventory_Receive_Start_Date__c,VA_EHRM_SG_Inventory_Receive_Due_Date__c from VA_EHRM_SG_Inventory__c where id =:IdOfVmSobject Limit 1];
        System.debug('Id is'+SpliteString[0]);
        System.debug('Value is'+SpliteString[1]);
        
        if(StageName == 'Intiate')
        {
            AllDateFields.VA_EHRM_SG_Inventory_Initiate_Start_Date__c = Date.valueOf(StartDate1);
            AllDateFields.VA_EHRM_SG_Inventory_Initiate_Due_Date__c = Date.valueOf(EndDate1).addDays(-1);
        }
        else if (StageName == 'Prepare')
        {
            AllDateFields.VA_EHRM_SG_Inventory_Prepare_Start_Date__c = Date.valueOf(StartDate1);
            AllDateFields.VA_EHRM_SG_Inventory_Prepare_Due_Date__c = Date.valueOf(EndDate1).addDays(-1);
        }
        else if(StageName == 'Preview')
        {
            AllDateFields.VA_EHRM_SG_Inventory_Preview_Start_Date__c = Date.valueOf(StartDate1);
            AllDateFields.VA_EHRM_SG_Inventory_Preview_Due_Date__c =  Date.valueOf(EndDate1).addDays(-1);
        }
        else if (StageName == 'Draft')
        {
            AllDateFields.VA_EHRM_SG_Inventory_Draft_Start_Date__c = Date.valueOf(StartDate1);
            AllDateFields.VA_EHRM_SG_Inventory_Draft_Due_Date__c = Date.valueOf(EndDate1).addDays(-1);
        }
        else if (StageName == 'Package')
        {
            AllDateFields.VA_EHRM_SG_Inventory_Package_Start_Date__c = Date.valueOf(StartDate1);
            AllDateFields.VA_EHRM_SG_Inventory_Package_Due_Date__c =  Date.valueOf(EndDate1).addDays(-1);
        }
        else if(StageName == 'Hand')
        {
            AllDateFields.VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c = Date.valueOf(StartDate1);
            AllDateFields.VA_EHRM_SG_Inventory_Hand_Off_Due_Date__c = Date.valueOf(EndDate1).addDays(-1);
        }
        else 
        {
            AllDateFields.VA_EHRM_SG_Inventory_Receive_Start_Date__c = Date.valueOf(StartDate1);
            AllDateFields.VA_EHRM_SG_Inventory_Receive_Due_Date__c = Date.valueOf(EndDate1).addDays(-1);
        }
        try
          {
            update AllDateFields;
          }
        catch(Exception e)
       {
           System.debug('No problem');
       }
    }

}