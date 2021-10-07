public with sharing class StudentScholarshipCalculator {

/* cohortRuleMap constructor - creates a working map from the sObject 'Cohort_Calculation_Rule__c'
    The 'Id' field is linked to a list called 'rules' that contains the following fields: 
        Id, Cohort__c, Enrollment_Status__c, College_University_Type__c, 
        EFC_Max__c, EFC_Min__c, Scholarship_Amount__c, Type__c, RecordTypeId
*/
    /*
  private static map<Id, list<Cohort_Calculation_Rule__c>> buildCohortRuleMap() {
    map<Id, list<Cohort_Calculation_Rule__c>> cohortRuleMap = new map<Id, list<Cohort_Calculation_Rule__c>>();
    list<Cohort_Calculation_Rule__c> rules = [Select Id, Cohort__c, Enrollment_Status__c, 
                                              College_University_Type__c, EFC_Max__c, EFC_Min__c, Scholarship_Amount__c, 
                                              Type__c, RecordTypeId From Cohort_Calculation_Rule__c];
    for (Cohort_Calculation_Rule__c rule : rules) {
      if (cohortRuleMap.get(rule.cohort__c) == null) {
        cohortRuleMap.put(rule.cohort__c, new list<Cohort_Calculation_Rule__c>());
      }
      cohortRuleMap.get(rule.cohort__c).add(rule);
    }
    return cohortRuleMap;
  }
*/
/* scholarshipMap constructor - creates a working map from the sObject 'Student_Term_Scholarship__c'
    Takes a list of sObject type 'Student_Term__c' and creates a map of scholarship entries that match 
        the student terms in the list.
    The 'Id' field is linked to a list called 'sts' that contains the following fields: 
        Id, Student_Term__c, program_designation__c
*/
    /*
  private static map<Id, map<Id, Student_Term_Scholarship__c>> buildscholarshipMap(list<Student_Term__c> stList) {
    map<Id, map<Id, Student_Term_Scholarship__c>> scholarshipMap = new map<Id, map<Id, Student_Term_Scholarship__c>>();
    for (Student_Term_Scholarship__c sts : [Select Id, Student_Term__c, program_designation__c 
                                            From Student_Term_Scholarship__c Where Student_Term__c IN :stList]) {
      if (scholarshipMap.get(sts.Student_Term__c) == null) {
        scholarshipMap.put(sts.Student_Term__c, new map<Id, Student_Term_Scholarship__c>());
      }
      scholarshipMap.get(sts.Student_Term__c).put(sts.Program_Designation__c, sts);
    }
    return scholarshipMap;
  }

  */
/* programNameMap constructor - creates a working map from the sObject 'CANDTECH_Programs__c'
    The program 'name' field is mapped to the program 'Id' field.
*/  
    /*
  private static map<String, Id> buildProgramNameMap() {
    map<String, Id> programNameMap = new map<String, Id>();
    for (CANDTECH_Programs__c prog : [Select Id, Name From CANDTECH_Programs__c]) {
      programNameMap.put(prog.name, prog.Id);
    }
    return programNameMap;
  }
*/
  /* partnerMap constructor - creates a working map from the sObject 'College_Partnership__c'
    The 'Id' field is linked to a list called 'pt' that contains the following fields: 
        Id, College_University__c, cohort__c
    Note that only active status entries are used.  
*/
    /*
  private static map<Id, map<Id, Boolean>> buildPartnerMap() {
    map<Id, map<Id, Boolean>> partnerMap = new map<Id, map<Id, Boolean>>();
    for (College_Partnership__c pt : [SELECT Id, College_University__c, cohort__c 
                                      FROM College_Partnership__c WHERE status__c = 'Active']) {
      if (partnerMap.get(pt.Cohort__c) == null) {
        partnerMap.put(pt.Cohort__c, new map<Id, Boolean>());
      }
      partnerMap.get(pt.Cohort__c).put(pt.College_University__c, true);
    }
    return partnerMap;
  }
*/

 /* calculateScholarshipAmount is the primary method that is called to calculate a student's eligibility.
        If eligible, their scholarship amount is determined.
        If not eligible, the 'Reason_for_Ineligibility__c' field is set.
    The method is handed a list of sObject 'Student_Term__c' entries in variable 'stList'.
*/
    /*
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
    map<String, Id> programNameMap = buildProgramNameMap();
    map<Id, list<Cohort_Calculation_Rule__c>> cohortRuleMap = buildCohortRuleMap();
    map<Id, map<Id, Student_Term_Scholarship__c>> scholarshipMap = buildscholarshipMap(stList);
    map<Id, map<Id, Boolean>> partnerMap = buildPartnerMap();

    // Loop through each Student term in stList
    for (Student_Term__c st : stList) {
      Student_Term__c extraFieldsForCurrentStudentTerm = studentTermExtraFieldsMap.get(st.Id);
      Boolean IneligibleCriteriaFound = false;
      String stType = extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Emily Griffith Technical College' ? 'EGTC' : 'PSI';

        // Update current school year check here -st.financial_data_status__c != 'Accepted' || 
      if ((!st.isCurrentTerm__c) &&
         (st.Term_Year__c == 'Fall 2016' || st.Term_Year__c == 'Winter 2017' || st.Term_Year__c == 'Spring 2017' )) {
// Initial Checks
      
        if (st.Has_Student_Completed_4_Year_Degree__c == 'Yes') {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - Alumni';
        
         } else if (
           extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2016' && 
           st.Final_EFC_Upon_FA_File_Completion__c > 7851 && 
           extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c == 'Yes') {
           IneligibleCriteriaFound = true;
           st.Reason_for_Ineligibility__c = 'Ineligible - High EFC';

            
        } else if (extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2015' && 
                   extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Must_Be_Recipient_By_Met__c == 'No' 
                   ) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - Pymt Deadline Not Met';
          
          
        } else if (extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2015' && 
                   extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Must_Be_Recipient_By_Met__c == null  
                   && st.FA_File_Completion_Deadline__c == 'No' 
                   ) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - Pymt Deadline Not Met';
          
            
        } else if (!(extraFieldsForCurrentStudentTerm.application__r.Mid_Year_Transfer_Status__c == null || 
             extraFieldsForCurrentStudentTerm.application__r.Mid_Year_Transfer_Status__c == 'Approved' || 
             extraFieldsForCurrentStudentTerm.application__r.Mid_Year_Transfer_Status__c == 'Not Approved - Stayed at Current College')) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible – Unapproved Mid-Year Transfer';

        } else if (extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Non DSF PSI' || 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Aims Community College' || 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Delta Montrose Technical College'|| 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Morgan Community College'|| 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Nazarene Bible College'|| 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Pueblo Community College'|| 
                   extraFieldsForCurrentStudentTerm.college_or_university__r.name == 'Trinidad State Junior College') {
        IneligibleCriteriaFound = true;
        st.Reason_for_Ineligibility__c = 'Ineligible - Non-Partner PSI';

       } else if 
        (   (extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2012' ||
            extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2013') && 
            (extraFieldsForCurrentStudentTerm.college_or_university__r.type == 'Community College' ||
            extraFieldsForCurrentStudentTerm.college_or_university__r.type == 'Technical College') ) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - Timed Out at PSI Type (CC/Tech)';

    } else if 
    ((extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2014' || 
    extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2015')
     && extraFieldsForCurrentStudentTerm.College_or_University__r.type == 'Technical College') {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - Timed Out at PSI Type (Tech)';


        } else if ((extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2014' ||
                    extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2015' ) && 
                   extraFieldsForCurrentStudentTerm.Application__r.Dev_Ed_Req_Complete__c == 'No' &&
                   extraFieldsForCurrentStudentTerm.Application__r.Enrolled_Previous_Year__c == 'Yes') {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - Dev Ed Not Met Within First Year';

         } else if (extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c == 'No' && 
                   extraFieldsForCurrentStudentTerm.application__r.Lawful_Presence_Req_Met__c == 'No' 
                   ) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - Lawful Presence Not Met';
                    
        } else if (st.SSR_Completed_Previous_Term__c == 'No' &&
                  st.Rec_d_Pymt_Previous_Term__c == 'Yes') {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - SSR Not Met';

// Cohort Program section             
        } else if ((extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2015' ||
                   extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2016') &&
                   
!(st.Enrollment_Type__c == null || st.Enrollment_Type__c ==  'Not Enrolled' || st.Enrollment_Status__c == null || st.Enrollment_Status__c ==  'Not Enrolled') &&
!(st.FA_File_Completion_Deadline__c == 'No' || st.FA_File_Completion_Deadline__c == null) &&
             
                   st.Program_Enrolled__c == null)
            {   IneligibleCriteriaFound = true;
                st.Reason_for_Ineligibility__c = 'Pending Status - Need Program Info';


        } else if (st.SAP_Status__c == 'Not Meeting SAP') {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - SAP Suspension';
          
          
        } else if ((extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2015' ||
                   extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2016') &&
                   ((st.Program_Enrolled__c == 'Associate\'s' || st.Program_Enrolled__c == 'Bachelor\'s') ||
                    (st.Program_Enrolled__c == 'Certificate' &&  
                    extraFieldsForCurrentStudentTerm.College_or_University__r.type == '4 Year College')) &&  
                    extraFieldsForCurrentStudentTerm.Application__r.student_name__r.Highest_Cumulative_HS_GPA__c < 2.75  && 
                   !(extraFieldsForCurrentStudentTerm.Application__r.HS_GPA_Waiver_Status__c=='Approved - waiver reqs met' || 
                   extraFieldsForCurrentStudentTerm.Application__r.HS_GPA_Waiver_Status__c=='Approved - certificate program completed'))
            {   IneligibleCriteriaFound = true;
                st.Reason_for_Ineligibility__c = 'Ineligible -  Ineligible Program Type - HS GPA < 2.75';


        } else if (st.Financial_Aid_Status__c == null || st.FA_File_Completion_Deadline__c == null) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Need FA Status Info';


       } else if  (
       extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.Confirmation_of_Financial_Need__c == null 
       && st.Final_EFC_Upon_FA_File_Completion__c == null &&
        (extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2014' ||
             extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2015')) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Pending Status - Need to Confirm Financial Need';
                     
        } else if (
          (extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2014' &&
          extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.Confirmation_of_Financial_Need__c == 'No'
          && st.Final_EFC_Upon_FA_File_Completion__c > 10468 && 
          extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c == 'Yes') ||
          (extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.cohort__r.name == '2015' && 
          st.Final_EFC_Upon_FA_File_Completion__c > 7851 && 
          extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c == 'Yes' &&
          extraFieldsForCurrentStudentTerm.application__r.Student_Name__r.Confirmation_of_Financial_Need__c == 'No')) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Ineligible - High EFC';

            
// Deadline - FA Status section

        } else if (st.FA_File_Completion_Deadline__c == 'No' ) {
            if ((stType == 'EGTC') ||
                (st.Enrollment_Type__c == 'Full Time (12 or more credit hours)') ||
                (   (st.Full_Time_Enrollment_Req_Exemption__c == 'Yes' ||
                     st.Program_Enrolled__c == 'Certificate') &&
                    (st.Enrollment_Type__c == '3/4 Time (9 - 11 credit hours)' || 
                     st.Enrollment_Type__c == 'Half Time (6 - 8 credit hours)')
                 )
                ){
                    if (st.Financial_Aid_Status__c == 'Complete/Eligible for Disbursement' || 
                     st.Financial_Aid_Status__c == 'DACA/ASSET') {
                        IneligibleCriteriaFound = true;
                        st.Reason_for_Ineligibility__c = 'Ineligible - Late Complete FA'; 
                    }
                    else {
                        IneligibleCriteriaFound = true;
                        st.Reason_for_Ineligibility__c = 'Ineligible - Late Incomplete FA';
                    }
                }
            else {
              IneligibleCriteriaFound = true;
              st.Reason_for_Ineligibility__c = 'Ineligible - Insufficient Enrollment - Missed FA Deadline';
            }


        } else if (extraFieldsForCurrentStudentTerm.application__r.Federal_FA_Eligible__c == 'Yes' && 
                   st.Final_EFC_Upon_FA_File_Completion__c == null &&
                   !(st.Enrollment_Type__c == null || st.Enrollment_Type__c ==  'Not Enrolled'|| st.Enrollment_Status__c == null || st.Enrollment_Status__c ==  'Not Enrolled' ) &&
    !(st.Financial_Aid_Status__c == 'DACA/ASSET')
                   ) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Pending Status - Not DACA - Need EFC';

       } else if (st.Financial_Aid_Status__c == 'Pending Packaging' ||
                  st.Financial_Aid_Status__c == 'Verification') {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Pending Status - FA Processing';

       } else if (st.Financial_Aid_Status__c == 'Incomplete' ||
                  st.Financial_Aid_Status__c == 'No Application') {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Pending Status - Incomplete FA';


       } else if ( stType == 'PSI' && 
                  ( 
                    ( !(st.Enrollment_Type__c == 'Full Time (12 or more credit hours)') &&
                      !(
                         (st.Full_Time_Enrollment_Req_Exemption__c == 'Yes' ||
                          st.Program_Enrolled__c == 'Certificate') &&
                         (st.Enrollment_Type__c == '3/4 Time (9 - 11 credit hours)' ||
                          st.Enrollment_Type__c == 'Half Time (6 - 8 credit hours)')
                       )
                    ) 
                  )
                 ){
            IneligibleCriteriaFound = true;
            st.Reason_for_Ineligibility__c = 'Ineligible - Insufficient Enrollment - Met FA Deadline';

       } else if ( stType == 'EGTC' && 
                  ( st.Enrollment_Status__c == null || st.Enrollment_Status__c == 'Not Enrolled')) {
            IneligibleCriteriaFound = true;
            st.Reason_for_Ineligibility__c = 'Ineligible - Insufficient Enrollment - Met FA Deadline';


        } else if (st.SAP_Status__c == null) {
          IneligibleCriteriaFound = true;
          st.Reason_for_Ineligibility__c = 'Need SAP Info';


        }
// End of eligibility determination. If IneligibleCriteriaFound != true, student is assumed eligible.
            
// Set award to zero whether or not student eligible. If student is eligible, the award amount will be updated by the Calculation section.
          st.Calculated_Award_Amount__c = 0;
          
// Calculation section - If student eligible, determine award amount
        if (!IneligibleCriteriaFound) {
          Id egtcRT = Schema.SObjectType.Cohort_Calculation_Rule__c.RecordTypeInfosByName.get('EGTC').RecordTypeId;
          Id psiRT = Schema.SObjectType.Cohort_Calculation_Rule__c.RecordTypeInfosByName.get('PSI').RecordTypeId;
          Boolean matchFound = false;
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
                              st.Final_EFC_Upon_FA_File_Completion__c <= ccr.efc_max__c) 
                          {
                             matchFound = true;
                             st.Calculated_Award_Amount__c = ccr.scholarship_amount__c;
                             break;                              
                          }
                    }
                  }
                  else if (ccr.Type__c == 'DACA') {
                          matchFound = true;
                          st.Calculated_Award_Amount__c = ccr.scholarship_amount__c;
                          break;
                  }

              }
            } // end for loop
            if (!matchFound) {
              st.Calculated_Award_Amount__c = 0;
              st.Reason_for_Ineligibility__c = 'Eligible - No matching rule found';
            } 
            else {
              if (stType == 'PSI' && st.Enrollment_Type__c != null) {
                 if (st.Enrollment_Type__c == '3/4 Time (9 - 11 credit hours)') {
                     st.Calculated_Award_Amount__c = st.Calculated_Award_Amount__c * 0.75; }
                 else if (st.Enrollment_Type__c == 'Half Time (6 - 8 credit hours)') {
                     st.Calculated_Award_Amount__c = st.Calculated_Award_Amount__c * 0.5; }
              }
              st.Reason_for_Ineligibility__c = 'Eligible - Award Calculated';
                // If Spring, round up to the nearest dollar. All other semesters, drop to the nearest dollar.
              if (st.Term_Semester__c == 'Winter') {
                 st.Calculated_Award_Amount__c = Math.round((st.Calculated_Award_Amount__c / Double.valueOf(extrafieldsforcurrentstudentterm.college_or_university__r.Scholarship_Payment_Frequency__c))+0.5);   
              } else {
                 st.Calculated_Award_Amount__c = Math.floor(st.Calculated_Award_Amount__c / Double.valueOf(extrafieldsforcurrentstudentterm.college_or_university__r.Scholarship_Payment_Frequency__c));         
              }
            }
          } // End Calculation Section - if (!IneligibleCriteriaFound)
      } // if (st.financial_data_status__c != 'Accepted' || !st.isCurrentTerm__c)
    } //for (Student_Term__c st : stList) {
  } // public static void calculateScholarshipAmount */
} // public with sharing class StudentScholarshipCalculator