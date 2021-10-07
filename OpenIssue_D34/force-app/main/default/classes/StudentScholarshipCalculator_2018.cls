public class StudentScholarshipCalculator_2018 {
// Update values for the new school year here
// Note: Please confirm that the new cohort and
// Cohort Calculation Rule entries have been made.
// ------------------------------------------------
// 
// UPDATE THIS VALUE TO CURRENT COHORT
   static final Integer CURRENT_COHORT = 2018;

   static final String COHORT_STRING = String.valueOf(CURRENT_COHORT);
//
// UPDATE COHORT AND EFC VALUES - add new efcByCohort.put(Cohort,EFC) line for each cohort
   private static map<Integer,Integer> buildEFCbyCohortMap() {
     map<Integer,Integer> efcMap = new map<Integer,Integer>(); 
     efcMap.put(2014, 10314);
     efcMap.put(2015, 7992);
     efcMap.put(2016, 7992);
     efcMap.put(2017, 8229);  
     efcMap.put(2018, 8229);  
     return efcMap;
   }
//
    // UPDATE ELIGIBILITY LENGTHS - add new data using elMap.put('{cohort}-{school type}',{Years of Eligibility});
    private static map<String,Integer> buildEligibilityLengthMap() {
      map<String,Integer> eLMap = new map<String,Integer>();
      elMap.put('2013-Technical College',2);
      elMap.put('2013-Community College',3);
      elMap.put('2013-4 Year College',5); 
      elMap.put('2014-Technical College',2);
      elMap.put('2014-Community College',3);
      elMap.put('2014-4 Year College',5);
      elMap.put('2015-Technical College',1);
      elMap.put('2015-Community College',2);
      elMap.put('2015-4 Year College',4);
      elMap.put('2016-Technical College',1);
      elMap.put('2016-Community College',2);
      elMap.put('2016-4 Year College',4);
      elMap.put('2017-Technical College',1);
      elMap.put('2017-Community College',2);
      elMap.put('2017-4 Year College',4);
      elMap.put('2018-Technical College',1);
      elMap.put('2018-Community College',2);
      elMap.put('2018-4 Year College',4);
      return elMap;
    }
//
// THAT'S IT! DONE! 
// The rest of the values generate based on those above and database queries.
// --------------------------------------------------------------------------------
// 

   static final String FALL_TERM_YEAR   = 'Fall ' + CURRENT_COHORT;
   static final String WINTER_TERM_YEAR = 'Winter ' + (CURRENT_COHORT +1);
   static final String SPRING_TERM_YEAR = 'Spring ' + (CURRENT_COHORT +1);
   private static Integer rankingResult = 9999;
    
/* cohortRuleMap constructor - creates a working map from the sObject 'Cohort_Calculation_Rule__c'
    The 'Id' field is linked to a list called 'rules' that contains the following fields: 
        Id, Cohort__c, Enrollment_Status__c, College_University_Type__c, 
        EFC_Max__c, EFC_Min__c, Scholarship_Amount__c, Type__c, RecordTypeId
*/
  private static map<Id, list<Cohort_Calculation_Rule__c>> buildCohortRuleMap() {
    map<Id, list<Cohort_Calculation_Rule__c>> cohortRuleMap = new map<Id, list<Cohort_Calculation_Rule__c>>();
    list<Cohort_Calculation_Rule__c> rules = [Select Id, Cohort__c, Enrollment_Status__c,
                                              College_University_Type__c, EFC_Max__c, EFC_Min__c, Scholarship_Amount__c, 
                                              Type__c, RecordTypeId, Year__c,X15_Credit_Incentive__c
                                              From Cohort_Calculation_Rule__c
                                              Where Year__c LIKE :COHORT_STRING];
    for (Cohort_Calculation_Rule__c rule : rules) {
      if (cohortRuleMap.get(rule.cohort__c) == null) {
        cohortRuleMap.put(rule.cohort__c, new list<Cohort_Calculation_Rule__c>());
      }
      cohortRuleMap.get(rule.cohort__c).add(rule);
    }
    return cohortRuleMap;
  }
    
    private static void addResult(map<Integer,Eligibility_Check__c> results, Eligibility_Check__c check, 
                                  Integer rank) {
        if (rank < rankingResult) rankingResult = rank;
        check.Result_Rank__c = rank;
        results.put(rank, check);
    }

 /* calculateScholarshipAmount is the primary method that is called to calculate a student's eligibility.
        If eligible, their scholarship amount is determined.
        If not eligible, the 'Reason_for_Ineligibility__c' field is set.
    The method is handed a list of sObject 'Student_Term__c' entries in variable 'stList'.
    Each check run will be recorded in a list of 'Eligibility Check' entries with a Pass or Fail result.
*/
  public static void calculateScholarshipAmount(list<Student_Term__c> stList) {

// Take list of Student Terms, map in extra fields from 'Application__r' and 'College_or_university__r'
    map<Id, Student_Term__c> studentTermExtraFieldsMap = new map<Id, Student_Term__c>([
          Select
          Application__r.Dev_Ed_Req_Complete__c,
          Application__r.Enrolled_Previous_Year__c,
          Application__r.Federal_FA_Eligible__c,
          Application__r.Lawful_Presence_Req_Met__c,
          Application__r.Mid_Year_Transfer_Status__c,
          Application__r.student_name__r.cohort__c,
          Application__r.student_name__r.Must_Be_Recipient_By_Met__c,
          Application__r.student_name__r.cohort__r.name,
          Application__r.student_name__r.Final_High_School_GPA__c,
          Application__r.student_name__r.Confirmation_of_Financial_Need__c,
          Application__r.student_name__r.Highest_Cumulative_HS_GPA__c,
          Application__r.student_name__r.Missed_15_Credit_Completion_Lifelong__c,
          Application__r.student_name__r.HS_GPA_assessment_approved_Contact__c,
          Application__r.HS_GPA_Waiver_Status__c,
          Application__r.One_Year_Extension_Form_Submitted__c,
          Term_eligibility_status__c,
          College_or_university__r.name,
          College_or_university__r.scholarship_payment_frequency__c,
          College_or_university__r.type,
          Id,
          recordtype.name
          From Student_Term__c Where Id In :stList
        ]);
    map<Id, list<Cohort_Calculation_Rule__c>> cohortRuleMap = buildCohortRuleMap();
    map<Integer,Integer> efcByCohort = buildEFCbyCohortMap();
    map<String,Integer> eligLength = buildEligibilityLengthMap();
    List<Id> stuWithChecks = new List<Id>(); 
    List<Eligibility_Check__c> checks = new List<Eligibility_Check__c>();

    // Loop through each Student term in stList
    for (Student_Term__c st : stList) {
      Student_Term__c extraFieldsForCurrentStudentTerm = studentTermExtraFieldsMap.get(st.Id);
      Boolean IneligibleCriteriaFound = false;
      String stType = extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Emily Griffith Technical College' ? 
          'EGTC' : 'PSI';
      // PROCEED flag notes whether checks should continue to be run or if the rest should be skipped.
      Boolean PROCEED = true;
      Integer cohortNum = Integer.valueOf(extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name);
      map<Integer,Eligibility_Check__c> results = new map<Integer,Eligibility_Check__c>();
      rankingResult = 9999;
      System.debug('Scholarship Cal 2018 ' + 'Name = ' + st.Name + ', Cohort: ' + cohortNum + ', Is Current Term = ' + st.isCurrentTerm__c + ',' + st.Term_Year__c + ',' + FALL_TERM_YEAR);  

// Confirm this Student Term entry should be checked  
//  ******************** 
      if ((st.isCurrentTerm__c || st.Test_Only__c == true) &&
          (st.Term_Year__c == FALL_TERM_YEAR || st.Term_Year__c == WINTER_TERM_YEAR || st.Term_Year__c == SPRING_TERM_YEAR )) 
 {

        stuWithChecks.add(st.Id);

// ********** Eligibility Checks Start here ***************
      
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: Alumni
// Filters   : Run on All
// Purpose   : Confirm scholar has not completed a four year degree
// Results   : Pass, Fail 
// Fields    : Student_Term__c.Has_Student_Completed_4_Year_Degree__c
// Logic     : If Student_Term.Has_Student_Completed_4_Year_Degree__c is 'No', then check passes.
//             If the student is in a cohort between two and four years past 
//               and Student_Term.Has_Student_Completed_4_Year_Degree__c is blank,
//               the check is failed with the Detail 'Need Info'.
//             If Student_Term.Has_Student_Completed_4_Year_Degree__c is 'Yes', the check fails.
//             Note this means there will be no result for a student with a cohort NOT two to four years past 
//               and a blank Student_Term.Has_Student_Completed_4_Year_Degree__c.
// Notes     : Fail ends all other checks (PROCEED set to 'false')            
////////////////////////////////////////////////////////////////////////////////////////////////////// 

        if (PROCEED) if (st.Has_Student_Completed_4_Year_Degree__c == 'No') {
          addResult(results,new Eligibility_Check__c(Check_Name__c='Alumni',Result__c='Pass',Student_Term__c=st.Id),
                   9010);
        } else if(st.Has_Student_Completed_4_Year_Degree__c == null && cohortNum >= (CURRENT_COHORT - 4 )
                  && cohortNum <= (CURRENT_COHORT - 2) ) {
          IneligibleCriteriaFound = true;
          addResult(results,new Eligibility_Check__c(Check_Name__c='Alumni',Result__c='Fail',Student_Term__c=st.Id
                    ,Detail__c='Need Info'),10);
          PROCEED = false;
        } else if (st.Has_Student_Completed_4_Year_Degree__c == 'Yes') {
          IneligibleCriteriaFound = true;
          addResult(results,new Eligibility_Check__c(Check_Name__c='Alumni',Result__c='Fail',Student_Term__c=st.Id),
                   10);
          PROCEED = false;
        }
             

//////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: Payment Deadline
// Filters   : Run if scholar's cohort is the previous year's cohort
// Purpose   : Determine if scholar has met their payment deadline.
// Results   : Pass, Fail
// Fields    : Contact.Must_Be_Recipient_By_Met__c
// Logic     : If Contact.Must_Be_Recipient_By_Met__c is 'Yes','N/A' or 'In Progress' then check passes, 
//             If blank, check fails with Detail 'Need Info',
//             otherwise check fails.
////////////////////////////////////////////////////////////////////////////////////////////////////// 
 
        if (PROCEED && cohortNum >= 2015) 
            if(extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Must_Be_Recipient_By_Met__c == 'Yes' 
               || extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Must_Be_Recipient_By_Met__c == 'N/A' 
               || extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Must_Be_Recipient_By_Met__c == 'In Progress' 
              ) 
        {
          addResult(results,new Eligibility_Check__c(Check_Name__c='Payment Deadline',Result__c='Pass',
                                                     Student_Term__c=st.Id),9020);
        } else if (extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Must_Be_Recipient_By_Met__c == null)
        {
            addResult(results,new Eligibility_Check__c(Check_Name__c='Payment Deadline',Result__c='Fail',
                     Student_Term__c=st.Id,Detail__c='Need Info'),20);
            IneligibleCriteriaFound = true;
            
        }    
        else {
          addResult(results,new Eligibility_Check__c(Check_Name__c='Payment Deadline',Result__c='Fail',
                     Student_Term__c=st.Id),20);
          IneligibleCriteriaFound = true;
        }

//////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: Mid-Year Transfer
// Filters   : Run on All
// Purpose   : Determine if scholar has a valid Mid-Year Transfer Status
// Results   : Pass, Fail
// Fields    : Application__c.Mid_Year_Transfer_Status__c
// Logic     : Valid values are no value (null), 'Approved', and 'Not Approved - Stayed at Current College'.
//             Any other value fails this check.
////////////////////////////////////////////////////////////////////////////////////////////////////// 
             
        if (PROCEED) if (extraFieldsForCurrentStudentTerm.application__r.Mid_Year_Transfer_Status__c == null || 
             extraFieldsForCurrentStudentTerm.application__r.Mid_Year_Transfer_Status__c == 'Approved' || 
             extraFieldsForCurrentStudentTerm.application__r.Mid_Year_Transfer_Status__c == 
                         'Not Approved - Stayed at Current College') 
        {
           addResult(results,new Eligibility_Check__c(Check_Name__c='Mid-Year Transfer',Result__c='Pass',
                      Student_Term__c=st.Id),9030);
        }
        else {
           addResult(results,new Eligibility_Check__c(Check_Name__c='Mid-Year Transfer',Result__c='Fail',
                     Student_Term__c=st.Id),30);      
           IneligibleCriteriaFound = true;
        }         
                 
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: Partner College
// Filters   : Run on All
// Purpose   : Determine if scholar is attending a known Non-PSI school
// Results   : Pass, Fail
// Fields    : Account.Name
// Logic     : If the college/university name matches any of those listed, the check fails.
//             Any other value passes this check.
// Notes     : Failure ends all other checks.
////////////////////////////////////////////////////////////////////////////////////////////////////// 

        if (PROCEED) if (extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Non DSF PSI' || 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Aims Community College' || 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Delta Montrose Technical College'|| 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Morgan Community College'|| 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Nazarene Bible College'|| 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Pueblo Community College'|| 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Trinidad State Junior College') {
           addResult(results,new Eligibility_Check__c(Check_Name__c='Partner College',Result__c='Fail',
                     Student_Term__c=st.Id),40);      
           IneligibleCriteriaFound = true;
           PROCEED = false;
        }
        else {
           addResult(results,new Eligibility_Check__c(Check_Name__c='Partner College',Result__c='Pass',
                      Student_Term__c=st.Id),9040);      
        }

//////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: FA Completion Deadline
// Filters   : Run for All
// Purpose   : Determine if application was completed before deadline
// Results   : Pass, Fail
// Fields    : Student_Term.FA_File_Completion_Deadline__c,Application.Federal_FA_Eligible__c
// Logic     : If FA_File_Completion_Deadline__c is 'Yes' or if it is 'N/A' and the scholar is DACA,
//              the check passes.
//             If FA_File_Completion_Deadline__c is blank, the check fails with the Detail 'Need Info'.
//             Any other values fail this check.
// Notes     : Fail ends all other checks (PROCEED set to 'false')            
//////////////////////////////////////////////////////////////////////////////////////////////////////  
        if (PROCEED) 
            if (st.FA_File_Completion_Deadline__c == 'Yes' || st.FA_File_Completion_Deadline__c == 'In Progress' 
                    || (st.FA_File_Completion_Deadline__c == 'N/A' 
                     && extraFieldsForCurrentStudentTerm.Application__r.Federal_FA_Eligible__c == 'No')){
          addResult(results,new Eligibility_Check__c(Check_Name__c='FA Completion Deadline',Result__c='Pass',
                    Student_Term__c=st.Id),9160); 
          } else if (st.FA_File_Completion_Deadline__c == null){
            addResult(results,new Eligibility_Check__c(Check_Name__c='FA Completion Deadline',Result__c='Fail',
                      Student_Term__c=st.Id,Detail__c='Need Info'),160);                   
            IneligibleCriteriaFound = true;
            PROCEED = false;
          } else {
            addResult(results,new Eligibility_Check__c(Check_Name__c='FA Completion Deadline',Result__c='Fail',
                      Student_Term__c=st.Id),160);                   
            IneligibleCriteriaFound = true;
            PROCEED = false;

          }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: {cohort} Timed Out
// Filters   : Run on All
// Purpose   : Determine if scholar is still eligible based on their cohort and current type of school
// Results   : Pass - Eligible through {eligible year}, Fail - Eligible through {eligible year}
// Fields    : Account.Type, Map eligLength, cohortNum
// Logic     : Eligible Year starts as the scholar's cohort (minus one to include the first year).
//             Each type of school adds it's eligibility length to the Eligible Year.
//             If scholar has a one year extension, one is added to the Eligible Year.
//             To pass, Eligible Year must be greater than or equal to the current cohort.
// Notes     : Failure ends all other checks.
//             Cohorts have been translated to integers so simple addition and comparison can be used.
//             Eligibility Length (# years of elig.) for each cohort and school type is held in the map eligLength.
//             There are two different checks, one for each cohort range, so Details list the cohort.
//             If a valid cohort-school type is not found in the eligLength map, a Fail result is registered.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
            
       if (PROCEED)
       {
          Integer eligibilityLength = eligLength.get(cohortNum+'-'+
                                                     extraFieldsForCurrentStudentTerm.college_or_university__r.type);
          if (eligibilityLength == null) {
             addResult(results,new Eligibility_Check__c(Check_Name__c=cohortNum + ' Timed Out',Result__c='Fail',
                        Student_Term__c=st.Id,Detail__c='Invalid cohort or school type'),50);
             IneligibleCriteriaFound = true;
             PROCEED = false; 
          }
          else {
              Integer eligYear = cohortNum - 1 + eligibilityLength;
              if (cohortNum >= 2015 && 
                  extraFieldsForCurrentStudentTerm.Application__r.One_Year_Extension_Form_Submitted__c == 'Yes - Approved') {
                  eligYear = eligYear + 1;
              }
              if (eligYear >= CURRENT_COHORT) {
                 addResult(results,new Eligibility_Check__c(Check_Name__c=cohortNum + ' Timed Out',Result__c='Pass',
                           Student_Term__c=st.Id),9050);             
              }
              else {
                 addResult(results,new Eligibility_Check__c(Check_Name__c=cohortNum + ' Timed Out',Result__c='Fail',
                           Student_Term__c=st.Id,
                           Detail__c=extraFieldsForCurrentStudentTerm.college_or_university__r.type),50);
                 IneligibleCriteriaFound = true;
                 PROCEED = false;
              }
          }
       }
 
          
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: SSR Requirement
// Filters   : Fall Term - Run if scholar cohort is less than the current cohort for Fall term 
// 			   Winter, Summer Term - Run for all cohorts.
// Purpose   : Determine if SSR was completed the previous term
// Results   : Pass, Fail, Fail - Required SSR Fields have blank values
// Fields    : Student_Term.Rec_d_Pymt_Previous_Term__c, Student_Term__c.SSR_Completed_Previous_Term__c
// Logic     : If Rec'd Payment Previous Term is 'No', the check passes.
//             If Rec'd Payment Previous Term is 'Yes' and SSR Completed Previous Term is 'Yes' or 'N/A', 
//                the check passes.
//             If Rec'd Payment Previous Term is null, 
//               or Rec'd Payment Previous Term is 'Yes' and SSR Completed Previous Term is blank,
//                the check fails with Detail 'Required SSR Fields have blank values'
//             Any other value fails this check.
//////////////////////////////////////////////////////////////////////////////////////////////////////              
          if (PROCEED && (cohortNum < CURRENT_COHORT || 
                          st.Term_Year__c == WINTER_TERM_YEAR || st.Term_Year__c == SPRING_TERM_YEAR))
            if (st.Rec_d_Pymt_Previous_Term__c == 'No' 
                  || (st.Rec_d_Pymt_Previous_Term__c == 'Yes' 
                      && (st.SSR_Completed_Previous_Term__c == 'Yes'
                         || st.SSR_Completed_Previous_Term__c == 'N/A'))) {
            addResult(results,new Eligibility_Check__c(Check_Name__c='SSR Requirement',Result__c='Pass',
                      Student_Term__c=st.Id),9090);
            }
          else if (st.Rec_d_Pymt_Previous_Term__c == null || (st.Rec_d_Pymt_Previous_Term__c == 'Yes' 
                      && st.SSR_Completed_Previous_Term__c == null)) {
            addResult(results,new Eligibility_Check__c(Check_Name__c='SSR Requirement',Result__c='Fail',
                       Student_Term__c=st.Id,Detail__c='Required SSR Fields have blank values'),90);  
            IneligibleCriteriaFound = true;
            PROCEED = false;
          }
          else{
            addResult(results,new Eligibility_Check__c(Check_Name__c='SSR Requirement',Result__c='Fail',
                       Student_Term__c=st.Id),90);  
            IneligibleCriteriaFound = true;
          }
          
          
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: Dev Ed Met w/in 1st Year
// Notes     : Removed for 2018 Calculator
////////////////////////////////////////////////////////////////////////////////////////////////////// 



//////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: Meeting SAP
// Filters   : Run for All
// Purpose   : Determine if SAP has been met
// Results   : Pass, Fail - SAP Suspension, Fail - Need SAP Info
// Fields    : Student_Term.SAP_Status__c
// Logic     : If SAP_Status__c is 'Meeting SAP', the check passes.
//             If SAP_Status__c is 'Not Meeting SAP', the check fails with the detail 'SAP Suspension'.
//             The only other possibility is a blank value, which fails with the detail 'Need SAP Info'.
////////////////////////////////////////////////////////////////////////////////////////////////////// 
        if (PROCEED) if (st.SAP_Status__c == 'Meeting SAP') {
          addResult(results,new Eligibility_Check__c(Check_Name__c='Meeting SAP',Result__c='Pass',
                    Student_Term__c=st.Id),9110);
        }
        else if (st.SAP_Status__c == 'Not Meeting SAP') {
          IneligibleCriteriaFound = true;
          addResult(results,new Eligibility_Check__c(Check_Name__c='Meeting SAP',Result__c='Fail',Student_Term__c=st.Id,
                    Detail__c='SAP Suspension'),110);  
          } else {
            IneligibleCriteriaFound = true;
            addResult(results,new Eligibility_Check__c(Check_Name__c='Meeting SAP',Result__c='Fail',Student_Term__c=st.Id,
                      Detail__c='Need SAP Info'),240);  
          } 
             
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: FA Status
// Filters   : Run for All
// Purpose   : Determine if Financial Aid Status is in a ready state
// Results   : Pass, Fail - Pending Status - FA Processing, Fail - FA Incomplete
// Fields    : Student_Term.Financial_Aid_Status__c
// Logic     : If Financial_Aid_Status__c is 'Complete/Eligible for Disbursement' or  
//              'DACA/ASSET', the check passes.
//             If Financial_Aid_Status__c is 'Pending Packaging' or 'Verification', 
//              the check fails with the detail 'Pending Status - FA Processing'.
//             The other possibilities are 'Incomplete', 'No Application' or a blank value, 
//              all of which fail with the detail 'FA Incomplete'.
//////////////////////////////////////////////////////////////////////////////////////////////////////  
        if (PROCEED) if (st.Financial_Aid_Status__c == 'Complete/Eligible for Disbursement' || 
                         st.Financial_Aid_Status__c == 'DACA/ASSET' ) {
          addResult(results,new Eligibility_Check__c(Check_Name__c='FA Status',Result__c='Pass',Student_Term__c=st.Id),
                   9200);
        } else if (st.Financial_Aid_Status__c == 'Pending Packaging' ||
                  st.Financial_Aid_Status__c == 'Verification') {
            IneligibleCriteriaFound = true;
            addResult(results,new Eligibility_Check__c(Check_Name__c='FA Status',Result__c='Fail',Student_Term__c=st.Id,
                      Detail__c='Pending Status - FA Processing'),200);  
          } else { //Incomplete, No Application, null value
              IneligibleCriteriaFound = true;
              addResult(results,new Eligibility_Check__c(Check_Name__c='FA Status',Result__c='Fail',Student_Term__c=st.Id,
                        Detail__c='FA Incomplete'),220);  
            }
             
            
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: Sufficient Enrollment
// Filters   : Run for ALL
// Purpose   : Determine if scholar has sufficient enrollment relative to their type of school and 
//              considering exemptions.
// Results   : Pass, Fail, Fail - Pending Status - Need Program Info
// Fields    : cohortNum, stType, Student_Term__c.Enrollment_Type__c, Student_Term__c.Program_Enrolled__c,
//              Student_Term__c.Full_Time_Enrollment_Req_Exemption__c, Student_Term__c.Enrollment_Status__c
// Logic     : If school type is 'PSI', Program_Enrolled__c is not blank and either 
//               the scholar is full time (12+), or
//               the scholar is in a Certificate program and is enrolled 1/2 or 3/4 time, or
//               the scholar has a Full Time Exemption and is 1/2 or 3/4 time,
//               the check is passed. 
//             If the school type is 'EGTC' and Enrollment_Status__c is anything other than blank, 'Not Enrolled' or 'Less than half-time',
//              the check is passed.
//             If the school type is 'EGTC' and Enrollment_Status__c is blank, or
//              if the school type is 'PSI' and Enrollment_Type__c is blank, or
//              if the school type is 'PSI', Enrollment_Type__c is not blank and isn't 'Not Enrolled'  
//                and Program_Enrolled__c is blank, 
//              the check is failed with a Detail of 'Pending Status - Need Program Info'.
//             In any other case the check is failed.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
        if (PROCEED && cohortNum >= 2013)  
          if ((stType == 'PSI' && st.Program_Enrolled__c != null &&
                ((st.Enrollment_Type__c == 'Full Time (12 - 14 credit hours)' ||
                 st.Enrollment_Type__c == 'Full Time Plus (15 or more credit hours)' ) ||
                (   (st.Full_Time_Enrollment_Req_Exemption__c == 'Yes' ||
                     st.Program_Enrolled__c == 'Certificate') &&
                    (st.Enrollment_Type__c == '3/4 Time (9 - 11 credit hours)' || 
                     st.Enrollment_Type__c == 'Half Time (6 - 8 credit hours)')
                 )
              )   
            ) ||
            ( stType == 'EGTC' && 
                !( st.Enrollment_Status__c == null || st.Enrollment_Status__c == 'Not Enrolled'|| st.Enrollment_Status__c == 'Less than half-time')
            )
          ){
            addResult(results,new Eligibility_Check__c(Check_Name__c='Sufficient Enrollment',Result__c='Pass',
                      Student_Term__c=st.Id),9180);         
          } else if ((stType == 'EGTC' && st.Enrollment_Status__c == null)
                  || (stType == 'PSI' 
                      && (st.Enrollment_Type__c == null
                         || (!(st.Enrollment_Type__c ==  'Not Enrolled' || st.Enrollment_Type__c == null) 
                             && st.Program_Enrolled__c == null)
                         ) 
                      )
                    )
            { IneligibleCriteriaFound = true;
              addResult(results,new Eligibility_Check__c(Check_Name__c='Sufficient Enrollment',Result__c='Fail',Student_Term__c=st.Id,
                        Detail__c='Pending Status - Need Program Info'),100); 
            } 
            else {addResult(results,new Eligibility_Check__c(Check_Name__c='Sufficient Enrollment',Result__c='Fail',
                            Student_Term__c=st.Id),180);
                  IneligibleCriteriaFound = true;
            }
                      
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: GPA
// Filters   : Run on scholars with a cohort of 2015 or greater 
// Purpose   : Determine if scholar has sufficient GPA rank for their program and cohort
// Results   : Pass, Fail
// Fields    : cohortNum, stType, Student_Term__c.Program_Enrolled__c, Contact.HS_GPA_assessment_approved_Contact__c
//              Contact.Highest_Cumulative_HS_GPA__c
// Logic     : If GPA greater than or equal to 2.75, check is passed.
//             If GPA is greater than or equal to 2.0 and any of the following:
//                  Attending a 4 Year College and have an Approved HS GPA Waiver, 
//                  Or Attending a Community College and in an Associate program with an Approved HS GPA Waiver,
//                  Or Attending a Community College and in a Certificate program (note EGTC is automatically
//                    assumed to be a Certificate program),
//                  Or Cohort 2016 or greater and attending a Technical College and in a Certificate program,
//                  Or Cohort 2016 or greater and attending a Community or Technical College 
//                      and in an Associate of Applied Science (AAS) program,
//                  the check is passed.
//             In any other case the check is failed.   
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
        if (PROCEED && cohortNum >= 2015)
          if(extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Highest_Cumulative_HS_GPA__c >= 2.75
             || (extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Highest_Cumulative_HS_GPA__c >= 2.0
                && (
                    ((extraFieldsForCurrentStudentTerm.College_or_university__r.type == '4 Year College' 
                     || (extraFieldsForCurrentStudentTerm.College_or_university__r.type == 'Community College'
                        && st.Program_Enrolled__c == 'Associate\'s')) 
                     && (extraFieldsForCurrentStudentTerm.Application__r.student_name__r.HS_GPA_assessment_approved_Contact__c > 0)
                    ) ||
                    ((extraFieldsForCurrentStudentTerm.College_or_university__r.type == 'Community College' 
                     || (extraFieldsForCurrentStudentTerm.College_or_university__r.type == 'Technical College'
                        && cohortNum >= 2016)
                      ) && (st.Program_Enrolled__c == 'Certificate' || stType == 'EGTC') 
                    ) ||
                    (cohortNum >= 2016 && (extraFieldsForCurrentStudentTerm.College_or_university__r.type == 'Community College' 
                                          || extraFieldsForCurrentStudentTerm.College_or_university__r.type == 'Technical College')
                                       && st.Program_Enrolled__c == 'Associate of Applied Science (AAS)'
                    )
              )  )) {
              addResult(results,new Eligibility_Check__c(Check_Name__c='GPA',Result__c='Pass',
                        Student_Term__c=st.Id),9120);
            } else { 
              IneligibleCriteriaFound = true;
              addResult(results,new Eligibility_Check__c(Check_Name__c='GPA',Result__c='Fail',
                        Student_Term__c=st.Id),120);
            }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Check Name: Financial Need
// Filters   : Run for All
// Purpose   : Confirm Financial Need is valid
// Results   : Pass, Fail - Lawful Presence Not Met, Fail - Need EFC, Fail - High EFC
// Fields    : Contact.Confirmation_of_Financial_Need__c, 
//              Application__c.Federal_FA_Eligible__c, Application__c.Lawful_Presence_Req_Met__c,
//              Student_Term__c.Final_EFC_Upon_FA_File_Completion__c, Map efcByCohort
// Logic     : If Federal_FA_Eligible__c and/or 'Lawful_Presence_Req_Met__c' is blank,
//              the check is failed with the Detail 'Fed FA Elig, Lawful Pres Req Met not set'.
//             If Federal_FA_Eligible__c is 'No' and 'Lawful_Presence_Req_Met__c' is 'No',
//              the check is passed.
//             If Federal_FA_Eligible__c is 'No' and 'Lawful_Presence_Req_Met__c' is 'No',
//              the check is failed with the Detail 'Lawful Presence Not Met'.
//             If Final_EFC_Upon_FA_File_Completion__c is blank, the check is failed with 
//              the Detail 'Need EFC'
//             If Confirmation_of_Financial_Need__c is 'Yes', the check is passed.
//             In the last part of the check, the Final_EFC_Upon_FA_File_Completion__c is compared to the EFC Max
//              for the scholar's cohort, which is listed in the efcByCohort Map (see above) if scholar's final EFC
//              is less than or equal to the EFC Max value, the check passes.
//              If not, the check fails with the Detail 'High EFC'.
//             
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
        if (PROCEED) if (extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c == null 
            || extraFieldsForCurrentStudentTerm.application__r.Lawful_Presence_Req_Met__c == null ) {
            addResult(results,new Eligibility_Check__c(Check_Name__c='Financial Need',Result__c='Fail',
                       Student_Term__c=st.Id,Detail__c='Fed FA Elig, Lawful Pres Req Met not set'),80);
            IneligibleCriteriaFound = true;      
          }
          else if (extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c == 'No' 
                 && (extraFieldsForCurrentStudentTerm.application__r.Lawful_Presence_Req_Met__c == 'Yes'
                    || extraFieldsForCurrentStudentTerm.application__r.Lawful_Presence_Req_Met__c == 'N/A'))
          {addResult(results,new Eligibility_Check__c(Check_Name__c='Financial Need',Result__c='Pass',Student_Term__c=st.Id),
                     9999);}
          else if (extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c == 'No' && 
                 extraFieldsForCurrentStudentTerm.application__r.Lawful_Presence_Req_Met__c == 'No')
            {addResult(results,new Eligibility_Check__c(Check_Name__c='Financial Need',Result__c='Fail',
                       Student_Term__c=st.Id,Detail__c='Lawful Presence Not Met'),80);
                IneligibleCriteriaFound = true;}
            else if (st.Final_EFC_Upon_FA_File_Completion__c == null) 
              {addResult(results,new Eligibility_Check__c(Check_Name__c='Financial Need',Result__c='Fail',
                         Student_Term__c=st.Id,Detail__c='Need EFC'),190);
               IneligibleCriteriaFound = true;
              }
            else if (extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.Confirmation_of_Financial_Need__c == 'Yes')
            {addResult(results,new Eligibility_Check__c(Check_Name__c='Financial Need',Result__c='Pass',
                     Student_Term__c=st.Id),9080);}  
            // Note: Uses efcByCohort map so only one check is needed, not one per cohort.
             else {
               Integer efcMax = efcByCohort.get(cohortNum);  
               if (st.Final_EFC_Upon_FA_File_Completion__c <= efcMax)
               {addResult(results,new Eligibility_Check__c(Check_Name__c='Financial Need',Result__c='Pass',
                          Student_Term__c=st.Id),9150);}
               else {addResult(results,new Eligibility_Check__c(Check_Name__c='Financial Need',Result__c='Fail',
                               Student_Term__c=st.Id,Detail__c='High EFC'),150);
                     IneligibleCriteriaFound = true;
                    }
             }

             
// End of eligibility determination. If IneligibleCriteriaFound != true, no checks were failed and scholar is assumed eligible.
            
// Set award to zero whether or not student eligible. 
// If student is eligible, the award amount will be updated by the Calculation section.
          st.Calculated_Award_Amount__c = 0;
          st.Incentive_Award_Amount__c = 0;
          
// Calculation section - If student eligible, determine award amount
        if (!IneligibleCriteriaFound) {
          Id egtcRT = Schema.SObjectType.Cohort_Calculation_Rule__c.RecordTypeInfosByName.get('EGTC').RecordTypeId;
          Id psiRT = Schema.SObjectType.Cohort_Calculation_Rule__c.RecordTypeInfosByName.get('PSI').RecordTypeId;
          Boolean matchFoundStandard = false;
          Boolean matchFoundIncentive = false;
          Boolean incentive = (st.Enrollment_Type__c == 'Full Time Plus (15 or more credit hours)' &&
             extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Missed_15_Credit_Completion_Lifelong__c < 2 &&
             cohortNum >= 2017) ? true : false;
          System.debug('Name: ' + st.Conga_Student_First_Name__c + ', Incentive:' + incentive);
          System.debug('College Type: ' + extrafieldsforcurrentstudentterm.college_or_university__r.type + ', EFC: ' + 
                       st.Final_EFC_Upon_FA_File_Completion__c + ', FA_Eligible:' + extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c );
          for (Cohort_Calculation_Rule__c ccr : cohortRuleMap.get(extraFieldsForCurrentStudentTerm.application__r.student_Name__r.cohort__c)) 
            {
                // check match of PSI and College Type, or EGTC and Enrollment Status
              if ((psiRT == ccr.RecordTypeId && stType == 'PSI' && 
                     ccr.college_university_type__c != null && extrafieldsforcurrentstudentterm.college_or_university__r.type != null &&
                     ccr.college_university_type__c.contains(extrafieldsforcurrentstudentterm.college_or_university__r.type) ) ||
                  (egtcRT == ccr.RecordTypeId && stType == 'EGTC' && ccr.Enrollment_Status__c == st.Enrollment_Status__c)
                 )
              {
                  // if student is FA Eligible and rule is EFC and EFC is in bounds, use rule
                  // else if student is DACA and rule is DACA, use rule
                  // any other result drops out and loop checks next rule
                  if (extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c == 'Yes') {
                    if (ccr.Type__c == 'EFC') {
                          if (st.Final_EFC_Upon_FA_File_Completion__c >= ccr.efc_min__c && 
                              st.Final_EFC_Upon_FA_File_Completion__c <= ccr.efc_max__c) {
                            // check for 15 hour incentive
                            if (ccr.X15_Credit_Incentive__c) {
                                matchFoundIncentive = true;
                                st.Incentive_Award_Amount__c = ccr.scholarship_amount__c;
                                if (matchFoundStandard) break;
                              }
                            else { // standard award
                                 matchFoundStandard = true;
                                 st.Calculated_Award_Amount__c = ccr.scholarship_amount__c;
                                 if (incentive) // check for incentive award if necessary, otherwise done.
                                 { if (matchFoundIncentive) break;  }                            
                                 else break;
                            } 
                          }
                    }
                  }
                  else if (ccr.Type__c == 'DACA') {
                      // check for 15 hour incentive
                      if (ccr.X15_Credit_Incentive__c == true) {
                          matchFoundIncentive = true;
                          st.Incentive_Award_Amount__c = ccr.scholarship_amount__c;
                          if (matchFoundStandard) break;
                      }
                      else {
                          matchFoundStandard = true;
                          st.Calculated_Award_Amount__c = ccr.scholarship_amount__c;
                          if (incentive) // check for incentive award if necessary, otherwise done.
                          {  if (matchFoundIncentive) break; }
                          else break;
                      } 
                  }

              }
            } // end for loop
            if (!matchFoundStandard) {
              st.Calculated_Award_Amount__c = 0;
              st.Reason_for_Ineligibility__c = 'Eligible - No matching CCR found';
            } 
            else {
              if (stType == 'PSI' && st.Enrollment_Type__c != null) {
                 if (st.Enrollment_Type__c == '3/4 Time (9 - 11 credit hours)') {
                     st.Calculated_Award_Amount__c = st.Calculated_Award_Amount__c * 0.75; 
                 }
                 else if (st.Enrollment_Type__c == 'Half Time (6 - 8 credit hours)') {
                     st.Calculated_Award_Amount__c = st.Calculated_Award_Amount__c * 0.5; 
                 }
              }
              st.Reason_for_Ineligibility__c = 'Eligible - Award Calculated';
                // If Winter, round up to the nearest dollar. All other semesters, drop to the nearest dollar.
              if (st.Term_Semester__c == 'Winter') {
                 st.Calculated_Award_Amount__c = Math.round((st.Calculated_Award_Amount__c / Double.valueOf(extrafieldsforcurrentstudentterm.college_or_university__r.Scholarship_Payment_Frequency__c))+0.5);   
                 if (st.Incentive_Award_Amount__c > 0) 
                     st.Incentive_Award_Amount__c = Math.round((st.Incentive_Award_Amount__c / Double.valueOf(extrafieldsforcurrentstudentterm.college_or_university__r.Scholarship_Payment_Frequency__c))+0.5); 
              } else {
                 st.Calculated_Award_Amount__c = Math.floor(st.Calculated_Award_Amount__c / Double.valueOf(extrafieldsforcurrentstudentterm.college_or_university__r.Scholarship_Payment_Frequency__c));         
                 if (st.Incentive_Award_Amount__c > 0)
                     st.Incentive_Award_Amount__c = Math.floor(st.Incentive_Award_Amount__c / Double.valueOf(extrafieldsforcurrentstudentterm.college_or_university__r.Scholarship_Payment_Frequency__c));         
              }
            }
          } // End Calculation Section - if (!IneligibleCriteriaFound)
          else {
              Eligibility_Check__c r = results.get(rankingResult);
              st.Reason_for_Ineligibility__c = 'Ineligible-'+r.Check_Name__c ;
              if (r.Detail__c != null) {
                  st.Reason_for_Ineligibility__c = st.Reason_for_Ineligibility__c+'-'+r.Detail__c;
              }
          }
        System.debug(st.Conga_Student_First_Name__c+' - '+'Status:'+st.Reason_for_Ineligibility__c+' Award:$'+st.Calculated_Award_Amount__c);
        checks.addAll(results.values());
      } // if (st.financial_data_status__c = 'Accepted' && st.isCurrentTerm__c)
    } //for (Student_Term__c st : stList) 

// Each set of checks generated by this run is a new set of checks that should replace any old set, 
//  so find the old checks, delete and then add the new checks.
    List<Eligibility_Check__c> checksToDelete = [SELECT Id 
                                                 FROM Eligibility_Check__c 
                                                 WHERE Student_Term__c IN :stuWithChecks];
    delete checksToDelete;
    insert checks;
 // From Student_Term__c Where Id In :stuWithChecks     
  } // public static void calculateScholarshipAmount
} // public with sharing class StudentScholarshipCalculator