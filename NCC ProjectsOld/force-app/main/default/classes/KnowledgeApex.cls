public class KnowledgeApex {
    
    @AuraEnabled
    public static List<Knowledge__kav> getKnowledgeArticles(){
        List<Knowledge__kav> KnowledgeBase = [SELECT Description__c,Static_Resource_Name__c ,Static_Resource__c,Source__c,Id,Summary,Title,PublishStatus FROM Knowledge__kav where PublishStatus ='Online' limit 4];
        return  KnowledgeBase;
    }
    
    @AuraEnabled
    public static String getTrendingArticles(){
        /*List<Knowledge__kav> getTrendingArticles = [SELECT Description__c,Source__c,Static_Resource_Name__c,Summary,ArticleTotalViewCount, Id, Title FROM Knowledge__kav where PublishStatus ='Online' ORDER BY ArticleTotalViewCount DESC limit 4];
        return getTrendingArticles;
    }*/
    
    
     List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
          DataCategoryGroupSobjectTypePair pair1 =  new DataCategoryGroupSobjectTypePair();
           pair1.setSobject('KnowledgeArticleVersion');
           pair1.setDataCategoryGroupName('CoronaFacts');
			pairs.add(pair1);
        	list<string> sources= new list<string>();
        	Map<String,String> getLabels = new Map<String,String>();
             List<Schema.DescribeDataCategoryGroupStructureResult>results =  Schema.describeDataCategoryGroupStructures(pairs, false);
               for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                   Schema.DataCategory[] topCategories = r.getTopCategories();
                    for(Schema.DataCategory c : topCategories){
                        Schema.DataCategory[] subCats = c.getChildCategories();
                            for(Schema.DataCategory sc: subCats){
                                if(sc.getName() == 'source'){
                                    for(Schema.DataCategory sourceList : sc.getChildCategories())
                                    {
                                        sources.add(sourceList.getLabel());
                                    } 
                                }
                                
                                	
                            }
        }}
        
        
        List<Knowledge__kav> KnowledgeBase = Database.query('SELECT Source__c,Description__c,Static_Resource_Name__c,Static_Resource__c,Article_URL_1__c,Id,FirstPublishedDate,CreatedDate,Summary,Title,PublishStatus,KnowledgeArticleId  from Knowledge__kav WHERE PublishStatus=' + '\''+ 'Online' + '\'  ORDER BY ArticleTotalViewCount DESC limit 4');
        List<Id> listOfIds = new List<Id>();
        For(Knowledge__kav ids : KnowledgeBase){
            listOfIds.add(ids.Id);
        }
        list<Map<string,string>> listMain = new List<Map<string,string>>();
        Map<string,string> dataMap_internal = new Map<string,string>() ;
        List<Knowledge__DataCategorySelection> DataCategory = [SELECT Id, toLabel(DataCategoryName), toLabel(DataCategoryGroupName), ParentId FROM Knowledge__DataCategorySelection where ParentId IN :listOfIds];
        
        
        For(Knowledge__kav checkIds : KnowledgeBase){
            
            list<String> source = new list<String>();
            dataMap_internal = new Map<string,string>() ;
            for(Knowledge__DataCategorySelection checkParentId :DataCategory){
                if(checkIds.Id == checkParentId.ParentId){
                     if(sources.contains(checkParentId.DataCategoryName)){
                           
                           source.add(checkParentId.DataCategoryName); 
                           String mainQuerySource = source [0];
                           for(integer i = 1; i < source.size(); i ++) {
                               mainQuerySource+= ' , ' + source [i];
                           }
                           dataMap_internal.put('Source',mainQuerySource); 
                       }
                    
                }
            }
            dataMap_internal.put('URL',checkIds.Article_URL_1__c);
            dataMap_internal.put('Description',checkIds.Description__c);
            dataMap_internal.put('Summary',checkIds.Summary);
            dataMap_internal.put('Title',checkIds.Title);
            dataMap_internal.put('Id',checkIds.id);
            dataMap_internal.put('StaticResource',checkIds.Static_Resource__c);
            listMain.add(dataMap_internal);
        }
        return JSON.serialize(listMain);
    }
    
    
    @AuraEnabled
    public static String getRecentArticles(){
        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
          DataCategoryGroupSobjectTypePair pair1 =  new DataCategoryGroupSobjectTypePair();
           pair1.setSobject('KnowledgeArticleVersion');
           pair1.setDataCategoryGroupName('CoronaFacts');
			pairs.add(pair1);
        	list<string> sources= new list<string>();
        	Map<String,String> getLabels = new Map<String,String>();
             List<Schema.DescribeDataCategoryGroupStructureResult>results =  Schema.describeDataCategoryGroupStructures(pairs, false);
               for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                   Schema.DataCategory[] topCategories = r.getTopCategories();
                    for(Schema.DataCategory c : topCategories){
                        Schema.DataCategory[] subCats = c.getChildCategories();
                            for(Schema.DataCategory sc: subCats){
                                if(sc.getName() == 'source'){
                                    for(Schema.DataCategory sourceList : sc.getChildCategories())
                                    {
                                        sources.add(sourceList.getLabel());
                                    } 
                                }
                                
                                	
                            }
        }}
        
        
        List<Knowledge__kav> KnowledgeBase = Database.query('SELECT Source__c,Description__c,Static_Resource__c,Article_URL_1__c,Id,FirstPublishedDate,CreatedDate,Summary,Title,PublishStatus,KnowledgeArticleId  from Knowledge__kav WHERE PublishStatus=' + '\''+ 'Online' + '\'  ORDER BY FirstPublishedDate limit 4');
        List<Id> listOfIds = new List<Id>();
        For(Knowledge__kav ids : KnowledgeBase){
            listOfIds.add(ids.Id);
        }
        list<Map<string,string>> listMain = new List<Map<string,string>>();
        Map<string,string> dataMap_internal = new Map<string,string>() ;
        List<Knowledge__DataCategorySelection> DataCategory = [SELECT Id, toLabel(DataCategoryName), toLabel(DataCategoryGroupName), ParentId FROM Knowledge__DataCategorySelection where ParentId IN :listOfIds];
        
        
        For(Knowledge__kav checkIds : KnowledgeBase){
            
            list<String> source = new list<String>();
            dataMap_internal = new Map<string,string>() ;
            for(Knowledge__DataCategorySelection checkParentId :DataCategory){
                if(checkIds.Id == checkParentId.ParentId){
                     if(sources.contains(checkParentId.DataCategoryName)){
                           
                           source.add(checkParentId.DataCategoryName); 
                           String mainQuerySource = source [0];
                           for(integer i = 1; i < source.size(); i ++) {
                               mainQuerySource+= ' , ' + source [i];
                           }
                           dataMap_internal.put('Source',mainQuerySource); 
                       }
                    
                }
            }
            dataMap_internal.put('URL',checkIds.Article_URL_1__c);
            dataMap_internal.put('Summary',checkIds.Summary);
            dataMap_internal.put('Title',checkIds.Title);
            dataMap_internal.put('Id',checkIds.id);
            dataMap_internal.put('StaticResource',checkIds.Static_Resource__c);
            listMain.add(dataMap_internal);
        }
        return JSON.serialize(listMain);
        //List<Knowledge__kav> getTrendingArticles = [SELECT Description__c,Source__c,Article_URL_1__c,Static_Resource__c,Summary,ArticleTotalViewCount, Id, Title FROM Knowledge__kav where PublishStatus ='Online' ORDER BY FirstPublishedDate limit 4];
        //return getTrendingArticles;
    }
    
    
    @AuraEnabled
    public static string getMostRatedArticles(){
        
        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
          DataCategoryGroupSobjectTypePair pair1 =  new DataCategoryGroupSobjectTypePair();
           pair1.setSobject('KnowledgeArticleVersion');
           pair1.setDataCategoryGroupName('CoronaFacts');
			pairs.add(pair1);
        	list<string> sources= new list<string>();
        	Map<String,String> getLabels = new Map<String,String>();
             List<Schema.DescribeDataCategoryGroupStructureResult>results =  Schema.describeDataCategoryGroupStructures(pairs, false);
               for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                   Schema.DataCategory[] topCategories = r.getTopCategories();
                    for(Schema.DataCategory c : topCategories){
                        Schema.DataCategory[] subCats = c.getChildCategories();
                            for(Schema.DataCategory sc: subCats){
                                if(sc.getName() == 'source'){
                                    for(Schema.DataCategory sourceList : sc.getChildCategories())
                                    {
                                        sources.add(sourceList.getLabel());
                                    } 
                                }
                                
                                	
                            }
        }}
        
        
        //List<Knowledge__kav> KnowledgeBase = Database.query('SELECT Source__c,Description__c,Static_Resource_Name__c,Article_URL_1__c,Id,FirstPublishedDate,CreatedDate,Summary,Title,PublishStatus,KnowledgeArticleId  from Knowledge__kav WHERE PublishStatus=' + '\''+ 'Online' + '\'  ORDER BY FirstPublishedDate limit 4');
        
		List<Voting__c> getTrendingArticles = [SELECT Id, Like_Counter__c,Dislike_Counter__c,KnowledgeArticle__r.id,KnowledgeArticle__r.Static_Resource__c,KnowledgeArticle__r.Description__c,KnowledgeArticle__r.Title, KnowledgeArticle__r.Source__c,KnowledgeArticle__r.Article_URL_1__c, KnowledgeArticle__r.Static_Resource_Name__c, KnowledgeArticle__r.Summary, Name FROM Voting__c WHERE KnowledgeArticle__r.PublishStatus='Online' order by Like_Counter__c DESC limit 4];

		List<Id> listOfIds = new List<Id>();
        For(Voting__c ids : getTrendingArticles){
            listOfIds.add(ids.KnowledgeArticle__r.Id);
        }
        list<Map<string,string>> listMain = new List<Map<string,string>>();
        Map<string,string> dataMap_internal = new Map<string,string>() ;
        List<Knowledge__DataCategorySelection> DataCategory = [SELECT Id, toLabel(DataCategoryName), toLabel(DataCategoryGroupName), ParentId FROM Knowledge__DataCategorySelection where ParentId IN :listOfIds];
        
        
        For(Voting__c checkIds : getTrendingArticles){
            
            list<String> source = new list<String>();
            dataMap_internal = new Map<string,string>() ;
            for(Knowledge__DataCategorySelection checkParentId :DataCategory){
                if(checkIds.KnowledgeArticle__r.Id == checkParentId.ParentId){
                     if(sources.contains(checkParentId.DataCategoryName)){
                           
                           source.add(checkParentId.DataCategoryName); 
                           String mainQuerySource = source [0];
                           for(integer i = 1; i < source.size(); i ++) {
                               mainQuerySource+= ' , ' + source [i];
                           }
                           dataMap_internal.put('Source',mainQuerySource); 
                       }
                    
                }
            }
            dataMap_internal.put('URL',checkIds.KnowledgeArticle__r.Article_URL_1__c);
            dataMap_internal.put('Summary',checkIds.KnowledgeArticle__r.Summary);
            dataMap_internal.put('Title',checkIds.KnowledgeArticle__r.Title);
            dataMap_internal.put('Id',checkIds.KnowledgeArticle__r.id);
            dataMap_internal.put('StaticResource',checkIds.KnowledgeArticle__r.Static_Resource__c);
            listMain.add(dataMap_internal);
        }
        return JSON.serialize(listMain);
        
        //List<Voting__c> getTrendingArticles = [SELECT Id, Like_Counter__c,Dislike_Counter__c,KnowledgeArticle__r.id, KnowledgeArticle__r.Description__c,KnowledgeArticle__r.Title, KnowledgeArticle__r.Source__c,KnowledgeArticle__r.Article_URL_1__c, KnowledgeArticle__r.Static_Resource_Name__c, KnowledgeArticle__r.Summary, Name FROM Voting__c WHERE KnowledgeArticle__r.PublishStatus='Online' order by Like_Counter__c DESC limit 4];
        //return getTrendingArticles;
    }
    
    @AuraEnabled
    public static List<Knowledge__kav> allArticles(){
        List<Knowledge__kav> allArticlesList = [SELECT Description__c,Article_URL_1__c,Source__c,Static_Resource_Name__c,Static_Resource__c,Summary,ArticleTotalViewCount, Id, Title FROM Knowledge__kav where PublishStatus ='Online'];
        return allArticlesList;
    }
    
    @AuraEnabled
    public static Knowledge__kav getDescription(String recordId){
        Knowledge__kav getDescription = [SELECT title,Description__c,Id FROM Knowledge__kav WHERE Id=:recordId];
        return getDescription;
    }
    
}