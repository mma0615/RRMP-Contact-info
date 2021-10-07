@isTest
private class ApplicationSubmissionService_Test {

  private static Application_Submission__c createSubmission() {
    Application_Submission__c app = new Application_Submission__c();

    app.Application_Id__c = '1234';
    app.User_Id__c = '2345';
    app.Created_At__c = Datetime.now();
    app.Updated_At__c = Datetime.now();
    app.Time_Submitted__c = Datetime.now();

    app.Application_Type__c = 'new_app';
    app.FA_Eligible__c = 'Have obtained lawful presence through Deferred Action (DACA)';
    app.Form_Spanish__c = null;
    app.School_Year__c = '2019 - 2020';
    app.Status__c = 'Approved';

    // Parent Fields
    app.Parent_Address__c = '121 Test ave';
    app.Parent_Address_2__c = null;
    app.Parent_Alt_Phone__c = '(888) 888-8888';
    app.Parent_Alt_Phone_Type__c = 'Home';
    app.Parent_City__c = 'Test';
    app.Parent_Ed_Level__c = 'High School/GED';
    app.Parent_Email__c = 'ab@sss.com';
    app.Parent_First_Name__c = 'Test new1';
    app.Parent_Gender__c = 'Male';
    app.Parent_Last_Name__c = 'Test';
    app.Parent_Middle_Name__c = null;
    app.Parent_Pref_Phone__c = '(555) 555-5555';
    app.Parent_Pref_Phone_Type__c = 'Cell';
    app.Parent_Relationship_To_Student__c = 'Parent';
    app.Parent_Same_Address__c = 'No';
    app.Parent_State__c = 'Colorado';
    app.Parent_Suffix__c = null;
    app.Parent_Title__c = null;
    app.Parent_Zip__c = '55555';
    app.Parent_Agree__c = 'Yes';
    app.Parent_Date__c = null;
    app.Parent_Sig__c = 'Parent';

    // Student fields
    app.Student_Address__c = '11 test ave';
    app.Student_Address_2__c = null;
    app.Student_Agree__c = 'Yes';
    app.Student_Alt_Email__c = null;
    app.Student_Alt_Phone__c = '(777) 777-7777';
    app.Student_Alt_Phone_Type__c = 'Home';
    app.Student_AP_Courses__c = 'Yes';
    app.Student_Authorize_Parent__c = 'Yes';
    app.Student_Children__c = 'No';
    app.Student_City__c = 'Test';
    app.Student_College_Attend__c = 'Arapahoe Community College';
    app.Student_College_Attend_Not_Listed__c = null;
    app.Student_College_Attend_Undecided__c = 'Adams State University,Colorado College,Fort Lewis College';
    app.Student_Current_Armed_Forces__c = 'No';
    app.Student_Date__c = null;
    app.Student_Disability__c = null;
    app.Student_DoB__c = '12/12/1998';
    app.Student_DPS_ID__c = '222222';
    app.Student_DPS_School__c = 'Abraham Lincoln Engagement Center';
    app.Student_DPS_School_Not_Listed__c = null;
    app.Student_ED_Level__c = 'Master\'s Degree';
    app.Student_Email__c = 'abe@ss.com';
    app.Student_Emailed_Type__c = null;
    app.Student_Enroll_Cole_MS__c = 'No';
    app.Student_Ethnicity__c = 'Asian, Asian American';
    app.Student_Family_Member_Armed_Forces_Vet__c = 'No';
    app.Student_First_Name__c = 'Test export new';
    app.Student_Foster_Care__c = 'No';
    app.Student_Gender__c = 'My gender is not listed';
    app.Gender_Description__c = 'Pandgender';
    app.Student_Grad_HS__c = '07/1/2015';
    app.Student_Homeless__c = 'No';
    app.Student_Honors_Courses__c = 'Yes';
    app.Student_IB_Courses__c = 'Yes';
    app.Student_Language_Home__c = 'Hebrew';
    app.Student_Language_Other__c = null;
    app.Student_Last_Name__c = 'Test';
    app.Student_Lawful_Presence__c = 'Yes';
    app.Student_Major__c = 'Chemistry';
    app.Student_Middle_Name__c = null;
    app.Student_New_Volunteer__c = 'Yes';
    app.Student_Occupation_NEW__c = 'Architecture';
    app.Student_Occupation_NEW_Other__c = null;
    app.Student_Pref_Phone__c = '(444) 444-4444';
    app.Student_Pref_Phone_Text__c = null;
    app.Student_Pref_Phone_Type__c = 'Cell';
    app.Student_Prev_Applied__c = null;
    app.Student_Prev_DSF_Payment__c = null;
    app.Student_PSEO_Courses__c = 'Yes';
    app.Student_Reduced_Lunch__c = 'No';
    app.Student_Religious_Affiliation__c = 'Christian';
    app.Student_Religious_Affiliation_Other__c = null;
    app.Student_Restricted_Scholarship__c = null;
    app.Student_ROTC_in_HS_or_College__c = null;
    app.Student_Scholarship_Name_1__c = 'Arapahoe Community College Institutional Scholarship';
    app.Student_Scholarship_Name_1_Other__c = null;
    app.Student_Scholarship_Name_2__c = 'Adams State College Institutional Scholarship';
    app.Student_Scholarship_Name_2_Other__c = null;
    app.Student_Scholarship_Name_3__c = 'Colorado Mesa University Institutional Scholarship';
    app.Student_Scholarship_Name_3_Other__c = null;
    app.Student_should_apply_as__c = 'New applicant';
    app.Student_Sig__c = 'Stu';
    app.Student_Single_Parent__c = 'No';
    app.Student_SSN__c = '000-00-1111';
    app.Student_SSN_Check__c = '000-00-1111';
    app.Student_State__c = 'Colorado';
    app.Student_Support_Program__c = 'Other';
    app.Student_Support_Program_Other__c = 'Other program';
    app.Student_Suffix__c = null;
    app.Student_TCW_Courses__c = 'No';
    app.Student_Transfer_From_Community__c = 'Yes';
    app.Student_Transfer_Not_Listed__c = null;
    app.Student_Transfer_To_Com_Yes__c = 'Colorado Mesa University';
    app.Student_Transfer_Undecided__c = null;
    app.Student_Trio_Courses__c = 'No';
    app.Student_Zip__c = '12345';
    app.X15_Credit_Hours_Intention__c = 'Yes';
    app.X15_Credit_Hours_Term_Intention__c = 'Fall Only';
    app.City_of_Legal_Residence__c = 'Denver';
    app.Lived_in_Denver_continuously_past_year__c = 'Yes';
    app.Date_Moved_to_Denver__c = '07/04/2016';
    app.Extended_Absence_from_Denver__c = 'No';
    app.Employed_in_Denver_for_past_year__c = 'Yes';
    app.Registered_to_vote_in_Denver_1_year__c = 'No';
    app.Colorado_driver_s_license_or_state_ID__c = 'Yes';
    app.Motor_Vehicle_Registered_in_Denver__c = 'No';
    app.Interested_in_internships__c = 'Not Sure';
    app.Interested_in_mentoring__c = 'Yes';
    app.Attended_Dora_Moore_K8_School__c = 'Yes';
    app.Participated_in_AVID__c = 'No';
    app.Participated_in_Girls_Inc__c = 'Not Sure';
    app.Participated_in_CareerConnect__c = 'Yes';
    app.Submitted_FAFSA_as_of_application_date__c = 'No';
    app.Estimated_EFC_Reported_by_Student__c = '2500';
      
    return app;
  }

    
private static Application_Submission__c createCCF() {
    Application_Submission__c app = new Application_Submission__c();

    app.Application_Id__c = '2234';
    app.User_Id__c = '2345';
    app.Created_At__c = Datetime.now();
    app.Updated_At__c = Datetime.now();
    app.Time_Submitted__c = Datetime.now();
    app.School_Year__c = '2019 - 2020';
    app.Status__c = 'Approved';

    app.Application_Type__c = 'ccf_app';
    app.Student_College_Attend__c = 'Arapahoe Community College';
    app.Student_College_Attend_Not_Listed__c = null;
    app.Student_College_Attend_Undecided__c = 'Adams State University,Colorado College,Fort Lewis College';
    app.Student_Transfer_From_Community__c = 'Yes';
    app.Student_Transfer_Not_Listed__c = null;
    app.Student_Transfer_To_Com_Yes__c = 'Colorado Mesa University';
    app.Student_Transfer_Undecided__c = null;
    return app;
  }    

private static Application_Submission__c createProfile() {
    Application_Submission__c app = new Application_Submission__c();

    app.Application_Id__c = '3234';
    app.User_Id__c = '2345';
    app.Created_At__c = Datetime.now();
    app.Updated_At__c = Datetime.now();
    app.Time_Submitted__c = Datetime.now();

    app.Application_Type__c = 'profile_update';
    app.Student_Email__c = 'abe@ss.com';
    app.Is_Email_Update__c = true;
    app.Student_Pref_Phone__c = '(444) 444-4444';
    app.Student_Pref_Phone_Text__c = 'Yes';
    app.Student_Pref_Phone_Type__c = 'Cell';
    app.Student_Alt_Phone__c = '(777) 777-7777';
    app.Student_Alt_Phone_Type__c = 'Home';
    app.Student_Address__c = '11 test ave';
    app.Student_Address_2__c = null;
    app.Student_City__c = 'Test';
    app.Parent_State__c = 'Colorado';
    app.Parent_Zip__c = '55555';
    
    return app;
  } 
      

