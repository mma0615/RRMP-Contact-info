global class UniveristyStudentTermGeneratorService implements Database.Batchable<sObject> {
  global list<String> accIds;
  global String termName;


  global UniveristyStudentTermGeneratorService(list<String> accIds, String termName) {
    this.accIds = accIds;
    this.termName = termName;
  }


  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator([SELECT school_name__c, student_name__c, id, dpsid__c,Mid_Year_Transfer_Status__c,application_status__c,mid_year_transfer_school__c FROM Application__c WHERE isCurrentApplication__c = true AND (School_Name__c IN :accIds OR mid_year_transfer_school__c IN :accIds)]);
  }


  global void execute(Database.BatchableContext BC, List<Application__c> appList) {
    list<Student_Term__c> stList = new list<Student_Term__c>();
    map<Id, Student_Term__c> stMap = new map<Id, Student_Term__c>();
    for (Student_Term__c st : [SELECT
                               Id,
                               Application__c,
                               Applied_for_ASSET__c,
                               Student_ID_at_College__c,
                               Daniels_Scholar__c,
                               Qualifies_for_Cook_Scholarship__c,
                               application__r.student_name__c,
                               application__r.school_name__c,
                               Program_Enrolled__c,
                               Financial_Aid_Deadline__c,
                               FA_File_Completion_Deadline__c,
                               Financial_Aid_Status__c,
                               Final_EFC_Upon_FA_File_Completion__c,
                               Projected_College_Graduation_Term__c,
                               Projected_College_Graduation_Year__c,
                               Has_Student_Completed_4_Year_Degree__c,
                               Qual_for_Daniels_Scholarship_by_College__c,
                               SSR_Completed_Previous_Term__c,
                               SSR_Comments_Previous_Term__c,
                               At_risk_of_stopping_out_Previous_Term__c,
                               At_Risk_Comments_Previous_Term__c,
                               SSR_Requirements_Completed__c,
                               SSR_Comments__c,
                               At_Risk_of_Stopping_Out__c,
                               At_Risk_Comments__c,
                               Term_Eligibility_Status__c,
                               Term_End_Date__c,
                               Rec_d_Pymt_Previous_Term__c,
                               Total_Payment_Value_Current_Term__c
                               FROM Student_Term__c
                               WHERE application__c IN :appList
                              ]) {
      Student_Term__c currentST = stMap.get(st.Application__c);
      if(currentST == null) {
        stMap.put(st.application__c, st);
      } else if(currentST != null && st.Term_End_Date__c != null && currentST.Term_End_Date__c != null && currentST.Term_End_Date__c < st.Term_End_Date__c) {
        stMap.put(st.application__c, st);
      }
    }
    for (Application__c app : appList) {
      if(app.application_status__c == 'Finalist' && (app.mid_year_transfer_school__c == null || (app.mid_year_transfer_school__c != null && app.Mid_Year_Transfer_Status__c == 'Approved'))) {
        Student_Term__c previousStudentTermForContact = stMap.get(app.Id);
        Student_Term__c st = new Student_Term__c();
        st.Application__c = app.Id;
          //set inital student recieved pmt previous term as 'No'
        st.Rec_d_Pymt_Previous_Term__c = 'No';  
        if (app.mid_year_transfer_school__c != null && app.Mid_Year_Transfer_Status__c == 'Approved') {
          st.College_or_University__c = app.mid_year_transfer_school__c;
        } else {
          if (previousStudentTermForContact != null && previousStudentTermForContact.Term_Eligibility_Status__c == 'Finalist') {
             //Should only be copied if not a mid year transfer
            st.Student_ID_at_College__c = previousStudentTermForContact.application__r.school_name__c == app.school_name__c ? previousStudentTermForContact.Student_ID_at_College__c : null;
            st.Term_Eligibility_Status__c = 'Finalist';
            st.Program_Enrolled__c = previousStudentTermForContact.Program_Enrolled__c;
            st.Financial_Aid_Deadline__c = previousStudentTermForContact.Financial_Aid_Deadline__c;
            st.FA_File_Completion_Deadline__c = previousStudentTermForContact.FA_File_Completion_Deadline__c;
            st.Financial_Aid_Status__c = previousStudentTermForContact.Financial_Aid_Status__c;
            st.Final_EFC_Upon_FA_File_Completion__c = previousStudentTermForContact.Final_EFC_Upon_FA_File_Completion__c;
            st.Applied_for_ASSET__c = previousStudentTermForContact.Applied_for_ASSET__c;
            st.Projected_College_Graduation_Term__c = previousStudentTermForContact.Projected_College_Graduation_Term__c;
            st.Projected_College_Graduation_Year__c = previousStudentTermForContact.Projected_College_Graduation_Year__c;
            st.Has_Student_Completed_4_Year_Degree__c = previousStudentTermForContact.Has_Student_Completed_4_Year_Degree__c;
            st.Daniels_Scholar__c = previousStudentTermForContact.Daniels_Scholar__c;
            st.Qualifies_for_Cook_Scholarship__c = previousStudentTermForContact.Qualifies_for_Cook_Scholarship__c;
            st.Qual_for_Daniels_Scholarship_by_College__c = previousStudentTermForContact.Qual_for_Daniels_Scholarship_by_College__c;
            st.SSR_Completed_Previous_Term__c = previousStudentTermForContact.SSR_Requirements_Completed__c;    
            st.SSR_Comments_Previous_Term__c = previousStudentTermForContact.SSR_Comments__c;
            st.At_risk_of_stopping_out_Previous_Term__c = previousStudentTermForContact.At_Risk_of_Stopping_Out__c; 
            st.At_Risk_Comments_Previous_Term__c = previousStudentTermForContact.At_Risk_Comments__c;
              //sv - Update recieved payment previous term to yes if the student has recieved a payment previous term 
            st.Rec_d_Pymt_Previous_Term__c = (previousStudentTermForContact.Total_Payment_Value_Current_Term__c > 0) ? 'Yes' : 'No'  ;
          }
          st.College_or_University__c = app.School_Name__c;
         
        }
        st.Term_Semester__c = termName;
        st.DPSID__c = app.DPSID__c;
        if(previousStudentTermForContact == null || (previousStudentTermForContact != null && previousStudentTermForContact.Term_Eligibility_Status__c == 'Finalist')) {
          stList.add(st);
        }
      }
    }
    insert stList;
  }


  global void finish(Database.BatchableContext BC) {

  }


  webservice static String generateStudentTermsForUniversities(list<String> accIds, String termName) {
    UniveristyStudentTermGeneratorService batchJob = new UniveristyStudentTermGeneratorService(accIds, termName);
    return Database.executeBatch(batchJob, 500);
  }
}