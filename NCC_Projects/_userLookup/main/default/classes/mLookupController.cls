/**
 * mLookupController
 * @author Minh Ma 
 * @date 02/28/2021
 * @description User lookup
 *
 * Update History:
 * 02/28/2021 - Initial Version
 */
public without sharing class mLookupController {
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName) {  
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        string query = 'SELECT Id, Name FROM ' + 
            objectName + 
            ' WHERE isactive=true and Name LIKE ' + 
            searchText + 
            ' LIMIT 6';

        System.debug('mLookupController ==> query: ' + query);
        return Database.query(query);  
    }
}
