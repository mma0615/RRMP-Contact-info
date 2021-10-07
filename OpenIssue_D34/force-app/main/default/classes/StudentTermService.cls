public with sharing class StudentTermService {
  public static void setStartAndEndDatesForStudentTerm(List<Student_Term__c> stList) {
    Set<Id> schoolIds = new Set<Id>();
    for(Student_Term__c st : stList) {
      if(st.college_or_university__c != null) {
        schoolIds.add(st.college_or_university__c);
      }
    }
    map<String, map<String, DSF_Term_Settings__c>> settingsMap = new map<String, map<String, DSF_Term_Settings__c>>();
    for (DSF_Term_Settings__c setting : [SELECT Term_Start_Date__c, Term_End_Date__c, Term_Name__c, Default_Setting__c, College_University_Override_SF_ID__c FROM DSF_Term_Settings__c WHERE (College_University_Override_SF_ID__c IN :schoolIds OR College_University_Override_SF_ID__c = null)]) {
      if (settingsMap.get(setting.Term_Name__c) == null) {
        settingsMap.put(setting.Term_Name__c, new map<String, DSF_Term_Settings__c>());
      }
      if (setting.Default_Setting__c) {
        settingsMap.get(setting.Term_Name__c).put('default',setting);
      } else {
        settingsMap.get(setting.Term_Name__c).put(setting.college_university_override_sf_id__c,setting);
      }
    }
    for (Student_Term__c st : stList) {
      if(settingsMap.get(st.term_semester__c) != null) {
        DSF_Term_Settings__c term;
        if(settingsMap.get(st.term_semester__c).get(st.college_or_university__c) != null) {
            term = settingsMap.get(st.term_semester__c).get(st.college_or_university__c);
          } else if(settingsMap.get(st.term_semester__c).get('default') != null) {
            term = settingsMap.get(st.term_semester__c).get('default');
          }
        if (term != null) {
          st.term_start_date__c = term.term_start_date__c;
          st.term_end_date__c = term.term_end_date__c;
        }
      }
    }
  }

  public static void setCurrentStudentCollegeId(List<Student_Term__c> stList) {
    Map<Id, Student_Term__c> appMap = new Map<Id, Student_Term__c>();
    for (Student_Term__c st : stList) {
      if ((st.iscurrentterm__c && appMap.get(st.application__c) == null) || (st.iscurrentterm__c && appMap.get(st.application__c) != null && appMap.get(st.application__c).term_end_date__c > st.term_end_date__c)) {
        appMap.put(st.application__c, st);
      }
    }
    Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
    for (Application__c app : [Select Id, student_name__c From Application__c Where Id In :appMap.keySet()]) {
      if (contactsToUpdate.get(app.student_name__c) == null) {
        Contact con = new Contact();
        con.id = app.student_name__c;
        con.current_college_id__c = appMap.get(app.Id).student_id_at_college__c;
        contactsToUpdate.put(con.Id, con);
      }
    }
    update contactsToUpdate.values();
  }

  public static void setCurrentStudentTerms(List<Student_Term__c> stList) {
    Set<Id> appIds = new Set<Id>();
    Set<Id> excludeIds = new Set<Id>();
    String cappseason; // custom setting application season
    list<Application_Season_Cycle__mdt> appseason = [SELECT Id,Application_Year__c FROM Application_Season_Cycle__mdt LIMIT 1];
      
        
    String appyear = appseason.size() > 0 && appseason[0].Application_Year__c != null ? appseason[0].Application_Year__c : null;
      
    map<Id, Student_Term__c> studentTermExtraFieldsMap = new map<Id, Student_Term__c>([
          Select
          Application__r.student_name__r.cohort__r.name,
          College_or_university__r.name,
          College_or_university__r.type,
          Id,
          recordtype.name
          From Student_Term__c Where Id In :stList
    ]); 
    for (Student_Term__c st : stList) {
      appIds.add(st.application__c);
      excludeIds.add(st.Id);
      if (st.term_end_date__c >= Date.today() && st.term_start_date__c <= Date.today()) {
        st.iscurrentterm__c = true;
      } else {
        st.iscurrentterm__c = false;
      }
        /*move the student term status portal message to the calculator code*/
      
        /* Student_Term__c extraFieldsForCurrentStudentTerm = studentTermExtraFieldsMap.get(st.Id);
        system.debug('here final award status' + st.Final_Award_Status__c);
            st.Student_Term_Status_Portal_Message__c = '';
            Switch on st.Student_term_Status_Details__c{
                when 'Ineligible-Alumni'{
                    st.Student_Term_Status_Portal_Message__c = 'Congratulations! According to your college, you have completed your bachelor\'s degree! Because DSF does not fund coursework beyond a bachelor\'s degree, you are no longer eligible for an award from DSF.'; 
                }
                when 'Ineligible-FA Completion Deadline' {
                    st.Student_Term_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because you did not complete your college\'s financial aid requirements by July 15.';
                }
                when 'Ineligible-Sufficient Enrollment' {
                    st.Student_Term_Status_Portal_Message__c = 'You are currently not eligible for a ' + appyear + ' DSF Scholarship because you are not enrolled full-time. If you enroll full-time and meet all other DSF requirements, you may qualify for an award this term.';
                }
                when 'Ineligible-Meeting SAP-SAP Suspension' {
                    st.Student_Term_Status_Portal_Message__c = 'You are not eligible for a DSF Scholarship this term because you are not meeting satisfactory academic progress (SAP) at your college. Contact your college\'s financial aid office for information about completing a SAP appeal.';
                }
                when 'Ineligible-Financial Need(EFC)-High EFC'{
                    st.Student_Term_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' Scholarship because your estimated family contribution (EFC) is above DSF\'s limit of $8,364. Head to the Resources tab for more about financial need.';
                }
                when 'Ineligible-Payment Deadline-Need Info' {
                    st.Student_Term_Status_Portal_Message__c = 'DSF needs your college\'s financial aid office to provide information about your financial aid, enrollment, and satisfactory academic progress (SAP). Once they report your information to DSF, we will determine whether you qualify for a scholarship award this term.';
                }
                when 'Ineligible-FA Completion Deadline-Need Info' {
                    st.Student_Term_Status_Portal_Message__c = 'DSF needs your college\'s financial aid office to provide information about your financial aid, enrollment, and satisfactory academic progress (SAP). Once they report your information to DSF, we will determine whether you qualify for a scholarship award this term.';
                }
                
                when 'Ineligible-FA Status-Pending Status - FA Processing'{
                    st.Student_Term_Status_Portal_Message__c = 'Your financial aid office is still processing your information. Once they complete this and report your enrollment to DSF, we can process your award. If you believe your financial aid has been processed and is now complete, please let DSF know so we can confirm with your college.';
                }
                when 'Ineligible - Missed Payment Deadline' {
                    st.Student_Term_Status_Portal_Message__c = 'Unfortunately, you did not qualify for a DSF award within a year of graduating high school and are now no longer eligible for the DSF Scholarship.';
                }
                when 'Ineligible-Financial Need(Lawful Presence)-Lawful Presence Not Met'{
                    st.Student_Term_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because you did not provide current proof of lawful presence in the U.S. by the July 15 deadline. Please contact us with any questions or for more information.';
                }
                when 'Ineligible-GPA'{
                    st.Student_Term_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because your high school GPA was below the minimum required for your college type. Head to the Resources tab for more about GPA requirements.';
                }
                when 'Ineligible-SSR Requirement'{
                    st.Student_Term_Status_Portal_Message__c = 'You are not eligible to receive a DSF award for Fall ' + appyear + ' because you did not complete your Student Success Requirements this past Spring. If you continue to meet DSF requirements, you may be eligible for a Spring award.';
                }
                when 'Eligible - Award Calculated' {
                    if (st.Total_Payment_Value_Current_Term__c > 0){
                        st.Student_Term_Status_Portal_Message__c = 'Your award was sent to ' + extraFieldsForCurrentStudentTerm.College_or_University__r.Name +' on ' + st.Most_Recent_Student_Term_Payment_Date__c.format(); 
                    }
                    else {
                        st.Student_Term_Status_Portal_Message__c = 'Congratulations, you qualified for a DSF Scholarship this term! Your award is being processed. Please allow up to 2 weeks for your award to appear in your student account.';
                    }
                }
                
            }*/
    } //for
       //SV -12/3/19-  run this only when using the insert from the Generate terms button, not on every update , to uncheck the current term marker on the previous student terms for the same application
     /* if (trigger.isInsert){  commenting because this causes the update trigger to fire on the old records and is not setting the value correctly. Will be handled by a batch process UpdateCurrentTermmarker.apxc
       * to update the is current term marker and also run the award calculation code on the new term generated . The batch process can be run after the new term is generated.
        updateOtherStudentTermsInApplicaiton(appIds, excludeIds);
        }*/
  }

  private static void updateOtherStudentTermsInApplicaiton(Set<Id> appIds, Set<Id> excludeIds) {
    List<Student_Term__c> allStudentTerms = [Select term_end_date__c, term_start_date__c From Student_Term__c Where application__c In :appIds And Id Not In :excludeIds];
    List <Student_Term__c> sttoupdate = new List<Student_Term__c>();
    for (Student_Term__c st : allStudentTerms) {
      if (st.term_end_date__c >= Date.today()) {
        if (st.term_start_date__c <= Date.today()) {
          st.iscurrentterm__c = true;
        } else {
          st.iscurrentterm__c = false;
        }
       sttoupdate.add(st)   ;
      }
    }
      if (sttoupdate.size() > 0) {
        update sttoupdate;
      }
  }
  
  public static void calculateUnmetNeed(list<Student_Term__c> stList) {
    Set<Id> appIds = new Set<Id>();
    for (Student_Term__c st : stList) {
      appIds.add(st.Application__c);
    }
    map<Id, Application__c> appMap = new map<Id, Application__c>([SELECT Total_Budget__c, Tuition_Fees__c, Federal_Grants__c, State_Grants__c, Institutional_Scholarships__c, Other_Outside_Scholarships__c, Accepted_Workstudy__c, Accepted_Student_Loans__c, Other_Aid_Resources__c FROM Application__c WHERE Id IN :appIds]);
    for (Student_Term__c st : stList) {
      Application__c app = appMap.get(st.Application__c);
      if (app.Total_Budget__c != null) {
        Double totalBudget = app.Total_Budget__c == null ? 0 : app.Total_Budget__c;
        Double tuitionFees = app.Tuition_Fees__c == null ? 0 : app.Tuition_Fees__c;
        Double federalGrants = app.Federal_Grants__c == null ? 0 : app.Federal_Grants__c;
        Double stateGrants = app.State_Grants__c == null ? 0 : app.State_Grants__c;
        Double institutionalScholarships = app.Institutional_Scholarships__c == null ? 0 : app.Institutional_Scholarships__c;
        Double otherOutsideScholarships = app.Other_Outside_Scholarships__c == null ? 0 : app.Other_Outside_Scholarships__c;
        Double acceptedWorkstudy = app.Accepted_Workstudy__c == null ? 0 : app.Accepted_Workstudy__c;
        Double acceptedStudentLoans = app.Accepted_Student_Loans__c == null ? 0 : app.Accepted_Student_Loans__c;
        Double otherAidResources = app.Other_Aid_Resources__c == null ? 0 : app.Other_Aid_Resources__c;
        Double finalScholarshipPaymentAmount = st.Final_Scholarship_Payment_Amount__c == null ? 0 : st.Final_Scholarship_Payment_Amount__c;
        Double finalEFCUponFAFileCompletion = st.Final_EFC_Upon_FA_File_Completion__c == null ? 0 : st.Final_EFC_Upon_FA_File_Completion__c;
        //Calculate unmet need
        app.Unmet_Need__c = totalBudget - federalGrants - stateGrants - institutionalScholarships - otherOutsideScholarships - acceptedWorkstudy - acceptedStudentLoans - otherAidResources - finalScholarshipPaymentAmount - finalEFCUponFAFileCompletion;
      } else {
        app.Unmet_Need__c = null;
      }
    }
    update appMap.values();
  }
}