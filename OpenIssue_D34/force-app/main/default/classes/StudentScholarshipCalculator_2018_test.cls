@isTest
public class StudentScholarshipCalculator_2018_test {

// UPDATE THIS VALUE TO CURRENT COHORT
   static final Integer CURRENT_COHORT = 2018;
   static Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
   static Id egtcRT = Schema.SObjectType.Cohort_Calculation_Rule__c.getRecordTypeInfosByName().get('EGTC').getRecordTypeId();
   static Id psiRT = Schema.SObjectType.Cohort_Calculation_Rule__c.getRecordTypeInfosByName().get('PSI').getRecordTypeId();
   
   // Create cohort__c entries for current, -1 and -2. Need cohort -1 entry for calc rules.
   // 
   
    private static List<cohort__c> createTestCohorts() {
      List<cohort__c> cohs = new List<cohort__c>();
        for(Integer i=0;i<3;i++){
          Cohort__c c = new Cohort__c();
          c.Name = String.valueOf(CURRENT_COHORT - i);
          cohs.add(c);  
        }  
      insert cohs;
      return cohs;
    } 
    
    private static List<Cohort_Calculation_Rule__c> createTestCohortRules(List<Cohort__c> cohs) {
      List<Cohort_Calculation_Rule__c> ccrs = new List<Cohort_Calculation_Rule__c>();
	// need two entries. standard - cohort=current-1,4 Year college, EFC Min 0, EFC Max 6000, amount 2200  
        for(Cohort__c c : cohs){
            Cohort_Calculation_Rule__c ccr1 = new Cohort_Calculation_Rule__c();
            ccr1.Cohort__c = c.Id;
            ccr1.Year__c = String.valueOf(CURRENT_COHORT);
            ccr1.College_University_Type__c = '4 Year College';
            ccr1.EFC_Max__c = 99999;
            ccr1.EFC_Min__c = 0;
            ccr1.RecordTypeId = psiRT;
            ccr1.Type__c = 'EFC';
            ccr1.Scholarship_Amount__c = 2200;
            ccr1.X15_Credit_Incentive__c = false;
           	ccrs.add(ccr1);
           // second for 15 hour incentive if year 2017 or greater
            if (Integer.valueOf(c.Name) >= 2017) {
                Cohort_Calculation_Rule__c ccr2 = new Cohort_Calculation_Rule__c();
                ccr2.Cohort__c = c.Id;
                ccr2.Year__c = String.valueOf(CURRENT_COHORT);
                ccr2.College_University_Type__c = '4 Year College';
                ccr2.EFC_Max__c = 99999;
                ccr2.EFC_Min__c = 0;
                ccr2.RecordTypeId = psiRT;
                ccr2.Type__c = 'EFC';
                ccr2.Scholarship_Amount__c = 600;
                ccr2.X15_Credit_Incentive__c = true;
                ccrs.add(ccr2);
            }
 
        }
        insert ccrs;
        return ccrs;
    }  
    
  private static List<Account> createTestAccounts() {
    List<String> colTypes = new List<String>{'4 Year College', 'Community College','Technical College',
          'Non DSF PSI'};
    List<Account> objList = new List<Account>();
    for (Integer i = 0; i < 4; i++) {
      Account obj = new Account();
      obj.recordTypeId = collRT;
      obj.name = colTypes[math.mod(i, 4)];
      obj.type = colTypes[math.mod(i, 4)];
      obj.scholarship_payment_frequency__c = '2';
      objList.add(obj);
    }
    objList.add(new Account(name='Emily Griffith Technical College',recordTypeId=collRT,type='Technical College'));
    insert objList;
    return objList;
  }
    
    private static void createStudentHistory(Id studentId, Double grade){
        Student_Education_History__c hist = new Student_Education_History__c();
        hist.Highest_Grade_Achieved__c = true;
        hist.Unweighted_Cumulative_GPA__c = grade;
        hist.Student__c = studentId;
        insert hist;
    }

