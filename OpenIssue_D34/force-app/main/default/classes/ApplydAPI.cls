public class ApplydAPI {

  public static ApplydModel.UsersResponse getUsers(Long startTime) {
    String endpoint = '/users';
    if (startTime != null) {
      endpoint += ('?time=' + startTime);
    }

    ApplydClient client = new ApplydClient('GET', endpoint);
    String result = client.performRequest();
    return (ApplydModel.UsersResponse)JSON.deserialize(result, ApplydModel.UsersResponse.class);
  }

  public static ApplydModel.ApplicationsResponse getApplications(Long startTime) {
    String endpoint = '/applications';
    if (startTime != null) {
      endpoint += ('?time=' + startTime);
    }

    ApplydClient client = new ApplydClient('GET', endpoint);
    String result = client.performRequest();
    return (ApplydModel.ApplicationsResponse)JSON.deserialize(result, ApplydModel.ApplicationsResponse.class);
  }

  public static ApplydModel.ApplicationsResponse getProfileUpdates(Long startTime) {
    String endpoint = '/profile_updates';
    if (startTime != null) {
      endpoint += ('?time=' + startTime);
    }

    ApplydClient client = new ApplydClient('GET', endpoint);
    String result = client.performRequest();
    return (ApplydModel.ApplicationsResponse)JSON.deserialize(result, ApplydModel.ApplicationsResponse.class);
  }
}