public class ApprovedSubmissionMapper {
 // public static initializeMajorSubmajorMap();
  public class ApprovedSubmissionMapperException extends Exception {}
  private List<Application_Submission__c> approvedSubmissions;
  private Map<String, Application__c> applydIdToApplicationMap;
  private Map<Id, List<Application__c>> contactIdToApplicationsMap;
  private Map<String, Account> collegeNameToAccountMap;
  private Map<Id, Contact> contactMap;
  private Map<String, Contact> dpsIdToContactMap;
  private Map<String, Contact> applydUserIdToContactMap;
  private Map<String, String> stateLowerToStateProperMap;
  private Map<String, String> applydFAEligibleToUSCitizenshipMap;
  private final Account nonDSFPSI;
    
   //defining variables inside the class for the Majors so it is accessible to all the private classes ;also fixes the SOQL limit error when approving a bunch of applications
   static list<ApplicationStemMajor__mdt> appmajors = [SELECT Id,STEM_Major__c FROM ApplicationStemMajor__mdt LIMIT 1];
   static String stemmajor = appmajors.size() > 0 && appmajors[0].STEM_Major__c != null ? appmajors[0].STEM_Major__c : null;
   static List<String> Agriculturesubmajor = new List<String>{'Agriculture, General','Agribusiness Operations', 'Agricultural Business & Management' ,'Agricultural Economics',
              								 'Agricultural Mechanization','Agricultural Production','Agronomy & Crop Science','Animal Sciences' ,'Food Sciences & Technology',
              								 'Horticulture Operations & Management','Horticulture Science', 'Natural Resources Conservation, General', 'Environmental Science',
             								 'Forestry','Natural Resources Management','Wildlife & Wildlands Management' };
   static List<String> ArchitectureMajor = new List<String>{'Architecture, General', 'Architectural Environmental Design','City/Urban/Regional Planning','Interior Architecture',
              							   'Landscape Architecture'};
                  
    static List<String> AreaEthnicMajor = new List<String>{'Area Studies, General (e.g., African, Middle Eastern)','Asian Area Studies','European Area Studies','Latin American Area Studies',
                      					 'North American Area Studies','Ethnic & Minority Studies, General','African American Studies','American Indian/Native American Studies','Latino/Chicano Studies',
                      					 'Women\'s Studies','Liberal Arts & General Studies', 'Library Science', 'Multi/Interdisciplinary Studies'};
   static List<String> ArtsMajor = new List<String>{'Art, General','Art History, Criticism & Conservation','Fine/Studio Arts','Cinema/Film','Cinematography/Film/Vide Production',
                              	   'Dance','Design & Visual Communications, General','Fashion/Apparel Design','Graphic Design','Industrial Design','Interior Design','Music, General','Music, Performance',
                                   'Music, Theory & Composition','Photography','Theatre Arts/Drama'};
    static List<String> BusinessMajor = new List<String>{'Accounting','Accounting Technician', 'Business Administration & Management, General', 'Hotel/Motel Management',
                                      'Human Resources Development/Training','Human Resources Management','International Business Management','Labor/Industrial Relations', 'Logistics & Materials Management',
                                      'Marketing Management & Research','Office Supervision & Management','Operations Management & Supervision','Organizational Behavior','Purchasing/Procurement/Contracts Management',
                                      'Restaurant/Food Services Management','Small Business Management/Operations','Travel/Tourism Management','Business/Management Quantitative Methods, General','Actuarial Science',
                                      'Business/Managerial Economics','Finance, General','Banking & Financial Support Services','Financial Planning & Services','Insurance & Risk Management','Investments & Securities',
                                      'Management Information Systems','Real Estate','Sales, Merchandising, & Marketing, General','Fashion Merchandising','Tourism & Travel Marketing','Secretarial Studies & Office Administration'};
   static List<String> CommunicationsMajor = new List<String>{'Communications, General','Advertising','Digital Communications/Media','Journalism, Broadcast','Journalism, Print', 'Mass Communications',
              							    'Public Relations & Organizational Communication','Radio & Television Broadcasting', 'Communications Technology, General','Graphic & Printing Equipment Operation',
											'Multimedia/Animation/Special Effects','Radio & Television Broadcasting Technology'};
                      
