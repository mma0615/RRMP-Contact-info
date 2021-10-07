/*********************
*   CGSRestAPIController
*   @author:        Minh H Ma / Geoffrey Murray / Catalina Vasallo
*   @date:          02/09/2021
*   description:   This is the API framework that is used to call out to external services. Custom metadata is used to drive the HTTP call out.
*                   The results can be parsed for updating data into Salesforce.
*
*                   This version currently support GET method, single record, single object.
*
*                   Example of adding remote site settings: http://api.openweathermap.org
*
*                   Parameters:
*                        Metadata label name for the api call
*                        Parameters (api=aaaa&customer=1234&country=usa)
*
*                   This can be called from an APEX using example below: 
*                        string results = CGSRestAPIController.APICallOut('Open Weather Map','q=London,uk');
*                        system.debug('results:' + results);                   
*
*   Update History:
*   02/09/2021  Intial Version
*********************/
public with sharing class CGSRestAPIController {

    public static string APICallOut(string metadataName, string parameters) {
        string result = null;
        try {
        
            Map<String, CGS_Rest_API__mdt> mapRESTApi = CGSRestAPIHelper.getRESTApi();
            CGS_Rest_API__mdt mdt = mapRESTApi.get(metadataName);
            
            if (mdt == null)
                result = 'No meta data found...';
            else
            {                
                HTTPRequest req = new HTTPRequest();
                
                // seting endpoint
                string endPoint = mdt.requestEndPoint__c;                
                if (string.isNotEmpty(parameters) && string.isNotEmpty(mdt.API_Key__c) )
                    endPoint = mdt.requestEndPoint__c + '?' + parameters + '&' + mdt.API_Key__c;
                else if (string.isNotEmpty(parameters) )
                    endPoint= mdt.requestEndPoint__c + '?' + parameters;
                else if (string.isNotEmpty(mdt.API_Key__c) )
                    endPoint = mdt.requestEndPoint__c + '?' + mdt.API_Key__c;
                    
                req.setEndpoint(endPoint);
                System.debug('***** endPoint: ' + endPoint );
                
                req.setMethod(mdt.Method__c);
                System.debug('***** mdt.Method__c: ' + mdt.Method__c );
                
                // setting headers
                req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
                req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); 
                /*
                if (string.isNotEmpty(mdt.User_Name__c) )
                {
                    Blob headerValue = Blob.valueOf(mdt.User_Name__c + ':' + mdt.Password__c);
                    String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                    req.setHeader('Authorization', authorizationHeader);                    
                }
                */             
                
                // HTTP Callout
                HTTP h = new HTTP();
                HTTPResponse resp = h.send(req);
                
                // if resource requested has been temporarily moved to the URL given by the Location header
                while(resp.getStatusCode() == 302) 
                {
                    req.setEndpoint(resp.getHeader('Location'));
                    resp = new HTTP().send(req);
                }

                // if successfull 
                if (resp.getStatusCode() == 200 ) 
                {  
                    result = resp.getBody();  
                } 
                else 
                {  
                    throw new CalloutException(resp.getBody());  
                }         

                System.debug('***** BODY: ' + resp.getBody());        
                //result = resp.getBody();        
                //jsonStr = jsonStr.replace('"desc":','"description":');
            }
        }
        catch(Exception ex) {
             System.Debug(ex);
        }

        return result;
    }
}