global class NamedScholarshipAssignment implements Database.Batchable<sObject> , Schedulable {
    public static final String CRON_EXP = '0 0 0/1 1/1 * ? *';
    
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select id, name, isCurrentTerm__c, College_or_University__r.Name, Term_year__c, Program_Enrolled__c,Final_Award_Status__c ,Application__r.STEM__c, Application__r.Desired_Occupation__c,Application__r.Application_Submission_Year__c, Application__r.Student_Name__r.AVID_Participant__c, Application__r.Attended_Dora_Moore_K8_School__c, Application__r.Student_Name__r.Cohort__r.Name, Application__r.Student_Name__r.Last_High_School_Attended__r.Name, Application__r.Student_Name__r.MailingPostalCode, Application__r.Major__c, Application__r.Sub_Major__c, Application__r.Student_Name__r.First_Generation_College_Student__c, Application__r.Student_Name__r.Highest_Cumulative_HS_GPA__c, Application__r.Student_Name__r.Gender__c,Application__r.Student_Name__r.US_Citizenship_Status__c , Application__r.Student_name__r.Race_Ethnicity__c  from Student_Term__c where (isCurrentTerm__c = true and Final_Award_Status__c =\'Eligible - Award Calculated\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Student_term__c> scope) {
        
        List<Named_Scholarships__c> nstoupdate = new List<Named_Scholarships__c>();
        
      //Fetch the Student term value from the scope into a set.
        for (Student_Term__c stu:scope){
          
            if (stu.Application__r.Student_name__r.Race_Ethnicity__c == 'Hispanic/Latinx' && stu.Program_Enrolled__c == 'Bachelor\'s'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Alpine Bank Latino-Hispanic Scholarship';
                nstoupdate.add(ns);
            }
            if (stu.College_or_University__r.Name == 'Metropolitan State University of Denver' && stu.Application__r.Student_Name__r.Gender__c == 'Female' 
                && stu.Application__r.Student_Name__r.US_Citizenship_Status__c == 'Have obtained lawful presence through Deferred Action'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Awad Scholarship';
                nstoupdate.add(ns);
            }
            if (stu.Program_Enrolled__c == 'Bachelor\'s' && stu.Application__r.STEM__c){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;              
                ns.Name = 'Ball Corporation Scholarship';
                nstoupdate.add(ns);
            }
           /* if (stu.College_or_University__r.Name == 'Colorado State University'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;                
                ns.Name = 'Joe Blake Scholarship';
                nstoupdate.add(ns);
            }*/
            if (stu.Program_Enrolled__c == 'Associate of Applied Science (AAS)' || stu.Program_Enrolled__c == 'Certificate'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;               
                ns.Name = 'Cielo Scholarship';
                nstoupdate.add(ns);
            }
            if (stu.Application__r.Major__c == 'Health Sciences & Technologies' || stu.Application__r.Major__c == 'Health Administration & Assisting'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;                    
                ns.Name = 'Comfort Dental Scholarship';
                nstoupdate.add(ns);
            }
           /* if (stu.Program_Enrolled__c == 'Associate\'s' || stu.Program_Enrolled__c == 'Certificate' ){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Congdon Scholarship';
                nstoupdate.add(ns);
            }*/
            if ((stu.College_or_University__r.Name == 'Colorado School of Mines' || stu.College_or_University__r.Name == 'Community College of Denver') &&(stu.Program_Enrolled__c == 'Bachelor\'s' || stu.Program_Enrolled__c == 'Certificate') && 
                (stu.Application__r.Major__c == 'Engineering' ||stu.Application__r.Major__c == 'Engineering Technology & Drafting' || stu.Application__r.Major__c == 'Repair, Production, & Construction' || stu.Application__r.STEM__c)){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'CoorsTek Scholarship';
                nstoupdate.add(ns);
            }
            if (stu.Application__r.Major__c == 'Health Sciences & Technologies' || stu.Application__r.Major__c == 'Health Administration & Assisting' ||
               (stu.Application__r.Desired_Occupation__c == 'Dental Assistant' ||stu.Application__r.Desired_Occupation__c == 'Dentist' ||
                stu.Application__r.Desired_Occupation__c == 'Medical Assistant' ||stu.Application__r.Desired_Occupation__c == 'Medical Doctor' ||
                stu.Application__r.Desired_Occupation__c == 'Medical Field' || stu.Application__r.Desired_Occupation__c == 'Nursing' ||
                stu.Application__r.Desired_Occupation__c == 'Pharmacist' || stu.Application__r.Desired_Occupation__c == 'Physical Therapist' ||
                stu.Application__r.Desired_Occupation__c == 'Radiologist')){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'DaVita Scholarship';
                nstoupdate.add(ns);
            }
            if (stu.College_or_University__r.Name == 'Colorado School of Mines' && (stu.Application__r.Major__c == 'Engineering' || stu.Application__r.Sub_Major__c == 'Geological & Earth Sciences')){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Enerplus Scholarship';   
                nstoupdate.add(ns);
            }
            if(stu.Application__r.Student_Name__r.Highest_Cumulative_HS_GPA__c >=3.0){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Omar Gaskin Scholarship';   
                nstoupdate.add(ns);
            }
            if ((stu.Application__r.Student_Name__r.Race_Ethnicity__c != null && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'White' && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Other' &&  stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Prefer Not to Respond' ) &&
                (stu.Application__r.Major__c == 'Engineering'  || stu.Application__r.Sub_Major__c == 'Architectural Environmental Design' || stu.Application__r.Sub_Major__c == 'Landscape Architecture' ||
                stu.Application__r.Sub_Major__c == 'Architectural Engineering' || stu.Application__r.Sub_Major__c == 'Mechanical Engineering')){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Group14 Engineering Scholarship';   
                nstoupdate.add(ns);
            }
            if(stu.Program_Enrolled__c == 'Bachelor\'s' && stu.Application__r.Major__c == 'Arts: Visual & Performing'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Cheryl Harmon Memorial Scholarship for the Arts';   
                nstoupdate.add(ns);  
            }
            if(stu.Application__r.STEM__c) {
            	Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Harvey Family Foundation Scholarship';   
                nstoupdate.add(ns);
            }
            if (( stu.Application__r.Student_Name__r.Race_Ethnicity__c != null && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'White' && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Other' && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Prefer Not to Respond' ) && 
                (stu.Application__r.Major__c == 'Health Sciences & Technologies' || stu.Application__r.Major__c == 'Health Administration & Assisting' ) ||
                (stu.Application__r.Desired_Occupation__c == 'Dental Assistant' ||stu.Application__r.Desired_Occupation__c == 'Dentist' ||
                stu.Application__r.Desired_Occupation__c == 'Medical Assistant' ||stu.Application__r.Desired_Occupation__c == 'Medical Doctor' ||
                stu.Application__r.Desired_Occupation__c == 'Medical Field' || stu.Application__r.Desired_Occupation__c == 'Nursing' ||
                stu.Application__r.Desired_Occupation__c == 'Pharmacist' || stu.Application__r.Desired_Occupation__c == 'Physical Therapist' ||
                stu.Application__r.Desired_Occupation__c == 'Radiologist')){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'HealthOne Scholarship';   
                nstoupdate.add(ns);
            }
            if(stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Manual High School'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Andrew D. Holleman Scholarship';   
                nstoupdate.add(ns);
            }
            /*As per Diane's mail to Natasha , this scholarship is currently on hold and funds will move to the General scholarship 
            if (stu.Application__r.STEM__c || stu.Application__r.Major__c == 'Health Sciences & Technologies' || stu.Application__r.Major__c == 'Health Administration & Assisting' || stu.Application__r.Major__c == 'Education' || stu.Application__r.Sub_major__c == 'Finance, General'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'R. A. Hunt Foundation Scholarship';   //needs work
                nstoupdate.add(ns);
            }*/
            if(stu.Application__r.Student_Name__r.Gender__c == 'Female' &&  (stu.College_or_University__r.Name =='Metropolitan State University of Denver' || stu.College_or_University__r.Name == 'University of Colorado Denver') 
               && (stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'West Leadership Academy' || 
                   stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'West Early College HS' ||
                   stu.Application__r.Student_Name__r.MailingPostalCode == '80204')){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'ID19APRIL1775 Scholarship';   
                nstoupdate.add(ns);  
            }
            if((stu.Program_Enrolled__c == 'Bachelor\'s' || stu.Program_Enrolled__c == 'Associate\'s' ||stu.Program_Enrolled__c == 'Certificate') &&
                (stu.Application__r.STEM__c || stu.Application__r.Major__c == 'Business' || stu.Application__r.Sub_Major__c == 'Economics' || 
                stu.Application__r.Major__c == 'Communications') && stu.Application__r.Student_Name__r.First_Generation_College_Student__c == 'Yes'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Janus Henderson Scholarship';   
                nstoupdate.add(ns);
                   
               } //journalism is a part of the communications major
            
            if (stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'South High School'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Katherine L. MacWilliams Scholarship';   
                nstoupdate.add(ns);
            }
            /*if((stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'George Washington High School' ||
               stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Dr. Martin Luther King Jr. Early College' ||
                stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'CEC Early College' )&&
               (stu.College_or_University__r.Name == 'Adams State University' ||stu.College_or_University__r.Name == 'Colorado State University' ||
                stu.College_or_University__r.Name == 'Community College of Denver')){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Loan and Dan Maas Memorial Scholarship';   
                nstoupdate.add(ns);
                    
                }*/
            if(stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Manual High School'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Lester R. Woodward Memorial Scholarship';   
                nstoupdate.add(ns);
            }
            if((stu.Application__r.Student_Name__r.Gender__c == 'Male' || stu.Application__r.Student_Name__r.Gender__c == 'Non-binary/third gender' ) &&
               ( stu.Application__r.Student_Name__r.Race_Ethnicity__c != null && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'White' && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Other' && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Prefer Not to Respond' ) &&
                (stu.Program_Enrolled__c == 'Bachelor\'s' || stu.Program_Enrolled__c == 'Associate\'s' || stu.Program_Enrolled__c == 'Certificate' )){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Kim Poast Scholarship';   
                nstoupdate.add(ns);
               }
            if((stu.Program_Enrolled__c == 'Bachelor\'s' && (stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'John F. Kennedy High School' ||
               stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Dr. Martin Luther King Jr. Early College' ||
              stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Denver School of Innovation and Sustainable Design')) && 
              (stu.Application__r.Major__c == 'Engineering' || stu.Application__r.Sub_Major__c == 'Physical Sciences, General' ||
               stu.Application__r.Sub_Major__c == 'Geological & Earth Sciences')){
               Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;   
                ns.Name = 'QEP Resources Scholarship';   
                nstoupdate.add(ns);    
               } // for energy submajor use Physical sciences and geological earth sciences
            if(stu.Application__r.Student_Name__r.US_Citizenship_Status__c == 'Have obtained lawful presence through Deferred Action'){
               Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Rana Tarkenton Scholarship';   
                nstoupdate.add(ns);  
                }
            if(stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'South High School' && stu.Application__r.Student_Name__r.AVID_Participant__c >0){
               Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Roth Education Foundation Scholarship';   
                nstoupdate.add(ns);   
            }
            if((stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Abraham Lincoln High School' || 
                stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'North High School')&& 
              (stu.College_or_University__r.Name == 'Metropolitan State University of Denver' || 
               stu.College_or_University__r.Name == 'University of Colorado Denver' ||
               stu.College_or_University__r.Name == 'Community College of Denver')){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;   
                ns.Name = 'Salazar Family Foundation Scholarship';   
                nstoupdate.add(ns);
               }
            if(stu.Application__r.Sub_major__c == 'Mathematics, General' || stu.Application__r.Sub_major__c == 'Applied Mathematics'){
               Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Schierburg Family Scholarship';   
                nstoupdate.add(ns); 
            }
            
            
           /* if(stu.Application__r.Student_Name__r.Race_Ethnicity__c == 'Hispanic/Latinx'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Consulado General de México en Denver Scholarship';   
                nstoupdate.add(ns);
            }*/
            if(stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'East High School'  &&
              (stu.College_or_University__r.Name == 'University of Colorado Boulder' || stu.College_or_University__r.Name == 'University of Colorado Denver' ||
               stu.College_or_University__r.Name == 'Colorado State University') && stu.Program_Enrolled__c == 'Bachelor\'s'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;   
                ns.Name = 'Mitzner/Baumel Family Scholarship';   
                nstoupdate.add(ns);
             }
            if(stu.College_or_University__r.Name == 'Colorado School of Mines' && stu.Application__r.STEM__c){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Newmont Corporation Scholarship';   
                nstoupdate.add(ns);
            }     
            if(stu.Application__r.Attended_Dora_Moore_K8_School__c == 'Yes'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Otten Johnson Robinson Neff + Ragonetti PC Scholarship';   
                nstoupdate.add(ns); 
            }
            if(stu.Program_Enrolled__c == 'Bachelor\'s' && (stu.College_or_University__r.Name != 'Colorado Christian University' || stu.College_or_University__r.Name != 'Regis University')){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Herbert and Judy Paige Family Foundation Scholarship';   
                nstoupdate.add(ns);
            }
            if(stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Thomas Jefferson High School' && 
               stu.College_or_University__r.Name == 'University of Colorado Boulder'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Dick Shahan Scholarship';   
                nstoupdate.add(ns);    
               }
            
            if(stu.Application__r.Student_Name__r.First_Generation_College_Student__c == 'Yes' && stu.Program_Enrolled__c == 'Bachelor\'s'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Stead Family Scholarship';   
                nstoupdate.add(ns);  
            }
                      
            
            if((stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Manual High School'  ||
               stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Bruce Randolph High School') &&
               (stu.Program_Enrolled__c == 'Bachelor\'s' ||stu.Program_Enrolled__c == 'Associate\'s' ||
                stu.Program_Enrolled__c == 'Certificate') && stu.Application__r.STEM__c){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;    
                ns.Name = 'Suncor Scholarship';   
                nstoupdate.add(ns);    
                }
            //should be Freshman , so Cohort Name = Application Submission year
            
             if(stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'George Washington High School' && stu.Program_Enrolled__c == 'Bachelor\'s' &&
                stu.Application__r.Student_Name__r.Cohort__r.Name == stu.Application__r.Application_Submission_Year__c){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;    
                ns.Name = 'Andrew T. Wade Scholarship';   
                nstoupdate.add(ns);    
                }
            
            if(stu.Application__r.Student_Name__r.Gender__c == 'Female' && (stu.Program_Enrolled__c == 'Bachelor\'s' ||
               stu.Program_Enrolled__c == 'Associate\'s' || stu.Program_Enrolled__c == 'Certificate') &&  
               (stu.Application__r.Sub_Major__c == 'Construction Engineering/Management' ||
                stu.Application__r.Sub_Major__c  == 'Construction/Building Technology' ||
                stu.Application__r.Sub_Major__c  ==  'Construction Trades (e.g., carpentry, plumbing, electrical)' ||
               stu.Application__r.Sub_Major__c  == 'Environmental Health Engineering' ||
               stu.Application__r.Sub_Major__c  ==  'Environmental Control Technologies' ||
               stu.Application__r.Sub_Major__c  ==  'Civil Engineering' ||
               stu.Application__r.Sub_Major__c  == 'Civil Engineering Technology' ||
                stu.Application__r.Sub_Major__c  == 'Engineering (Pre-Engineering), General')){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Dennis and Phyllis Washington Foundation Scholarship';   
                nstoupdate.add(ns);    
                }
          
            if(stu.Program_Enrolled__c == 'Bachelor\'s'){
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Connie Burwell White and William W. White Foundation Scholarship';   
                nstoupdate.add(ns);  
            }
           
            if (stu.Application__r.Student_Name__r.Gender__c == 'Female' && stu.Application__r.Student_Name__r.First_Generation_College_Student__c == 'Yes'){
               Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Willow Connery Scholarship';   
                nstoupdate.add(ns); 
            }
            
            if ((stu.Application__r.Student_Name__r.Race_Ethnicity__c != null && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'White' && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Other' &&  stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Prefer Not to Respond' ) &&
               (stu.Program_Enrolled__c == 'Bachelor\'s' ||stu.Program_Enrolled__c == 'Associate\'s' || stu.Program_Enrolled__c == 'Associate of Applied Science (AAS)' ||
                stu.Program_Enrolled__c == 'Bachelor\'s of Applied Science (BAS)') && (stu.Application__r.Sub_major__c == 'Nursing, Practical/Vocational (LPN)' || stu.Application__r.Sub_major__c == 'Nursing, Registered (BS/RN)'))
            {
               Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'AORN Scholarship';   
                nstoupdate.add(ns); 
            }
            
            
           
            if (stu.Application__r.Student_Name__r.Gender__c == 'Female' &&
                (stu.Application__r.Student_Name__r.Race_Ethnicity__c != null && 
                 stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'White' && stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Other' &&  
                 stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Prefer Not to Respond' ))
            {
               Named_Scholarships__c ns = new Named_Scholarships__c();
               ns.Student_Term__c = stu.id;
               ns.Term_Year__c = stu.Term_Year__c;
               ns.Name = 'Chapin Scholarship ANONYMOUS';   
               nstoupdate.add(ns);                                                                 
             }
            
            if ((stu.Program_Enrolled__c == 'Bachelor\'s' ||stu.Program_Enrolled__c == 'Associate\'s' ||
                stu.Program_Enrolled__c == 'Associate of Applied Science (AAS)' ||  stu.Program_Enrolled__c == 'Bachelor\'s of Applied Science (BAS)') &&
                (stu.Application__r.Sub_major__c == 'Culinary Arts/Chef Training' 
                || stu.Application__r.Sub_major__c == 'Food Sciences & Technology' ||
                stu.Application__r.Sub_major__c == 'Food & Nutrition' || stu.Application__r.Sub_major__c == 'Horticulture Operations & Management' || stu.Application__r.Sub_major__c == 'Horticulture Science' || 
                stu.Application__r.Major__c == 'Business' || stu.Application__r.Sub_major__c =='Agribusiness Operations'||
                 stu.Application__r.Sub_major__c == 'Agricultural/Bioengineering' ||
                 stu.Application__r.Sub_major__c == 'Agricultural Business & Management' ||
                 stu.Application__r.Sub_major__c == 'Agricultural Economics' ||
                 stu.Application__r.Sub_major__c == 'Agricultural Education' ||
                 stu.Application__r.Sub_major__c == 'Agricultural Mechanization' ||
                 stu.Application__r.Sub_major__c =='Agricultural Production' ||
                 stu.Application__r.Sub_major__c =='Agriculture, General' ||
                 stu.Application__r.Sub_major__c =='Agronomy & Crop Science'))
                /* stu.Application__r.Sub_major__c.contains('Agri')))*/
             {
               Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Leprino Foods Scholarship';   
                nstoupdate.add(ns); 
            }
            
            //New scholarships added for Spring 2021
            if(stu.Application__r.Student_Name__r.Gender__c == 'Female' &&
              (stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'South High School' ||
                stu.College_or_University__r.Name == 'University of Colorado - Boulder') &&
               (stu.Application__r.Major__c == 'Engineering' ||stu.Application__r.Major__c == 'Engineering Technology & Drafting'||
                stu.Application__r.Major__c == 'Education')){
               Named_Scholarships__c ns = new Named_Scholarships__c();
               ns.Student_Term__c = stu.id;
               ns.Term_Year__c = stu.Term_Year__c;
               ns.Name = 'Frenkel Family Scholarship';   
               nstoupdate.add(ns);     
                    
                }
            if (stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'Bruce Randolph High School'){
              Named_Scholarships__c ns = new Named_Scholarships__c();
               ns.Student_Term__c = stu.id;
               ns.Term_Year__c = stu.Term_Year__c;
               ns.Name = 'Kiewit Meridiam Partners Scholarship';   
               nstoupdate.add(ns);       
                
            }
            if (stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'South High School'){
              Named_Scholarships__c ns = new Named_Scholarships__c();
               ns.Student_Term__c = stu.id;
               ns.Term_Year__c = stu.Term_Year__c;
               ns.Name = 'Lanning Sisters Scholarship';   
               nstoupdate.add(ns);       
                
            }
            
            if ((stu.Application__r.Major__c == 'Health Sciences & Technologies' || stu.Application__r.Major__c == 'Health Administration & Assisting') ||
                 (stu.Application__r.Desired_Occupation__c == 'Medical Doctor' ||
                stu.Application__r.Desired_Occupation__c == 'Medical Field' || stu.Application__r.Desired_Occupation__c == 'Nursing' ||
                stu.Application__r.Desired_Occupation__c == 'Physical Therapist' ||
                stu.Application__r.Desired_Occupation__c == 'Radiologist')
                ){
              Named_Scholarships__c ns = new Named_Scholarships__c();
               ns.Student_Term__c = stu.id;
               ns.Term_Year__c = stu.Term_Year__c;
               ns.Name = 'SCL Health Building Futures in Healthcare Scholarship';   
               nstoupdate.add(ns);       
                
            }
            
            if (stu.Application__r.Student_Name__r.Last_High_School_Attended__r.Name == 'East High School'  || stu.Application__r.Student_name__r.Race_Ethnicity__c == 'Black/African American'){
              Named_Scholarships__c ns = new Named_Scholarships__c();
               ns.Student_Term__c = stu.id;
               ns.Term_Year__c = stu.Term_Year__c;
               ns.Name = 'The Hope Scholarship';   
               nstoupdate.add(ns);       
                
            }
            
                   
            
            if(stu.Application__r.Student_Name__r.Gender__c == 'Female' && (stu.Application__r.Student_Name__r.Race_Ethnicity__c != null ||  
                 stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'White' || stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Other' ||  
                 stu.Application__r.Student_Name__r.Race_Ethnicity__c != 'Prefer Not to Respond') &&
               (stu.Application__r.Sub_Major__c == 'Construction Engineering/Management' || 
                stu.Application__r.Sub_Major__c  == 'Construction/Building Technology' || 
                stu.Application__r.Sub_Major__c  ==  'Construction Trades (e.g., carpentry, plumbing, electrical)' || 
                stu.Application__r.Major__c == 'Repair, Production, & Construction' || 
                stu.Application__r.Sub_Major__c  == 'Sales, Merchandising, & Marketing, General' ||
                stu.Application__r.Major__c == 'Marketing'|| stu.Application__r.Major__c == 'Engineering' ||
                stu.Application__r.Major__c == 'Engineering Technology & Drafting' ||  stu.Application__r.Major__c == 'Management')){
                  Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'VF Foundation Scholarship';
                nstoupdate.add(ns);  
                    
                }   
            
            if (stu.Application__r.Sub_Major__c == 'Natural Resources Conservation, General' || 
                stu.Application__r.Sub_Major__c == 'Natural Resources Management' ||
                stu.Application__r.Sub_Major__c == 'Physical Sciences, General' ||
               stu.Application__r.Sub_Major__c == 'Geological & Earth Sciences'
               ){
                Named_Scholarships__c ns = new Named_Scholarships__c();
               ns.Student_Term__c = stu.id;
               ns.Term_Year__c = stu.Term_Year__c;
               ns.Name = 'Xcel Energy Scholarship';   
               nstoupdate.add(ns);   
                   
               }
            
            //No additional criteria
             Named_Scholarships__c ns6 = new Named_Scholarships__c();
                ns6.Student_Term__c = stu.id;
                ns6.Term_Year__c = stu.Term_Year__c;
                ns6.Name = 'LibertyGives Foundation Scholarship';
                nstoupdate.add(ns6);
            
             Named_Scholarships__c ns7 = new Named_Scholarships__c();
                ns7.Student_Term__c = stu.id;
                ns7.Term_Year__c = stu.Term_Year__c;
                ns7.Name = 'Peter Rynders Memorial Scholarship';
                nstoupdate.add(ns7);
               
            
            //Create these below scholarships for all students as there are no criteria /conditions 
                Named_Scholarships__c ns = new Named_Scholarships__c();
                ns.Student_Term__c = stu.id;
                ns.Term_Year__c = stu.Term_Year__c;
                ns.Name = 'Better Business Bureau Scholarship';
                nstoupdate.add(ns);
            
			    Named_Scholarships__c ns1 = new Named_Scholarships__c();
                ns1.Student_Term__c = stu.id;
                ns1.Term_Year__c = stu.Term_Year__c;
                ns1.Name = 'Virginia Hill Foundation Scholarship';
                nstoupdate.add(ns1);
              
                Named_Scholarships__c ns2 = new Named_Scholarships__c();
                ns2.Student_Term__c = stu.id;
                ns2.Term_Year__c = stu.Term_Year__c;
                ns2.Name = 'Schlessman Family Foundation Scholarship';
                nstoupdate.add(ns2);
            
                
            
                Named_Scholarships__c ns4 = new Named_Scholarships__c();
                ns4.Student_Term__c = stu.id;
                ns4.Term_Year__c = stu.Term_Year__c;
                ns4.Name = 'Wiegers Family Foundation Scholarship';
                nstoupdate.add(ns4);
            
                Named_Scholarships__c ns5 = new Named_Scholarships__c();
                ns5.Student_Term__c = stu.id;
                ns5.Term_Year__c = stu.Term_Year__c;
                ns5.Name = 'Cathey and Richard Finlon Scholarship';
                nstoupdate.add(ns5);
        }
        insert nstoupdate;
        
        system.debug('studenttermlist to update'+ nstoupdate.size());
        
    }
     global void finish(Database.BatchableContext BC){
    }
    global void execute(SchedulableContext sc) {
      Database.executeBatch(this);
  }
}