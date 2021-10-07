/**
* @author Dana Wolfe
* @date 2021/02/14
*
* @group ShoutOut
*
* @description This class is the developer facing interface to the Framework, hosting the request and response
* Maps, providing @AuraEnabled methods for Lightning Web Components, and proving the callWebService() method.
*
*/
public inherited sharing class SO_Callout {

  // The internal request and response maps
  private Map<String, Object> requestMap;
  private Map<String, Object> responseMap;
  /**
  * @description Provides read-only access to the request map of a SO_Callout instance. Use one of the
  * addToRequestMap() methods to modify this Map.
  */
  Public Map<String, Object> serviceRequestMap {
    get {
        return requestMap;
    }
  }

  /**
  * @description Provides read-only access to the response map of a SO_Callout instance.
  */
  Public Map<String, Object> serviceResponseMap {
    get {
        return responseMap;
    }
  }

  /**
  * @description
  * The Default contructor initializes the request and response Maps.
  *
  */
  Public SO_Callout(){
    requestMap = new Map<String, Object>();
    responseMap = new Map<String, Object>();
  }

  /**
  * @description
  * This method adds a single key and object to the requestMap
  *
  * @param key A key of type String
  * @param value A value of type Object
  * @return returns a reference to itself (SO_Callout)
  * @example
  * myCallout.addToRequestMap('someParamName','someParamValue');
  */
  public SO_Callout addToRequestMap(String key, Object value) {
    // If key is empty then return
    if (String.isEmpty(key)) {return this;}
    // Process input
    this.requestMap.put(key.toUpperCase(), value);
    return this;
  }

  /**
  * @description
  * This method adds a Map<String, Object> to the requestMap
  *
  * @param mapToAdd a Map<String, Object> of request parameters
  * @return returns a reference to itself (SO_Callout)
  * @example
  * Map<String, Object> paramMap = new Map<String, Object>('someParamName' => (Object)'someParamValue', 'anotherParamName' => (Object)'anotherParamValue'};
  * myCallout.addToRequestMap(paramMap);
  */
  public SO_Callout addToRequestMap(Map<String,Object> mapToAdd) {
    // If input is null then return
    if (mapToAdd == null) {return this;}
    // Process input
    for (String key : mapToAdd.keySet()) {
        this.requestMap.put(key.toUpperCase(), mapToAdd.get(key));
    }
    return this;
  }

  /**
  * @description
  * This method adds a single key and object to the responseMap
  *
  * @param key A key of type String
  * @param value A value of type Object
  * @return returns a reference to itself (SO_Callout)
  * @example
  * myCallout.addToResponseMap('someParamName','someParamValue');
  */
  public SO_Callout addToResponseMap(String key, Object value) {
    // If key is empty then return
    if (String.isEmpty(key)) {return this;}
    // Process input
    this.responseMap.put(key.toUpperCase(), value);
    return this;
  }

  /**
  * @description
  * This method adds a Map<String, Object> to the responseMap
  *
  * @param mapToAdd a Map<String, Object> of request parameters
  * @return returns a reference to itself (SO_Callout)
  * @example
  * Map<String, Object> paramMap = new Map<String, Object>('someResponseFieldName' => (Object)'someResponseFieldValue', 'anotherResponseFieldName' => (Object)'anotherResponseFieldValue'};
  * myCallout.addToResponseMap(paramMap);
  */
  public SO_Callout addToResponseMap(Map<String,Object> mapToAdd) {
    // If input is null then return
    if (mapToAdd == null) {return this;}
    // Process input
    for (String key : mapToAdd.keySet()) {
        this.responseMap.put(key.toUpperCase(), mapToAdd.get(key));
    }
    return this;
  }

  /**
  * @description This method is where the magic happens. With the requestMap prepared it
  * is heaved over the fence into the Frameworks yard and with luck a responseMap will
  * soon be heaved back into ours
  *
  * @param name description
  * @return A Map<String, Object> that is the responseMap
  */
  public Map<String, Object> callWebService() {
    try {
        SO_ProviderInterface webServiceProvider = SO_ProviderFactory.getInstance(this.requestMap);
        this.responseMap = webServiceProvider.makeCallout(this);
    } catch (Exception ex) {
        addToResponseMap('SO_RETURN', ex.getMessage());
        addToResponseMap('SO_SUCCESS', (Boolean) false);
        // TODO Add Exception handling / logging
      }
    return this.serviceResponseMap;
  }
}