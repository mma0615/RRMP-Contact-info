public class ProjectIssueTriggerHandler extends TriggerHandler{
/*
	protected override void beforeInsert(List<SObject> newRecords) {
		defaultRaisedBy(newRecords);
        populateUrl(newRecords);
	}
    
	protected override void beforeUpdate(Map<Id, SObject> updatedRecordsMap, Map<Id, SObject> oldRecordsMap) {
		defaultRaisedBy(getUpdatedRecordsWithChangedFields(new List<sObjectField>{
			Issue__c.Raised_By_Email__c,
			Issue__c.Raised_By__c
		}));
        populateUrl(updatedRecordsMap.values());
	}
    

	private void defaultRaisedBy(List<Issue__c> newRecords){
		Set<String> emails = new Set<String>();
		for (Issue__c issue : (List<Issue__c>) newRecords){
			emails.add(issue.Raised_By_Email__c);
		}
		
		// Find contacts if it's existing;
		Map<String, Contact> emailContactMap = new Map<String, Contact>();
		for (Contact con : [
			SELECT ID,
			Email
			FROM Contact
			WHERE Email IN :emails
		]){
			emailContactMap.put(con.Email, con);
		}

		// get emails that are not existing as contacts
		Set<String> foundContacts = new Set<String>(emailContactMap.keySet());
		Set<String> newEmails = new Set<String>(emails);
		newEmails.removeAll(foundContacts);

		List<Contact> contactList = new List<Contact>();
		for (String em : newEmails){
			contactList.add(new Contact(Email=em, LastName=Em));
		}

		if (contactList.size() > 0){
			insert contactList;
			for (Contact con : contactList){
				emailcontactMap.put(con.Email, con);
			}
		}

		for (Issue__c issue : (List<Issue__c>) newRecords){
			issue.Raised_By__c = emailContactMap.get(issue.Raised_By_Email__c).Id;
		}
	}
    
    private void populateUrl(List<Issue__c> newRecords){
        Set<Id> evtIds = new Set<Id>();
        for(Issue__c projIssue : newRecords){
            evtIds.add(projIssue.Event__c);
        }
        Map<Id,Event__c> eventMap = new Map<Id,Event__c> ([SELECT Id, OwnerId, Parking_Lot_User__c,Parking_Lot_User__r.Email,Owner.Email,Event_Id__c 
                                                           FROM Event__c 
                                                           WHERE Id IN: evtIds]);
        for(Issue__c projIssue : newRecords){
            projIssue.Issue_Page_URL_c__c =  getCommunityURL('Compass') + '/s/issue-tracker?id=' + eventMap.get(projIssue.Event__c)?.Event_Id__c;
        }
    }
    
     
   private String getCommunityURL(string communityName){
        if (!Test.isRunningTest()){
            Network myNetwork = [SELECT Id FROM Network WHERE Name = :communityName];
            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
            return myCommunity.siteUrl ;
        } else {
            return 'some random url';   
        }
    }
*/ 	
}