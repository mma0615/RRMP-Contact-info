public class ApplydClient {
  private static final String BASE_API_URL = Applyd_API_Settings__c.getOrgDefaults().Base_API_URL__c;
  private static final String API_KEY = Applyd_API_Settings__c.getOrgDefaults().API_Key__c;

  public String requestMethod;
  public String endpoint;
  public String body;

  public ApplydClient(String requestMethod, String endpoint) {
    this.requestMethod = requestMethod;
    this.endpoint = endpoint;
  }

  public ApplydClient(String requestMethod, String endpoint, String body) {
    this.requestMethod = requestMethod;
    this.endpoint = endpoint;
    this.body = body;
  }

  public String performRequest() {
    if (this.requestMethod == null || this.endpoint == null) {
      throw new ApplydClientException('Request method and endpoint must be supplied in the constructor.');
    }

    HttpRequest req = new HttpRequest();
    req.setEndpoint(ApplydClient.BASE_API_URL + this.endpoint);
    req.setMethod(this.requestMethod);
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('api-key', ApplydClient.API_KEY);

    if (String.isNotBlank(this.body)) {
      req.setBody(this.body);
    }

    Http http = new Http();
    HttpResponse res = http.send(req);
    return res.getBody();
  }

  public class ApplydClientException extends Exception {}
}