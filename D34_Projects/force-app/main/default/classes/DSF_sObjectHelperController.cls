/**
 * Created by ahasic on 10/28/2019.
 */

public with sharing class DSF_sObjectHelperController {

    @AuraEnabled
    public static List<String> getSelectOptions(sObject objObject, string fld, Boolean sortOptions, Boolean defaultOption) {
        
        List<String> allOptions = new List<String>();

        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = objObject.getSObjectType().getDescribe().fields.getMap().get(fld).getDescribe().getPickListValues();

        //add an empty field if attribute is set.
        if(defaultOption){
            allOptions.add('');
        }
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry p : values) {
            allOptions.add(p.getValue());
        }

        //Sort values when needed
        if (sortOptions){
            allOptions.sort();
        }

        return allOptions;
    }

    @AuraEnabled
    public static void saveSObject(sObject objectValue) {
        upsert objectValue;
    }

    @AuraEnabled
    public static List<sObject> savesObjectList( List<sObject> sObjectsList) {
        insert sObjectsList;  
        return sObjectsList;
    } 

    @AuraEnabled
    public static List<sObject> updateObjectList( List<sObject> sObjectsList) {
        update sObjectsList;  
        return sObjectsList;
    }

    @AuraEnabled
    public static List<sObject> getSObject(string objectName,
                                           string fields,
                                           string conditions,
                                           string sortFields,
                                           string groupByFields,
                                           Integer recordCount) { 

        String query = 'SELECT ' + fields + ' FROM ' + objectName;

        // If conditions array is not empty, combine all array items into a WHERE clause
        String whereClause = '';
        if(!String.isBlank(conditions)){
            whereClause = ' WHERE ' + conditions;
            System.debug('ECHOTS::DSF_sObjectHelperController::getSObject::whereClause = ' + whereClause); 
        }

        query += whereClause;

        // If group by fields are not empty, combine them into an GROUP BY clause
        if(!String.isBlank(groupByFields)){
            query += ' GROUP BY ' + groupByFields;
        }

        // If sorting options are not empty, combine them into an ORDER BY clause
        if(!String.isBlank(sortFields)){
            query += ' ORDER BY ' + sortFields; 
            System.debug('ECHOTS::DSF_sObjectHelperController::getSObject::sortFields = ' + sortFields);  
        }
 
        System.debug('ECHOTS::DSF_sObjectHelperController::getSObject::LIMIT query = ' + recordCount);  

        if(Integer.valueOf(recordCount) > 0){
            query += ' LIMIT '+ recordCount; 
        } 

        List<sObject> output = Database.query(query); 

        System.debug('ECHOTS::DSF_sObjectHelperController::getSObject::query = ' + query);  
        System.debug('ECHOTS::DSF_sObjectHelperController::getSObject::output = ' + output);  
        return output;
    }
}