global with sharing class ScholarshipEditorController {
  public String currentTermInProgress {get; private set;}
  public ScholarshipEditorController() {
    currentTermInProgress = getCurrentTerm();
  }

  private static String getCurrentTerm() {
    return null;
/* The return null above skips the rest of this code, so commenting it out.
 * 
 * Id schoolId = ApexPages.currentPage().getParameters().get('id');

    list<AggregateResult> termsAvailable = [
        SELECT count(Id) num, Term_Semester__c, MAX(Term_End_Date__c) endDate
        FROM Student_Term__c
        WHERE Term_Eligibility_Status__c = 'Finalist'
                                           AND isCurrentTerm__c = true
                                               AND College_or_University__c = :schoolId
                                                   GROUP BY Term_Semester__c
                                           ];

    if (termsAvailable.size() > 1) {
      Set<String> termList = new Set<String>();
      for (AggregateResult tm : termsAvailable) {
        Datetime dt = (DateTime)tm.get('endDate');
        termList.add(String.valueOf(tm.get('Term_Semester__c')) + ' ' + dt.year());
      }
      return 'ATTENTION: There are currently multiple terms available in the editor (' + String.join(new list<String>(termList), ', ') + ').';
    } else {
      Datetime dt = (DateTime)termsAvailable[0].get('endDate');
      if (termsAvailable.size() > 0) {
        system.debug(String.valueOf(termsAvailable[0].get('Term_Semester__c')));
        system.debug(dt);
      }
      return termsAvailable.size() > 0 ? String.valueOf(String.valueOf(termsAvailable[0].get('Term_Semester__c')) + ' ' + dt.year()) : null;
    }
*/
  }
  private static Map<Id,String> buildCheckMap(List<Student_Term__c> stList) {
    List<Id> stIds = new List<Id>();
    for (Student_Term__c st : stList) {
      stIds.add(st.Id);
    }
    List<Eligibility_Check__c> chkList = [SELECT Id,Check_Name__c,Result__c,Detail__c,Student_Term__c
                                         FROM Eligibility_Check__c
                                         WHERE Student_Term__c IN :stIds
                                          ORDER BY Result__c DESC,Check_Name__c ASC];
    Map<Id,String> chkMap = new Map<Id,String>();
    for (Eligibility_Check__c chk : chkList) {
        String result;
        System.debug('map entry:'+chkMap.get(chk.Student_Term__c));
        if (String.isNotEmpty(chkMap.get(chk.Student_Term__c))) {
            result = chkMap.get(chk.Student_Term__c) + chk.Result__c + ':' + chk.Check_Name__c;
        }
        else {
            result = chk.Result__c + ':' + chk.Check_Name__c;    
        }
        If (String.isNotBlank(chk.Detail__c)) {
            result = result + ' (' + chk.Detail__c + ')';
        }
        result = result + '\n';
        chkMap.put(chk.Student_Term__c, result);
    } 
    return chkMap; 
  }

  @RemoteAction
  global static list<ScholarshipWorksheet> getStudentTerms() {
    list<User> uList = [SELECT contact.accountId FROM User WHERE Id = :UserInfo.getUserId()];
    Id currentAccountId = uList.isEmpty() ? null : uList[0].contact.accountId;
    list<Student_Term__c> stList = [
                                     SELECT
                                     Application__c,
                                     //Application__r.Dev_Ed_Req_Complete__c,
                                     //Application__r.Lawful_Presence_Req_Met__c,
                                     Application__r.Student_Name__c,
                                     Application__r.Student_Name__r.Birthdate,
                                     Application__r.Student_Name__r.Cohort__r.Name,
                                     //Application__r.Student_Name__r.High_School_GPA_Eligibility_Category__c,
                                     Application__r.Federal_FA_Eligible__c,
                                     Application__r.Student_Name__r.FirstName,
                                     Application__r.Student_Name__r.LastName,
                                     Application__r.Application_Type__c,
                                     Applied_for_ASSET__c,
        						     Asset_Application_Approved__c,
                                     //Reason_for_Ineligibility__c,
                                     Final_Award_Status__c,
                                     Final_Scholarship_Payment_Amount__c,
                                     Calculated_Award_Amount__c, 
                                     Incentive_Award_Amount__c,                                  
                                     College_or_University__r.Name,
                                     Comments__c,
                                     Cumulative_GPA_Entering_Term__c,
                                     //Daniels_Scholar__c,
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
                                     Id,
                                     LastModifiedDate,
                                     Term_Year__c,
                                     //Partner_Scholarship_Recipient__c,
                                     Program_Enrolled__c,
                                     //Qual_for_Daniels_Scholarship_by_College__c,
                                     //Qualifies_for_Cook_Scholarship__c,
                                     SAP_Status__c,
                                     //SSR_Completed_Previous_Term__c,
                                     Student_ID_at_College__c
                                     //Application__r.Submitted_Part_Time_Preapproval_Form__c
                                     FROM Student_Term__c
                                     WHERE Term_Eligibility_Status__c = 'Finalist'
                                     AND College_or_University__c = :currentAccountId
                                     AND isCurrentTerm__c = true
                                     AND (Application__r.Mid_Year_Transfer_School__c = :currentAccountId OR 
                                          Application__r.Mid_Year_Transfer_School__c = null)
    								 ];

    Map<Id,String> chkMap = buildCheckMap(stList);
    list<ScholarshipWorksheet> swList = new list<ScholarshipWorksheet>();
    for (Student_Term__c st : stList) {
      ScholarshipWorksheet sw = new ScholarshipWorksheet();
      sw.applicationid = st.Application__c;
      sw.appliedforasset = st.Applied_for_ASSET__c;
      sw.ASSETapproved = st.Asset_Application_Approved__c;
      //sw.birthdate = st.Application__r.Student_Name__r.Birthdate != null ? datetime.newinstance(st.Application__r.Student_Name__r.Birthdate, time.newinstance(0, 0, 0, 0)).format('yyyy-mm-dd') : null;
      sw.birthdate = st.Application__r.Student_Name__r.Birthdate != null ? st.Application__r.Student_Name__r.Birthdate.format() : null;
      sw.cohort = st.Application__r.Student_Name__r.Cohort__r.Name;
      sw.comments = st.Comments__c;
      sw.cumulativecollegegpa = st.Cumulative_GPA_Entering_Term__c;
      //sw.danielsscholar = st.Qual_for_Daniels_Scholarship_by_College__c;
      //sw.devedreqcompletedwithin1styear = st.Application__r.Dev_Ed_Req_Complete__c;
      sw.dsfscholarshipstatus = st.DSF_Scholarship_Status__c;
      sw.awardstatus = st.Final_Award_Status__c;
      sw.checkResults = chkMap.get(st.Id);  
      //sw.eligibilityhsgpamet = st.Application__r.Student_Name__r.High_School_GPA_Eligibility_Category__c;
      //sw.eligibilitylawfulpresencedocs = st.Application__r.Lawful_Presence_Req_Met__c;
      sw.enrollmentstatus = st.Enrollment_Status__c;
      sw.enrollmenttype = st.Enrollment_Type__c;
      sw.parttimeFormApproved = st.Full_Time_Enrollment_Req_Exemption__c;
      sw.fafilecompletiondeadline = st.FA_File_Completion_Deadline__c;
      sw.federalFAeligible = st.Application__r.Federal_FA_Eligible__c;
      sw.finalefcuponfafilecompletion = st.Final_EFC_Upon_FA_File_Completion__c;
      sw.financialaidcompletedbydeadline = st.Financial_Aid_Deadline__c;
      sw.financialaiddatastatus = st.Financial_Data_Status__c;
      sw.financialaidstatus = st.Financial_Aid_Status__c;
      sw.hasstudentcompleted4yeardegree = st.Has_Student_Completed_4_Year_Degree__c;
      sw.lastmodifieddate = st.LastModifiedDate;
      sw.neworrenewal = st.Application__r.Application_Type__c;
      //sw.partnerscholarshiprecipient = st.Partner_Scholarship_Recipient__c;
      sw.programenrolled = st.Program_Enrolled__c;
      //sw.qualifiesforcookscholarship = st.Qualifies_for_Cook_Scholarship__c;
      sw.sapstatus = st.SAP_Status__c;
      sw.finalScholarshipAmount = st.Calculated_Award_Amount__c;
     // sw.scholarshippaymentamount = st.Calculated_Award_Amount__c;
      sw.incentiveAmount = st.Incentive_Award_Amount__c;
  	  sw.schoolname = st.College_or_University__r.Name;
      //sw.ssrrequirementscomplete = st.SSR_Completed_Previous_Term__c;
      sw.studentid = st.Application__r.Student_Name__c;
      sw.studentidatcollege = st.Student_ID_at_College__c;
      sw.studentname = st.Application__r.Student_Name__r.LastName + ', ' + st.Application__r.Student_Name__r.FirstName;
      sw.studenttermid = st.Id;
      sw.termAndYear = st.Term_Year__c;
      //sw.submittedptenrollpreapprovalform = st.Application__r.Submitted_Part_Time_Preapproval_Form__c;
      swList.add(sw);

    }
    return swList;
  }

  global class ScholarshipWorksheet {
    public Id studentTermId {get; set;}
    public String appliedforASSET {get; set;}
    public String ASSETapproved {get;set;}   
    public String studentIDatCollege {get; set;}
    public String newOrRenewal {get; set;}
    //public String eligibilityHSGPAMet {get; set;}
    public String comments {get; set;}
    public String financialAidDataStatus {get; set;}
    public String applicationId {get; set;}
    //public String danielsScholar {get; set;}
    public String awardstatus {get; set;}
    public String checkResults {get; set;}  
    public String dSFScholarshipStatus {get; set;}
    //public String eligibilityLawfulPresenceDocs {get; set;}
    public String enrollmentStatus {get; set;}
    public String enrollmentType {get; set;}
    public String parttimeFormApproved {get;set;}  
    public String fAFileCompletionDeadline {get; set;}
    public String federalFAeligible {get; set;}
    public Double finalEFCUponFAFileCompletion {get; set;}
    public String financialAidCompletedbyDeadline {get; set;}
    public String financialAidStatus {get; set;}
    public String hasStudentCompleted4YearDegree {get; set;}
    public String programEnrolled {get; set;}
    //public String qualifiesforCookScholarship {get; set;}
    public String sAPStatus {get; set;}
    //public String partnerScholarshipRecipient {get; set;}
    //public Double scholarshipPaymentAmount {get; set;}
    //public String sSRRequirementsComplete {get; set;}
    //public String submittedPTEnrollPreApprovalForm {get; set;}
    public String studentName {get; set;}
    public String schoolName {get; set;}
    public Double incentiveAmount {get; set;}
    public Double finalScholarshipAmount{get; set;}
    public Id studentId {get; set;}
    public String cohort {get; set;}
    public String termAndYear {get; set;}
    public String birthdate {get; set;}
    public Double cumulativeCollegeGPA {get; set;}
    //public String devEdReqcompletedwithin1stYear {get; set;}
    public DateTime lastModifiedDate {get; set;}
  }

  @RemoteAction
  global static map<String, list<Schema.PicklistEntry>> getSelectOptions() {
    map<String, list<Schema.PicklistEntry>> optionsMap = new map<String, list<Schema.PicklistEntry>>();
    optionsMap.put('Application_Type__c', Application__c.Application_Type__c.getDescribe().getPicklistValues());
    optionsMap.put('Applied_for_ASSET__c', Student_Term__c.Applied_for_ASSET__c.getDescribe().getPicklistValues());
    optionsMap.put('Asset_Application_Approved__c', Student_Term__c.Asset_Application_Approved__c.getDescribe().getPicklistValues()); 
    //optionsMap.put('Daniels_Scholar__c', Student_Term__c.Daniels_Scholar__c.getDescribe().getPicklistValues());
    //optionsMap.put('Dev_Ed_Req_Complete__c', Application__c.Dev_Ed_Req_Complete__c.getDescribe().getPicklistValues());
    optionsMap.put('Federal_FA_Eligible__c', Application__c.Federal_FA_Eligible__c.getDescribe().getPicklistValues());
    //optionsMap.put('Dev_Ed_Req_Completed_within_1st_Year__c', Contact.Dev_Ed_Req_Completed_within_1st_Year__c.getDescribe().getPicklistValues());
    optionsMap.put('DSF_Scholarship_Status__c', Student_Term__c.DSF_Scholarship_Status__c.getDescribe().getPicklistValues());
    optionsMap.put('Enrollment_Status__c', Student_Term__c.Enrollment_Status__c.getDescribe().getPicklistValues());
    optionsMap.put('Enrollment_Type__c', Student_Term__c.Enrollment_Type__c.getDescribe().getPicklistValues());
    optionsMap.put('Full_Time_Enrollment_Req_Exemption__c', Student_Term__c.Full_Time_Enrollment_Req_Exemption__c.getDescribe().getPicklistValues());  
    optionsMap.put('FA_File_Completion_Deadline__c', Student_Term__c.FA_File_Completion_Deadline__c.getDescribe().getPicklistValues());
    optionsMap.put('Final_EFC_Upon_FA_File_Completion__c', Student_Term__c.Final_EFC_Upon_FA_File_Completion__c.getDescribe().getPicklistValues());
    optionsMap.put('Financial_Aid_Deadline__c', Student_Term__c.Financial_Aid_Deadline__c.getDescribe().getPicklistValues());
    optionsMap.put('Financial_Aid_Status__c', Student_Term__c.Financial_Aid_Status__c.getDescribe().getPicklistValues());
    optionsMap.put('Has_Student_Completed_4_Year_Degree__c', Student_Term__c.Has_Student_Completed_4_Year_Degree__c.getDescribe().getPicklistValues());
    //optionsMap.put('High_School_GPA_Eligibility_Category__c', Contact.High_School_GPA_Eligibility_Category__c.getDescribe().getPicklistValues());
    //optionsMap.put('Lawful_Presence_Req_Met__c', Application__c.Lawful_Presence_Req_Met__c.getDescribe().getPicklistValues());
    optionsMap.put('Partner_Scholarship_Recipient__c', Student_Term__c.Partner_Scholarship_Recipient__c.getDescribe().getPicklistValues());
    optionsMap.put('Program_Enrolled__c', Student_Term__c.Program_Enrolled__c.getDescribe().getPicklistValues());
    //optionsMap.put('Qual_for_Daniels_Scholarship_by_College__c', Student_Term__c.Qual_for_Daniels_Scholarship_by_College__c.getDescribe().getPicklistValues());
    //optionsMap.put('Qualifies_for_Cook_Scholarship__c', Student_Term__c.Qualifies_for_Cook_Scholarship__c.getDescribe().getPicklistValues());
    optionsMap.put('SAP_Status__c', Student_Term__c.SAP_Status__c.getDescribe().getPicklistValues());
    //optionsMap.put('SSR_Completed_Previous_Term__c', Student_Term__c.SSR_Completed_Previous_Term__c.getDescribe().getPicklistValues());
    //optionsMap.put('Submitted_Part_Time_Preapproval_Form__c', Application__c.Submitted_Part_Time_Preapproval_Form__c.getDescribe().getPicklistValues());
    return optionsMap;
  }

  @RemoteAction
  global static ScholarshipWorksheet updateStudentTerm(ScholarshipWorksheet sw) {
    if (sw.studentTermId != null) {
      Student_Term__c st = new Student_Term__c();
      st.Applied_for_ASSET__c = sw.appliedforasset;
      st.Asset_Application_Approved__c = sw.ASSETapproved;
      st.Comments__c = sw.comments;
      st.Enrollment_Status__c = sw.enrollmentstatus;
      st.Enrollment_Type__c = sw.enrollmenttype;
      st.Full_Time_Enrollment_Req_Exemption__c = sw.parttimeFormApproved;  
      st.FA_File_Completion_Deadline__c = sw.fafilecompletiondeadline;
      st.Final_EFC_Upon_FA_File_Completion__c = sw.finalefcuponfafilecompletion;
      st.Financial_Aid_Deadline__c = sw.financialaidcompletedbydeadline;
      st.Financial_Aid_Status__c = sw.financialaidstatus;
      st.Has_Student_Completed_4_Year_Degree__c = sw.hasstudentcompleted4yeardegree;
      st.Id = sw.studenttermid;
      st.Program_Enrolled__c = sw.programenrolled;
      //st.Qual_for_Daniels_Scholarship_by_College__c = sw.danielsscholar;
      st.SAP_Status__c = sw.sapstatus;
      st.Student_ID_at_College__c = sw.studentidatcollege;
      st.Cumulative_GPA_Entering_Term__c = sw.cumulativeCollegeGPA;
      update st;
    }

    Student_Term__c updatedST = [SELECT Id,Final_Scholarship_Payment_Amount__c,Final_Award_Status__c,
                                 Calculated_Award_Amount__c,Incentive_Award_Amount__c 
                                 FROM Student_Term__c WHERE Id = :sw.studentTermId];
    sw.finalScholarshipAmount = updatedST.Calculated_Award_Amount__c;
    //sw.scholarshipPaymentAmount = updatedST.Calculated_Award_Amount__c;
    sw.incentiveAmount = updatedST.Incentive_Award_Amount__c;
    sw.awardstatus = updatedST.Final_Award_Status__c;
    Map<Id,String> chkR = buildCheckMap(new List<Student_Term__c>{updatedST});
    sw.checkResults = chkR.get(sw.studentTermId);
    return sw;
  }

 @RemoteAction
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
    
/*    
  @RemoteAction
  global static void massUpdate(list<Id> idList, string editField, string editValue) {
    if (!idList.isEmpty()) {
        list<Student_Term__c> stList = new list<Student_Term__c>();
        Student_Term__c st = new Student_Term__c();

        if (editField == 'Program') {
            for (Id studID : idList){
              st.Id = studId;
              st.Program_Enrolled__c = editValue;
              stList.add(st);
            }
            update stList;
        } else if (editField == 'Appl. ASSET') {
            for (Id studID : idList){
              st.Id = studId;
              st.Applied_for_ASSET__c = editValue;
              stList.add(st);
            }
            update stList;
        } else if (editField == '4 Year Degree') {
            for (Id studID : idList){
              st.Id = studId;
              st.Has_Student_Completed_4_Year_Degree__c = editValue;
              stList.add(st);
            }
            update stList;
        }
      
    }
  }
*/    
    
  @RemoteAction
  global static Boolean isEGTC() {
    system.debug('Name of current school for user: ' + UserInfo.getOrganizationName());
    User currentUser = [SELECT contact.account.name FROM User WHERE ID = : UserInfo.getUserId()];
    return currentUser.contact.account.name == 'Emily Griffith Technical College';

  }
}