  private static List<Contact> createTestContacts(List<Account> accList, List<Cohort__c> cohs) {
	// accList='4 Year College', 'Community College','Technical College','Non DSF PSI','Emily Griffith Technical College'
	// cohs=current, current-1, current-2
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    List<Contact> cons = new List<Contact>();
    // Create one contact for each Student Term test entry used, designated st0-8
    cons.add(new Contact(firstName='st0',Must_Be_Recipient_By_Met__c='Yes',Cohort__c=cohs[1].Id,
                            Confirmation_of_Financial_Need__c='Yes',AccountId=accList[0].Id));
    cons.add(new Contact(firstName='st1',Must_Be_Recipient_By_Met__c='Yes',Cohort__c=cohs[2].Id,
                              Confirmation_of_Financial_Need__c='Yes',AccountId=accList[0].Id));
    cons.add(new Contact(firstName='st2',Must_Be_Recipient_By_Met__c='Yes',Cohort__c=cohs[0].Id,
                              AccountId=accList[0].Id));
    cons.add(new Contact(firstName='st3',Cohort__c=cohs[0].Id,AccountId=accList[0].Id));
    cons.add(new Contact(firstName='st4',Cohort__c=cohs[0].Id,AccountId=accList[3].Id));
    cons.add(new Contact(firstName='st5',Cohort__c=cohs[2].Id,AccountId=accList[2].Id));
    cons.add(new Contact(firstName='st6',Must_Be_Recipient_By_Met__c='No',Cohort__c=cohs[1].Id,
                              AccountId=accList[0].Id));
    cons.add(new Contact(firstName='st7',Must_Be_Recipient_By_Met__c='No',Cohort__c=cohs[0].Id,
                              AccountId=accList[0].Id));
    cons.add(new Contact(firstName='st8',Must_Be_Recipient_By_Met__c='No',Cohort__c=cohs[2].Id,
                              AccountId=accList[2].Id));
      
    for (Contact cn : cons) {
      cn.LastName = 'Test';  
      cn.RecordTypeId = stRT;
    }
    insert cons;
    createStudentHistory(cons[0].Id,3); //GPA
    createStudentHistory(cons[2].Id,2); //GPA  
    createStudentHistory(cons[6].Id,1); //GPA  
    createStudentHistory(cons[7].Id,1); //GPA  
    return cons;
  }


  private static List<Application__c> createTestApplications(List<Contact> conList) {
    Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
    List<Application__c> apps = new List<Application__c>();
    // Match applications to student (conList) 0-8
    for(Contact c : conList) {
      apps.add(new Application__c(Student_Name__c=c.Id,Federal_FA_Eligible__c='Yes',
                                  Lawful_Presence_Req_Met__c='No'));
    }
    // add values for specific entries.
    apps[0].Mid_Year_Transfer_Status__c='Approved';
    apps[0].One_Year_Extension_Form_Submitted__c = 'Yes - Approved';
    apps[0].Dev_Ed_Req_Complete__c = 'Yes';
    apps[1].Enrolled_Previous_Year__c='Yes';
    apps[1].Dev_Ed_Req_Complete__c='Yes';
    apps[1].Mid_Year_Transfer_Status__c='Not Approved';
    apps[2].Federal_FA_Eligible__c='No';
    apps[2].Lawful_Presence_Req_Met__c='No';
	apps[2].Mid_Year_Transfer_Status__c='Not Approved - Stayed at Current College';  
	apps[4].Mid_Year_Transfer_Status__c='Not Approved - Late';
    apps[8].Dev_Ed_Req_Complete__c='No';
    apps[8].Enrolled_Previous_Year__c='Yes';
    insert apps;
    return apps;
  }
    
  private static Map<String, DSF_Term_Settings__c> createDsfSettings() {

    Map<String, DSF_Term_Settings__c> settings = new Map<String, DSF_Term_Settings__c>();
    DSF_Term_Settings__c setting2 = new DSF_Term_Settings__c();
    setting2.Name = 'Fall Default';
    setting2.Term_Name__c = 'Fall';
    setting2.Default_Setting__c = true;
    setting2.Term_Start_Date__c = Date.today().addDays(-20);
    setting2.Term_End_Date__c = Date.today().addDays(3);

    settings.put(setting2.Term_Name__c, setting2);
    insert settings.values();
    return settings;
  }

