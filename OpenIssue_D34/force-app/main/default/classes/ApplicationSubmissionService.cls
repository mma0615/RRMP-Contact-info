/* Temporarily set class to global, method to webservice for testing, restore afterwards */
/* public with sharing class ApplicationSubmissionService { */
global with sharing class ApplicationSubmissionService {
  public class ApplicationSubmissionServiceException extends Exception {}

    // Methods used to standardize the key values that will be matched against.
    private static string keyIdDoB(String id, String doB) {
        // Match the date parse used for the Contact object, then turn back to a string
        String doBParsed = String.valueOf(Date.parse(doB));
        return id + ':' + doBParsed;
    }
    
    private static string keyIdDoB(String id, Date doB) {
        return id + ':' + String.valueOf(doB);
    }
    
   
  @future(callout = true)
  @AuraEnabled
 /* public static void fetchApplydApplications() { */
  webservice static void fetchApplydApplications() { 
    Applyd_API_Settings__c applydSettings = Applyd_API_Settings__c.getOrgDefaults();
    Long lastCheckedTime = (applydSettings.Application_Last_Checked_Time__c != null ? applydSettings.Application_Last_Checked_Time__c.getTime() / 1000 : null);
    if (lastCheckedTime == null){
      throw new ApplicationSubmissionServiceException('Application_Last_Checked_Time not set');
    }
    ApplydModel.ApplicationsResponse res = ApplydAPI.getApplications(lastCheckedTime);
    if (res.status != 'success' || res.data == null) {
      throw new ApplicationSubmissionServiceException('Error fetching applications from Applyd');
    }

    ApplydModel.ApplicationsResponse profileRes = ApplydAPI.getProfileUpdates(lastCheckedTime);
    if (profileRes.status != 'success' || res.data == null) {
      throw new ApplicationSubmissionServiceException('Error fetching profile updates from Applyd');
    }
    profileRes = ApplydModel.addTypeToData(profileRes, 'profile_update');

    // Merge both result sets
    res.data.addAll(profileRes.data);

    Datetime mostRecentUpdateTime = Datetime.now();
    System.debug('Setting most recent update time to now: ' + mostRecentUpdateTime);
    if (!res.data.isEmpty()) {
      List<Application_Submission__c> appSubmissionsToUpsert = new List<Application_Submission__c>();
      List<String> dpsIds = new List<String>();
      List<String> applydUserIds = new List<String>();
      List<String> applydAppIds = new List<String>();
      List<Date> birthdates = new List<Date>();
        
      res.data.sort();

      System.debug('All data: ' + res.data);
      System.debug('First Item: ' + res.data[0]);
      System.debug('Last Item: ' + res.data[res.data.size() - 1]);

      Integer maxSize = res.data.size();
      for (Integer i = 0; i < maxSize; i++) {
        Application_Submission__c app = ApplydModel.convertApplicationToApplicationSubmissionSObject(res.data[i]);
        if (app.Student_DPS_Id__c != null) { dpsIds.add(app.Student_DPS_Id__c); }
        if (app.User_Id__c != null) { applydUserIds.add(app.User_Id__c); }
        if (app.Application_Id__c != null) { applydAppIds.add(app.Application_Id__c); }
        if (app.Student_DoB__c != null) { birthdates.add(Date.parse(app.Student_DoB__c)); }
        appSubmissionsToUpsert.add(app);
      }
      mostRecentUpdateTime = appSubmissionsToUpsert.get(appSubmissionsToUpsert.size() - 1).Updated_At__c;
      System.debug('Setting most recent update time to last app submission: ' + mostRecentUpdateTime);

      List<Contact> contacts = [SELECT Id, DPSID__c, ApplydID__c, Birthdate FROM Contact WHERE DPSID__c IN :dpsIds OR 
                                ApplydID__c IN :applydUserIds OR Birthdate IN :birthdates];

      // Build contact maps to check by DPS Id and Applyd User Id
      Map<String, Contact> dpsIdandDoBToContactMap = new Map<String, Contact>();
      Map<String, Contact> applydUserIdToContactMap = new Map<String, Contact>();
      for (Contact c : contacts) {
        if (c.DPSID__c != null) { dpsIdandDoBToContactMap.put(keyIdDob(c.DPSID__c,c.Birthdate), c); }
        if (c.ApplydID__c != null) { applydUserIdToContactMap.put(c.ApplydID__c, c); }
      }

      Map<String, Application_Submission__c> appSubmissionMap = new Map<String, Application_Submission__c>();
      for (Application_Submission__c appSub : [SELECT Id, Application_Id__c, Application__c, Approval_Status__c FROM Application_Submission__c WHERE Application_Id__c IN :applydAppIds]) {
        appSubmissionMap.put(appSub.Application_Id__c, appSub);
      }

      // Try to match application to a contact
      // If application is new, then check by the Applyd User ID, and
      //   if no match to Applyd User ID, check DPS ID + Birthdate
      // If Application is not new, check just the Applyd User ID
      for (Application_Submission__c appSubmission : appSubmissionsToUpsert) {
        Contact matchingContact = null;
        if (appSubmission.Application_Type__c == 'new_app') {
          matchingContact = applydUserIdToContactMap.get(appSubmission.User_Id__c);
          if (matchingContact == null) matchingContact = dpsIdandDoBToContactMap.get(
                     keyIdDoB(appSubmission.Student_DPS_Id__c,appSubmission.Student_DoB__c));
        } else {
          matchingContact = applydUserIdToContactMap.get(appSubmission.User_Id__c);
        }

        if (matchingContact != null) {
          appSubmission.Contact__c = matchingContact.Id;
        }

        Application_Submission__c matchingAppSubmission = appSubmissionMap.get(appSubmission.Application_Id__c);
        if (matchingAppSubmission != null) {
          appSubmission.Id = matchingAppSubmission.Id;
          //if (matchingAppSubmission.Approval_Status__c != 'Pending') {
          //  appSubmission.Approval_Status__c = 'Has Updates';
          //}
        }
      }

      upsert appSubmissionsToUpsert;
    }

    if (mostRecentUpdateTime != null) {
      applydSettings.Application_Last_Checked_Time__c = mostRecentUpdateTime;
      update applydSettings;
    }
  }

    
  public static void handleSubmissionApproval(List<Application_Submission__c> submissions, Map<Id, Application_Submission__c> oldMap) {
    List<Application_Submission__c> approvedSubmissions = new List<Application_Submission__c>();
    if (oldMap == null) {
      for (Application_Submission__c submission : submissions) {
        if (submission.Approval_Status__c == 'Approved') {
          approvedSubmissions.add(submission);
        }
      }
    } else {
      for (Application_Submission__c submission : submissions) {
        Application_Submission__c oldSubmission = oldMap.get(submission.Id);
        if (submission.Approval_Status__c == 'Approved' && (submission.Approval_Status__c != oldSubmission.Approval_Status__c)) {
          approvedSubmissions.add(submission);
        }
      }
    }

    System.debug(approvedSubmissions);
    if (!approvedSubmissions.isEmpty()) {
      ApprovedSubmissionMapper mapper = new ApprovedSubmissionMapper(approvedSubmissions);
      mapper.run();
    }
  }
}