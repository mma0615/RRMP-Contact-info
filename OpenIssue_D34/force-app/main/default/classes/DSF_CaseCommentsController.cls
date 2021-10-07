public class DSF_CaseCommentsController {
    @AuraEnabled
    public static CaseComment addCaseComment(String commentBody, Id caseId) {
        
        CaseComment caseComment = new CaseComment();
        caseComment.ParentId = caseId;
		
        caseComment.CommentBody  = commentBody;
        
        insert caseComment;
        return caseComment;   
    }
    
    @AuraEnabled
    public static void updateFileTitle(String contendDocumentId){
        ContentDocument contentDoc = [SELECT Id, Title FROM ContentDocument WHERE Id = :contendDocumentId];
        contentDoc.Title = contentDoc.Title + '_' + Date.today();
        update contentDoc;
    }
}