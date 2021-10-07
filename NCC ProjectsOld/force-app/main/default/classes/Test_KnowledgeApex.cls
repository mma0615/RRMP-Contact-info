@isTest
public class Test_KnowledgeApex 
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
        
        
        
        Knowledge__DataCategorySelection kADCS = new Knowledge__DataCategorySelection();
        kADCS.ParentId = knowledge.Id;
        kADCS.DataCategoryGroupName = 'CoronaFacts';
        kADCS.DataCategoryName = 'General';                    
        insert kADCS;       
        
        
        Knowledge__DataCategorySelection kADCS3 = new Knowledge__DataCategorySelection();
        kADCS3.ParentId = knowledge.Id;
        kADCS3.DataCategoryGroupName = 'CoronaFacts';
        kADCS3.DataCategoryName = 'Other';                    
        insert kADCS3; 
    }
    
    static testMethod void Test_getKnowledgeArticles() 
    {	
		Knowledge__kav KnowledgeList = [ SELECT Id, Title, UrlName,KnowledgeArticleId FROM Knowledge__kav LIMIT 1 ];
        
        KbManagement.PublishingService.publishArticle(KnowledgeList.KnowledgeArticleId, true);
        KnowledgeApex.getKnowledgeArticles();
        
        Knowledge__kav updateViewCount = [SELECT Title FROM Knowledge__kav  WHERE id=:KnowledgeList.Id and PublishStatus='online' and    Language = 'en_US'   UPDATE VIEWSTAT ];
         KnowledgeApex.getTrendingArticles();
       KnowledgeApex.getRecentArticles();
        
        Voting__c newVoting=[SELECT KnowledgeArticle__c, Dislike_Counter__c, Like_Counter__c, Name, Id FROM Voting__c limit 1];
        KnowledgeApex.getMostRatedArticles();
        
        KnowledgeApex.allArticles();
        
        KnowledgeApex.getDescription(KnowledgeList.Id);
        
    }
}