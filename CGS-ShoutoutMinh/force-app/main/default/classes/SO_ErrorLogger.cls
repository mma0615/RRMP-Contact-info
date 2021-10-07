public inherited sharing class SO_ErrorLogger implements Callable {

  public static Object call(String action, Map<String, Object> args) {
    switch on action {
      when 'logFrameworkError' {
        return logError(args);
      }
      when else {
       throw new ExtensionMalformedCallException('Method not implemented');
      }
    }
  }

  public static Object logError(Map<String, Object> error){
    System.debug(JSON.serializePretty(error));
    return null;
  }

  public class ExtensionMalformedCallException extends Exception {}
}