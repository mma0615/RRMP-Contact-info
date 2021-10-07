public with sharing class filteredCmpApex {

    //used to return the map of api and label name of fields of this VA_EHRM_SG_Inventory__c object
    @AuraEnabled
    public static Map<String,String> fieldReturn() {
        List<String> ListOfLabelsName = new List<String>();
        Map<String,String> objectRelatedFields = new Map<String,String>(); 
        Map<String,String> objectRelatedFields1 = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('VA_EHRM_SG_Inventory__c').getDescribe().fields.getMap();
        for (Schema.SObjectField field :fieldMap.values()) {
            Schema.DescribeFieldResult getFields = field.getDescribe();
            if(string.valueOf(getFields.getType()) != 'TEXTAREA') {
                ListOfLabelsName.add(getFields.getLabel());
                objectRelatedFields1.put(getFields.getLabel(),getFields.getname());
            }
        }
        ListOfLabelsName.sort();
        for(String LabelsName : ListOfLabelsName)
        {
            objectRelatedFields.put(LabelsName,objectRelatedFields1.get(LabelsName));
        }
        return objectRelatedFields;
    }
    
    @AuraEnabled
    public static String getCustomSettingOnLoad(){
        List<FilteredData__c> updateObject=[SELECT Name,Filtered_Label__c,Filter_Field__c FROM FilteredData__c];
        system.debug('updateObject ' +updateObject);
        if(updateObject.size() > 0){
            return 'success';
        }
        else{
            return 'not successfully';
        }
    }
    
    //get the filter data from custom setting and show it on UI onload
    @AuraEnabled
    public static String getCustomSetting(){
        List<FilteredData__c> getObject=[SELECT Name,Filter_Field__c,Filtered_Label__c,Operator__c FROM FilteredData__c];
        system.debug('getObject ' +getObject);
        List<ListWrapper> listWrap = new List<ListWrapper>();
        ListWrapper WrapObject = new ListWrapper();
        IF(getObject.size() > 0){
            for(FilteredData__c records :getObject){
                WrapObject.getApi.add(records.Filter_Field__c);
                WrapObject.getLabel.add(records.Filtered_Label__c);
                WrapObject.getOperator.add(records.Operator__c);
            }
            //listWrap.add(WrapObject);
            system.debug('data ' +JSON.serialize(WrapObject));
            return JSON.serialize(WrapObject);
            
        }
        else{
            return '';
        }
    }
    
    public class ListWrapper {
        @AuraEnabled public List<String> getApi = new List<String>();
        @AuraEnabled public List<String> getLabel = new List<String>();
        @AuraEnabled public List<String> getOperator = new List<String>();
    }
    
    //get the record count on the basis of filter which are store in custom setting onload
    @AuraEnabled
    public static integer getCountDataOnload(String Operator){
        List<FilteredData__c> getObject=[SELECT Name,Filter_Field__c,Operator__c FROM FilteredData__c];
        String mainQuery;
        IF(getObject.size() > 0){
            mainQuery = getObject[0].Filter_Field__c;
            
            for(integer i = 1; i < getObject.size(); i ++) {
                mainQuery+= ' '+Operator+' ' + getObject[i].Filter_Field__c;
            }
            integer  count= database.countQuery('select count() from VA_EHRM_SG_Inventory__c where ' +mainQuery);
            system.debug('count ' +count);
            return count;
        }
        else{
            return 0;
        }
    }
    
    //get the total record count on done button on the basis of filter
    @AuraEnabled
    public static integer getCountDataOnDone(String Operator){
        List<FilteredData__c> getObject=[SELECT Name,Filter_Field__c,Operator__c FROM FilteredData__c];
        String mainQuery;
        IF(getObject.size() > 0){
            mainQuery = getObject[0].Filter_Field__c;
            
            for(integer i = 1; i < getObject.size(); i ++) {
                mainQuery+= ' '+Operator+' ' + getObject[i].Filter_Field__c;
            }
            integer  count= database.countQuery('select count() from VA_EHRM_SG_Inventory__c where ' +mainQuery);
            system.debug('count ' +count);
            return count;
        }
        else{
            return 0;
        }
        
 
    /*
        List<FilteredData__c> getObject=[SELECT Name,Filter_Field__c,Operator__c FROM FilteredData__c];
        System.debug('getObjecthhhffhgfhfdcfff'+getObject);
        String mainQuery;
        IF(getObject.size() > 0){
             mainQuery = getObject[0].Filter_Field__c;
            for(integer i = 1; i < getObject.size(); i ++) {
                  mainQuery+= ' '+getObject[i].Operator__c+' ' + getObject[i].Filter_Field__c;
                //mainQuery+= ' OR ' + getObject[i].Filter_Field__c;
            }
            system.debug('mainQuery ' +mainQuery);
            integer  count= database.countQuery('select count() from VA_EHRM_SG_Inventory__c where ' +mainQuery);
            system.debug('count ' +count);
            return count;
        }
        else{
            return 0;
        }
        
          /*
        system.debug('Query'+Query);
        String mainQuery = Query[0];
        System.debug('On done button'+mainQuery);
        for(integer i = 1; i < Query.size(); i ++) {
            mainQuery+= ' OR ' + Query[i];
        }
        System.debug('On done button1'+mainQuery);
        integer  count= database.countQuery('select count() from VA_EHRM_SG_Inventory__c where ' +mainQuery);
        System.debug('count is '+count);
        return count;
       */
      
    }
    
    //return the datatype of the selected field by first combobox
    @AuraEnabled
    public static map<String, list<string>> fieldTypeReturn(String fieldName) {
        List<String> ll= fieldName.split(' ~ ');
        
        List<String> allPickvalue = new list<String>();
        Map<String, list<string>> mapOfPickvalue = new Map<String, list<string>>(); 
        String getApi;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get('VA_EHRM_SG_Inventory__c');
        Map<String, Schema.SObjectField> objectFieldMap = objectSchema.getDescribe().fields.getMap();
        Schema.DisplayType getFieldDataType = objectFieldMap.get(ll[0]).getDescribe().getType(); 
        if(string.valueOf(getFieldDataType) == 'PICKLIST') {
            list<Schema.PicklistEntry> values = objectFieldMap.get(ll[0]).getDescribe().getPickListValues();
            for (Schema.PicklistEntry getPickValues :values) {
                allPickvalue.add(getPickValues.getValue());
            }
        }
        mapOfPickvalue.put(string.valueOf(getFieldDataType), allPickvalue);
        return mapOfPickvalue;
    }
    
    //get the time zone of user.It will used to show the data time value on the basis of user timezone
    @AuraEnabled
    public static String getUserTimeZone() {
        try{
            TimeZone userTimezone = UserInfo.getTimeZone(); 
            string getTimeZone = String.valueOf(userTimezone);
            return getTimeZone;
        }
        catch(Exception e) {return '';}
    }
    
    
    //used to get the total records on the basis of selected filter and show it on ui as table form.
	//also used to insert/update the filter in custom setting on button click
    @AuraEnabled
    public static List<VA_EHRM_SG_Inventory__c> getRecordData(String Operator) {
        List<FilteredData__c> getObject=[SELECT Name,Filter_Field__c,Operator__c,Filtered_Label__c FROM FilteredData__c ];
        String mainQuery;
        IF(getObject.size() > 0){
            mainQuery = getObject[0].Filter_Field__c;
            for(integer i = 1; i < getObject.size(); i ++) {
                mainQuery+= ' '+Operator+' ' + getObject[i].Filter_Field__c;
            }
            String LabelQueryString = getObject[0].Filtered_Label__c;
            for(integer i = 1; i < getObject.size(); i ++) {
                LabelQueryString+= ' '+Operator+' ' + getObject[i].Filtered_Label__c;
            }
        }
        String getQueryData= 'SELECT Id,VA_EHRM_SG_Inventory_Status__c,VA_EHRM_SG_Inventory_Step__c,VA_EHRM_SG_Inventory_Draft_Start_Date__c,VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c,VA_EHRM_SG_Inventory_Initiate_Start_Date__c,VA_EHRM_SG_Inventory_Package_Start_Date__c,VA_EHRM_SG_Inventory_Prepare_Start_Date__c,VA_EHRM_SG_Inventory_Preview_Start_Date__c,VA_EHRM_SG_Inventory_Receive_Start_Date__c,VA_EHRM_SG_Inventory_Draft_Due_Date__c,VA_EHRM_SG_Inventory_Hand_Off_Due_Date__c,VA_EHRM_SG_Inventory_Initiate_Due_Date__c,VA_EHRM_SG_Inventory_Package_Due_Date__c,VA_EHRM_SG_Inventory_Prepare_Due_Date__c,VA_EHRM_SG_Inventory_Preview_Due_Date__c,VA_EHRM_SG_Inventory_Receive_Due_Date__c,VA_EHRM_SG_Inventory_Title__c, VA_EHRM_SG_Inventory_Update_Priority__c,VA_EHRM_SG_Council_Workgroup__c FROM VA_EHRM_SG_Inventory__c WHERE ' + mainQuery;
        List<VA_EHRM_SG_Inventory__c> getRecords= Database.query(getQueryData); 
        return getRecords;
    }
    
    // It will insert the record in custom setting when we add filter
    @AuraEnabled
    public static String storeData(List<String> Query, String LabelQuery)
    {
       // System.debug('Operator is'+ Operator);
        Datetime scheduleTime = System.now();
        list<FilteredData__c> getObjs = FilteredData__c.getAll().Values();
        List<String> data = new List<String>();
        for(FilteredData__c setData :getObjs){
            data.add(String.valueOf(setData.Filtered_Label__c));
        }
        LabelQuery.trim();
        system.debug('data ' +data);
        system.debug('LabelQuery ' +LabelQuery);
        if(!data.contains(LabelQuery.trim())){
            system.debug('not contain');
            FilteredData__c insertObj=new FilteredData__c();
            insertObj.Name='Objects' + ' - ' + scheduleTime;
            insertObj.Filtered_Label__c = LabelQuery;
            insertObj.Filter_Field__c = Query[0];
            insertObj.Operator__c = ' AND ';
            Insert insertObj; 
            return 'succcess';
        }
        else{
            system.debug('contain');
            return 'Duplicate filter are not supported';
        }
    }

    // When we delete the filter
     @AuraEnabled
    public static String deleteCustomData(String indexData){
        List<FilteredData__c> updateObject=[SELECT Name,Filtered_Label__c,Filter_Field__c FROM FilteredData__c where Filtered_Label__c =: indexData];
        system.debug('updateObject ' +updateObject);
        delete updateObject;
        return 'deleted successfully';
        
    }
    
    // It will be updated when we will change the search in select field
    @AuraEnabled
    public static List<String> getRecords(String searchString)
    {
        List<String>ListOfShortLabelsName = new List<String>();
        List<String> ListOfLabelsName = new List<String>();
        Map<String,String> objectRelatedFields1 = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('VA_EHRM_SG_Inventory__c').getDescribe().fields.getMap();
        for (Schema.SObjectField field :fieldMap.values()) {
            Schema.DescribeFieldResult getFields = field.getDescribe();
            if(string.valueOf(getFields.getType()) != 'TEXTAREA') {
                ListOfLabelsName.add(getFields.getLabel());
                objectRelatedFields1.put(getFields.getLabel(),getFields.getname());
            }
        }
        ListOfLabelsName.sort();
        for(String LabelsName : ListOfLabelsName)
        {
            if(LabelsName.containsIgnoreCase(searchString))
            {
                ListOfShortLabelsName.add(LabelsName);
            }
        }
        return ListOfShortLabelsName;
    }
        
   // It will be get all the label when we click on the select field 
    @AuraEnabled
    public static List<String> AllLabels()
    {
        List<String> ListOfLabelsName = new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('VA_EHRM_SG_Inventory__c').getDescribe().fields.getMap();
        for (Schema.SObjectField field :fieldMap.values()) {
            Schema.DescribeFieldResult getFields = field.getDescribe();
            if(string.valueOf(getFields.getType()) != 'TEXTAREA') {
                ListOfLabelsName.add(getFields.getLabel());
            }
        }
        ListOfLabelsName.sort();
        return ListOfLabelsName;
    }
    
    // It will update the custom setting when we change operator 
    @AuraEnabled
    public static void UpdateCustomSetting(String Operator )
    {
        List<FilteredData__c>  FilerData = [SELECT Name,Filter_Field__c,Operator__c,Filtered_Label__c FROM FilteredData__c];
        if(FilerData.size()>0)
        {
            for(FilteredData__c data : FilerData)
            {
                data.Operator__c = Operator;
            }
        }
        System.debug('FilerData'+FilerData);
        update FilerData;
    }
    
    // It will be update set the custom setting when we load the page
    @AuraEnabled
    public static void UpdateCustomSettingwhenLoad()
    {
        List<FilteredData__c>  FilerData = [SELECT Name,Filter_Field__c,Operator__c,Filtered_Label__c FROM FilteredData__c];
        if(FilerData.size()>0)
        {
            for(FilteredData__c data : FilerData)
            {
                data.Operator__c = 'AND';
            }
        }
        System.debug('FilerData'+FilerData);
        update FilerData;
    }
    
   /* @AuraEnabled
    public static String setDateFilterValue(String dateFilter){
        list<DateFilter__c> getObjs = DateFilter__c.getAll().Values();
        If(getObjs.size()==0){
            DateFilter__c filterDate=new DateFilter__c();
            filterDate.Name='Filter';
            filterDate.DateField__c=dateFilter;
            Insert filterDate; 
        }
        else if(dateFilter == 'None'){
            DateFilter__c updateObject=[SELECT Name,DateField__c,DueDate__c,StartDate__c FROM DateFilter__c LIMIT 1];
            delete updateObject;
        }
        else{
            DateFilter__c updateObject=[SELECT Name,DateField__c,DueDate__c,StartDate__c FROM DateFilter__c LIMIT 1];
            updateObject.DateField__c = dateFilter;
            updateObject.DueDate__c  = null;
            updateObject.StartDate__c = null;
			            
            Update updateObject;
        }
        return 'success';
        
    }

    @AuraEnabled
    public static String dueDate(Date StartDate ,Date DueDate){
        if(StartDate > DueDate){
            return 'not success';
        }
        else{
            
            DateFilter__c updateObject=[SELECT Name,DateField__c,DueDate__c,StartDate__c FROM DateFilter__c LIMIT 1];
            updateObject.DueDate__c=DueDate;  
            updateObject.StartDate__c=StartDate;  
            Update updateObject;
            return 'success';
            
        }
        
    }*/  
}