   static List<String> CommunityMajor = new List<String>{'Family & Consumer Sciences, General','Adult Development & Aging/Gerontology','Child Care Services Management','Child Development', 'Consumer & Family Economics',
										'Food & Nutrition','Textile & Apparel','Parks, Recreation, & Leisure, General','Exercise Science/Physiology/Kinesiology','Health & Physical Education/Fitness',
										'Parks/Rec/Leisure Facilities Management','Sport & Fitness Administration/Management','Personal Services, General','Cosmetology/Hairstyling','Culinary Arts/Chef Training',
										'Funeral Services & Mortuary Science','Protective Services, General','Corrections','Criminal Justice','Fire Protection & Safety Technology','Law Enforcement','Military Technologies',
										'Public Administration & Services, General','Community Organization & Advocacy','Public Administration','Public Affairs & Public Policy Analysis','Social Work'};             
   static List<String> ComputerMajor = new List<String>{'Computer & Information Sciences, General','Computer Networking/Telecommunications','Computer Science & Programming','Computer Software & Media Applications',
             						   'Computer System Administration','Data Management Technology','Information Science','Webpage Design','Mathematics, General','Applied Mathematics','Statistics'};
   static List<String> EducationMajor = new List<String>{'Counseling & Student Services','Educational Administration','Special Education','Teacher Education, General','Curriculum & Instruction','Early Childhood Education',
										'Elementary Education','Junior High/Middle School Education','Postsecondary Education','Secondary Education','Teacher Assisting/Aide Education','Teacher Education, Subject-Specific',
										'Agricultural Education','Art Education','Business Education','Career & Technical Education','English-as-a-Second-Language Education','English/Language Arts Education',
            					        'Foreign Languages Education','Health Education','Mathematics Education','Music Education','Physical Education & Coaching','Science Education','Social Studies/Sciences Education'};                    
   static List<String>Engineeringmajor = new List<String>{'Engineering (Pre-Engineering), General','Aerospace/Aeronautical Engineering','Agricultural/Bioengineering','Architectural Engineering','Biomedical Engineering','Chemical Engineering',
										'Civil Engineering','Computer Engineering','Construction Engineering/Management','Electrical, Electronics & Communications Engineering','Environmental Health Engineering',
										'Industrial Engineering','Mechanical Engineering','Nuclear Engineering'};
   static List<String>EngineeringTechnologyMajor = new List<String>{'Drafting/CAD Technology, General','Architectural Drafting/CAD Technology','Mechanical Drafting/CAD Technology','Engineering Technology, General',
												   'Aeronautical/Aerospace Engineering Technologies','Architectural Engineering Technology','Automotive Engineering Technology','Civil Engineering Technology',
												   'Computer Engineering Technology','Construction/Building Technology','Electrical, Electronics Engineering Technologies','Electromechanical/Biomedical Engineering Technologies',
												   'Environmental Control Technologies','Industrial Production Technologies','Mechanical Engineering Technology','Quality Control & Safety Technologies','Surveying Technology'};
   static List <String>LanguageMajor = new List<String>{'English Language & Literature, General','American/English Literature','Creative Writing','Public Speaking','Foreign Languages/Literatures, General',
									   'Asian Languages & Literatures','Classical/Ancient Languages & Literatures','Comparative Literature','French Language & Literature','German Language & Literature',
									   'Linguistics','Middle Eastern Languages & Literatures','Spanish Language & Literature'};                           
                                            
   static List<String> HealthAdminMajor = new List<String>{'Health Services Administration,General','Hospital/Facilities Administration','Medical Office/Secretarial','Medical Records','Medical/Clinical Assisting, General',
										 'Dental Assisting','Medical Assisting','Occupational Therapy Assisting','Physical Therapy Assisting','Veterinarian Assisting/Technology'}  ;
           
   static List<String> HealthSciencesMajor = new List<String>{'Chiropractic (Pre-Chiropractic)','Dental Hygiene','Dentistry (Pre-Dentistry)','Emergency Medical Technology','Health-Related Professions & Services, General','Athletic Training',
											'Communication Disorder Services (e.g., Speech Pathology)','Public Health','Health/Medical Technology, General','Medical Laboratory Technology','Medical Radiologic Technology',
											'Nuclear Medicine Technology','Respiratory Therapy Technology','Surgical Technology','Medicine (Pre-Medicine)','Nursing, Practical/Vocational (LPN)','Nursing, Registered (BS/RN)',
											'Optometry (Pre-Optometry)','Osteopathic Medicine','Pharmacy (Pre-Pharmacy)','Physician Assisting','Therapy & Rehabilitation, General','Alcohol/Drug Abuse Counseling',
											'Massage Therapy','Mental Health Counseling','Occupational Therapy','Physical Therapy (Pre-Physical Therapy)','Psychiatric/Mental Health Technician','Rehabilitation Therapy',
											'Vocational Rehabilitation Counseling','Veterinary Medicine (Pre-Veterinarian)'} ;
   static List<String> PhilosophyReligionMajor = new List<String> {'Philosophy','Religion','Theology, General','Bible/Biblical Studies','Divinity/Ministry','Religious Education'};
   static List<String> RepairProdMajor = new List<String>{'Aviation & Airway Science, General','Aircraft Piloting & Navigation','Aviation Management & Operations','Construction Trades (e.g., carpentry, plumbing, electrical)',
										'Mechanics & Repairers, General','Aircraft Mechanics/Technology','Autobody Repair/Technology','Automotive Mechanics/Technology','Avionics Technology','Diesel Mechanics/Technology',
										'Electrical/Electronics Equip Installation & Repair','Heating/Air Cond/Refrig Install/Repair','Precision Production Trades, General','Machine Tool Technology','Welding Technology',
             							 'Transportation & Materials Moving (e.g., air, ground, & marine)'};
   static List<String> BioScienceMajor = new List<String> {'Biology, General','Biochemistry & Biophysics','Cell/Cellular Biology','Ecology','Genetics','Marine/Aquatic Biology','Microbiology & Immunology','Zoology','Physical Sciences, General',
                      					 'Astronomy','Atmospheric Sciences & Meteorology','Chemistry','Geological & Earth Sciences','Physics'};
   static List<String> SocialSciencemajor = new List<String> {'Legal Studies, General','Court Reporting','Law (Pre-Law)','Legal Administrative Assisting/Secretarial','Paralegal/Legal Assistant','Social Sciences, General','Anthropology',
                          			       'Criminology','Economics','Geography','History','International Relations & Affairs','Political Science & Government','Psychology, Clinical & Counseling','Psychology, General',
                          				   'Sociology','Urban Studies/Urban Affairs'};
                                               
