/*
* Purpose is to support a generic file upload capability whereby
* the uploaded file id is stored into a configured target text field.
*
*/
public with sharing class FileUploadUtility {
    
    @AuraEnabled
    public static string updateTargetRecord(Id recordId, string fileId, string fieldName){
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        try{
            List<contentVersion>  contentList = new List<contentVersion>([select id from contentVersion where ContentDocumentId =:fileId limit 1]);
            Id docId = (contentList.isEmpty()) ? null : contentList[0].Id;
            sobject obj = Database.query(buildQuery(recordId, fieldName, sobjectType));
            obj.put(fieldName, docId);
            update obj;
            return '';
        } catch (Exception e){
            return e.getMessage();
        }
        
    }
    
    private static string buildQuery( Id recordId, string fieldName, string sobjectType){
        return  'select id,'+fieldName+' from '+sobjectType+' where id =\''+recordId+'\' limit 1';
    }

}