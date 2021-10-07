@isTest
public class Test_addArticleApex 
{
    @testSetup static void setup() 
    {
        Lead newLead=new Lead();
        newLead.FirstName='Demo';
        newLead.LastName='Lead';
        newLead.Email = 'demolead@test.com';
        newLead.Company='Demo';
        insert newLead; 
        
        Lead newLeadSec=new Lead();
        newLeadSec.FirstName='Demotest';
        newLeadSec.LastName='Leadtest';
        newLeadSec.Email = 'testdemo@test.com';
        newLeadSec.Company='testing';
        insert newLeadSec; 
        
        Account acc= new Account();
        acc.Name = newLead.Company;
        insert acc;
        
        Contact newContact=new Contact();
        newContact.FirstName='test';
        newContact.LastName='testLast';
        newContact.AccountId=acc.Id;
        newContact.Contact_Type__c='Lead';
        newContact.Email=newLead.Email;
        insert newContact;
        
       
        
        
        
        Knowledge__kav knowledge = new Knowledge__kav();
        knowledge.Title = 'India Coronavirus Trajectory Looks Worse Than Other Countries';
        knowledge.UrlName = 'India-Coronavirus-Trajectory-Looks-Worse-Than-Other-Countries';
        knowledge.Lead__c=newLead.Id;        
        insert knowledge;
        
        Knowledge__DataCategorySelection kADCS1 = new Knowledge__DataCategorySelection();
        kADCS1.ParentId = knowledge.Id;
        kADCS1.DataCategoryGroupName = 'CoronaFacts';
        kADCS1.DataCategoryName = 'General';                    
        insert kADCS1; 
    }


	static testMethod void Test_getDataCategory() 
    {
        addArticleApex.getChildCategoriesofTarget();
        addArticleApex.getChildCategoriesofTopic();
        addArticleApex.getChildCategoriesofSource();
        addArticleApex.getChildCategoriesofAttributes();
    }
    
    
    static testMethod void Test_onLoadmethod() 
    {
        Knowledge__kav KnowledgeList = [ SELECT Id, Title, UrlName,KnowledgeArticleId FROM Knowledge__kav LIMIT 1 ];
        KbManagement.PublishingService.publishArticle(KnowledgeList.KnowledgeArticleId, true);
        Lead newLead=[Select FirstName,LastName,Email,Company from Lead where Email like 'demolead@test.com'];
        Lead newLeadSec=[Select FirstName,LastName,Email,Company from Lead where Email like 'testdemo@test.com'];
		        
        
        List<String> newList=new List<String>();
        newList.add('General');
        
        String result=addArticleApex.createArticle(KnowledgeList,newLead,'https://google.com','https://google.com','https://google.com','https://google.com',newList);
        addArticleApex.createArticle(KnowledgeList,newLeadSec,'https://google.com','https://google.com','https://google.com','https://google.com',newList);
        System.debug('result'+result);
    }
    
    
    static testMethod void Test_saveFile()
    {
        Knowledge__kav KnowledgeList = [ SELECT Id, Title, UrlName,KnowledgeArticleId FROM Knowledge__kav LIMIT 1 ];
        
        addArticleApex.saveFile(KnowledgeList.Id,'FileName','ThisisBase64Data');
    }
    
    static testMethod void Test_savePdf()
    {
        Knowledge__kav KnowledgeList = [ SELECT Id, Title, UrlName,KnowledgeArticleId FROM Knowledge__kav LIMIT 1 ];
        
        addArticleApex.savePdf(KnowledgeList.Id,'FileName','ThisisBase64Data');
    }
}