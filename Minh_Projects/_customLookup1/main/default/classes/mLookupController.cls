/**
 * mLookupController
 * @author Minh Ma 
 * @date 02/28/2021
 * @description reusable lookup
 *
 * Update History:
 * 02/28/2021 - Initial Version
 */
public with sharing class mLookupController {
    
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName) {  
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6';  
        return Database.query('SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6');  
    }
}
