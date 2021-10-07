/**
* @author Dana Wolfe
* @date 2021/02/16
*
* @group ShoutOut
*
* @description An abstraction layer for makeing REST callouts. Much of this class was borrowed from
* the Apex Recipies Rest Client. This class would typically be extended by a class associated with
* a specific web service.
*/
public inherited sharing virtual class SO_ServiceAdapterBase_REST implements SO_ServiceAdapterInterface {
  /**
  * @description The default headers to use, when none are specified
  */
  @testVisible
  private static Map<String, String> defaultHeaders = new Map<String, String>{
      'Content-Type' => 'application/json; charset=UTF-8',
      'Accept' => 'application/json'
  };

  /**
  * @description
  * Implements the getServiceResponse() method defined by the SO_ServiceAdapterInterface interface.
  * This is a very basic implementation of the method suitable for web services that don't require
  * any pre or post call processing of data.
  *
  * @param requestMap the input parameters used by the web service.
  * @return A Map<String,Object> of web service status and data values.
  */
  Public virtual Map<String,Object> getServiceResponse(Map<String,Object> requestMap) {
    // The responseMap to return
    Map<String, Object> mapToReturn = new Map<String,Object>();
    // Make the call
    HttpResponse response = makeApiCall(requestMap);
    // Deal with the aftermath
    mapToReturn.put('SERVICE_STATUS',response.getStatusCode());
    if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
      mapToReturn.put('SERVICE_DATA',response.getBody());
      mapToReturn.put('SO_RETURN',null);
      mapToReturn.put('SO_SUCCESS',true);
    } else {
      mapToReturn.put('SERVICE_DATA',response.getBody());
      mapToReturn.put('SO_RETURN',null);
      mapToReturn.put('SO_SUCCESS',false);
    }
    return mapToReturn;
  }

  /**
   * @description The primary method for making a REST callout.
   *
   * @param   requestMap A Map<String, Object> of parameters from the calling client code.
   *          Key / value pairs may exist for:
   *          - method : Enum HTTP verb to use. i.e. GET
   *          - path : path component of the callout url i.e. `/services/data/v51.0/SObjects`
   *          - query : Query portion of the URL i.e. `?q=SELECT Id FROM Account`
   *          - body : JSON string representing the body of the callout in post/patch actions
   *          - headers : A map<String,String> of headers to use for this callout
   *
   * @return HttpResponse  The service response
   */
  @testVisible
  protected HttpResponse makeApiCall(Map<String, Object> requestMap) {
    // Augment the requestMap with any available config data from ShoutOut_Service_Setting__mdt
    requestMap = augmentAndValidateRequestMap(requestMap);
    // Is the requestMap valid?
    if (!(Boolean)requestMap.get('ISVALID')) {
      throw new ServiceAdapterException('The requestMap failed validation');
    }

    // TODO Is this neeeded for Salesforce? Salesforce Only? If yes, it should be in a class extending this one targeting Salesforce
    // if (method == HttpVerb.PATCH) {
    //     method = HttpVerb.POST;
    //     encodedQuery += '?_HttpMethod=PATCH';
    // }

    // Create the HttpRequest
    HttpRequest apiRequest = new HttpRequest();
    // Set the method from the requestMap
    apiRequest.setMethod((String)requestMap.get(SO_Constants.RESTHTTPVERB));
    // Process Headers from the requestMap
    Map<String,String> headers = (Map<String,String>)requestMap.get(SO_Constants.RESTHEADERS);
    for (String header : headers.keySet()) {
      apiRequest.setHeader(header, headers.get(header));
    }
    // Process Body, if present
    String body = (String)requestMap.get(SO_Constants.RESTBODY);
    if (!String.isEmpty(body)) {
      String method = apiRequest.getMethod();
      if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
        apiRequest.setBody(body);
      }
    }
    // Start the endpoint with whatever is configured in the named credential
    String endpoint = 'callout:' + (String) requestMap.get(SO_Constants.NAMEDCREDENTIAL);
    // If we have path add it
    if (requestMap.containsKey(SO_Constants.RESTPATH) && String.isNotBlank((String)requestMap.get(SO_Constants.RESTPATH))) {
      endpoint += (String) requestMap.get(SO_Constants.RESTPATH);
    }
    // If we have a query add it
    if (requestMap.containsKey(SO_Constants.RESTQUERY) && String.isNotBlank((String)requestMap.get(SO_Constants.RESTQUERY))) {
      endpoint += (String) requestMap.get(SO_Constants.RESTQUERY);
    }
    // Set the endpoint
    apiRequest.setEndpoint(endpoint);

    Http http = new Http();
    HttpResponse toReturn = http.send(apiRequest);

    return toReturn;
  }

  // Helper Methods

  /**
   * @description Ensures that the inputted string ends in a `/`
   * makes callouts more robust.
   * @param   resource string to ensure ends in `/`
   * @return  inputted string with `/` if it didn't already end in one.
   */
  @testVisible
  protected String ensureStringEndsInSlash(String resource) {
      if (resource.endsWith('/')) {
          return resource;
      }
      return resource + '/';
  }

  /**
  * @description Provides validation of the requestMap provided by the Framework client.
  * If any of the keys RESTHTTPVERB,RESTPATH,RESTQUERY, or RESTHEADERS are not in the requestMap
  * then ShoutOut_Service_Setting__mdt will be consulted and if available a value from there will be used.
  *
  * @param requestMap The requestMap of an instance of the SO_Callout class originating from the Framework client
  * @return True when valid and False when not
  */
  protected Map<String,Object> augmentAndValidateRequestMap(Map<String,Object> requestMap){
    Boolean isValid = true;   // Be optimistic!
    // Get the CALLOUTOPERATION into a variable
    String webServiceName = (String)requestMap.get(SO_Constants.CALLOUTOPERATION);
    /**
     * VERB
     */
    // Do we have a VERB in the requestMap
    if (!requestMap.containsKey(SO_Constants.RESTHTTPVERB)) {
      // No, but is there one configured in ShoutOut_Service_Setting__mdt?
      String verb = SO_Config.getRestVerb(webServiceName);
      if (String.isNotBlank(verb) && isValidHttpVerb(verb)) {
        // Yes, there is one configured and it is valid so add it to requestMap
        requestMap.put(SO_Constants.RESTHTTPVERB,verb);
      } else {
        system.debug('The requestMap does not contain a valid RESTHTTPVERB');
        isValid = false;
      }
    }
    /**
     * PATH
     */
    // Do we have a PATH in the requestMap
    if (!requestMap.containsKey(SO_Constants.RESTPATH)) {
      // No, but is there one configured in ShoutOut_Service_Setting__mdt?
      String path = SO_Config.getRestPath(webServiceName);
      if (String.isNotBlank(path)) {
        requestMap.put(SO_Constants.RESTPATH,path);
      } else {
        system.debug('The requestMap does not contain the key RESTPATH');
      }
    }
    // Finally, make sure the path ends with a slash
    requestMap.put(SO_Constants.RESTPATH,ensureStringEndsInSlash((String)requestMap.get(SO_Constants.RESTPATH)));
    /**
     * QUERY
     */
    // Do we have a QUERY in the requestMap
    if (!requestMap.containsKey(SO_Constants.RESTQUERY)) {
      // No, but is there one configured in ShoutOut_Service_Setting__mdt?
      String query = SO_Config.getRestQuery(webServiceName);
      if (String.isNotBlank(query)) {
        requestMap.put(SO_Constants.RESTQUERY,query);
      }
    }
    // At this point do we have a Query?
    if (requestMap.containsKey(SO_Constants.RESTQUERY)) {
      // Yes, so encode it and put it back in requestMap
      String query = (String) requestMap.get(SO_Constants.RESTQUERY);
      requestMap.put(SO_Constants.RESTQUERY, EncodingUtil.urlEncode(query, 'UTF-8'));
    } else {
      system.debug('The requestMap does not contain the key RESTQUERY');
    }
    /**
     * HEADERS
     */
    // Do we have HEADERS in the requestMap
    if (!requestMap.containsKey(SO_Constants.RESTHEADERS)) {
      // No, so put the default ones in requestMap
      requestMap.put(SO_Constants.RESTHEADERS,defaultHeaders);
    }
    requestMap.put('ISVALID', isValid);
    return requestMap;
  }

  protected Boolean isValidHttpVerb(String verb) {
    return SO_Constants.HTTPVERBSET.contains(verb);
  }

  /**
  * @description Internal custom exception class
  */
  public class ServiceAdapterException extends Exception {
  }


}