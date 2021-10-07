public with sharing class ApplicationService {
    
    
  //Define the sub majors associated with the Majors
   static list<ApplicationStemMajor__mdt> appmajors = [SELECT Id,STEM_Major__c FROM ApplicationStemMajor__mdt LIMIT 1];
   static String stemmajor = appmajors.size() > 0 && appmajors[0].STEM_Major__c != null ? appmajors[0].STEM_Major__c : null;
   static List<String> Agriculturesubmajor = new List<String>{'Agriculture, General','Agribusiness Operations', 'Agricultural Business & Management' ,'Agricultural Economics',
              								 'Agricultural Mechanization','Agricultural Production','Agronomy & Crop Science','Animal Sciences' ,'Food Sciences & Technology',
              								 'Horticulture Operations & Management','Horticulture Science', 'Natural Resources Conservation, General', 'Environmental Science', 
             								 'Environmental Studies', 'Forestry','Natural Resources Management','Wildlife & Wildlands Management' };
   static List<String> ArchitectureMajor = new List<String>{'Architecture, General', 'Architectural Environmental Design','City/Urban/Regional Planning','Interior Architecture',
              							   'Landscape Architecture'};
                  
   static List<String> AreaEthnicMajor = new List<String>{'Area Studies, General (e.g., African, Middle Eastern)','Asian Area Studies','European Area Studies','Latin American Area Studies',
                      					 'North American Area Studies','Ethnic & Minority Studies, General','African American Studies','American Indian/Native American Studies','Latino/Chicano Studies',
                      					 'Women\'s Studies','Liberal Arts & General Studies', 'Library Science', 'Multi/Interdisciplinary Studies', 'LGBTQ & Gender Studies'};
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
										'Geological Engineering','Geophysical Engineering','Materials Engineering', 'Mining Engineering','Petroleum Engineering','Industrial Engineering','Mechanical Engineering','Nuclear Engineering'};
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
											'Neuroscience','Nuclear Medicine Technology','Respiratory Therapy Technology','Surgical Technology','Medicine (Pre-Medicine)','Nursing, Practical/Vocational (LPN)','Nursing, Registered (BS/RN)',
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
      
