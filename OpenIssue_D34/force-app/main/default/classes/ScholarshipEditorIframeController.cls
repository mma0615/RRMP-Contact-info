public with sharing class ScholarshipEditorIframeController {
  public static Boolean pageAccess {get; private set;}
  public ID collegeAccountId {get; private set;}
  public ScholarshipEditorIframeController() {
    Integer editorId = 1; //ID of Editor
    list<Contact> uList = [
                             SELECT
                             account.scholarship_payment_frequency__c,
                             accountId
                             FROM Contact
                             WHERE Id IN (SELECT contactId FROM User WHERE Id = :UserInfo.getUserId())
                           ];
    Integer schoolPaymentFreq = !uList.isEmpty() && uList[0].account.scholarship_payment_frequency__c != null ? Integer.valueOf(uList[0].account.scholarship_payment_frequency__c) : null;
    Id schoolId = !uList.isEmpty() && uList[0].accountId != null ? uList[0].accountId : null;
    list<DSF_Editor_Access_Settings__c> settingsCt =
      [
        SELECT
        Id
        FROM DSF_Editor_Access_Settings__c
        WHERE Editor_Access_Start_Date__c <= :Datetime.now()
        AND Editor_Access_End_Date__c >= :Datetime.now()
        AND Scholarship_Payment_Frequency__c = :schoolPaymentFreq
        AND Editor_Id__c = :editorId
        AND (College_University_Override_SF_ID__c = :schoolId OR College_University_Override_SF_ID__c = null)
        ORDER BY Default_Setting__c ASC
        LIMIT 1
      ];
    collegeAccountId = schoolId;
    pageAccess = settingsCt.size() > 0;
  }
}