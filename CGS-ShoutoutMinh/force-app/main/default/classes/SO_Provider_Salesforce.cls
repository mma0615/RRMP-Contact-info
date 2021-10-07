public inherited sharing class SO_Provider_Salesforce extends SO_Provider_Base {

  /**
  * @description
  * Calls the getServiceResponse() method of the SO service adapter class.
  *
  * @param callout an instance of the SO_Callout class
  * @return the web service response map in the format Map<String, Object>
  */
  public override Map<String, Object> makeCallout(SO_Callout callout) {
    // Before handing off to the service adapter class add the org-specific named credential
    callout.addToRequestMap(
      SO_Constants.NAMEDCREDENTIAL,
      getOrgNamedCredential(SO_Config.getNamedCredentialName((String)callout.serviceRequestMap.get(SO_Constants.CALLOUTOPERATION))));

    if (isValidRequest(callout)) {
      // Get the Service Adapter class name configured for this Framework service name
      String serviceAdapterClassName = SO_Config.getServiceAdapterClassName((String)callout.serviceRequestMap.get(SO_Constants.CALLOUTOPERATION));
      // Is a Service Adapter class name configured for this Framework service name?
      if (String.isNotEmpty(serviceAdapterClassName)) {
        // Yes,
        SO_ServiceAdapterInterface webServiceClass = (SO_ServiceAdapterInterface) Type.forName(serviceAdapterClassName).newInstance();
          callout.addToResponseMap((Map<String,Object>) webServiceClass.getServiceResponse(callout.serviceRequestMap));
      } else {
          system.debug('*** SO ERROR *** : No callout class found for Framework operation ' + callout.serviceRequestMap.get(SO_Constants.CALLOUTOPERATION));
      }
    }
    return callout.serviceResponseMap;
  }
}