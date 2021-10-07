public class ApplydModel {

  public class UsersResponse {
    public String status;
    public List<ApplydModel.User> data;
  }

  public class User {
    public String first_name;
    public String last_name;
    public String email;
    public String college_choice;
    public String college_choice_source;
  }

  public class ApplicationsResponse {
    public String status;
    public List<ApplydModel.Application> data;
  }

  public class Application implements Comparable {
    public String id;
    public Long created_at;
    public Long updated_at;
    public String user_id;
    public String app_type;
    public String school_year;
    public String status;
    public Long date_submitted;
    public Long time_submitted;
    public String stu_GradHS;
    public String stu_PrevDSFPayment;
    public String stu_PrevApplied;
    public String stu_EmailedType;
    public String stu_FirstName;
    public String stu_MiddleName;
    public String stu_LastName;
    public String stu_Suffix;
    public String stu_DoB;
    public String FA_Eligible;
    public String stu_SSN;
    public String stu_SSNCheck;
    public String stu_Gender;
    public String stu_Address;
    public String stu_Address2;
    public String stu_City;
    public String stu_State;
    public String stu_Zip;
    public String stu_Email;
    public String stu_PrefPhText;
    public String stu_PrefPh;
    public String stu_PrefPhType;
    public String stu_AltPh;
    public String stu_AltPhType;
    public String stu_Ethnicity;
    public String stu_LanguageOther;
    public String stu_Children;
    public String stu_LanguageHome;
    public String stu_TransferFromCommunity;
    public String stu_TransferToComYes;
    public String stu_TransferUndecided;
    public String stu_TransferNotListed;
    public String stu_OccupationNEW;
    public String stu_OccupationNEWOther;
    public String stu_Major;
    public String stu_EDLevel;
    public String stu_CreditsHours;
    public String stu_Terms;
    public String stu_Schol1Name;
    public String stu_Schol1NameOther;
    public String stu_Schol2Name;
    public String stu_Schol2NameOther;
    public String stu_Schol3Name;
    public String stu_Schol3NameOther;
    public String stu_SupportProgram1Name;
    public String stu_SupportProgram1NameOther;
    public String stu_Disability;
    public String stu_EnrollColeMS;
    public String stu_NewVolunteer;
    public String stu_DPSSchool;
    public String stu_DPSSchoolNotListed;
    public String stu_DPSID;
    public String stu_APCourses;
    public String stu_HonorsCourses;
    public String stu_IBCourses;
    public String stu_PSEOCourses;
    public String stu_TCWCourses;
    public String stu_CollegeAttend;
    public String stu_CollegeAttendUndecided1;
    public String stu_CollegeAttendUndecided2;
    public String stu_CollegeAttendUndecided3;
    public String stu_CollegeAttendNotListed;
    public String p1_Title;
    public String p1_FirstName;
    public String p1_MiddleName;
    public String p1_LastName;
    public String p1_Suffix;
    public String p1_Gender;
    public String p1_RelationshipToStu;
    public String p1_SameAddress;
    public String p1_Address;
    public String p1_Address2;
    public String p1_City;
    public String p1_State;
    public String p1_Zip;
    public String p1_PrefPh;
    public String p1_PrefPhType;
    public String p1_AltPh;
    public String p1_AltPhType;
    public String p1_Email;
    public String p1_EdLevel;
    public String form_Spanish;
    public String stu_Agree;
    public String stu_Sig;
    public String stu_Date;
    public String p_Agree;
    public String p_Sig;
    public String p_Date;
    public String stu_Religious_Affiliation;
    public String stu_Religious_AffiliationOther;
    public String stu_Current_Armed_Forces;
    public String stu_ROTC_in_HS_or_College;
    public String stu_Family_member_in_armed_forces_or_veteran;
    public String stu_Foster_Care;
    public String stu_Homeless;
    public String stu_Single_Parent;
    public String stu_TrioCourses;
    public String stu_AltEmail;
    public String stu_AuthorizeParent;
    public String stu_RestrictedScholarship;
    public String stu_ReducedLunch;
    public String stu_LawfulPresence;
    public String stu_CollegeId;
    public String stu_EthnicityOther;
    public String registration_email;
    public Boolean is_email_update;
    public String stu_LegalCity;
    public String stu_isDenverResidence;
    public String stu_DenverResidenceFrom;
    public String stu_isDenverExtendedAbsence;
    public String stu_isEmployedInDenver;
    public String stu_isRegisteredToVoteInDenver;
    public String stu_hasStateIdentificationCard;
    public String stu_hasMotorVehicleInDenver;
    public String stu_MentoringConnections;
    public String stu_Internships;
    public String stu_DoraMoore;
    public String stu_GirlsInc;
    public String stu_AVID;
    public String stu_is_fafsa_submitted;
    public String stu_EFC;
    public String stu_CCCourses;
    public String stu_PreferredFirstName;
    public String stu_PreferredPronouns;
    public String stu_PreferredPronounsText;
    public String stu_GenderNotListed;
    public String stu_LgbtqiaCommunity;
    public String stu_DenverKids;
    public String stu_SigTermsAndConditions;
    public String stu_AgreeTermsAndConditions;
    public String stu_MajorOther;
            
    public Integer compareTo(Object compareTo) {
      ApplydModel.Application that = (ApplydModel.Application)compareTo;
      if (this.updated_at == null) return (that.updated_at == null) ? 0 : -1;
      if (that.updated_at == null) return 1;
      if (this.updated_at == that.updated_at) return 0;
      if (this.updated_at > that.updated_at) return 1;
      return -1;
    }
  }

  public static ApplicationsResponse addTypeToData(ApplicationsResponse ar, String type) {
    for (ApplydModel.Application app : ar.data) {
      app.app_type = type;
    }
    return ar;
  }

  public static Application_Submission__c convertApplicationToApplicationSubmissionSObject(ApplydModel.Application applydApp) {
    // Convert to application submission
    Application_Submission__c app = new Application_Submission__c();

    if (applydApp.id != null && applydApp.id != 'false') { app.Application_Id__c = applydApp.id; }
    if (applydApp.user_id != null && applydApp.user_id != 'false') { app.User_Id__c = applydApp.user_id; }
    if (applydApp.created_at != null) { app.Created_At__c = Datetime.newInstance(applydApp.created_at * 1000); }
    if (applydApp.updated_at != null) { app.Updated_At__c = Datetime.newInstance(applydApp.updated_at * 1000); }
      
    if (applydApp.app_type != null && applydApp.app_type != 'false') { app.Application_Type__c = applydApp.app_type; }
    if (applydApp.FA_Eligible != null && applydApp.FA_Eligible != 'false') { app.FA_Eligible__c = applydApp.FA_Eligible; }
    if (applydApp.form_Spanish != null && applydApp.form_Spanish != 'false') { app.Form_Spanish__c = applydApp.form_Spanish; }
    if (applydApp.school_year != null && applydApp.school_year != 'false') { app.School_Year__c = applydApp.school_year; }
    if (applydApp.status != null && applydApp.status != 'false') { app.Status__c = applydApp.status; }
    if (applydApp.time_submitted != null) { app.Time_Submitted__c = Datetime.newInstance(applydApp.time_submitted * 1000); }
    if (applydApp.registration_email != null && applydApp.registration_email != 'false') { app.Registration_Email__c = applydApp.registration_email; }
    if (applydApp.is_email_update != null) { app.Is_Email_Update__c = applydApp.is_email_update; }

    // Parent Fields
    if (applydApp.p1_Address != null && applydApp.p1_Address != 'false') { app.Parent_Address__c = applydApp.p1_Address; }
    if (applydApp.p1_Address2 != null && applydApp.p1_Address2 != 'false') { app.Parent_Address_2__c = applydApp.p1_Address2; }
    if (applydApp.p1_AltPh != null && applydApp.p1_AltPh != 'false') { app.Parent_Alt_Phone__c = applydApp.p1_AltPh; }
    if (applydApp.p1_AltPhType != null && applydApp.p1_AltPhType != 'false') { app.Parent_Alt_Phone_Type__c = applydApp.p1_AltPhType; }
    if (applydApp.p1_City != null && applydApp.p1_City != 'false') { app.Parent_City__c = applydApp.p1_City; }
    if (applydApp.p1_EdLevel != null && applydApp.p1_EdLevel != 'false') { app.Parent_Ed_Level__c = applydApp.p1_EdLevel; }
    if (applydApp.p1_Email != null && applydApp.p1_Email != 'false') { app.Parent_Email__c = applydApp.p1_Email; }
    if (applydApp.p1_FirstName != null && applydApp.p1_FirstName != 'false') { app.Parent_First_Name__c = applydApp.p1_FirstName; }
    if (applydApp.p1_Gender != null && applydApp.p1_Gender != 'false') { app.Parent_Gender__c = applydApp.p1_Gender; }
    if (applydApp.p1_LastName != null && applydApp.p1_LastName != 'false') { app.Parent_Last_Name__c = applydApp.p1_LastName; }
    if (applydApp.p1_MiddleName != null && applydApp.p1_MiddleName != 'false') { app.Parent_Middle_Name__c = applydApp.p1_MiddleName; }
    if (applydApp.p1_PrefPh != null && applydApp.p1_PrefPh != 'false') { app.Parent_Pref_Phone__c = applydApp.p1_PrefPh; }
    if (applydApp.p1_PrefPhType != null && applydApp.p1_PrefPhType != 'false') { app.Parent_Pref_Phone_Type__c = applydApp.p1_PrefPhType; }
    if (applydApp.p1_RelationshipToStu != null && applydApp.p1_RelationshipToStu != 'false') { app.Parent_Relationship_To_Student__c = applydApp.p1_RelationshipToStu; }
    if (applydApp.p1_SameAddress != null && applydApp.p1_SameAddress != 'false') { app.Parent_Same_Address__c = applydApp.p1_SameAddress; }
    if (applydApp.p1_State != null && applydApp.p1_State != 'false') { app.Parent_State__c = applydApp.p1_State; }
    if (applydApp.p1_Suffix != null && applydApp.p1_Suffix != 'false') { app.Parent_Suffix__c = applydApp.p1_Suffix; }
    if (applydApp.p1_Title != null && applydApp.p1_Title != 'false') { app.Parent_Title__c = applydApp.p1_Title; }
    if (applydApp.p1_Zip != null && applydApp.p1_Zip != 'false') { app.Parent_Zip__c = applydApp.p1_Zip; }
    if (applydApp.p_Agree != null && applydApp.p_Agree != 'false') { app.Parent_Agree__c = applydApp.p_Agree; }
    if (applydApp.p_Date != null && applydApp.p_Date != 'false') { app.Parent_Date__c = applydApp.p_Date; }
    if (applydApp.p_Sig != null && applydApp.p_Sig != 'false') { app.Parent_Sig__c = applydApp.p_Sig; }

    // Student fields
    if (applydApp.stu_Address != null && applydApp.stu_Address != 'false') { app.Student_Address__c = applydApp.stu_Address; }
    if (applydApp.stu_Address2 != null && applydApp.stu_Address2 != 'false') { app.Student_Address_2__c = applydApp.stu_Address2; }
    if (applydApp.stu_Agree != null && applydApp.stu_Agree != 'false') { app.Application_Authorization__c = applydApp.stu_Agree; }
    if (applydApp.stu_AltEmail != null && applydApp.stu_AltEmail != 'false') { app.Student_Alt_Email__c = applydApp.stu_AltEmail; }
    if (applydApp.stu_AltPh != null && applydApp.stu_AltPh != 'false') { app.Student_Alt_Phone__c = applydApp.stu_AltPh; }
    if (applydApp.stu_AltPhType != null && applydApp.stu_AltPhType != 'false') { app.Student_Alt_Phone_Type__c = applydApp.stu_AltPhType; }
    if (applydApp.stu_APCourses != null && applydApp.stu_APCourses != 'false') { app.Student_AP_Courses__c = applydApp.stu_APCourses; }
    if (applydApp.stu_AuthorizeParent != null && applydApp.stu_AuthorizeParent != 'false') { app.Student_Authorize_Parent__c = applydApp.stu_AuthorizeParent; }
    if (applydApp.stu_AVID != null && applydApp.stu_AVID != 'false') { app.Participated_in_AVID__c = applydApp.stu_AVID; }
    if (applydApp.stu_CCCourses != null && applydApp.stu_CCCourses != 'false') { app.Participated_in_CareerConnect__c = applydApp.stu_CCCourses; }
    if (applydApp.stu_Children != null && applydApp.stu_Children != 'false') { app.Student_Children__c = applydApp.stu_Children; }
    if (applydApp.stu_City != null && applydApp.stu_City != 'false') { app.Student_City__c = applydApp.stu_City; }
    if (applydApp.stu_CollegeAttend != null && applydApp.stu_CollegeAttend != 'false') { app.Student_College_Attend__c = applydApp.stu_CollegeAttend; }
    if (applydApp.stu_CollegeAttendNotListed != null && applydApp.stu_CollegeAttendNotListed != 'false') { app.Student_College_Attend_Not_Listed__c = applydApp.stu_CollegeAttendNotListed; }
    if (applydApp.stu_CollegeAttendUndecided1 != null && applydApp.stu_CollegeAttendUndecided1 != 'null' && 
        applydApp.stu_CollegeAttendUndecided1 != 'false') 
      { app.Student_College_Attend_Undecided__c = applydApp.stu_CollegeAttendUndecided1; }
    if (applydApp.stu_CollegeAttendUndecided2 != null && applydApp.stu_CollegeAttendUndecided2 != 'null' && 
        applydApp.stu_CollegeAttendUndecided2 != 'false') {
      if ( String.isBlank(app.Student_College_Attend_Undecided__c)) {
        app.Student_College_Attend_Undecided__c = applydApp.stu_CollegeAttendUndecided2; }
      else {app.Student_College_Attend_Undecided__c = app.Student_College_Attend_Undecided__c + ', ' + applydApp.stu_CollegeAttendUndecided2; }
    }
    if (applydApp.stu_CollegeAttendUndecided3 != null && applydApp.stu_CollegeAttendUndecided3 != 'null' && 
        applydApp.stu_CollegeAttendUndecided3 != 'false') {
      if ( String.isBlank(app.Student_College_Attend_Undecided__c)) {
        app.Student_College_Attend_Undecided__c = applydApp.stu_CollegeAttendUndecided3; }
      else {app.Student_College_Attend_Undecided__c = app.Student_College_Attend_Undecided__c + ', ' + applydApp.stu_CollegeAttendUndecided3; }
    }
    if (applydApp.stu_CollegeAttendUndecided1 != null && applydApp.stu_CollegeAttendUndecided1 != 'false') { app.Student_College_Attend_Undecided__c = applydApp.stu_CollegeAttendUndecided1; }
    if (applydApp.stu_CollegeID != null && applydApp.stu_CollegeID != 'false') { app.College_ID__c = applydApp.stu_CollegeID; }
    if (applydApp.stu_CreditsHours != null && applydApp.stu_CreditsHours != 'false') { app.X15_Credit_Hours_Intention__c = applydApp.stu_CreditsHours; }
    if (applydApp.stu_Current_Armed_Forces != null && applydApp.stu_Current_Armed_Forces != 'false') { app.Student_Current_Armed_Forces__c = applydApp.stu_Current_Armed_Forces; }
    if (applydApp.stu_Date != null && applydApp.stu_Date != 'false') { app.Student_Date__c = applydApp.stu_Date; }
    if (applydApp.stu_DenverResidenceFrom != null && applydApp.stu_DenverResidenceFrom != 'false') { app.Date_Moved_to_Denver__c = applydApp.stu_DenverResidenceFrom; }
    if (applydApp.stu_Disability != null && applydApp.stu_Disability != 'false') { app.Student_Disability__c = applydApp.stu_Disability; }
    if (applydApp.stu_DoB != null && applydApp.stu_DoB != 'false') { app.Student_DoB__c = applydApp.stu_DoB; }
    if (applydApp.stu_DoraMoore != null && applydApp.stu_DoraMoore != 'false') { app.Attended_Dora_Moore_K8_School__c = applydApp.stu_DoraMoore; }
    if (applydApp.stu_DPSID != null && applydApp.stu_DPSID != 'false') { app.Student_DPS_ID__c = applydApp.stu_DPSID; }
    if (applydApp.stu_DPSSchool != null && applydApp.stu_DPSSchool != 'false') { app.Student_DPS_School__c = applydApp.stu_DPSSchool; }
    if (applydApp.stu_DPSSchoolNotListed != null && applydApp.stu_DPSSchoolNotListed != 'false') { app.Student_DPS_School_Not_Listed__c = applydApp.stu_DPSSchoolNotListed; }
    if (applydApp.stu_EDLevel != null && applydApp.stu_EDLevel != 'false') { app.Student_ED_Level__c = applydApp.stu_EDLevel; }
    if (applydApp.stu_EFC != null && applydApp.stu_EFC != 'false') { app.Estimated_EFC_Reported_by_Student__c = applydApp.stu_EFC; }
    if (applydApp.stu_Email != null && applydApp.stu_Email != 'false') { app.Student_Email__c = applydApp.stu_Email; }
    //if (applydApp.stu_EmailedType != null && applydApp.stu_EmailedType != 'false') { app.Student_should_apply_as__c = applydApp.stu_EmailedType; }
    if (applydApp.stu_EnrollColeMS != null && applydApp.stu_EnrollColeMS != 'false') { app.Student_Enroll_Cole_MS__c = applydApp.stu_EnrollColeMS; }
    if (applydApp.stu_Ethnicity != null && applydApp.stu_Ethnicity != 'false') { app.Student_Ethnicity__c = applydApp.stu_Ethnicity; }
    if (applydApp.stu_EthnicityOther != null && applydApp.stu_EthnicityOther != 'false') { app.Ethnicity_Other__c = applydApp.stu_EthnicityOther; }
    if (applydApp.stu_Family_member_in_armed_forces_or_veteran != null && applydApp.stu_Family_member_in_armed_forces_or_veteran != 'false') { app.Student_Family_Member_Armed_Forces_Vet__c = applydApp.stu_Family_member_in_armed_forces_or_veteran; }
    if (applydApp.stu_FirstName != null && applydApp.stu_FirstName != 'false') { app.Student_First_Name__c = applydApp.stu_FirstName; }
    if (applydApp.stu_Foster_Care != null && applydApp.stu_Foster_Care != 'false') { app.Student_Foster_Care__c = applydApp.stu_Foster_Care; }
    if (applydApp.stu_Gender != null && applydApp.stu_Gender != 'false') { app.Student_Gender__c = applydApp.stu_Gender; }
    if (applydApp.stu_GenderNotListed != null && applydApp.stu_GenderNotListed != 'false') { app.Gender_Description__c = applydApp.stu_GenderNotListed; }
    if (applydApp.stu_GirlsInc != null && applydApp.stu_GirlsInc != 'false') { app.Participated_in_Girls_Inc__c = applydApp.stu_GirlsInc; }
    if (applydApp.stu_GradHS != null && applydApp.stu_GradHS != 'false') { app.Student_Grad_HS__c = applydApp.stu_GradHS; }
    if (applydApp.stu_hasMotorVehicleInDenver != null && applydApp.stu_hasMotorVehicleInDenver != 'false') { app.Motor_Vehicle_Registered_in_Denver__c = applydApp.stu_hasMotorVehicleInDenver; }
    if (applydApp.stu_hasStateIdentificationCard != null && applydApp.stu_hasStateIdentificationCard != 'false') { app.Colorado_driver_s_license_or_state_ID__c = applydApp.stu_hasStateIdentificationCard; }
    if (applydApp.stu_Homeless != null && applydApp.stu_Homeless != 'false') { app.Student_Homeless__c = applydApp.stu_Homeless; }
    if (applydApp.stu_HonorsCourses != null && applydApp.stu_HonorsCourses != 'false') { app.Student_Honors_Courses__c = applydApp.stu_HonorsCourses; }
    if (applydApp.stu_isDenverExtendedAbsence != null && applydApp.stu_isDenverExtendedAbsence != 'false' ) {app.Extended_Absence_from_Denver__c = applydApp.stu_isDenverExtendedAbsence;}
    if (applydApp.stu_isDenverResidence != null && applydApp.stu_isDenverResidence != 'false' ) {app.Lived_in_Denver_continuously_past_year__c = applydApp.stu_isDenverResidence;}
    if (applydApp.stu_isEmployedInDenver != null && applydApp.stu_isEmployedInDenver != 'false' ) {app.Employed_in_Denver_for_past_year__c = applydApp.stu_isEmployedInDenver;}
    if (applydApp.stu_is_fafsa_submitted != null && applydApp.stu_is_fafsa_submitted != 'false' ) {app.Submitted_FAFSA_as_of_application_date__c = applydApp.stu_is_fafsa_submitted;}
    if (applydApp.stu_isRegisteredToVoteInDenver != null && applydApp.stu_isRegisteredToVoteInDenver != 'false' ) {app.Registered_to_vote_in_Denver_1_year__c = applydApp.stu_isRegisteredToVoteInDenver;}
    if (applydApp.stu_IBCourses != null && applydApp.stu_IBCourses != 'false') { app.Student_IB_Courses__c = applydApp.stu_IBCourses; }
    if (applydApp.stu_Internships != null && applydApp.stu_Internships != 'false') { app.Interested_in_internships__c = applydApp.stu_Internships; }
    if (applydApp.stu_LanguageHome != null && applydApp.stu_LanguageHome != 'false') { app.Student_Language_Home__c = applydApp.stu_LanguageHome; }
    if (applydApp.stu_LanguageOther != null && applydApp.stu_LanguageOther != 'false') { app.Student_Language_Other__c = applydApp.stu_LanguageOther; }
    if (applydApp.stu_LastName != null && applydApp.stu_LastName != 'false') { app.Student_Last_Name__c = applydApp.stu_LastName; }
    if (applydApp.stu_LawfulPresence != null && applydApp.stu_LawfulPresence != 'false') { app.Student_Lawful_Presence__c = applydApp.stu_LawfulPresence; }
    if (applydApp.stu_LegalCity != null && applydApp.stu_LegalCity != 'false') { app.City_of_Legal_Residence__c = applydApp.stu_LegalCity; }
      //Map to sub Major instead of Student Major
    if (applydApp.stu_Major != null && applydApp.stu_Major != 'false') { app.Student_Major__c = applydApp.stu_Major; }
    if (applydApp.stu_MajorOther != null && applydApp.stu_MajorOther != 'false') {app.Major_Other__c = applydApp.stu_MajorOther;}  
    if (applydApp.stu_MentoringConnections != null && applydApp.stu_MentoringConnections != 'false') { app.Interested_in_mentoring__c = applydApp.stu_MentoringConnections; }
    if (applydApp.stu_MiddleName != null && applydApp.stu_MiddleName != 'false') { app.Student_Middle_Name__c = applydApp.stu_MiddleName; }
    if (applydApp.stu_NewVolunteer != null && applydApp.stu_NewVolunteer != 'false') { app.Student_New_Volunteer__c = applydApp.stu_NewVolunteer; }
    if (applydApp.stu_OccupationNEW != null && applydApp.stu_OccupationNEW != 'false') { app.Student_Occupation_NEW__c = applydApp.stu_OccupationNEW; }
    if (applydApp.stu_OccupationNEWOther != null && applydApp.stu_OccupationNEWOther != 'false') { app.Student_Occupation_NEW_Other__c = applydApp.stu_OccupationNEWOther; }
    if (applydApp.stu_PrefPh != null && applydApp.stu_PrefPh != 'false') { app.Student_Pref_Phone__c = applydApp.stu_PrefPh; }
    if (applydApp.stu_PrefPhText != null && applydApp.stu_PrefPhText != 'false') { app.Student_Pref_Phone_Text__c = applydApp.stu_PrefPhText; }
    if (applydApp.stu_PrefPhType != null && applydApp.stu_PrefPhType != 'false') { app.Student_Pref_Phone_Type__c = applydApp.stu_PrefPhType; }
    if (applydApp.stu_PrevApplied != null && applydApp.stu_PrevApplied != 'false') { app.Student_Prev_Applied__c = applydApp.stu_PrevApplied; }
    if (applydApp.stu_PrevDSFPayment != null && applydApp.stu_PrevDSFPayment != 'false') { app.Student_Prev_DSF_Payment__c = applydApp.stu_PrevDSFPayment; }
    if (applydApp.stu_PSEOCourses != null && applydApp.stu_PSEOCourses != 'false') { app.Concurr_Enrol_or_College_Classes_in_HS__c = applydApp.stu_PSEOCourses; }
    if (applydApp.stu_ReducedLunch != null && applydApp.stu_ReducedLunch != 'false') { app.Student_Reduced_Lunch__c = applydApp.stu_ReducedLunch; }
    if (applydApp.stu_Religious_Affiliation != null && applydApp.stu_Religious_Affiliation != 'false') { app.Student_Religious_Affiliation__c = applydApp.stu_Religious_Affiliation; }
    if (applydApp.stu_Religious_AffiliationOther != null && applydApp.stu_Religious_AffiliationOther != 'false') { app.Student_Religious_Affiliation_Other__c = applydApp.stu_Religious_AffiliationOther; }
    if (applydApp.stu_RestrictedScholarship != null && applydApp.stu_RestrictedScholarship != 'false') { app.Student_Restricted_Scholarship__c = applydApp.stu_RestrictedScholarship; }
    if (applydApp.stu_ROTC_in_HS_or_College != null && applydApp.stu_ROTC_in_HS_or_College != 'false') { app.Student_ROTC_in_HS_or_College__c = applydApp.stu_ROTC_in_HS_or_College; }
    if (applydApp.stu_Schol1Name != null && applydApp.stu_Schol1Name != 'false') { app.Student_Scholarship_Name_1__c = applydApp.stu_Schol1Name; }
    if (applydApp.stu_Schol1NameOther != null && applydApp.stu_Schol1NameOther != 'false') { app.Student_Scholarship_Name_1_Other__c = applydApp.stu_Schol1NameOther; }
    if (applydApp.stu_Schol2Name != null && applydApp.stu_Schol2Name != 'false') { app.Student_Scholarship_Name_2__c = applydApp.stu_Schol2Name; }
    if (applydApp.stu_Schol2NameOther != null && applydApp.stu_Schol2NameOther != 'false') { app.Student_Scholarship_Name_2_Other__c = applydApp.stu_Schol2NameOther; }
    if (applydApp.stu_Schol3Name != null && applydApp.stu_Schol3Name != 'false') { app.Student_Scholarship_Name_3__c = applydApp.stu_Schol3Name; }
    if (applydApp.stu_Schol3NameOther != null && applydApp.stu_Schol3NameOther != 'false') { app.Student_Scholarship_Name_3_Other__c = applydApp.stu_Schol3NameOther; }
    if (applydApp.stu_SupportProgram1Name != null && applydApp.stu_SupportProgram1Name  != 'false') { app.Student_Support_Program__c = applydApp.stu_SupportProgram1Name ; }
    if (applydApp.stu_SupportProgram1NameOther != null && applydApp.stu_SupportProgram1NameOther  != 'false') { app.Student_Support_Program_Other__c = applydApp.stu_SupportProgram1NameOther ; }
    if (applydApp.stu_Sig != null && applydApp.stu_Sig != 'false') { app.Student_Sig__c = applydApp.stu_Sig; }
    if (applydApp.stu_Single_Parent != null && applydApp.stu_Single_Parent != 'false') { app.Student_Single_Parent__c = applydApp.stu_Single_Parent; }
    if (applydApp.stu_SSN != null && applydApp.stu_SSN != 'false') { app.Student_SSN__c = applydApp.stu_SSN; }
    if (applydApp.stu_SSNCheck != null && applydApp.stu_SSNCheck != 'false') { app.Student_SSN_Check__c = applydApp.stu_SSNCheck; }
    if (applydApp.stu_State != null && applydApp.stu_State != 'false') { app.Student_State__c = applydApp.stu_State; }
    if (applydApp.stu_Suffix != null && applydApp.stu_Suffix != 'false') { app.Student_Suffix__c = applydApp.stu_Suffix; }
    if (applydApp.stu_TCWCourses != null && applydApp.stu_TCWCourses != 'false') { app.Student_TCW_Courses__c = applydApp.stu_TCWCourses; }
    if (applydApp.stu_Terms != null && applydApp.stu_Terms != 'false') { app.X15_Credit_Hours_Term_Intention__c = applydApp.stu_Terms; }
    if (applydApp.stu_TransferFromCommunity != null && applydApp.stu_TransferFromCommunity != 'false') { app.Student_Transfer_From_Community__c = applydApp.stu_TransferFromCommunity; }
    if (applydApp.stu_TransferNotListed != null && applydApp.stu_TransferNotListed != 'false') { app.Student_Transfer_Not_Listed__c = applydApp.stu_TransferNotListed; }
    if (applydApp.stu_TransferToComYes != null && applydApp.stu_TransferToComYes != 'false') { app.Student_Transfer_To_Com_Yes__c = applydApp.stu_TransferToComYes; }
    if (applydApp.stu_TransferUndecided != null && applydApp.stu_TransferUndecided != 'false') { app.Student_Transfer_Undecided__c = applydApp.stu_TransferUndecided; }
    if (applydApp.stu_TrioCourses != null && applydApp.stu_TrioCourses != 'false') { app.Student_Trio_Courses__c = applydApp.stu_TrioCourses; }
    if (applydApp.stu_Zip != null && applydApp.stu_Zip != 'false') { app.Student_Zip__c = applydApp.stu_Zip; }
    if (applydApp.stu_PreferredFirstName != null && applydApp.stu_PreferredFirstName != 'false') {app.Preferred_First_Name__c = applydApp.stu_PreferredFirstName; }
    if (applydApp.stu_PreferredPronouns != null && applydApp.stu_PreferredPronouns != 'false'){app.Preferred_Pronouns__c = applydApp.stu_PreferredPronouns; }   
    if (applydApp.stu_PreferredPronounsText != null && applydApp.stu_PreferredPronounsText != 'false'){app.Preferred_Pronouns_self_identified__c = applydApp.stu_PreferredPronounsText ;}
    if (applydApp.stu_LgbtqiaCommunity != null && applydApp.stu_LgbtqiaCommunity != 'false'){app.LGBTQIA_community__c = applydApp.stu_LgbtqiaCommunity; }
    if (applydApp.stu_DenverKids != null && applydApp.stu_DenverKids != 'false') { app.Participated_in_Denver_Kids__c = applydApp.stu_DenverKids; }
   // if (applydApp.stu_SigTermsAndConditions!= null && applydApp.stu_SigTermsAndConditions != 'false'){app.Student_Signature_T_C__c = applydApp.stu_SigTermsAndConditions; }  
    if (applydApp.stu_AgreeTermsAndConditions != null && applydApp.stu_AgreeTermsAndConditions != 'false') { app.Student_Agree__c = applydApp.stu_AgreeTermsAndConditions; }
    if (app.Parent_Same_Address__c == 'Yes') {
      app.Parent_Address__c = app.Student_Address__c;
      app.Parent_City__c = app.Student_City__c;
      app.Parent_State__c = app.Student_State__c;
      app.Parent_Zip__c = app.Student_Zip__c;
    }

    return app;
  }

}