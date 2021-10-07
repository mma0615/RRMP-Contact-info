/**
* @author Dana Wolfe
* @date 2021/02/15
*
* @group ShoutOut
*
* @description Wraps Framework configuration store in custom settings or custom metadata types.
* Direct queries against these objects should only occur in this class with all other code relying
* on the properties or methods of this class.
*/
public inherited sharing class SO_Config {

  /**
  * @description Boolean to indicate of if execution environment is a sandbox
  *
  */
  private static Boolean inSandbox;
  public static Boolean runningInSandbox {
    get {
      if (inSandbox == null) {
        inSandbox = [SELECT isSandbox FROM Organization LIMIT 1].isSandbox;
      }
      return inSandbox;
    }
  }
  /**
  * @description
  * The List of ShoutOut Service Settings
  *
  */
  @testvisible
  private static List<ShoutOut_Service_Setting__mdt> SO_ServiceList_mock = new List<ShoutOut_Service_Setting__mdt>(); //NOPMD
  private static List<ShoutOut_Service_Setting__mdt> SO_ServiceList_cached; //NOPMD
  public  static List<ShoutOut_Service_Setting__mdt> SO_ServiceList { //NOPMD
    get
    {
      return getServiceList();
    }
  }

  /**
  * @description Given the Framework Service Name return the name of the Provider class name
  *
  * @param frameworkServiceName The Framework Service Name as configured in ShoutOut_Service_Setting__mdt
  * @return Provider class name
  */
  public static String getNamedCredentialName(String frameworkServiceName) {
    String credName;
    // input check
    if (String.isBlank(frameworkServiceName)) { return credName; }
    // Let's look for the Framework Callout Name
    for (ShoutOut_Service_Setting__mdt setting : SO_ServiceList) {
      if (frameworkServiceName.equalsIgnoreCase(setting.Framework_Callout_Name__c)) {
        credName = setting.Named_Credential__c;
        break;
      }
    }
    return credName;
  }

  /**
  * @description Given the Framework Service Name return the name of the Provider class name
  *
  * @param frameworkServiceName The Framework Service Name as configured in ShoutOut_Service_Setting__mdt
  * @return Provider class name
  */
  public static String getProviderClassName(String frameworkServiceName) {
    String className;
    // input check
    if (String.isBlank(frameworkServiceName)) { return className; }
    // Let's look for the Framework Callout Name
    for (ShoutOut_Service_Setting__mdt setting : SO_ServiceList) {
      if (frameworkServiceName.equalsIgnoreCase(setting.Framework_Callout_Name__c)) {
        className = setting.Provider_Class__c;
        break;
      }
    }
    return className;
  }

  /**
  * @description Given the Framework Service Name return the name of the Service Adapter class name
  *
  * @param frameworkServiceName The Framework Service Name as configured in ShoutOut_Service_Setting__mdt
  * @return Service Adapter class name
  */
  public static String getServiceAdapterClassName(String frameworkServiceName) {
    String className;
    // input check
    if (String.isBlank(frameworkServiceName)) { return className; }
    // Let's look for the Framework Callout Name
    for (ShoutOut_Service_Setting__mdt setting : SO_ServiceList) {
      if (frameworkServiceName.equalsIgnoreCase(setting.Framework_Callout_Name__c)) {
        className = setting.Service_Class__c;
        break;
      }
    }
    return className;
  }

  /**
  * @description Given the Framework Service Name return the name of the Error Handler class name
  *
  * @param frameworkServiceName The Framework Service Name as configured in ShoutOut_Service_Setting__mdt
  * @return Error Handler class name
  */
  public static String getErrorHandlerClassName(String frameworkServiceName) {
    String className = 'SO_ErrorLogger';   // The Framework Provided class that performs minimal logging
    // input check
    if (String.isBlank(frameworkServiceName)) { return className; }
    // Let's look for the Framework Callout Name
    for (ShoutOut_Service_Setting__mdt setting : SO_ServiceList) {
      if (frameworkServiceName.equalsIgnoreCase(setting.Error_Handler_Class__c)) {
        className = setting.Service_Class__c;
        break;
      }
    }
    return className;
  }

  /**
  * @description Given the Framework Service Name return the name of the REST verb
  *
  * @param frameworkServiceName The Framework Service Name as configured in ShoutOut_Service_Setting__mdt
  * @return REST Verb
  */
  public static String getRestVerb(String frameworkServiceName) {
    String stringToReturn;
    // input check
    if (String.isBlank(frameworkServiceName)) { return stringToReturn; }
    // Let's look for the Framework Callout Name
    for (ShoutOut_Service_Setting__mdt setting : SO_ServiceList) {
      if (frameworkServiceName.equalsIgnoreCase(setting.Framework_Callout_Name__c)) {
        stringToReturn = setting.REST_Verb__c;
        break;
      }
    }
    return stringToReturn;
  }

  /**
  * @description Given the Framework Service Name return the name of the REST path
  *
  * @param frameworkServiceName The Framework Service Name as configured in ShoutOut_Service_Setting__mdt
  * @return REST Path
  */
  public static String getRestPath(String frameworkServiceName) {
    String stringToReturn;
    // input check
    if (String.isBlank(frameworkServiceName)) { return stringToReturn; }
    // Let's look for the Framework Callout Name
    for (ShoutOut_Service_Setting__mdt setting : SO_ServiceList) {
      if (frameworkServiceName.equalsIgnoreCase(setting.Framework_Callout_Name__c)) {
        stringToReturn = setting.REST_Path__c;
        break;
      }
    }
    return stringToReturn;
  }


  /**
  * @description Given the Framework Service Name return the name of the REST query
  *
  * @param frameworkServiceName The Framework Service Name as configured in ShoutOut_Service_Setting__mdt
  * @return REST query
  */
  public static String getRestQuery(String frameworkServiceName) {
    String stringToReturn;
    // input check
    if (String.isBlank(frameworkServiceName)) { return stringToReturn; }
    // Let's look for the Framework Callout Name
    for (ShoutOut_Service_Setting__mdt setting : SO_ServiceList) {
      if (frameworkServiceName.equalsIgnoreCase(setting.Framework_Callout_Name__c)) {
        stringToReturn = setting.REST_query__c;
        break;
      }
    }
    return stringToReturn;
  }

  private static List<ShoutOut_Service_Setting__mdt> getServiceList(){
    // Is is cached? If so then return it
    if (SO_ServiceList_cached != null) { return SO_ServiceList_cached; }
    // Are we running in test mode?
    if (Test.isRunningTest()) {
      // Yes, return the mock list that should have been populated by the unit test code
      SO_ServiceList_cached = SO_ServiceList_mock;
    } else {
      // No, get the real stuff
      SO_ServiceList_cached = [
        SELECT  Id,
                Framework_Callout_Name__c,
                Named_Credential__c,
                DeveloperName,
                REST_Path__c,
                REST_query__c,
                REST_Verb__c,
                Provider_Class__c,
                Service_Class__c,
                Error_Handler_Class__c
          FROM  ShoutOut_Service_Setting__mdt
         WHERE  isActive__c = true
      ];
    }
    return SO_ServiceList_cached;
  }


}