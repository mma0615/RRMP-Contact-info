@isTest
public class Test_getArticle 
{
    
    @testSetup static void setup() 
    {
        Knowledge__kav knowledge = new Knowledge__kav();
        knowledge.Title = 'India Coronavirus Trajectory Looks Worse Than Other Countries';
        knowledge.UrlName = 'India-Coronavirus-Trajectory-Looks-Worse-Than-Other-Countries';
        insert knowledge;
        
        Voting__c newVoting=new Voting__c();
        newVoting.Dislike_Counter__c=2;
        newVoting.Like_Counter__c=4;
        newVoting.KnowledgeArticle__c=knowledge.Id;
        insert newVoting;
        
        
        Knowledge__DataCategorySelection kADCS1 = new Knowledge__DataCategorySelection();
        kADCS1.ParentId = knowledge.Id;
        kADCS1.DataCategoryGroupName = 'CoronaFacts';
        kADCS1.DataCategoryName = 'Consumer';                    
        insert kADCS1; 
        
        
    }
    
    
    static testMethod void Test_onLoadmethod() 
    {
		  Domain newdomain=[SELECT Id, DomainType, Domain FROM Domain limit 1];        
        Knowledge__kav KnowledgeList = [ SELECT Id, Title, UrlName,KnowledgeArticleId FROM Knowledge__kav LIMIT 1 ];
        KbManagement.PublishingService.publishArticle(KnowledgeList.KnowledgeArticleId, true);
        Knowledge__kav updateViewCount = [SELECT Title FROM Knowledge__kav  WHERE id=:KnowledgeList.Id and PublishStatus='online' and    Language = 'en_US'   UPDATE VIEWSTAT ];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'https://'+newdomain.Domain +'/services/apexrest/getArticle/';
        req.httpMethod = 'GET';
       
        RestContext.request = req;
        RestContext.response = res;
        
        getArticle.doGet();
    

    }
}