// ** Removed from test, not used in Trigger, commented out.
// public static void setApplicationStatus(List<Application__c> appList) {
//    Set<Id> conIds = new Set<Id>();
//    for (Application__c app : appList) {
//      conIds.add(app.Student_Name__c);
//    }
//
//    Map<Id, List<Id>> contactApplicationsMap = new Map<Id, List<Id>>();
//    for (Application__c app : [Select student_name__c, Id From Application__c Where Student_Name__c IN :conIds]) {
//      Id studentId = String.valueOf(app.student_name__c);
//      contactApplicationsMap.put(studentId, new List<Id>());
//      contactApplicationsMap.get(studentId).add(app.Id);
//    }
//    for (Application__c app : appList) {
//      if (contactApplicationsMap.get(app.student_name__c) != null && contactApplicationsMap.get(app.student_name__c).size() > 0) {
//        app.application_type__c = 'Renewal';
//      }
//    }
//  }

  public static void setLawfulPresenceStatus(List<Application__c> applications) {
  
    Summer_Doc_Submission_Date__c summerDocSettings = Summer_Doc_Submission_Date__c.getOrgDefaults();
      
      
//  No longer necessary - US_Citizenship_Status__c is on the app object now - Kelly Logan, Raptek, 9/19/2016
//    Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, US_Citizenship_Status__c FROM Contact WHERE Id IN :contactIds]);
    String cappseason;
    list<Application_Season_Cycle__mdt> appseason = [SELECT Id,Application_Year__c FROM Application_Season_Cycle__mdt LIMIT 1];
    														
    String appyear = appseason.size() > 0 && appseason[0].Application_Year__c != null ? appseason[0].Application_Year__c : null;
    list<ApplicationStemMajor__mdt> appmajors = [SELECT Id,STEM_Major__c FROM ApplicationStemMajor__mdt LIMIT 1];
    String stemmajor = appmajors.size() > 0 && appmajors[0].STEM_Major__c != null ? appmajors[0].STEM_Major__c : null;
     
    for (Application__c app : applications) {
      if(app.isCurrentApplication__c) {

//  No longer necessary - US_Citizenship_Status__c is on the app object now - Kelly Logan, Raptek, 9/19/2016
//        Contact appContact = contactMap.get(app.Student_Name__c);
          
        if (app.US_Citizenship_Status__c != null) {
          if (app.US_Citizenship_Status__c == 'United States Citizen' || app.US_Citizenship_Status__c == 'Legal Permanent Resident'|| app.US_Citizenship_Status__c == 'Have obtained lawful presence in United States as a refugee or asylee') {
            app.Federal_FA_Eligible__c = 'Yes';
            app.Lawful_Presence_Req_Met__c = 'N/A';
            app.Affirmation_Docs__c = 'N/A';

          } else {
            app.Federal_FA_Eligible__c = 'No';

              if (app.Lawful_Presence_Docs__c == 'I-797 Approval Notice' || app.Lawful_Presence_Docs__c == 'Employment Authorization Document' || app.Lawful_Presence_Docs__c == 'Other') {
                  if (app.Lawful_Presence_Proof_Expiration_Date__c >= summerDocSettings.Expiration_Date__c && app.Lawful_Presence_Doc_Submission_Date__c <= summerDocSettings.Expiration_Date__c) {
                      if (app.Affirmation_Docs__c == 'Yes') { 
                          //&& app.Affirmation_Date__c <= summerDocSettings.Expiration_Date__c) //remove app.Affirmation_Date__c as per defect SCR-28 Lawful Presence
                          app.Lawful_Presence_Req_Met__c = 'Yes';
                      }
                  } //if app.lawful_presence_docs__c
              } else {
              app.Lawful_Presence_Req_Met__c = 'No';
            } //else
          }  //else fa_elgible = no loop
        }  //if app.US_Citizenship_Status__c!= null
     }  //if app.iscurrentApplication
       
        
      app.App_Status_Portal_Message__c = '';
          if (app.Application_Status__c == ''){
              app.App_Status_Portal_Message__c = 'You have not started your ' + appyear + ' DSF Scholarship Application.';
          }
          else if (app.Application_Status__c == 'Pending' || app.Application_Status__c == 'Submitted'){
              Switch on app.App_Status_Detail__c{
                  when 'Application in Progress' {
                      app.App_Status_Portal_Message__c  = 'You have not completed your '+ appyear + ' application.';
                  }
                  when 'Application submitted, need FAFSA proof'{
                      app.App_Status_Portal_Message__c = 'You have submitted your ' + appyear + ' application, but we do not have your FAFSA proof. The deadline to complete your ' +  appyear + ' FAFSA is April 1.';
                  }
                  when 'Application is being processed'{
                    app.App_Status_Portal_Message__c = 'Your ' + appyear + ' application has been submitted and is being reviewed by DSF\'s Scholarship Team. Check back in mid-May for your updated status.' ;
                  }
              } //switch
          } //else if
          else if(app.isCurrentApplication__c){
              Switch on app.App_Status_Detail__c{
                  when 'Preliminary Finalist - On track' {
                     app.App_Status_Portal_Message__c = 'You are on track for the DSF Scholarship, but there are additional requirements you must meet to receive a scholarship award. DSF will confirm your high school graduation and final GPA with the Denver Public Schools. Check back in late July for your updated status.';
                   }
                  when 'Alumni'{
                    app.App_Status_Portal_Message__c = 'Congratulations on completing your bachelor\'s degree! Because DSF does not fund coursework beyond a bachelor\'s degree, you are no longer eligible for an award from DSF.';  
                  }
                  when 'Ineligible - Did not Graduate'{
                     app.App_Status_Portal_Message__c = 'You are not eligible for a ' +  appyear + ' DSF Scholarship because Denver Public Schools (DPS) reports that you have not yet graduated from high school. If this is incorrect, contact DSF.';   
                  }
                  when 'Ineligible - GPA < 2.0' {
                      app.App_Status_Portal_Message__c = 'Denver Public Schools (DPS) reported you did not graduate with a cumulative GPA of at least 2.0. Because you did not meet the required minimum GPA, you are not eligible for a DSF Scholarship for ' + appyear + ' or in the future.' ;
                  }
                  when 'Ineligible - GED'{
                      app.App_Status_Portal_Message__c = 'You are not eligible for the DSF Scholarship because you received a GED rather than graduating with a high school diploma.';
                  }
                  when 'Incomplete application'{
                     app.App_Status_Portal_Message__c = 'The ' + appyear +' DSF Scholarship Application is now closed. You are not eligible for a ' + appyear + ' DSF Scholarship because you did not submit a complete application.';
                 }
                 when 'No FAFSA proof' {
                     app.App_Status_Portal_Message__c = 'You are not eligible for a '+ appyear + ' DSF Scholarship because you did not provide proof that you completed the FAFSA by April 1. If you have proof that you submitted your FAFSA by April 1, upload it to DSF by May 20. Head to the Resources tab for more about acceptable proof.';
                 }
                 when 'Late FAFSA'{
                     app.App_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because the FAFSA confirmation you provided shows you did not meet DSF\'s April 1 deadline to complete the FAFSA. If you have proof that you submitted your FAFSA by April 1, upload it to DSF by May 20. Head to the Resources tab for more about acceptable proof.';
                 }
                 when 'Ineligible - App Withdrawn' {
                     app.App_Status_Portal_Message__c = 'You withdrew your ' + appyear + ' DSF Scholarship application, so you will not be considered for a DSF scholarship this year. Check back in early February to re-apply for the next academic year.';
                 }
                 when 'Ineligible - ASCENT'{
                     app.App_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because you are participating in ASCENT. Check back in early February to re-apply for the next academic year.';
                 }
                  when 'Finalist - Did not complete Spring SSRs'{
                      app.App_Status_Portal_Message__c= 'You are not eligible to receive a DSF award for Fall ' + appyear + ' because you did not complete your Student Success Requirements this past Spring. If you continue to meet DSF requirements, you may be eligible for a Spring ' + appyear + ' award.';
                  }
                  when 'Finalist - On track'{
                      app.App_Status_Portal_Message__c = 'You are on track for the DSF Scholarship, but there are additional requirements you must meet to receive a scholarship award. Check back in late July for an update on your status.';
                  }
                  when 'Ineligible - Did not submit LP'{
                      app.App_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because you did not provide current proof of lawful presence in the U.S. by the July 15 deadline. Please contact us with any questions or for more information.';
                  }
                  when 'Ineligible - LP has expired' {
                      app.App_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because the proof of lawful presence you provided was expired on July 15. Please contact us with any questions or for more information.';
                  }
                  when 'Ineligible - Undecided' {
                      app.App_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because you did not finalize your college selection by July 15.';
                  }
                  when 'Ineligible - Non-DSF College'{
                      app.App_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because you told us you will not be attending a DSF college partner.';
                  }
                  when 'Ineligible - Not Planning to Enroll'{
                      app.App_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because you told us you are not planning to enroll in college.';
                  }
                  when 'Ineligible - Timed out at College Selection (Technical College)' {
                      app.App_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because your years of DSF eligibility at a technical college have expired.';
                  }
                  when 'Ineligible - Timed out at College Selection (Community College)' {
                      app.App_Status_Portal_Message__c = 'You are not eligible for a ' + appyear + ' DSF Scholarship because your years of DSF eligibility at a community college have expired.';
                  }
                  when 'Ineligible - GPA below threshold for college selection (Community College)'{
                      app.App_Status_Portal_Message__c = 'Your high school GPA must be 2.5 or higher to be eligible for the DSF scholarship at a community college. Unfortunately, your high school GPA was below 2.5. Head to the Resources tab for more about GPA requirements.';
                  }
                  when 'Ineligible - GPA below threshold for college selection (4-year college)' {
                      app.App_Status_Portal_Message__c = 'Your high school GPA must be 2.75 or higher to be eligible for the DSF scholarship at a 4-year college. Unfortunately, your high school GPA was below 2.75. Head to the Resources tab for more about GPA requirements.';
                  }
                  when 'On track'{
                      app.App_Status_Portal_Message__c = 'You are on track for the DSF Scholarship, but there are additional requirements you must meet to receive a scholarship award. DSF will confirm your financial aid, enrollment, and satisfactory academic progress (SAP) information with your college\'s financial aid office. You do not need to provide any information to DSF. Check back in mid-August to late September for your updated status.';
                  }
              }
          } //else if 
         String subMajor= app.Sub_Major__c;
         if (app.Sub_Major__c != null){ 
           
             if (stemmajor.contains(app.Sub_Major__c)){
                 app.STEM__c = true;
             }
             else {
                 app.STEM__c = false;
             }
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
             
         }  /*if (app.Sub_Major__c != null)*/
       
    } //for loop
  }
    

  public static void setContactCitizenship(map<Id, Application__c> appMap){
    // This method brings in a map of applications, keyed by id and looks for the most current 
    // applications for the related Contact by using an aggregating MAX on the app sub year.
    // 
	
    Map<Id,Contact> contactMap = new Map<Id,Contact>();
    Map<Id,Id> stuIDs = new map<Id,Id>();
    for (Application__c a : appMap.values()) {
     	if (! stuIDs.containsKey(a.Student_Name__c)) 
            stuIDs.put(a.Student_Name__c, a.Student_Name__c);
    }
    Map<Id,String> recentAppMap = new Map<Id,String>();
    AggregateResult[] appAggs = [Select Student_Name__c,
                                 	MAX(Application_Submission_Year__c)maxYear
                                 From Application__c
                                 Where Student_Name__c IN :stuIDs.values()
                                 Group By Student_Name__c
                                  ];
    for (AggregateResult ar : appAggs) {
          recentAppMap.put((Id) ar.get('Student_Name__c'), (String) ar.get('maxYear'));
    } 
      
    for (Application__c app : appMap.values()) {
        System.debug('App Year,Status: ' + app.Application_Submission_Year__c + ',' + app.US_Citizenship_Status__c);
        System.debug('Map Max Year for student: ' + recentAppMap.get(app.Student_Name__c));
        if(recentAppMap.containsKey(app.Student_Name__c))
            if (app.Application_Submission_Year__c == recentAppMap.get(app.Student_Name__c)){
            Contact c = new Contact();
            c.Id = app.Student_Name__c;
           if (app.US_Citizenship_Status__c != null) {
                c.US_Citizenship_Status__c = app.US_Citizenship_Status__c ;
                contactMap.put(app.Student_Name__c, c);
            }
           /*if(app.Application_Type__c == 'New'){*/  /*pass the SSN , Race thnicity and First Gen to the contact only on new app because Approved Submission Mapper will not be used with the new Student portal*/
         /*  c.First_Generation_College_Student__c = app.First_Generation_College_Student__c;
           c.Social_Security_Number__c = app.Social_Security_Number__c;
           c.Race_Ethnicity__c = app.Race_Ethnicity__c;
           contactMap.put(app.Student_Name__c, c);  
            }*/  /*Commenting this out , instead use the batch program to update this one time , based on the New app*/
                
            }
       
    }
    update contactMap.values();
  }      
    
  public class StudentSummary {
    public Student_Term__c st {get; set;}
    public Double totalAward {get; set;}
  }

  public static void calculateUnmetNeed(map<Id, Application__c> appMap) {
    map<Id,StudentSummary> stMap = new map<Id,StudentSummary>();
    for(Student_Term__c st : [SELECT Id,Final_Scholarship_Payment_Amount__c,isCurrentTerm__c,Final_EFC_Upon_FA_File_Completion__c,Application__c,CreatedDate FROM Student_Term__c WHERE Application__c IN :appMap.keySet()]) {
      StudentSummary ss = stMap.get(st.Application__c);
      if(ss == null) {
        ss = new StudentSummary();
        ss.st = st;
        ss.totalAward = 0;
        stMap.put(st.Application__c, ss);
      } if(ss.st.isCurrentTerm__c && ss.st.CreatedDate < st.CreatedDate) {
        ss.st = st;
      }
      if(st.Final_Scholarship_Payment_Amount__c != null) {
         ss.totalAward += st.Final_Scholarship_Payment_Amount__c;
      }
    }
    for(Application__c app : appMap.values()) {
      StudentSummary ss = stMap.get(app.Id);
      if(app.Total_Budget__c != null) {
        Double totalBudget = app.Total_Budget__c == null ? 0 : app.Total_Budget__c;
        Double tuitionFees = app.Tuition_Fees__c == null ? 0 : app.Tuition_Fees__c;
        Double federalGrants = app.Federal_Grants__c == null ? 0 : app.Federal_Grants__c;
        Double stateGrants = app.State_Grants__c == null ? 0 : app.State_Grants__c;
        Double institutionalScholarships = app.Institutional_Scholarships__c == null ? 0 : app.Institutional_Scholarships__c;
        Double otherOutsideScholarships = app.Other_Outside_Scholarships__c == null ? 0 : app.Other_Outside_Scholarships__c;
        Double acceptedWorkstudy = app.Accepted_Workstudy__c == null ? 0 : app.Accepted_Workstudy__c;
        Double acceptedStudentLoans = app.Accepted_Student_Loans__c == null ? 0 : app.Accepted_Student_Loans__c;
        Double otherAidResources = app.Other_Aid_Resources__c == null ? 0 : app.Other_Aid_Resources__c;
        Double finalScholarshipPaymentAmount = ss == null || ss.totalAward == null ? 0 : ss.totalAward;
        Double finalEFCUponFAFileCompletion = ss == null || ss.st.Final_EFC_Upon_FA_File_Completion__c == null ? 0 : ss.st.Final_EFC_Upon_FA_File_Completion__c;
        //Calculate unmet need
        app.Unmet_Need__c = totalBudget - federalGrants - stateGrants - institutionalScholarships - otherOutsideScholarships - acceptedWorkstudy - acceptedStudentLoans - otherAidResources - finalScholarshipPaymentAmount - finalEFCUponFAFileCompletion;
        app.Unmet_Need__c = app.Unmet_Need__c > 0 ? app.Unmet_Need__c : 0;
      } else {
        app.Unmet_Need__c = null;
      }
    }
  }
}