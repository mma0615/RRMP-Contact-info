/**
* Description: This is the Main Class for Navigator Component pages
* Author: Jester Cabantog
* Version: 1.0
* Last modified date: 1/23/2021
**/
public without sharing class NavigatorController {
    
    @AuraEnabled 
    public static string getNavigationDetailsWithVerif(String contactId, String token){
        
        //Verify token
        List<Contact> conRec = [SELECT Id, Contact_Id__c, Name, Login_Token__c from Contact WHERE Contact_Id__c=:contactId /*and Login_Token__c =:token*/];//Disable login function
        if(conRec.isEmpty()){
            return 'INVALIDTOKEN';
        }
        else{
            Map<String,Object> returnMap = new Map <String,Object>();
            
            //Add Contact Details
            returnMap.put('contact',conRec[0]);
            
            //Get Navigation Details
            String navigationId;
            try{
                Navigator__c navigationRecord = [SELECT Id, Name, Event__c,Event__r.Event_Id__c, Journey__c FROM Navigator__c LIMIT 1];
                navigationId =  navigationRecord.Id;
                returnMap.put('navigationRecord',navigationRecord);
                returnMap.put('eventId',navigationRecord.Event__r.Event_Id__c);
            }
            catch(QueryException e){
                if(navigationId == ''){
                    throw new AuraHandledException('No Navigation record for the user');    
                }
                
            }
            //Get Navigation Items for sidebar
            List<Navigator_Item__c> navItemList = [SELECT Id, Name, Navigator__c, Sort_Order__c, Page_URL__c, SLDS_Icon_Name__c 
            FROM Navigator_Item__c 
            WHERE Navigator__r.Id =:navigationId
            ORDER BY Sort_Order__c ASC]; 
            returnMap.put('navItemList',navItemList);
            
            return JSON.serialize(returnMap);  
        }
        
        
    }
    
    @AuraEnabled 
    public static string getNavigationDetails(){
        
        Map<String,Object> returnMap = new Map <String,Object>();
        //Get Navigation Details
        String navigationId;
        try{
            Navigator__c navigationRecord = [SELECT Id, Name, Event__c,Event__r.Event_Id__c, Journey__c FROM Navigator__c LIMIT 1];
            navigationId =  navigationRecord.Id;
            returnMap.put('navigationRecord',navigationRecord);
            returnMap.put('eventId',navigationRecord.Event__r.Event_Id__c);
        }
        catch(QueryException e){
            if(navigationId == ''){
                throw new AuraHandledException('No Navigation record for the user');    
            }
            
        }
        //Get Navigation Items for sidebar
        List<Navigator_Item__c> navItemList = [SELECT Id, Name, Navigator__c, Sort_Order__c, Page_URL__c, SLDS_Icon_Name__c FROM Navigator_Item__c WHERE Navigator__r.Id =:navigationId]; 
        returnMap.put('navItemList',navItemList);
        
        return JSON.serialize(returnMap);     
    }
    
    @AuraEnabled  
    public static string sendTokenCode(String email){
        try{
            List<Contact> conList = [SELECT Name, Email, Login_Token__c  from Contact WHERE Email=:email AND Login_Token__c != ''];
            if(!conList.isEmpty()){
                
                Contact conRec = conList[0];
                //Send Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {email}; 
                    mail.setToAddresses(toAddresses);
                mail.setReplyTo('noreply@salesforce.com');
                mail.setSenderDisplayName('NCC Support');
                mail.setSubject('Login Token for ' + conRec.Name);
                mail.setPlainTextBody('Your token: ' + conRec.Login_Token__c);
                mail.setHtmlBody('Your token: ' +  conRec.Login_Token__c);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                /*
//Create Token
Token_Request__c token = new Token_Request__c();
token.Email__c = email;
//loookup contact

//Generate token
Integer len = 32;
Blob blobKey = crypto.generateAesKey(128);
token.Token__c=  EncodingUtil.convertToHex(blobKey).substring(0, len);
insert token;
*/
            }
            
            else{
                return 'INVALID CONTACT';
            }
        }
        catch(exception e){
            throw new AuraHandledException('Error Sending Email');
        }
        return 'SUCCESS';
    }
    
    @AuraEnabled  
    public static string doLogin(String email, string token){
        List<Contact> conList = [SELECT Id, Name, Email, Login_Token__c, Navigator__r.Event__r.Event_Id__c, Navigator__c,Contact_Id__c from Contact 
        WHERE Email=:email AND Login_Token__c =: token]; 
        if(conList.isEmpty()){
            throw new AuraHandledException('Invalid token, please try again');
        }
        else{
            Map<String,Object> returnMap = new Map <String,Object>();
            String navigationId = conList[0].Navigator__c;
            returnMap.put('contact',conList[0]);
            returnMap.put('eventId',conList[0].Navigator__r.Event__r.Event_Id__c); 

            //Get Home Community URL
            String baseUrl ='';
            for( Navigator_Item__c nav : [SELECT Id, Name, Navigator__c, Sort_Order__c, Page_URL__c, SLDS_Icon_Name__c 
            FROM Navigator_Item__c 
            WHERE Navigator__r.Id =:navigationId AND Sort_Order__c=1]){
                baseUrl = nav.Page_URL__c;
            }
            if(String.isBlank(baseUrl)){
                throw new AuraHandledException('Contact is not associated to any Navigator');
            }
            returnMap.put('baseUrl',baseUrl);

            return JSON.serialize(returnMap);   
        }       
    }

    @AuraEnabled 
    public static Contact getContactInfo(String contactId){
        return [SELECT Id, Name, Title, Contact_Id__c, Profile_Picture_URL__c FROM Contact WHERE Contact_Id__c=:contactId LIMIT 1];
    }

    
}