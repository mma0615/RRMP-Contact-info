/*
*   contactController
*   @author:        Minh H Ma
*   @date:          11/15/2020
*   descrtiption:   This is to display related from dynamically from fieldset
*
*   Update History:
*   11/15/2020  Intial Version
*/
public with sharing class contactController 
{
    public contactController() 
    {
    }

    /*****
     * Querying list of records
     */
    @AuraEnabled(Cacheable = true)
    public static List<Contact> getContacts()
    {
        List<String> selectedFields = getSelectedFields();
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

        String query = 'SELECT ' + s + ' FROM Contact limit 20';
        System.debug('query ====> '+ query);      
        return Database.query(query);
       
    }

    /*****
     * Delete contact(s)
     */
    @AuraEnabled
    public static void deleteContacts(list<Id> lstConIds){
        try {
            list<Contact> lstConsToDelete = new list<Contact>();
            System.debug('lstConIds ====> '+lstConIds);
            for(Id idCon : lstConIds) {
                lstConsToDelete.add(new Contact(Id = idCon));
            }
            if(!lstConsToDelete.isEmpty()) {
                delete lstConsToDelete;
            }
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /*****
     * populating fields from fieldset and return JSON string
     */
    @AuraEnabled(Cacheable = true)
    public static String getFieldTypes(String objectName)
    {	
        List<String> selectedFields = getSelectedFields();
        List<Columns> columnList = new List<Columns>();
        System.debug('objectName:' + objectName);

        for(String field : selectedFields)
        {
            Schema.SObjectField describeField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(field);            
            columns selCols = new columns();
            selCols.label = describeField.getDescribe().getLabel();
            selCols.fieldName = describeField.getDescribe().getName();
            selCols.type = String.valueOf(describeField.getDescribe().getType() );
            selCols.editable = 'false';            
            columnList.Add(selCols);
        }
        
        return JSON.serialize(columnList);
    }
    
    /*****
     * Getting fieldsets
     */
    private static List<String> getSelectedFields()
    {
        List<String> selFields = new List<String>();
        /*****  object: Contact,  
        *      fieldset: Contact_Selected_Fields
        */
        for(Schema.FieldSetMember fld :SObjectType.Contact.FieldSets.Contact_Selected_Fields.getFields()) 
        {
            selFields.Add(fld.getFieldPath() );
        }
        return selFields;       
    }

    /*****
     * data columns Class
     */
    public with sharing class columns 
    {
        public string label;
        public string fieldName;
        public string type;
        public string editable;

        public columns() 
        {

        }
    }


}