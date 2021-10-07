/**
* @author Dana Wolfe
* @date 2021/02/14
*
* @group ShoutOut
*
* @description Identifies methods that every Framework Provider must implement. The Provider represents the endpoint host that
* makes one or more services available. Technically, the Provider is usually aligned with a Named Credential in Salesforce.
*
*/
public interface SO_ProviderInterface {
  /**
  * @description Validates an instance of the SO_Callout class
  *
  * @param callout an instance of the SO_Callout class originating from the Framework client
  * @return True when valid and False when not
  */
  Boolean isValidRequest(SO_Callout callout);
  /**
  * @description Validates an instance of the SO_Callout class
  *
  * @param callout an instance of the SO_Callout class originating from the Framework client.
  * @return The responseMap, a Map<String, Object>
  */
  Map<String, Object> makeCallout(SO_Callout callout);
}