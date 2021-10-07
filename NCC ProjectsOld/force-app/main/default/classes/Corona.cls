public class Corona
{
    
    
   
    
    @AuraEnabled
    public static string getChildCategoriesofTopic(){
         List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
          DataCategoryGroupSobjectTypePair pair1 =  new DataCategoryGroupSobjectTypePair();
           pair1.setSobject('KnowledgeArticleVersion');
           pair1.setDataCategoryGroupName('CoronaFacts');
            pairs.add(pair1);
            Map<String,String> topics = new Map<String,String>();
             List<Schema.DescribeDataCategoryGroupStructureResult>results =  Schema.describeDataCategoryGroupStructures(pairs, false);
               for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                   Schema.DataCategory[] topCategories = r.getTopCategories();
                    for(Schema.DataCategory c : topCategories){
                        Schema.DataCategory[] subCats = c.getChildCategories();
                            for(Schema.DataCategory sc: subCats){
                                if(sc.getName() == 'topic'){
                                    for(Schema.DataCategory topicList : sc.getChildCategories())
                                    {
                                        topics.put(String.valueOf(topicList.getLabel()),String.valueOf(topicList.getName()));
                                       
                                    }  
                                  
                                }
                                    
                            }
                       
        }}
                
       return JSON.serialize(topics);
    }
    
    
    @AuraEnabled
    public static string getChildCategoriesofSource(){
         List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
          DataCategoryGroupSobjectTypePair pair1 =  new DataCategoryGroupSobjectTypePair();
           pair1.setSobject('KnowledgeArticleVersion');
           pair1.setDataCategoryGroupName('CoronaFacts');
            pairs.add(pair1);
            Map<String,String> sources = new Map<String,String>();
             List<Schema.DescribeDataCategoryGroupStructureResult>results =  Schema.describeDataCategoryGroupStructures(pairs, false);
               for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                   Schema.DataCategory[] topCategories = r.getTopCategories();
                    for(Schema.DataCategory c : topCategories){
                        Schema.DataCategory[] subCats = c.getChildCategories();
                            for(Schema.DataCategory sc: subCats){
                                if(sc.getName() == 'source'){
                                    for(Schema.DataCategory topicList : sc.getChildCategories())
                                    {
                                        sources.put(String.valueOf(topicList.getLabel()),String.valueOf(topicList.getName()));
                                       
                                    }  
                                  
                                }
                                    
                            }
                       
        }}
                
       return JSON.serialize(sources);
    }
    
    
    
    @AuraEnabled
    public static String onLoadmethod(){
       List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
          DataCategoryGroupSobjectTypePair pair1 =  new DataCategoryGroupSobjectTypePair();
           pair1.setSobject('KnowledgeArticleVersion');
           pair1.setDataCategoryGroupName('CoronaFacts');
            pairs.add(pair1);
            list<string> topics= new list<string>();
            list<string> sources= new list<string>();
            Map<String,String> getLabels = new Map<String,String>();
             List<Schema.DescribeDataCategoryGroupStructureResult>results =  Schema.describeDataCategoryGroupStructures(pairs, false);
               for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                   Schema.DataCategory[] topCategories = r.getTopCategories();
                    for(Schema.DataCategory c : topCategories){
                        Schema.DataCategory[] subCats = c.getChildCategories();
                            for(Schema.DataCategory sc: subCats){
                                if(sc.getName() == 'topic'){
                                    for(Schema.DataCategory topicList : sc.getChildCategories())
                                    {
                                        topics.add( topicList.getLabel());
                                    }  
                                  
                                }
                                else if(sc.getName() == 'source'){
                                    for(Schema.DataCategory sourceList : sc.getChildCategories())
                                    {
                                        sources.add(sourceList.getLabel());
                                    } 
                                }
                                
                                    
                            }
        }}
        
        
        List<Knowledge__kav> KnowledgeBase = Database.query('SELECT Description__c,Source__c,Static_Resource_Name__c,Static_Resource__c,Id,FirstPublishedDate,CreatedDate,Summary,Title,PublishStatus,KnowledgeArticleId  from Knowledge__kav WHERE PublishStatus=' + '\''+ 'Online' + '\'  ORDER BY FirstPublishedDate DESC');
        List<Id> listOfIds = new List<Id>();
        For(Knowledge__kav ids : KnowledgeBase){
            listOfIds.add(ids.Id);
        }
        list<Map<string,string>> listMain = new List<Map<string,string>>();
        Map<string,string> dataMap_internal = new Map<string,string>() ;
        List<Knowledge__DataCategorySelection> DataCategory = [SELECT Id, toLabel(DataCategoryName), toLabel(DataCategoryGroupName), ParentId FROM Knowledge__DataCategorySelection where ParentId IN :listOfIds];
        
        
        For(Knowledge__kav checkIds : KnowledgeBase){
            list<String> topic = new list<String>();
            list<String> source = new list<String>();
            dataMap_internal = new Map<string,string>() ;
            for(Knowledge__DataCategorySelection checkParentId :DataCategory){
                if(checkIds.Id == checkParentId.ParentId){
                    if(topics.contains(checkParentId.DataCategoryName)){
                           
                           topic.add(checkParentId.DataCategoryName); 
                           String mainQuery = topic [0];
                           for(integer i = 1; i < topic.size(); i ++) {
                               mainQuery+= ' , ' + topic [i];
                           }
                           dataMap_internal.put('Topic',mainQuery); 
                       }
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
            dataMap_internal.put('CreatedDate',String.valueof(checkIds.CreatedDate));
            dataMap_internal.put('Summary',checkIds.Summary);
            dataMap_internal.put('Title',checkIds.Title);
            dataMap_internal.put('Id',checkIds.id);
            dataMap_internal.put('StaticResource',checkIds.Static_Resource__c);
            listMain.add(dataMap_internal);
        }
        return JSON.serialize(listMain);
    }
    
    
    
    
    @AuraEnabled
    public static  String changemethod(String topic, String source){
         List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
          DataCategoryGroupSobjectTypePair pair1 =  new DataCategoryGroupSobjectTypePair();
           pair1.setSobject('KnowledgeArticleVersion');
           pair1.setDataCategoryGroupName('CoronaFacts');
            pairs.add(pair1);
            list<string> topics= new list<string>();
            list<string> sources= new list<string>();
            Map<String,String> getLabels = new Map<String,String>();
             List<Schema.DescribeDataCategoryGroupStructureResult>results =  Schema.describeDataCategoryGroupStructures(pairs, false);
               for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                   Schema.DataCategory[] topCategories = r.getTopCategories();
                    for(Schema.DataCategory c : topCategories){
                        Schema.DataCategory[] subCats = c.getChildCategories();
                            for(Schema.DataCategory sc: subCats){
                                if(sc.getName() == 'topic'){
                                    for(Schema.DataCategory topicList : sc.getChildCategories())
                                    {
                                        topics.add( topicList.getLabel());
                                    }  
                                  
                                }
                                else if(sc.getName() == 'source'){
                                    for(Schema.DataCategory sourceList : sc.getChildCategories())
                                    {
                                        sources.add(sourceList.getLabel());
                                    } 
                                }
                                
                                    
                            }
        }}

        
        List<Knowledge__kav> KnowledgeBase = new List<Knowledge__kav>();
        if(topic == 'Topic' && source == 'Source'){
            KnowledgeBase = Database.query('SELECT Source__c,Static_Resource_Name__c,Static_Resource__c,Id,FirstPublishedDate,CreatedDate,Summary,Title,PublishStatus,KnowledgeArticleId  from Knowledge__kav WHERE PublishStatus=' + '\''+ 'Online' + '\' ORDER BY FirstPublishedDate DESC');
        }
        else if(topic != 'Topic' && source == 'Source'){
            KnowledgeBase = Database.query('SELECT Source__c,Static_Resource_Name__c,Static_Resource__c,Id,FirstPublishedDate,CreatedDate,Summary,Title,PublishStatus,KnowledgeArticleId  from Knowledge__kav WHERE PublishStatus=' + '\''+ 'Online' + '\' WITH  DATA CATEGORY CoronaFacts__c AT '+'('+ topic +'__c'+')');
        }
        else if(topic == 'Topic' && source != 'Source'){
            KnowledgeBase = Database.query('SELECT Source__c,Static_Resource_Name__c,Static_Resource__c,Id,FirstPublishedDate,CreatedDate,Summary,Title,PublishStatus,KnowledgeArticleId  from Knowledge__kav WHERE PublishStatus=' + '\''+ 'Online' + '\' WITH  DATA CATEGORY CoronaFacts__c AT '+'('+ source +'__c'+')');
        }
        else if(topic != 'Topic' && source != 'Source'){
            List<Knowledge__kav> topicKnow = Database.query('SELECT Source__c,Static_Resource_Name__c,Static_Resource__c,Id,FirstPublishedDate,CreatedDate,Summary,Title,PublishStatus,KnowledgeArticleId  from Knowledge__kav WHERE PublishStatus=' + '\''+ 'Online' + '\' WITH  DATA CATEGORY CoronaFacts__c AT '+'('+ topic +'__c'+')');
            List<Knowledge__kav> sourceKnow = Database.query('SELECT Source__c,Static_Resource_Name__c,Static_Resource__c,Id,FirstPublishedDate,CreatedDate,Summary,Title,PublishStatus,KnowledgeArticleId  from Knowledge__kav WHERE PublishStatus=' + '\''+ 'Online' + '\' WITH  DATA CATEGORY CoronaFacts__c AT '+'('+ source +'__c'+')');
            for(Knowledge__kav topicValue :topicKnow){
                for(Knowledge__kav sourceValue :sourceKnow){
                    if(topicValue.Id == sourceValue.Id){
                        KnowledgeBase.add(topicValue);
                    }
                }
            } 
            
        }        
        
        List<Id> listOfIds = new List<Id>();
        List<String> listds = new List<String>();
        For(Knowledge__kav ids : KnowledgeBase){
            listds.add(ids.Title);
            listOfIds.add(ids.Id);
        }
        list<Map<string,string>> listMain = new List<Map<string,string>>();
        Map<string,string> dataMap_internal = new Map<string,string>() ;
        List<Knowledge__DataCategorySelection> DataCategory = [SELECT Id, toLabel(DataCategoryName), toLabel(DataCategoryGroupName), ParentId FROM Knowledge__DataCategorySelection where ParentId IN :listOfIds];
        
        For(Knowledge__kav checkIds : KnowledgeBase){
            list<String> topicss = new list<String>();
            list<String> sourcess = new list<String>();
            dataMap_internal = new Map<string,string>() ;
            for(Knowledge__DataCategorySelection checkParentId :DataCategory){
                if(checkIds.Id == checkParentId.ParentId){
                    if(topics.contains(checkParentId.DataCategoryName)){
                           
                           topicss.add(checkParentId.DataCategoryName); 
                           String mainQuery = topicss [0];
                           for(integer i = 1; i < topicss.size(); i ++) {
                               mainQuery+= ' , ' + topicss [i];
                           }
                           dataMap_internal.put('Topic',mainQuery); 
                       }
                    
                    if(sources.contains(checkParentId.DataCategoryName)){
                           
                           sourcess.add(checkParentId.DataCategoryName); 
                           String mainQuerySource = sourcess [0];
                           for(integer i = 1; i < sourcess.size(); i ++) {
                               mainQuerySource+= ' , ' + sourcess [i];
                           }
                           dataMap_internal.put('Source',mainQuerySource); 
                       }
                    
                }
            }
            dataMap_internal.put('CreatedDate',String.valueof(checkIds.CreatedDate));
            dataMap_internal.put('Summary',checkIds.Summary);
            dataMap_internal.put('Title',checkIds.Title);
            dataMap_internal.put('Id',checkIds.id);
            dataMap_internal.put('StaticResource',checkIds.Static_Resource__c);
            listMain.add(dataMap_internal);
        }
        return JSON.serialize(listMain);
        
    }
    
        
    @AuraEnabled
    public static String showTitle(String getId){
        Knowledge__kav getDescription = [SELECT title,Id FROM Knowledge__kav WHERE Id=:getId];
        return getDescription.title; 
    }   
    
    
    @AuraEnabled
    public static Knowledge__kav getDescription(String recordId){
        Knowledge__kav getDescription = [SELECT title,Description__c,Id FROM Knowledge__kav WHERE Id=:recordId];
        return getDescription;
    }
    
}