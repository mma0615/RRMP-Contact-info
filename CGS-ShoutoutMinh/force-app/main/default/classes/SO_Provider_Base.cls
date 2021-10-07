/**
* @author Dana Wolfe
* @date 2021/02/14
*
* @group ShoutOut
*
* @description Implements the SO_ProviderInterface, providing common code used by the Framework
* with all providers and methods requried by the interface.
*
*/
public inherited sharing virtual class SO_Provider_Base implements SO_ProviderInterface {

  /**
  * @description Provides basic validation of the SO_Callout object provided by the
  * Framework client code to insure a CALLOUTOPERATION parameter that identifies the  .
  * web service to be called has been provided. This method is defined as virtual with
  * the intent that classes that extend this base class will perform additional validation.
  *
  * @param callout an instance of the SO_Callout class originating from the Framework client
  * @return True when valid and False when not
  */
  public virtual Boolean isValidRequest(SO_Callout callout){
    Boolean returnValue = true;   // Let's be optimistic!
    // Does the requestMap identifie the web service to be called?
    if (!callout.serviceRequestMap.containsKey(SO_Constants.CALLOUTOPERATION)) {
      // No, fail!
      returnValue = false;
    }
    return returnValue;
  }

  /**
  * @description Returns the provided Named Credential name with a suffix of either "_production"
  * or "_sandbox" depending on what type of Org we're executing on. The implication
  * is that both versions of the named credential exist even if they are the same.
  *
  * @param nameRoot The root ,or beginning, part of the Named Credential name
  * @return The root + extension. For example, "SOMEHOST" becomes "SOMEHOST_sandbox" or "SOMEHOST_production"
  *
  */
  public static String getOrgNamedCredential(String nameRoot){
    String nameToReturn = nameRoot;
    // First we'll remove "_production" or "_sandbox" if it's already there.
    nameToReturn.remove('_production');
    nameToReturn.remove('_sandbox');
    // Now append the correct suffix
    if (SO_Config.runningInSandbox) {
      nameToReturn += '_sandbox';
    } else {
      nameToReturn += '_production';
    }
    return nameToReturn;
  }

  /**
  * @description Implementing the SO_ProviderInterface requires us to have this method but
  * it returns an empty responseMap. The "actual" Provider will extend this base class and
  * override this method.
  *
  * @param callout an instance of the SO_Callout class originating from the Framework client
  * @return The responseMap, a Map<String, Object>
  */
  public virtual Map<String, Object> makeCallout(SO_Callout callout) {
      system.debug('*** SO ERROR *** : Calling the SO_Provider_Base makeSyncCallout() method. Don\'t expect anything to happen');
      return callout.serviceResponseMap;
  }
  /**
  * @description
  * If the requestMap has a element with key SO_Constants.SERVICETIMEOUT then return the
  * integer value to be used as the call timeout.
  *
  * @param requestMap A Map of parameters used in making the callout
  * @return Integer representing the timeout in seconds
  */
  public static integer getTimeout(Map<String,Object> requestMap){
    Integer timeout = 10;        // Defaults to 10 seconds
    if (requestMap.containsKey(SO_Constants.SERVICETIMEOUT)){
        timeout = Integer.valueOf(requestMap.get(SO_Constants.SERVICETIMEOUT));
        // Insure the value is between 10 and 120 seconds
        timeout = timeout > 120 ? 120 : timeout;
        timeout = timeout < 10 ? 10 : timeout;
    }
    return timeout;
  }
}