public class PostTermEditorIFrameController {
  public static Boolean pageAccess {get; private set;}
  public PostTermEditorIFrameController() {
    Integer editorId = 5; //ID of Editor
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
        AND Editor_Id__c = :editorId
        ORDER BY Default_Setting__c ASC
        LIMIT 1
      ];
    pageAccess = settingsCt.size() > 0;
  }

}