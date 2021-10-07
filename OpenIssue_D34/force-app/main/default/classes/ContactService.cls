public with sharing class ContactService {

  public static List<Contact> setRollupTermEligibilityAndDevEdInformation(List<Contact> contacts) {
    List<Id> contactIds = new List<Id>();
    for (Contact c : contacts) {
      contactIds.add(c.Id);
    }

    Map<Id, List<Application__c>> contactIdToApplicationsMap = new Map<Id, List<Application__c>>();

    List<Application__c> applicationList = [SELECT Id, Student_Name__c, Application_Submission_Year__c, Dev_Ed_Math_Completed__c,Dev_Ed_English_Completed__c,isCurrentApplication__c,Dev_Ed_Req_Complete__c FROM Application__c WHERE Student_Name__c IN :contactIds ORDER BY Application_Submission_Year__c ASC];
    List<Id> applicationIds = new List<Id>();

    for (Application__c app : applicationList) {
      applicationIds.add(app.Id);
      List<Application__c> applications = contactIdToApplicationsMap.get(app.Id);
      if (applications == null) {
        applications = new List<Application__c>();
      }
      applications.add(app);
      contactIdToApplicationsMap.put(app.Student_Name__c, applications);
    }

    Map<Id, Student_Term__c> studentTermMap = new Map<Id, Student_Term__c>([SELECT Id, Application__c, Term_Eligibility_Status__c, isCurrentTerm__c FROM Student_Term__c WHERE Application__c IN :applicationIds]);
    Map<Id, List<Student_Term__c>> appIdToStudentTermsMap = new Map<Id, List<Student_Term__c>>();
    for (Student_Term__c term : studentTermMap.values()) {
      List<Student_Term__c> terms = appIdToStudentTermsMap.get(term.Application__c);
      if (terms == null) {
        terms = new List<Student_Term__c>();
      }
      terms.add(term);
      appIdToStudentTermsMap.put(term.Application__c, terms);
    }

    List<Application__c> appsToUpdate = new List<Application__c>();
    for (Contact c : contacts) {
      List<Application__c> applications = contactIdToApplicationsMap.get(c.Id);

      // Handle setting the Dev_Ed_Req_Completed_within_1st_Year__c field on contact
      ContactPackage pk = rollupDevEdReqWithin1stYear(c, applications);
      c = pk.con;
      if(pk.firstApp != null) {
        appsToUpdate.add(pk.firstApp);
      }
    }
    if(!appsToUpdate.isEmpty()) {
      update appsToUpdate;
    }
    return contacts;
  }

  private static ContactPackage rollupDevEdReqWithin1stYear(Contact c, List<Application__c> apps) {
    ContactPackage pk = new ContactPackage();
    if (apps == null || apps.size() == 0) {
      c.Dev_Ed_Req_Completed_within_1st_Year__c = 'N/A';
      pk.con = c;
      return pk;
    }

    // Assuming applications are ordered ascending by Application_Submission_Year__c
    Application__c firstApplication = apps[0];
    if (c.cohort__c == null || (c.cohort__c != null && Integer.valueOf(c.cohort__r.name) <= 2013)) {
      c.Dev_Ed_Req_Completed_within_1st_Year__c = 'N/A';
      firstApplication.Dev_Ed_Req_Complete__c = 'N/A';
      pk.firstApp = firstApplication;
    }

    if (firstApplication.Dev_Ed_Req_Complete__c == 'Yes') {
      c.Dev_Ed_Req_Completed_within_1st_Year__c = 'Yes';
    } else if(firstApplication.Dev_Ed_Req_Complete__c == null && Integer.valueOf(firstApplication.Application_Submission_Year__c) == Date.today().year()) {
      c.Dev_Ed_Req_Completed_within_1st_Year__c = 'In Progress';
    } else {
      c.Dev_Ed_Req_Completed_within_1st_Year__c = 'No';
    }

    pk.con = c;
    return pk;
  }

  private class ContactPackage {
    public Contact con {get; set;}
    public Application__c firstApp {get; set;}
  }

  public static List<Contact> setRollupEducationInformation(List<Contact> contacts) {
    List<Id> contactIds = new List<Id>();
    for (Contact c : contacts) {
      contactIds.add(c.Id);
    }

    List<Schema.PicklistEntry> gradeEntries = Student_Education_History__c.High_School_Grade__c.getDescribe().getPicklistValues();
    Map<String, Integer> gradeMap = new Map<String, Integer>();
    for (Integer i = 0; i < gradeEntries.size(); i++) {
      gradeMap.put(gradeEntries[i].getValue(), i);
    }

    List<Student_Education_History__c> educationHistoryList = [SELECT Id, Student__c, High_School_Grade__c, High_School_Name__c FROM Student_Education_History__c WHERE Student__c IN :contactIds ORDER BY  Highest_Grade_Achieved__c DESC , Academic_Year__c DESC];
    Map<Id, List<Student_Education_History__c>> contactIdToEducationHistoryMap = new Map<Id, List<Student_Education_History__c>>();
    for (Student_Education_History__c educationHistory : educationHistoryList) {
      List<Student_Education_History__c> historyForContact = contactIdToEducationHistoryMap.get(educationHistory.Student__c);
      if (historyForContact == null) {
        historyForContact = new List<Student_Education_History__c>();
      }
      historyForContact.add(educationHistory);
      contactIdToEducationHistoryMap.put(educationHistory.Student__c, historyForContact);
    }

   /* Map<Id, AggregateResult> maxTermResultsMap = getMaxTermResultsMap(contactIds);*/

    List<Degrees__c> degrees = [SELECT Id, Degree_Type__c, Student__c FROM Degrees__c WHERE Student__c IN :contactIds];
    Map<Id, List<Degrees__c>> contactIdToDegreesMap = new Map<Id, List<Degrees__c>>();
    for (Degrees__c degree : degrees) {
      List<Degrees__c> degreesForContact = contactIdToDegreesMap.get(degree.Student__c);
      if (degreesForContact == null) {
        degreesForContact = new List<Degrees__c>();
      }
      degreesForContact.add(degree);
      contactIdToDegreesMap.put(degree.Student__c, degreesForContact);
    }

    List<Schema.PicklistEntry> degreeEntries = Degrees__c.Degree_Type__c.getDescribe().getPicklistValues();
    Map<String, Integer> degreeMap = new Map<String, Integer>();
    for (Integer i = 0; i < degreeEntries.size(); i++) {
      degreeMap.put(degreeEntries[i].getValue(), i);
    }

    for (Contact c : contacts) {
      List<Student_Education_History__c> contactEduationHistory = contactIdToEducationHistoryMap.get(c.Id);
      // Set last high school attended
      if (contactEduationHistory == null || contactEduationHistory.size() == 0) {
        c.Last_High_School_Attended__c = null;
      } else {
        c.Last_High_School_Attended__c = contactEduationHistory[0].High_School_Name__c;
        /* Last high school should be based on the latest academic year from Student education history records and not on the grade level.
         * Added order by and sorted by academic year desc when pulling the educationHistoryList
         * Students typically can move to a lower grade in a different school if they have not satisfied the credits. Hence commenting this out for now to not check the highest grader to make this decision
          String lastHighSchoolAttended = contactEduationHistory[0].High_School_Name__c;
        Integer lastGradeIndex = gradeMap.get(contactEduationHistory[0].High_School_Grade__c);
        for (Integer i = 1; i < contactEduationHistory.size(); i++) {
          Integer currentGradeIndex = gradeMap.get(contactEduationHistory[i].High_School_Grade__c);
          if (currentGradeIndex > lastGradeIndex) {
            lastHighSchoolAttended = contactEduationHistory[i].High_School_Name__c;
            lastGradeIndex = gradeMap.get(contactEduationHistory[i].High_School_Grade__c);
          }
        }
        c.Last_High_School_Attended__c = lastHighSchoolAttended;*/
          
      }
     
      // Set last college attended-- will no longer be calculating from the student term but will be set from PSI enrollment records , no need to run this everyday as
      //  PSI records are updated only once /twice a year 
   /*   AggregateResult termResult = maxTermResultsMap.get(c.Id);
      c.Last_College_Attended__c = (termResult != null ? (Id)termResult.get('college') : null);*/

      // Set highest degree earned and first degree earned
      List<Degrees__c> contactDegrees = contactIdToDegreesMap.get(c.Id);
      if (contactDegrees == null || contactDegrees.size() == 0) {
        c.Highest_Degree_Earned__c = null;
        c.First_Degree_Earned__c = null;
      } else {
        String highestDegreeEarned = contactDegrees[0].Degree_Type__c;
        Integer highestDegreeEarnedIndex = degreeMap.get(highestDegreeEarned);
        String firstDegreeEarned = contactDegrees[0].Degree_Type__c;
        Integer firstDegreeEarnedIndex = degreeMap.get(firstDegreeEarned);

        for (Integer i = 1; i < contactDegrees.size(); i++) {
          if (degreeMap.get(contactDegrees[i].Degree_Type__c) > highestDegreeEarnedIndex) {
            highestDegreeEarned = contactDegrees[i].Degree_Type__c;
            highestDegreeEarnedIndex = i;
          }

          if (degreeMap.get(contactDegrees[i].Degree_Type__c) < firstDegreeEarnedIndex) {
            firstDegreeEarned = contactDegrees[i].Degree_Type__c;
            firstDegreeEarnedIndex = i;
          }
        }

        c.Highest_Degree_Earned__c = highestDegreeEarned;
        c.First_Degree_Earned__c = firstDegreeEarned;
      }
    }

    return contacts;
  }

  private static Map<Id, AggregateResult> getMaxTermResultsMap(List<Id> contactIds) {
    List<AggregateResult> results = [SELECT MAX(Term_Start_Date__c) maxStartDate,
                                     Application__r.Student_Name__c contactId,
                                     College_or_University__c college
                                     FROM Student_Term__c
                                     WHERE Application__r.Student_Name__c IN :contactIds
                                     GROUP BY Application__r.Student_Name__c, College_or_University__c
                                    ];
    Map<Id, AggregateResult> aggResultMap = new Map<Id, AggregateResult>();
    if (results == null || results.size() == 0) {
      return aggResultMap;
    }

    for (AggregateResult ar : results) {
      aggResultMap.put((Id)ar.get('contactId'), ar);
    }
    return aggResultMap;
  }

/* This method is no longer used as Citizenship is pushed from the current Application now - Kelly Logan, Raptek, 11/28/16
  public static void setCurrentApplicationLawfulPresence(List<Contact> contacts, Map<Id, Contact> oldMap) {
    List<Id> contactIds = new List<Id>();
    for (Contact c : contacts) {
      contactIds.add(c.Id);
    }

    List<Application__c> applicationList = [SELECT Id, Student_Name__c FROM Application__c WHERE Student_Name__c IN :contactIds AND isCurrentApplication__c = TRUE];
    Map<Id, List<Application__c>> contactIdToApplicationsMap = new Map<Id, List<Application__c>>();
    for (Application__c app : applicationList) {
      List<Application__c> applications = contactIdToApplicationsMap.get(app.Student_Name__c);
      if (applications == null) {
        applications = new List<Application__c>();
      }
      applications.add(app);
      contactIdToApplicationsMap.put(app.Student_Name__c, applications);
    }

    List<Application__c> applicationsToUpdate = new List<Application__c>();
    for (Contact c : contacts) {
      List<Application__c> contactApplications = contactIdToApplicationsMap.get(c.Id);
      if (contactApplications != null && contactApplications.size() > 0) {
        // should only have one application
        Application__c app = contactApplications[0];

        if (c.US_Citizenship_Status__c == 'United States Citizen' || c.US_Citizenship_Status__c == 'Legal Permanent Resident') {
          app.Federal_FA_Eligible__c = 'Yes';
          app.Lawful_Presence_Req_Met__c = 'N/A';
          app.Affirmation_Docs__c = 'N/A';
        } else {
          app.Federal_FA_Eligible__c = 'No';
          app.Lawful_Presence_Req_Met__c = 'No';
        }

        applicationsToUpdate.add(app);
      }
    }

    if (applicationsToUpdate.size() > 0) {
      update applicationsToUpdate;
    }
  } */
}