   static List<String> OtherMajor = new List <String>{'Other'};   
      
  

  public ApprovedSubmissionMapper(List<Application_Submission__c> approvedSubmissions) {
    this.approvedSubmissions = approvedSubmissions;
    this.applydIdToApplicationMap = this.initializeApplydIdToApplicationMap(this.approvedSubmissions);
    this.contactMap = this.initializeContactMap(this.approvedSubmissions);
    this.collegeNameToAccountMap = this.initializecollegeNameToAccountMap(approvedSubmissions);
    this.stateLowerToStateProperMap = this.initializeStateLowerToStateProperMap();
    this.contactIdToApplicationsMap = this.initializeContactIdToApplicationsMap(approvedSubmissions);
    this.initializeContactMatchMaps(approvedSubmissions);
    this.applydFAEligibleToUSCitizenshipMap = initializeApplydFAEligibleToUSCitizenshipMap();
  //  this.MajorSubMajormap = initializeMajorSubmajorMap();
    this.nonDSFPSI = this.getNonDSFPSI();
  }

  private Account getNonDSFPSI() {
    List<Account> accts = [SELECT Id FROM Account WHERE Name = 'Non DSF PSI' LIMIT 1];
    return (accts != null && !accts.isEmpty() ? accts[0] : null);
  }

  private Map<String, String> initializeStateLowerToStateProperMap() {
    Schema.DescribeFieldResult fieldResult = Contact.MailingStateCode.getDescribe();
    List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
    Map<String, String> stateMap = new Map<String, String>();
    for (Schema.PicklistEntry entry : picklistEntries) {
      stateMap.put(entry.getLabel().toLowerCase(), entry.getLabel());
    }
    return stateMap;
  }

  private Map<String, String> initializeApplydFAEligibleToUSCitizenshipMap() {
    Map<String, String> faMap = new Map<String, String>();
    faMap.put('Are a Legal Permanent Resident', 'Legal Permanent Resident');
    faMap.put('Are a United States Citizen', 'United States Citizen');
    faMap.put('Are planning to obtain, or in the process of obtaining, Deferred Action (DACA)', 'Planning to obtain, or in the process of obtaining, Deferred Action (DACA)');
    faMap.put('Are in the process of obtaining Deferred Action (DACA) (have a pending DACA application on file with USCIS)', 'Planning to obtain, or in the process of obtaining, Deferred Action (DACA)');
    faMap.put('Have obtained lawful presence in the United States as a refugee or asylee', 'Have obtained lawful presence in United States as a refugee or asylee');  
	faMap.put('Have obtained lawful presence through Deferred Action (DACA)', 'Have obtained lawful presence through Deferred Action');
    return faMap;
  }
    
  public void initializeMajorSubmajorMap() {
      
  }
    
  private Map<String, Application__c> initializeApplydIdToApplicationMap(List<Application_Submission__c> submissions) {
    List<String> applydIds = new List<String>();
    for (Application_Submission__c submission : submissions) {
      if (submission.Application_Id__c != null) {
        applydIds.add(submission.Application_Id__c);
      }
    }

    List<Application__c> applications = [SELECT Id, ApplydID__c FROM Application__c WHERE ApplydID__c IN :applydIds];
    Map<String, Application__c> applicationMap = new Map<String, Application__c>();
    for (Application__c app : applications) {
      applicationMap.put(app.ApplydID__c, app);
    }
    return applicationMap;
  }

