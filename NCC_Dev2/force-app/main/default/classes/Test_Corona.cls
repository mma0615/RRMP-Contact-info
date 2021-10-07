@isTest
public class Test_Corona 
{
    @testSetup static void setup() 
    {
        Knowledge__kav knowledge = new Knowledge__kav();
        knowledge.Title = 'India Coronavirus Trajectory Looks Worse Than Other Countries';
        knowledge.UrlName = 'India-Coronavirus-Trajectory-Looks-Worse-Than-Other-Countries';
        knowledge.Language = 'en_US' ;
        insert knowledge;
        
        Voting__c newVoting=new Voting__c();
        newVoting.Dislike_Counter__c=2;
        newVoting.Like_Counter__c=4;
        newVoting.KnowledgeArticle__c=knowledge.Id;
        insert newVoting;
        
        
        Knowledge__DataCategorySelection kADCS1 = new Knowledge__DataCategorySelection();
        kADCS1.ParentId = knowledge.Id;
        kADCS1.DataCategoryGroupName = 'CoronaFacts';
        kADCS1.DataCategoryName = 'General';                    
        insert kADCS1; 
        
        Knowledge__DataCategorySelection kADCS2 = new Knowledge__DataCategorySelection();
        kADCS2.ParentId = knowledge.Id;
        kADCS2.DataCategoryGroupName = 'CoronaFacts';
        kADCS2.DataCategoryName = 'Treatment';                    
        insert kADCS2;
        
		Knowledge__DataCategorySelection kADCS3 = new Knowledge__DataCategorySelection();
        kADCS3.ParentId = knowledge.Id;
        kADCS3.DataCategoryGroupName = 'CoronaFacts';
        kADCS3.DataCategoryName = 'Other';                    
        insert kADCS3; 
        
		Knowledge__DataCategorySelection kADCS4 = new Knowledge__DataCategorySelection();
        kADCS4.ParentId = knowledge.Id;
        kADCS4.DataCategoryGroupName = 'CoronaFacts';
        kADCS4.DataCategoryName = 'Economics';                    
        insert kADCS4; 
    }


	static testMethod void Test_getDataCategory() 
    {
        Corona.getChildCategoriesofTopic();
        Corona.getChildCategoriesofSource();
    }


    
    static testMethod void Test_onLoadmethod() 
    {
        Knowledge__kav KnowledgeList = [ SELECT Id, Title,UrlName,KnowledgeArticleId FROM Knowledge__kav LIMIT 1 ];
        KbManagement.PublishingService.publishArticle(KnowledgeList.KnowledgeArticleId, true);
        Corona.onLoadmethod();
    }
    
    static testmethod void Test_changemethod()
    {
        Knowledge__kav KnowledgeList = [ SELECT Id, Title, UrlName,KnowledgeArticleId FROM Knowledge__kav LIMIT 1 ];
        KbManagement.PublishingService.publishArticle(KnowledgeList.KnowledgeArticleId, true);
        
        Corona.changemethod('Economics','Other');
    }
	
        static testmethod void Test_getDescription()
    {
        Knowledge__kav KnowledgeList = [ SELECT Id, Title, UrlName,KnowledgeArticleId FROM Knowledge__kav LIMIT 1 ];
        list<Id> knowledgeID=new List<Id>();
        knowledgeID.add(KnowledgeList.Id);
        KbManagement.PublishingService.publishArticle(KnowledgeList.KnowledgeArticleId, true);
        Corona.getDescription(KnowledgeList.Id);
    } 
    
   
    static testmethod void Test_showTitle()
    {
    	Knowledge__kav KnowledgeList = [ SELECT Id, Title FROM Knowledge__kav LIMIT 1 ];
        Corona.showTitle(KnowledgeList.Id);
        
    }		
}