  private static List<Id> createTestStudent_Terms(List<Application__c> appList, List<Account> uniList) {
	// uniList='4 Year College', 'Community College','Technical College','Non DSF PSI','Emily Griffith Technical College'
    List<Student_Term__c> sts = new List<Student_Term__c>();
    List<Id> stIds = new List<Id>();
    //Set common fields for all entries
    for (Application__c app : appList) {
      sts.add(new Student_Term__c(Application__c=app.Id,Term_Semester__c='Fall',
                                  FA_File_Completion_Deadline__c = 'Yes',
                                  Has_Student_Completed_4_Year_Degree__c = 'No',
								  Term_End_Date__c=Date.valueOf(CURRENT_COHORT + '-11-20'),
                                  Term_Eligibility_Status__c='Finalist',
                                  SSR_Completed_Previous_Term__c = 'N/A',
                                  Rec_d_Pymt_Previous_Term__c = 'No',
                                  Test_Only__c = true,
                                  student_id_at_college__c = String.valueOf(Math.round(Math.random() * 10000))));  
    }
    // Set specific values for test entries 0-8  
    sts[0].Rec_d_Pymt_Previous_Term__c = 'Yes';
    sts[0].SSR_Completed_Previous_Term__c = 'Yes';
    sts[0].SAP_Status__c = 'Meeting SAP';
    sts[0].Financial_Aid_Status__c = 'Complete/Eligible for Disbursement';
    sts[0].FA_File_Completion_Deadline__c = 'Yes';
    sts[0].Enrollment_Type__c = 'Full Time Plus (15 or more credit hours)';
    sts[0].Program_Enrolled__c='Associate\'s';
    sts[0].Final_EFC_Upon_FA_File_Completion__c=5000;
    sts[0].College_or_University__c = uniList[0].Id;

    
    sts[1].Financial_Aid_Status__c = 'DACA/ASSET';
    sts[1].Rec_d_Pymt_Previous_Term__c = 'Yes';
    sts[1].SSR_Completed_Previous_Term__c = 'No';
    sts[1].SAP_Status__c = 'Not Meeting SAP';
    sts[1].College_or_University__c = uniList[0].Id;
      
	sts[2].Program_Enrolled__c='Certificate';
    sts[2].Final_EFC_Upon_FA_File_Completion__c = null;
    sts[2].Financial_Aid_Status__c = null;
    sts[2].SAP_Status__c = null;
    sts[2].College_or_University__c = uniList[0].Id;
      
    sts[3].Has_Student_Completed_4_Year_Degree__c = 'Yes';
    sts[3].College_or_University__c = uniList[0].Id;
      
    sts[4].College_or_University__c = uniList[3].Id;
      

    sts[5].College_or_University__c = uniList[2].Id;
    sts[5].SSR_Completed_Previous_Term__c = 'N/A';
      
    sts[6].Enrollment_Type__c = 'Other';
    sts[6].Program_Enrolled__c='Associate\'s';
    sts[6].FA_File_Completion_Deadline__c = 'No';
    sts[6].Financial_Aid_Status__c = 'Pending Packaging';
    sts[6].College_or_University__c = uniList[0].Id;
    sts[6].Rec_d_Pymt_Previous_Term__c = 'Yes' ;
   
      
    sts[7].Program_Enrolled__c='Certificate';
    sts[7].College_or_University__c = uniList[0].Id;
    sts[7].SAP_Status__c = ' ';

    sts[8].Enrollment_Type__c = 'Other';
    sts[8].Enrollment_Status__c = 'Enrolled in ONE Non-Pell-eligible Program'; 
    sts[8].Rec_d_Pymt_Previous_Term__c = 'Yes';
    sts[8].SAP_Status__c = 'Not Meeting SAP';
    sts[8].SSR_Completed_Previous_Term__c = null;
    sts[8].Program_Enrolled__c = null;
    sts[8].Final_EFC_Upon_FA_File_Completion__c = 9001; 
    sts[8].College_or_University__c = uniList[0].Id;

    insert sts;
    for(Student_Term__c st : sts) { 
        st.financial_data_status__c = 'Accepted';
        stIds.add(st.Id);
    }  
    update sts;  
    return stIds;
  }
    