  private Map<String, Account> initializeCollegeNameToAccountMap(List<Application_Submission__c> submissions) {
    Set<String> collegeNames = new Set<String>();
    for (Application_Submission__c submission : submissions) {
      collegeNames.add(submission.Student_College_Attend__c);
    }
    Id collegeRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'College/University'].Id;
    List<Account> colleges = [SELECT Id, Name FROM Account WHERE Name IN :collegeNames AND RecordTypeId = :collegeRecordTypeId];
    Map<String, Account> collegeMap = new Map<String, Account>();
    for (Account college : colleges) {
      collegeMap.put(college.Name, college);
    }
    return collegeMap;
  }

  private Map<Id, Contact> initializeContactMap(List<Application_Submission__c> submissions) {
    List<Id> contactIds = new List<Id>();
    for (Application_Submission__c submission : submissions) {
      if (submission.Contact__c != null) {
        contactIds.add(submission.Contact__c);
      }
    }
    return new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id IN :contactIds]);
  }

  private Map<Id, List<Application__c>> initializeContactIdToApplicationsMap(List<Application_Submission__c> submissions) {
    Set<Id> contactIds = new Set<Id>();
    for (Application_Submission__c submission : submissions) {
      if (submission.Contact__c != null && submission.Application_Type__c == 'ccf_app') {
        contactIds.add(submission.Contact__c);
      }
    }

    Map<Id, List<Application__c>> contactIdToAppsMap = new Map<Id, List<Application__c>>();
    for (Application__c app : [SELECT Id, ApplydID__c, Student_Name__c, Application_Submission_Year__c FROM Application__c WHERE Student_Name__c IN :contactIds]) {
      List<Application__c> apps = contactIdToAppsMap.get(app.Student_Name__c);
      if (apps == null) { apps = new List<Application__c>(); }
      apps.add(app);
      contactIdToAppsMap.put(app.Student_Name__c, apps);
    }
    return contactIdToAppsMap;
  }
    
  private String mapYesNo(String authText){
    
    if (String.isNotEmpty(authText))
      if ((authText.toLowerCase().startsWith('yes')) ||
          (authText.toLowerCase().startsWith('sí'))) {
        return 'Yes';
      } else if (authText.toLowerCase().startsWith('no')) {
        return 'No';
      } else return null;
    else return 'No'; //SV -If the authorization text is empty it means that the student did not agree and hence should be No
  }

  private void initializeContactMatchMaps(List<Application_Submission__c> submissions) {
    List<String> dpsIds = new List<String>();
    List<String> applydUserIds = new List<String>();
    for (Application_Submission__c submission : submissions) {
      if (submission.Student_DPS_ID__c != null) { dpsIds.add(submission.Student_DPS_Id__c); }
      if (submission.User_Id__c != null) { applydUserIds.add(submission.User_Id__c); }
    }

    List<Contact> contacts = [SELECT Id, DPSID__c, ApplydID__c FROM Contact WHERE DPSID__c IN :dpsIds OR ApplydID__c IN :applydUserIds];
    List<Id> contactIds = new List<Id>();
    for (Contact c : contacts) {
      contactIds.add(c.Id);
    }

    this.dpsIdToContactMap = new Map<String, Contact>();
    this.applydUserIdToContactMap = new Map<String, Contact>();
    for (Contact c : contacts) {
      if (c.DPSID__c != null) { dpsIdToContactMap.put(c.DPSID__c, c); }
      if (c.ApplydID__c != null) { applydUserIdToContactMap.put(c.ApplydID__c, c); }
    }
  }

  public void run() {
    
    for (Application_Submission__c submission : approvedSubmissions) {
      Contact submissionContact = contactMap.get(submission.Contact__c);
      if (submissionContact == null) {
        if (submission.Application_Type__c == 'new_app') {
          submissionContact = dpsIdToContactMap.get(submission.Student_DPS_Id__c);
        } else {
          submissionContact = applydUserIdToContactMap.get(submission.User_Id__c);
        }
      }

      if (submissionContact == null) {
        throw new ApprovedSubmissionMapperException('All applications moved to "Approved" status must have an associated student.');
      } else {
        submissionContact.ApplydID__c = submission.User_Id__c;
      }

      Application__c app = null;
      if (submission.Application_Type__c == 'ccf_app') {
        List<Application__c> apps = this.contactIdToApplicationsMap.get(submissionContact.Id);
        // Find matching application by year
        if (apps != null) {
          for (Application__c searchApp : apps) {
            String submissionYear = submission.School_Year__c.split(' - ')[0];
            if (submissionYear == searchApp.Application_Submission_Year__c) {
              app = searchApp;
              break;
            }
          }
        }
      } else {
        app = applydIdToApplicationMap.get(submission.Application_Id__c);
      }

      if (app == null && submission.Application_Type__c != 'profile_update' && submission.Application_Type__c != 'ccf_app') {
        app = new Application__c();
      }

      if (submission.Application_Type__c == 'new_app' || submission.Application_Type__c == 'renewal_app') {
        app = this.mapApplicationFields(submission, app);
        applydIdToApplicationMap.put(app.ApplydID__c, app);
        submissionContact = this.mapContactFields(submission, submissionContact);
      } else if (submission.Application_Type__c == 'ccf_app' && app != null) {
        app = this.mapCCFFormFields(submission, app);
        applydIdToApplicationMap.put(app.ApplydID__c, app);
      } else if (submission.Application_Type__c == 'profile_update') {
        submissionContact = this.mapProfileTypeContactFields(submission, submissionContact);
      }
    }

    upsert this.contactMap.values();
    upsert this.applydIdToApplicationMap.values();
  }

  private Application__c mapApplicationFields(Application_Submission__c submission, Application__c app) {
    /*
      Fields on Application_Submission__c unsure of mapping location

      School_Year__c
      Status__c
      User_Id__c

      Parent_Agree__c
      Parent_Date__c
      Parent_Sig__c

      Student_College_Attend_Not_Listed__c
      Student_Date__c
      Student_Emailed_Type__c
      Student_Grad_HS__c
      Student_Prev_DSF_Payment__c
      Student_PSEO_Courses__c
      Student_Sig__c
      Student_Transfer_Not_Listed__c
      Student_Transfer_To_Com_Yes__c
      Student_Transfer_Undecided__c

    */

    /*
      Information
    */
    app.Student_Name__c = submission.Contact__c;
    app.Social_Security_Number__c = submission.Student_SSN__c;

    if (submission.Application_Type__c == 'new_app') {
      app.Suffix__c = submission.Student_Suffix__c;
      app.Birthdate__c = Date.parse(submission.Student_DoB__c);
    } 


    if (app.ApplydID__c == null) {
      app.ApplydID__c = submission.Application_Id__c;
    }
    if (app.Estimated_EFC_Reported_by_Student__c != null)
      app.Estimated_EFC_Reported_by_Student__c = Integer.valueOf(submission.Estimated_EFC_Reported_by_Student__c);
    app.Submitted_FAFSA_as_of_application_date__c = mapYesNo(submission.Submitted_FAFSA_as_of_application_date__c);
    app.Gender__c = submission.Student_Gender__c;
    app.Gender_Description__c = submission.Gender_Description__c;

    app.Primary_Language_Spoken_At_Home__c = submission.Student_Language_Home__c;
    app.Other_Language__c = submission.Student_Language_Other__c;

    app.Affirmation_Docs__c = mapYesNo(submission.Student_Lawful_Presence__c);

    app.Application_Submission_Date_Time__c = submission.Time_Submitted__c;
    
    
    if (submission.FA_Eligible__c == 'Are a United States Citizen' || submission.FA_Eligible__c == 'Are a Legal Permanent Resident' || submission.FA_Eligible__c == 'Have obtained lawful presence in the United States as a refugee or asylee') {
      app.Affirmation_Date__c = null;
      } else {
       app.Affirmation_Date__c = Date.valueof(submission.Time_Submitted__c);
      }
    
    app.DSF_Scholar_Volunteer_Interest__c = submission.Student_New_Volunteer__c;

    app.Restricted_Scholarship_Authorization__c = 
        mapYesNo(submission.Student_Restricted_Scholarship__c);
    
    app.Parent_Guardian_Authorization__c = 
        mapYesNo(submission.Student_Authorize_Parent__c); 
    
    app.Free_Reduced_Lunch_Authorization__c = 
        mapYesNo(submission.Student_Reduced_Lunch__c);  
      
      //SV - Changing authorization text to map authorization and student agree to Terms &Conditions
    app.Application_Authorization__c = mapYesNo(submission.Application_Authorization__c);
    app.Application_Terms_Conditions__c = mapYesNo(submission.Student_Agree__c);
   
    /*
      Contact information
    */
    //app.Country__c = ??
    app.Address_Lines__c = submission.Student_Address__c;
    if (String.isNotEmpty(app.Address_Lines__c) && String.isNotEmpty(submission.Student_Address_2__c)) {
      app.Address_Lines__c += ' ' + submission.Student_Address_2__c;
    }
    app.City__c = submission.Student_City__c;
    app.State__c = (String.isNotEmpty(submission.Student_State__c) ? submission.Student_State__c.toLowerCase().capitalize() : null);
    app.Postal_Code__c = submission.Student_Zip__c;

    app.City_of_Legal_Residence__c = submission.City_of_Legal_Residence__c;
    app.Lived_in_Denver_continuously_past_year__c = submission.Lived_in_Denver_continuously_past_year__c;
    app.Date_Moved_to_Denver__c = Date.parse(submission.Date_Moved_to_Denver__c);
    app.Extended_Absence_from_Denver__c = submission.Extended_Absence_from_Denver__c;
    app.Employed_in_Denver_for_past_year__c = submission.Employed_in_Denver_for_past_year__c;
    app.Registered_to_vote_in_Denver_1_year__c = submission.Registered_to_vote_in_Denver_1_year__c;
    app.Colorado_driver_s_license_or_state_ID__c = submission.Colorado_driver_s_license_or_state_ID__c;
    app.Motor_Vehicle_Registered_in_Denver__c = submission.Motor_Vehicle_Registered_in_Denver__c;
      
    //app.Primary_Email__c = submission.Student_Email__c;
    app.Primary_Email__c = submission.Registration_Email__c;
    app.Alternate_Email__c = submission.Student_Alt_Email__c;
    app.Mobile_Phone__c = submission.Student_Pref_Phone__c;
    app.Alternate_Phone__c = submission.Student_Alt_Phone__c;
    app.OK_to_Text__c = Boolean.valueOf(submission.Student_Pref_Phone_Text__c == 'Yes');

    /*
      College Choice Information
    */
    app.College_Selection__c = submission.Student_College_Attend__c;
	app.College_ID__c = submission.College_ID__c;
    //app.College_Type__c = ??
    //app.High_School_GPA_Waiver_Form__c = ??
    app.Planned_Transfer_from_CC_Tech_to_4_year__c = submission.Student_Transfer_From_Community__c;
    app.College_Transfer_Intention__c = submission.Student_Transfer_To_Com_Yes__c;
    //app.One_Year_Extension_Form_Submitted__c ??

    /*
      Eligibility Information
    */
    if (submission.Application_Type__c == 'new_app') {
      app.Application_Type__c = 'New';
    } else if (submission.Application_Type__c == 'renewal_app') {
      app.Application_Type__c = 'Renewal';
    }
    if (submission.FA_Eligible__c != null) {
      if (this.applydFAEligibleToUSCitizenshipMap.get(submission.FA_Eligible__c) != null) {
        app.US_Citizenship_Status__c = this.applydFAEligibleToUSCitizenshipMap.get(submission.FA_Eligible__c);
      } else {
        app.US_Citizenship_Status__c = submission.FA_Eligible__c;
      }
    }
      
      
    //app.App_Withdrawal_Form_Submitted__c = ??
    if (submission.Student_Scholarship_Name_1__c != null && submission.Student_Scholarship_Name_1__c.contains('Other')) {
      app.Scholarship_Name_1__c = 'Other';
    } else {
      app.Scholarship_Name_1__c = submission.Student_Scholarship_Name_1__c;
    }
    app.Scholarship_Name_1_Other__c = submission.Student_Scholarship_Name_1_Other__c;

    if (submission.Student_Scholarship_Name_2__c != null && submission.Student_Scholarship_Name_2__c.contains('Other')) {
      app.Scholarship_Name_2__c = 'Other';
    } else {
      app.Scholarship_Name_2__c = submission.Student_Scholarship_Name_2__c;
    }
    app.Scholarship_Name_2_Other__c = submission.Student_Scholarship_Name_2_Other__c;

    if (submission.Student_Scholarship_Name_3__c != null && submission.Student_Scholarship_Name_3__c.contains('Other')) {
      app.Scholarship_Name_3__c = 'Other';
    } else {
      app.Scholarship_Name_3__c = submission.Student_Scholarship_Name_3__c;
    }
    app.Scholarship_Name_3_Other__c = submission.Student_Scholarship_Name_3_Other__c;

    if (submission.Student_Support_Program__c != null && submission.Student_Support_Program__c.contains('Other')) {
      app.Student_Support_Program__c = 'Other';
    } else {
      app.Student_Support_Program__c = submission.Student_Support_Program__c;
    }
    app.Student_Support_Program_Other__c = submission.Student_Support_Program_Other__c;
      
      
    //app.Submitted_Part_Time_Preapproval_Form__c = ??
    //app.Scholarship_Recipient__c = ??

    if (submission.Student_College_Attend__c != null && submission.Student_College_Attend__c.contains('My College Is Not Listed')) {
      app.School_Name__c = (this.nonDSFPSI != null ? this.nonDSFPSI.Id : null);
    } else {
      Account matchingCollege = this.collegeNameToAccountMap.get(submission.Student_College_Attend__c);
      if (matchingCollege != null) {
        app.School_Name__c = matchingCollege.Id;
      }
    }

    /*
      Parent Information
    */
    app.Parent_Title__c = submission.Parent_Title__c;
    app.Parent_First_Name__c = submission.Parent_First_Name__c;
    app.Parent_Middle_Name__c = submission.Parent_Middle_Name__c;
    app.Parent_Last_Name__c = submission.Parent_Last_Name__c;
    // TODO: Make sure values match picklist on application
    app.Parent_Suffix__c = submission.Parent_Suffix__c;
    // TODO: investigate to make sure values match picklist
    app.Parent_Gender__c = submission.Parent_Gender__c;
    app.Parent_Relationship_to_Student__c = submission.Parent_Relationship_to_Student__c;

    if (submission.Parent_Same_Address__c == 'Yes') {
      app.Parent_Address_Lines__c = app.Address_Lines__c;
      app.Parent_City__c = app.City__c;
      app.Parent_State__c = app.State__c;
      app.Parent_Postal_Code__c = app.Postal_Code__c;
    } else {
      app.Parent_Address_Lines__c = submission.Parent_Address__c;
      if (String.isNotEmpty(app.Parent_Address_Lines__c) && String.isNotEmpty(submission.Parent_Address_2__c)) {
        app.Parent_Address_Lines__c += ' ' + submission.Parent_Address_2__c;
      }

      app.Parent_City__c = submission.Parent_City__c;
      app.Parent_State__c = (String.isNotEmpty(submission.Parent_State__c) ? submission.Parent_State__c.toLowerCase().capitalize() : null);
      app.Parent_Postal_Code__c = submission.Parent_Zip__c;
    }

    app.Parent_Email__c = submission.Parent_Email__c;
    app.Parent_Mobile_Phone__c = submission.Parent_Pref_Phone__c;
    app.Parent_Alternate_Phone__c = submission.Parent_Alt_Phone__c;

    // TODO: this may need cleansed to a proper picklist value before inserting
    app.Parent_Highest_Education_Level__c = submission.Parent_Ed_Level__c;

    /*
      Additional Application Information
    */
    /*app.Major__c = submission.Student_Major__c;*/ /*Unmap the Major before we set the Sub Major beacuse of dependent Picklist issues*/
    String subMajor= submission.Student_Major__c;
    
    if (subMajor != null){ 
      if (stemmajor.contains(subMajor)){
        app.STEM__c = true;
      }
      else {
        app.STEM__c = false;
      }
    }   //if app.Sub_major
          //use this code to map the major back because the students will enter only Sub major in the application 20-21
        
        system.debug('SubMajor' + subMajor);
                                               
                                              
     if (Agriculturesubmajor.contains(subMajor)){
          app.Major__c = 'Agricultural, Food and Natural Resources';}                                   
      else if(ArchitectureMajor.contains(subMajor)){
          app.Major__c = 'Architecture';}
      else if(AreaEthnicMajor.contains(subMajor)){
          app.Major__c = 'Area, Ethnic, & Multidisciplinary Studies';}
      else if(ArtsMajor.contains(subMajor)){
          app.Major__c = 'Arts: Visual & Performing'; }
      else if (BusinessMajor.contains(subMajor)){
          app.Major__c = 'Business';}
      else if (CommunicationsMajor.contains(subMajor)){
          app.Major__c = 'Communications';}
      else if (CommunityMajor.contains(subMajor)){
          app.Major__c = 'Community, Family, & Personal Services';}
      else if (ComputerMajor.contains(subMajor)){
          app.Major__c = 'Computer Science & Mathematics';}
      else if(EducationMajor.contains(subMajor)){
          app.Major__c = 'Education';}
      else if(Engineeringmajor.contains(subMajor)){
          app.Major__c = 'Engineering'; }
      else if(EngineeringTechnologyMajor.contains(subMajor)){
          app.Major__c = 'Engineering Technology & Drafting' ; }
      else if(LanguageMajor.contains(subMajor)){
          app.Major__c = 'English & Foreign Languages'; }
      else if(HealthAdminMajor.contains(subMajor)){
          app.Major__c = 'Health Administration & Assisting';}
      else if(HealthSciencesMajor.contains(subMajor)){
          app.Major__c = 'Health Sciences & Technologies'; }
      else if(PhilosophyReligionMajor.contains(subMajor)){
          app.Major__c = 'Philosophy, Religion, & Theology';}
      else if(RepairProdMajor.contains(subMajor)){
          app.Major__c = 'Repair, Production, & Construction'; }
      else if(BioScienceMajor.contains(subMajor)){
          app.Major__c = 'Sciences: Biological & Physical'; }
      else if(SocialSciencemajor.contains(subMajor)){
          app.Major__c = 'Social Sciences & Law'; }
      else if(OtherMajor.contains(subMajor)){
          app.Major__c = 'Other'; }
       else {
          app.Major__c = 'Undecided';
      }
      
    /*Map sub Major after Major is set*/     
    app.Sub_Major__c = submission.Student_Major__c;  
    app.Major_Other__c = submission.Major_Other__c;  
    app.Desired_Occupation__c = submission.Student_Occupation_NEW__c;
    app.Other_Desired_Occupation__c = submission.Student_Occupation_NEW_Other__c;
    app.Educational_Aspirations__c = submission.Student_Ed_Level__c;
    app.Have_Children__c = submission.Student_Children__c;
    app.High_School_Name__c = submission.Student_DPS_School__c;
    app.High_School_Name_Other__c = submission.Student_DPS_School_Not_Listed__c;

    app.International_Baccalaureate_in_HS__c = submission.Student_IB_Courses__c;
    app.Concurr_Enrol_or_College_Classes_in_HS__c = submission.Concurr_Enrol_or_College_Classes_in_HS__c;
    app.Honors_Course_in_HS__c = submission.Student_Honors_Courses__c;
    app.AP_Course_in_HS__c = submission.Student_AP_Courses__c;
    app.Participation_in_Trio_college_access__c = submission.Student_Trio_Courses__c;
	app.Attended_Dora_Moore_K8_School__c = submission.Attended_Dora_Moore_K8_School__c;
    app.Participated_in_Girls_Inc__c = submission.Participated_in_Girls_Inc__c;
    app.Participated_in_AVID__c = submission.Participated_in_AVID__c;
    app.Participated_in_CareerConnect__c = submission.Participated_in_CareerConnect__c;
    app.Participated_in_Denver_Kids__c  = submission.Participated_in_Denver_Kids__c;
      
    app.X15_Credit_Hours_Intention__c = submission.X15_Credit_Hours_Intention__c;
    app.X15_Credit_Hours_Term_Intention__c = submission.X15_Credit_Hours_Term_Intention__c;
    app.Interested_in_mentoring__c = submission.Interested_in_mentoring__c;
    app.Interested_in_internships__c = submission.Interested_in_internships__c;

    /*
      Donor Requested Information
    */
    app.Race_Ethnicity__c = submission.Student_Ethnicity__c;
    app.Race_Ethnicity_Other__c = submission.Ethnicity_Other__c;
    app.Religious_Affiliation__c = submission.Student_Religious_Affiliation__c;
    app.Religious_Affiliation_Other__c = submission.Student_Religious_Affiliation_Other__c;
    app.LGBTQIA_community__c = submission.LGBTQIA_community__c;  
    app.ROTC_in_HS_or_College__c = submission.Student_ROTC_in_HS_or_College__c;
    app.Current_Armed_Forces__c = submission.Student_Current_Armed_Forces__c;
    app.Family_member_in_armed_forces_or_veteran__c = submission.Student_Family_Member_Armed_Forces_Vet__c;
    app.Foster_Care__c = submission.Student_Foster_Care__c;
    app.Homeless__c = submission.Student_Homeless__c;
    // TODO: Make sure values match picklist on application
    app.Single_Parent__c = submission.Student_Single_Parent__c;

    app.Application_Submission__c = submission.Id;

    return app;
  }

  private Contact mapContactFields(Application_Submission__c submission, Contact c) {
    // Fields not to overwrite
    //c.FirstName = submission.Student_First_Name__c;
    //c.LastName = submission.Student_Last_Name__c;
    //c.Suffix = submission.Student_Suffix__c;
    //c.Birthdate = Date.parse(submission.Student_DoB__c);
    if (submission.Application_Type__c == 'new_app') {
      c.Social_Security_Number__c = submission.Student_SSN__c;
      c.Race_Ethnicity__c = submission.Student_Ethnicity__c;  //update race/ethnicity only from the first new application
      //update contact.First_generation_Student__c only from new application
	 if (String.isNotEmpty(submission.Parent_Ed_Level__c) &&  ((submission.Parent_Ed_Level__c == 'Less than High School' )|| (submission.Parent_Ed_Level__c == 'High School/GED') ||
                                                               (submission.Parent_Ed_Level__c == 'Certificate') || (submission.Parent_Ed_Level__c == 'Associate Degree'))){
       c.First_Generation_College_Student__c = 'Yes';                                                        
                                                                   
      } 
      else { c.First_Generation_College_Student__c = 'No';
      } 
 
    }
           
      
    c.MailingStreet = submission.Student_Address__c;
    if (String.isNotEmpty(c.MailingStreet) && String.isNotEmpty(submission.Student_Address_2__c)) {
      c.MailingStreet += ' ' + submission.Student_Address_2__c;
    }
    c.MailingCity = submission.Student_City__c;
    c.MailingCountry = 'United States';
    c.MailingState = (submission.Student_State__c != null ? this.stateLowerToStateProperMap.get(submission.Student_State__c.toLowerCase()) : null);
    c.MailingPostalCode = submission.Student_Zip__c;

    c.MobilePhone = submission.Student_Pref_Phone__c;
    c.Phone = submission.Student_Alt_Phone__c;
    c.OK_to_Text__c = Boolean.valueOf(submission.Student_Pref_Phone_Text__c == 'Yes');

    c.Email = submission.Registration_Email__c;
    c.npe01__AlternateEmail__c = submission.Student_Alt_Email__c;

    c.Gender__c = submission.Student_Gender__c;
     
    c.Primary_Language_Spoken_At_Home__c = submission.Student_Language_Home__c;
    //sv -map the preferred first name to contact preferred Name  
    c.Preferred_Name__c = submission.Preferred_First_Name__c;
    c.Preferred_Pronouns__c = submission.Preferred_Pronouns__c;
    c.Preferred_Pronouns_self_identified__c = submission.Preferred_Pronouns_self_identified__c;
    c.Gender_self_identified__c = submission.Gender_Description__c;  
      
    if (submission.FA_Eligible__c != null) {
      if (this.applydFAEligibleToUSCitizenshipMap.get(submission.FA_Eligible__c) != null) {
        c.US_Citizenship_Status__c = this.applydFAEligibleToUSCitizenshipMap.get(submission.FA_Eligible__c);
      } else {
        c.US_Citizenship_Status__c = submission.FA_Eligible__c;
      }
    }

    return c;
  }

  private Application__c mapCCFFormFields(Application_Submission__c submission, Application__c app) {
    //app.College_Selection__c = submission.Student_College_Attend__c;
    //app.College_Type__c = ??
   
      if (submission.Student_College_Attend__c != null && submission.Student_College_Attend__c.contains('My College Is Not Listed')) {
          app.School_Name__c = (this.nonDSFPSI != null ? this.nonDSFPSI.Id : null);
      } else {
          Account matchingCollege = this.collegeNameToAccountMap.get(submission.Student_College_Attend__c);
          if (matchingCollege != null) {
              app.School_Name__c = matchingCollege.Id;
              app.Dev_Ed_Req_Completed_On__c = date.TODAY();  
          }
      }

    app.Planned_Transfer_from_CC_Tech_to_4_year__c = submission.Student_Transfer_From_Community__c;
    app.College_Transfer_Intention__c = submission.Student_Transfer_To_Com_Yes__c;
    return app;
  }

  private Contact mapProfileTypeContactFields(Application_Submission__c submission, Contact c) {
    if (c == null) { return c; }

    Boolean isEmailUpdate = (submission.Is_Email_Update__c != null && submission.Is_Email_Update__c);
    if (isEmailUpdate && String.isNotEmpty(submission.Student_Email__c)) {
      c.Email = submission.Student_Email__c;
    }

    if (String.isNotEmpty(submission.Student_Pref_Phone__c)) {
      c.MobilePhone = submission.Student_Pref_Phone__c;
    }
    if (String.isNotEmpty(submission.Student_Alt_Phone__c)) {
      c.Phone = submission.Student_Alt_Phone__c;
    }
    
    if (String.isNotEmpty(submission.Student_Pref_Phone_Text__c)) {
      c.OK_to_Text__c = Boolean.valueOf(submission.Student_Pref_Phone_Text__c == 'Yes');      
    }

    if (String.isNotEmpty(submission.Student_Address__c)) {
      c.MailingStreet = submission.Student_Address__c;
      if (String.isNotEmpty(c.MailingStreet) && String.isNotEmpty(submission.Student_Address_2__c)) {
        c.MailingStreet += ' ' + submission.Student_Address_2__c;
      }
    }
    if (String.isNotEmpty(submission.Student_City__c)) {
      c.MailingCity = submission.Student_City__c;
    }
    if (String.isNotEmpty(submission.Student_State__c)) {
      c.MailingState = (submission.Student_State__c != null ? this.stateLowerToStateProperMap.get(submission.Student_State__c.toLowerCase()) : null);
    }
    if (String.isNotEmpty(submission.Student_Zip__c)) {
      c.MailingPostalCode = submission.Student_Zip__c;
    }
    c.MailingCountry = 'United States';

    return c;
  }
}