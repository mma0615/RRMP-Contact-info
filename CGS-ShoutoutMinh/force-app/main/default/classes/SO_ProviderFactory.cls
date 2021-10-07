public inherited sharing class SO_ProviderFactory {

  public static SO_ProviderInterface getInstance(Map<String,Object> requestMap) {
      SO_ProviderInterface factoryInstance = null;
      // Based on the value of the CALLOUTOPERATION key in requestMap determine the name of the factory class
      String factoryClassName = SO_Config.getProviderClassName((String)requestMap.get(SO_Constants.CALLOUTOPERATION));
      // Did we determine a class?
      if (String.isNotBlank(factoryClassName)) {
          // Yes, create an instance of that class
          Type factoryType = Type.forName(factoryClassName);
          factoryInstance = (SO_ProviderInterface)factoryType.newInstance();
      } else {
          //No, throw custom exception
          throw new SO_ProviderFactoryException('Unable to determine SO_Provider class from request map: ' + requestMap.get(SO_Constants.CALLOUTOPERATION));
      }
      return factoryInstance;
  }

  public class SO_ProviderFactoryException extends Exception {}
}