  private static Map<String,Student_Term__c> createStudentTermMap(List<Student_Term__c> stList){
    // Creates a map of the Student Terms, keyed by first name (should be st0-8)
    Map<String,Student_Term__c> stMap = new Map<String,Student_Term__c>();  
    for(Student_Term__c st : stList){
      System.debug('stMap-'+st.Conga_Student_First_Name__c+': '+ st.Reason_for_Ineligibility__c + 
                   ' - Awarded:' + String.valueOf(st.Calculated_Award_Amount__c));
      if (stMap.get(st.Conga_Student_First_Name__c) == null){
        stMap.put(st.Conga_Student_First_Name__c, st);
      }
    }
    return stMap;
  }    
    
  private static Map<String,Eligibility_Check__c> createResultsMap(){  
    // Create a map of the generated check entries, keyed by Check Name + scholar First Name (st0-8)  
    List<Eligibility_Check__c> checkList = new List<Eligibility_Check__c>([SELECT Id, Check_Name__c,
                                                                Result__c, Detail__c,
                                                                Student_Term__r.Application__r.Student_Name__r.firstName
                                                                FROM Eligibility_Check__c]);
    Map<String,Eligibility_Check__c> checkMap = new Map<String,Eligibility_Check__c>();  
    for(Eligibility_Check__c chk : checkList) {
      String k = chk.Student_Term__r.Application__r.Student_Name__r.firstName + '-' + chk.Check_Name__c;
      System.debug(k+':'+chk.Result__c+'-'+chk.Detail__c);
      if (checkMap.get(k)==null){  
        checkMap.put(k, chk);  
      }    
    }
    return checkMap;
  } 
    
    
  static testMethod void testStudentScholarshipCalculator() {
    Integer testSize = 1;
    Map<String, DSF_Term_Settings__c> settings = createDsfSettings();
    List<Cohort__c> cohorts = createTestCohorts();  
    List<Cohort_Calculation_Rule__c> ccrs = createTestCohortRules(cohorts);  
    List<Account> accList = createTestAccounts();
    List<Contact> conList = createTestContacts(accList, cohorts);
    List<Application__c> appList = createTestApplications(conList);
    List<Id> stIds = createTestStudent_Terms(appList, accList);
    List<Student_Term__c> stList = [SELECT Id,Application__c,Term_Semester__c,Term_Eligibility_Status__c,
                                    student_id_at_college__c,Rec_d_Pymt_Previous_Term__c,
                                    SSR_Completed_Previous_Term__c,SAP_Status__c,Financial_Aid_Status__c,
                                    FA_File_Completion_Deadline__c,Enrollment_Type__c,Program_Enrolled__c,
                                    Final_EFC_Upon_FA_File_Completion__c,College_or_University__c,
                                    Has_Student_Completed_4_Year_Degree__c,isCurrentTerm__c,Term_Year__c,
                                    financial_data_status__c,Full_Time_Enrollment_Req_Exemption__c,
                                    Enrollment_Status__c,Conga_Student_First_Name__c,Reason_for_Ineligibility__c,
                                    Calculated_Award_Amount__c, Incentive_Award_Amount__c
									FROM Student_Term__c
									WHERE Id in :stIds];
    Map<String,Student_Term__c> stMap = createStudentTermMap(stList);
    System.assertEquals(1100, stMap.get('st0').Calculated_Award_Amount__c);  
    System.assertEquals(300, stMap.get('st0').Incentive_Award_Amount__c);  
    Map<String,Eligibility_Check__c> resultMap = createResultsMap();
    System.assertEquals('Pass', resultMap.get('st0-Alumni').Result__c);
  }

}