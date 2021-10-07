public without sharing class DSF_MyToDoList {
	@AuraEnabled
	public static FAFSA_Detail__c getFafsaDetail() {

        List<Current_Application_Season__c> currentApplicationSeasons = [SELECT Application_Year__c
                                                                         FROM Current_Application_Season__c 
                                                                         WHERE Name = 'Current Application Year'
                                                                         ORDER BY CreatedDate DESC];

        String academicYear = currentApplicationSeasons != null && currentApplicationSeasons.size() > 0 
                                ? currentApplicationSeasons[0].Application_Year__c : '';                                                 
                                                                         
		System.debug('DSF_MyToDoList::currentApplicationSeasons.size() = ' + currentApplicationSeasons.size());
		System.debug('DSF_MyToDoList::UserInfo.getUserId() = ' + UserInfo.getUserId());

		List<User> listOfUsers = [SELECT Id, ContactId
							      FROM User
							      WHERE Id = :UserInfo.getUserId()];

        User loggedUser = listOfUsers != null && listOfUsers.size() > 0 ? listOfUsers [0] : null;
        
		System.debug('DSF_MyToDoList::academicYear = ' + academicYear);
		System.debug('DSF_MyToDoList::loggedUser = ' + loggedUser);

		if(loggedUser != null && !String.isEmpty(academicYear)) { 
 
			List<FAFSA_Detail__c> fafsaDetails = [SELECT Id, Name, FAFSA_Requirement_Status__c, FAFSA_Completed_Date__c, 
										      FAFSA_Proof_Submission_Date__c, Academic_Year__c
										      FROM FAFSA_Detail__c
										      WHERE Student__c = :loggedUser.ContactId AND Academic_Year__c = :academicYear];

			System.debug('DSF_MyToDoList::studentId = ' + loggedUser.ContactId);
			System.debug('DSF_MyToDoList::academicYear = ' + academicYear);
			System.debug('DSF_MyToDoList::fafsaDetails = ' + fafsaDetails);

            if(fafsaDetails != null && fafsaDetails.size() > 0)
                return fafsaDetails[0]; 
        }
        
        return null;
	}
}