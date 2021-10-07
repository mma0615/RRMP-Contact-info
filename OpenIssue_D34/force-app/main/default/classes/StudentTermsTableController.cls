global with sharing class StudentTermsTableController {
    
    @AuraEnabled 
    public static Id fetchUser(){
        list<User> uList = [SELECT contact.accountId FROM User WHERE Id = :UserInfo.getUserId()];
        Id currentAccountId = uList.isEmpty() ? null : uList[0].contact.accountId;
        return currentAccountId; 
    }

    @AuraEnabled 
    public static Boolean fetchDate(Boolean pageAccess, ID collegeAccountId ) {
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
      return pageAccess = settingsCt.size() > 0;
    }

    @AuraEnabled        
    public static Map<String,String> getPicklistValues(String objectAPIName, String fieldAPIName){
        Map<String,String> pickListValuesMap = new Map<String,String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectAPIName);
        Schema.DescribeSObjectResult descResult = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = descResult.fields.getMap().get(fieldAPIName).getDescribe();
        Boolean isFieldNotRequired = fieldResult.isNillable();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            if(isFieldNotRequired)
                pickListValuesMap.put('--None--', '');
            if(pickListVal.isActive())
                pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
        }
        return pickListValuesMap;
    }

    @AuraEnabled
    public static List<Student_Term__c> getRecords() {
        list<User> uList = [SELECT contact.accountId FROM User WHERE Id = :UserInfo.getUserId()];
        Id currentAccountId = uList.isEmpty() ? null : uList[0].contact.accountId;
        
        List<Student_Term__c> accs = [
            SELECT
            Id,
            Application__c,
            Application__r.Student_Name__c,
            Application__r.Student_Name__r.Id,
            Application__r.Student_Name__r.Birthdate,
            Application__r.Student_Name__r.Cohort__r.Name,
            Application__r.Federal_FA_Eligible__c,
            Application__r.Student_Name__r.FirstName,
            Application__r.Student_Name__r.LastName,
            Application__r.Application_Type__c,
            Applied_for_ASSET__c,
            Asset_Application_Approved__c,
            Final_Award_Status__c,
            Final_Scholarship_Payment_Amount__c,
            Calculated_Award_Amount__c, 
            Incentive_Award_Amount__c,                                  
            College_or_University__r.Name,
            Comments__c,
            Cumulative_GPA_Entering_Term__c,
            DSF_Scholarship_Status__c,
            Enrollment_Status__c,
            Enrollment_Type__c,
            Full_Time_Enrollment_Req_Exemption__c,
            FA_File_Completion_Deadline__c,
            Final_EFC_Upon_FA_File_Completion__c,
            Financial_Aid_Deadline__c,
            Financial_Aid_Status__c,
            Financial_Data_Status__c,
            Has_Student_Completed_4_Year_Degree__c,            
            LastModifiedDate,
            Term_Year__c,
            Program_Enrolled__c,
            SAP_Status__c,
            Student_ID_at_College__c,
            Test_Field__c,
            x_eligibility__c,
            (SELECT Id,
            Check_Name__c,
            Result__c,
            Detail__c,
            Student_Term__c
            FROM Eligibility_Checks__r) 
            
            FROM Student_Term__c 
          
            WHERE Term_Eligibility_Status__c = 'Finalist'
            AND College_or_University__c = :currentAccountId
            AND isCurrentTerm__c = true
            AND (Application__r.Mid_Year_Transfer_School__c = :currentAccountId OR 
                 Application__r.Mid_Year_Transfer_School__c = null)
            AND  Application__r.Student_Name__r.Cohort__c != NULL
            and Application__c != NULL

            ];

            for (Student_Term__c st : accs) {
                string sST_Elig = '';
                for (Eligibility_Check__c ec : st.Eligibility_Checks__r) {
                    sST_Elig += ec.Check_Name__c+':' +ec.Result__c+'\n';
                }
                st.x_eligibility__c = sST_Elig;
            }
            return accs;
    } 
    
    private class myErrorMsg{
        ID StudentTermId;
        list<String> Fields;
        String StatusCode;
        String Message;
    }
    @AuraEnabled
    public static  String updateRecordsv2(String jsonString){
        list<string> lRetErrors = new list<string>();
        list<myErrorMsg> lErrorMsgs = new list<myErrorMsg>();
        string sRetString;
        try{
            List<Student_Term__c> records = (List<Student_Term__c>) JSON.deserialize(jsonString, List<Student_Term__c>.class);
            //        update records;
            // use database.update with all or nothing false to enable partial saves.
            Database.SaveResult[] srList = Database.update(records, false );


            // for (Database.SaveResult sr : srList) {  // need to iterate over record list to update since errors return null for Sr.Id
            for (Integer i = 0; i < records.size(); i++) {
                Database.SaveResult sr = srList[i];
                Student_Term__c OrigST =  records[i];
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Updated StudentTerm Record.  ID: ' + sr.getId());
                } else {
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Student termm fields that affected this error: ' + err.getFields());

                        lRetErrors.add('Student_Term ID:'+OrigST.Id +' | Field:'+err.getFields() + ' | Message: '+ err.getStatusCode() + ': ' + err.getMessage());
                        myErrorMsg mem = new myErrorMsg();
                        mem.StudentTermId=OrigST.Id;
                       // mem.StudentName=OrigST.Student_Name__c;
                         mem.fields=err.getFields();
                        mem.Message=err.getMessage();
                        lErrorMsgs.add(mem);
                    }
                }


            }

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        system.debug('lErrorMsgs:' + lErrorMsgs);
        sRetString =  JSON.serialize(lErrorMsgs);
        system.debug('sRetString:' + sRetString);

        return sRetString;
    }
 
    @AuraEnabled 
    global static void notifyUpdatesDone(){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<User> uList = [SELECT contact.firstName, contact.lastName, contact.Account.Name FROM User WHERE Id = :UserInfo.getUserId()];
        if (!uList.isEmpty()) {
            email.setSubject('Student Term Updates Done for ' + uList[0].contact.Account.Name + ' by ' +
                            uList[0].contact.firstName + ' ' + uList[0].contact.lastName);  
            email.setPlainTextBody(uList[0].contact.firstName + ' ' + uList[0].contact.lastName + 
                ' from ' + uList[0].contact.Account.Name + ' has submitted data for Financial Aid.');  
            List<String> sendTo = new List<String>();
            sendTo.add('support@denverscholarship.org');    
            email.setToAddresses(sendTo);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
        }
    }
}