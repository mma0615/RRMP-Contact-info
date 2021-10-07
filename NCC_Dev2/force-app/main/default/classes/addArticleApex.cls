public with sharing class addArticleApex{

    
     @AuraEnabled(cacheable = true)
    public static string getChildCategoriesofTarget(){
         List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
          DataCategoryGroupSobjectTypePair pair1 =  new DataCategoryGroupSobjectTypePair();
           pair1.setSobject('KnowledgeArticleVersion');
           pair1.setDataCategoryGroupName('CoronaFacts');
			pairs.add(pair1);
        	Map<String,String> target = new Map<String,String>();
             List<Schema.DescribeDataCategoryGroupStructureResult>results =  Schema.describeDataCategoryGroupStructures(pairs, false);
               for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                   Schema.DataCategory[] topCategories = r.getTopCategories();
                    for(Schema.DataCategory c : topCategories){
                        Schema.DataCategory[] subCats = c.getChildCategories();
                            for(Schema.DataCategory sc: subCats){
                                System.debug('ParentData  ' +sc.getName());
                                if(sc.getName() == 'Target_Audience'){
                                    for(Schema.DataCategory topicList : sc.getChildCategories())
                                    {
                                        target.put(String.valueOf(topicList.getLabel()),String.valueOf(topicList.getName()));
                                       
                                    }  
                                  
                                }
                                	
                            }
                       
        }}
       target.put('Additional Target','Additional_Target_Audience__c');           
       return JSON.serialize(target);
    }
    
    
     @AuraEnabled(cacheable = true)
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
                                System.debug('ParentData  ' +sc.getName());
                                if(sc.getName() == 'topic'){
                                    for(Schema.DataCategory topicList : sc.getChildCategories())
                                    {
                                        topics.put(String.valueOf(topicList.getLabel()),String.valueOf(topicList.getName()));
                                       
                                    }  
                                  
                                }
                                	
                            }
                       
        }}
       topics.put('Additional Topic','Additional_Topic__c');         
       return JSON.serialize(topics);
    }
    
    
     @AuraEnabled(cacheable = true)
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
                                System.debug('ParentData  ' +sc.getName());
                                if(sc.getName() == 'source'){
                                    for(Schema.DataCategory topicList : sc.getChildCategories())
                                    {
                                        sources.put(String.valueOf(topicList.getLabel()),String.valueOf(topicList.getName()));
                                       
                                    }  
                                  
                                }
                                	
                            }
                       
        }}
       sources.put('Additional Source','Additional_Source__c');         
       return JSON.serialize(sources);
    }
    


	@AuraEnabled(cacheable = true)
    public static string getChildCategoriesofAttributes(){
         List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
          DataCategoryGroupSobjectTypePair pair1 =  new DataCategoryGroupSobjectTypePair();
           pair1.setSobject('KnowledgeArticleVersion');
           pair1.setDataCategoryGroupName('CoronaFacts');
			pairs.add(pair1);
        	Map<String,String> attributes = new Map<String,String>();
             List<Schema.DescribeDataCategoryGroupStructureResult>results =  Schema.describeDataCategoryGroupStructures(pairs, false);
               for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                   Schema.DataCategory[] topCategories = r.getTopCategories();
                    for(Schema.DataCategory c : topCategories){
                        Schema.DataCategory[] subCats = c.getChildCategories();
                            for(Schema.DataCategory sc: subCats){
                                System.debug('ParentData  ' +sc.getName());
                                if(sc.getName() == 'Source_Attributes'){
                                    for(Schema.DataCategory topicList : sc.getChildCategories())
                                    {
                                        attributes.put(String.valueOf(topicList.getLabel()),String.valueOf(topicList.getName()));
                                       
                                    }  
                                  
                                }
                                	
                            }
                       
        }}
       attributes.put('Additional Source Attribute','Additional_Source_Attribute__c');         
       return JSON.serialize(attributes);
    }
    
    
    
    
    
    @AuraEnabled
    public static String createArticle(Knowledge__kav acc, Lead lead, String urlTwo, String urlThrees, String urlForth, String urlFiv, List<String> target){
        system.debug('categorrru' +target);
        String msg = '';
        try{
            list<contact> dupContact = [SELECT Id, Email, FirstName, LastName, AccountId FROM Contact where Email = :lead.Email];
            if(dupContact.size() > 0){
                acc.Contact__c = dupContact[0].Id;
            }
            else{
                new Lead();
                list<Lead> dupes = [SELECT Id FROM lead WHERE Email = :lead.Email];
                lead.Status = 'New';
                if (dupes.size() > 0){
                    dupes[0].FirstName = lead.FirstName;
                    dupes[0].LastName = lead.LastName;
                    dupes[0].Company = lead.Company;
                    update dupes;
                } else{
                    insert lead;
                }
                if (dupes.size() > 0){
                    acc.Lead__c = dupes[0].Id;
                } else{
                    acc.Lead__c = lead.Id;
                }
            }
            acc.IsVisibleInPkb = true;
            acc.Static_Resource__c = 'DefaultImageOfArticle';
            acc.Article_URL_2__c = urlTwo;
            acc.Article_URL_3__c = urlThrees;
            acc.Article_URL_4__c = urlForth;
            acc.Article_URL_5__c = urlFiv;
            insert acc;
            system.debug('insert lead ' +acc);
            if (target.size() > 0){
                List<Knowledge__DataCategorySelection> kk = new List<Knowledge__DataCategorySelection>();
                for (String cat : target){
                    
                    Knowledge__DataCategorySelection kADCS = new Knowledge__DataCategorySelection();
                    kADCS.ParentId = acc.Id;
                    kADCS.DataCategoryGroupName = 'CoronaFacts';
                    kADCS.DataCategoryName = cat;
                    kk.add(kADCS);
                }
                insert (kk);
                system.debug('kkk ' +kk);
            }
            return acc.Id;
        } catch (DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++){
                //Get Validation Rule & Trigger Error Messages
                msg = e.getDmlMessage(i) + '\n';
            }
            return 'Error :' + msg;
        } catch (Exception e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static ContentVersion saveFile(Id idParent, String strFileName, String base64Data){
        system.debug('enter in first upload');
        // Decoding base64Data
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = strFileName;
        cv.PathOnClient = '/' + strFileName;
        cv.FirstPublishLocationId = idParent;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;
        return cv;
        
        
    }
    
    @AuraEnabled
    public static ContentVersion savePdf(Id idParent, String strFileName, String base64Data){
        // Decoding base64Data
        system.debug('enter in second upload');
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = strFileName;
        cv.PathOnClient = '/' + strFileName;
        cv.FirstPublishLocationId = idParent;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;
        return cv;
    }
}