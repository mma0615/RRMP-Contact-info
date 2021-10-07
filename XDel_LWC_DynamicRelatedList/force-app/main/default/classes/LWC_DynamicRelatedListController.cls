/*********************
*   FinancialAccountController
*   @author:        Minh H Ma
*   @date:          11/15/2020
*   descrtiption:   This is to display related from dynamically from fieldset
*
*   Update History:
*   11/15/2020  Intial Version
*********************/
public with sharing class LWC_DynamicRelatedListController 
{
    public LWC_DynamicRelatedListController() { }

    /*****
     * Querying list of records
     */
    @AuraEnabled(Cacheable = true)
    public static lwcData getRecords(id recordId, 
        string parentAPIName,
        string childAPIName,
        string childParentField,
        string fieldSet)
    {
        System.debug('parentAPIName ====> '+ parentAPIName);
        System.debug('childAPIName ====> '+ childAPIName);
        System.debug('childParentField ====> '+ childParentField);
        System.debug('fieldSet ====> '+ fieldSet);

        lwcData oLWCData = new lwcData();
        oLWCData.parentId = recordId;
        System.debug('parentId ====> '+ recordId);
        
        oLWCData.iconName = getIconName(childAPIName);
        System.debug('oLWCData.iconName ====> ' + oLWCData.iconName);

        /***** Get Object label */
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    	Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(childAPIName);
    	Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        oLWCData.objectLabel = DescribeSObjectResultObj.getLabelPlural();

        /***** Get related lists*/
        Map<String, String> mapRelatedList = new Map<String, String>();
        List<Schema.ChildRelationship> listChildRelationship = DescribeSObjectResultObj.getChildRelationships();
        for(Schema.ChildRelationship thisChild : listChildRelationship)
        {
            if(thisChild.getRelationshipName() != null)
            {
                
            }
        }

        /***** get selected fields */
        List<String> selectedFields = getSelectedFields(fieldSet, DescribeSObjectResultObj);
        System.debug('selectedFields ====> '+ selectedFields);

        oLWCData.listColumns = getFieldTypes(childAPIName, selectedFields);
        System.debug('oLWCData.listColumns ====> '+ oLWCData.listColumns);
        
        String s = '';
        Integer i = 0;

        for(String field : selectedFields )
        {
            if(i == 0)
            {
                s+= field;
            }
            else
            {
                s+= ','+field;
            }
            i++;
        }

        String query = 'SELECT Id, ' + s + 
                ' from ' + childAPIName +
                ' where ' + childParentField + ' =\'' + recordId + '\'' +
                ' limit 100';
        System.debug('query ====> '+ query);        
        oLWCData.listRecords = Database.query(query);

        return oLWCData;
       
    }

    /*****
     * Getting fieldsets
     */
    private static List<String> getSelectedFields(string fieldSetName,
            Schema.DescribeSObjectResult DescribeSObjectResultObj)
    {        
    	//system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName));

    	Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

    	List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
    	//system.debug('fieldSetMemberList ====>' + fieldSetMemberList);
    	       
        List<String> selFields = new List<String>();
        for(Schema.FieldSetMember fld :fieldSetMemberList) 
        {
            selFields.Add(fld.getFieldPath() );
        }
        return selFields;       
    }

    /*****
     * populating fields from fieldset and return JSON string
     */
    public static String getFieldTypes(String objectName, List<String> selectedFields)
    {	
        List<Columns> listColumns = new List<Columns>();
        System.debug('objectName:' + objectName);

        for(String field : selectedFields)
        {
            Schema.SObjectField describeField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(field);            
            columns selCols = new columns();
            selCols.label = describeField.getDescribe().getLabel();
            selCols.fieldName = describeField.getDescribe().getName();
            selCols.type = String.valueOf(describeField.getDescribe().getType() ).toLowercase();
            if (selCols.fieldName == 'Name')
            {
                selCols.fieldName = 'Id';
                selCols.type = 'url';
                selCols.sortable = true;

                label selLab = new label();
                selLab.fieldName = 'Name';
                
                attributes selAtt = new attributes();
                selatt.label = selLab;
                selAtt.target = '_blank';

                selCols.typeAttributes = selAtt;                
            }   

            //selCols.editable = 'false';
            System.debug('columns:' + selCols);
            System.debug('columns in JSon:' + JSON.serialize(selCols));             
            listColumns.Add(selCols);
        }
                
        return JSON.serialize(listColumns);
    }

    public static String getIconName(String objectName)
    {
        System.debug('objectName:' + objectName);
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) 
        { 
            tabDesc.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tr : tabDesc) 
        {
            if( objectName == tr.getSobjectName() ) 
            {
                if( tr.isCustom() ) 
                {
                    iconDesc.addAll(tr.getIcons());
                } 
                else 
                {
                    iconName = 'standard:' + objectName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) 
        {
            if (ir.getContentType() == 'image/svg+xml')
            {
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }

        System.debug('iconName:' + iconName);
        return iconName;
    }  
    
    /*****
     * lwcData
    */
    public with sharing class lwcData 
    {
        @AuraEnabled public id parentId;
        @AuraEnabled public string iconName;
        @AuraEnabled public string objectLabel;
        @AuraEnabled public List<Object> listRecords;
        @AuraEnabled public string listColumns;

        public lwcData() {}
    }


    /*****
     * data columns Class
     */
    public with sharing class columns 
    {
        public string label;
        public string fieldName;
        public string type;
        public attributes typeAttributes;
        public Boolean editable;
        public Boolean sortable;

        public columns() { }
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
