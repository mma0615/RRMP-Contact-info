public class ProjectIssueTriggerHandler extends TriggerHandler{

	protected override void beforeInsert(List<SObject> newRecords) {
		defaultRaisedBy(newRecords);
	}
	
	protected override void beforeUpdate(Map<Id, SObject> updatedRecordsMap, Map<Id, SObject> oldRecordsMap) {
		defaultRaisedBy(getUpdatedRecordsWithChangedFields(new List<sObjectField>{
			Project_Issue__c.Raised_By_Email__c,
			Project_Issue__c.Raised_By__c
		}));
	}

	private void defaultRaisedBy(List<Project_Issue__c> newRecords){
		Set<String> emails = new Set<String>();
		for (Project_Issue__c issue : (List<Project_Issue__c>) newRecords){
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

		for (Project_Issue__c issue : (List<Project_Issue__c>) newRecords){
			issue.Raised_By__c = emailContactMap.get(issue.Raised_By_Email__c).Id;
		}
	}
}