  @isTest static void testSubmissionApproval() {
    Contact c = new Contact();
    c.FirstName = 'Test';
    c.LastName = 'Test';
    c.ApplydID__c = '1234';
    c.Birthdate = Date.parse('12/12/1998');
    insert c;

    Test.startTest();
    Application_Submission__c submission = createSubmission();
    submission.Approval_Status__c = 'Approved';
    submission.Contact__c = c.Id;
    insert submission;
    Test.stopTest();
      
  }

  @isTest static void testCCFApproval() {
    Contact c = new Contact();
    c.FirstName = 'Test';
    c.LastName = 'Test';
    c.ApplydID__c = '1234';
    c.Birthdate = Date.parse('12/12/1998');
    insert c;

    Application_Submission__c submission = createSubmission();
    submission.Approval_Status__c = 'Approved';
    submission.Contact__c = c.Id;
    insert submission;
      
    Test.startTest();
    Application_Submission__c ccf = createCCF();
    ccf.Approval_Status__c = 'Approved';
    ccf.Contact__c = c.Id;
    insert ccf;
    Test.stopTest();
      
  }

  @isTest static void testProfileApproval() {
    Contact c = new Contact();
    c.FirstName = 'Test';
    c.LastName = 'Test';
    c.ApplydID__c = '1234';
    c.Birthdate = Date.parse('12/12/1998');
    insert c;

    Test.startTest();
    Application_Submission__c profile = createProfile();
    profile.Approval_Status__c = 'Approved';
    profile.Contact__c = c.Id;
    insert profile;
    Test.stopTest();
      
  }
  

}