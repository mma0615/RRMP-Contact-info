public without sharing class DSF_SchoolDetailsController {

    @AuraEnabled
    public static List<Account> getUniversities() { 
        return [SELECT Name FROM Account WHERE RecordType.Name = 'College/University' AND Partner_Status__c = 'Current' order by Name ASC];
    }

    @AuraEnabled
    public static Boolean updateApplication(String applicationId, String newSchoolId) {
        Application__c appl = new Application__c(Id = applicationId);
        appl.School_Name__c = newSchoolId;
        update appl;
        return true;
    }

    @AuraEnabled
    public static Application__c getCurrentApplication() { 

        List<User> listOfUsers = [SELECT Id,ContactId,Contact.Application_Portal_Page_Access__c 
                                  FROM User 
                                  WHERE Id =: UserInfo.getUserId()];
        
        User loggedUser = listOfUsers != null && listOfUsers.size() > 0 ? listOfUsers[0] : null;

        if(loggedUser != null) {

            String currentYear = Label.DSF_App_Season_End_Date.right(4);

            List<Application__c> listOfApplications = [SELECT Id, Name, Student_Name__c, School_Name__r.Name 
                                                       FROM Application__c 
                                                       WHERE Application_Submission_Year__c =: currentYear 
                                                             AND Student_Name__c =: loggedUser.ContactId];

            if(listOfApplications != null && listOfApplications.size() > 0)
                return listOfApplications[0];
        }
        
        return null;
    }
    
}