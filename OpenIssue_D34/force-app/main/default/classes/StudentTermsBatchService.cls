global class StudentTermsBatchService implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
	global Map<String, Group> groupMap;
	global Map<String, Map<Id,CommunitiesUserPermissionService.ContactShareMatch>> existingGroupSharingRulesMap;
	global List<ContactShare> csList;

	global static String scheduleBatchJob(String cron) {
    StudentTermsBatchService SC = new StudentTermsBatchService();
    String cron_exp = cron != null ? cron : '0 0 0/1 1/1 * ? *';
    return System.schedule('Student Terms Permissions Batch Job', cron_exp, SC);
  }

  global static void executeBatchOnDemand() {
    StudentTermsBatchService batch = new StudentTermsBatchService();
  	Id batchprocessId = Database.executeBatch(batch, 1000);
  }

	global void execute(SchedulableContext sc) {
    Id batchprocessId = Database.executeBatch(this, 1000);
  }

	global StudentTermsBatchService() {

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		CommunitiesUserPermissionService.userPermissionsForCommunity();
		groupMap = CommunitiesUserPermissionService.getUniversityGroups();
		existingGroupSharingRulesMap = CommunitiesUserPermissionService.getExistingGroupSharingRules(groupMap);
		csList = new List<ContactShare>();
		return Database.getQueryLocator([Select Id, iscurrentterm__c, term_start_date__c, term_end_date__c, application__c, application__r.student_name__c, college_or_university__r.recordtype.name, college_or_university__c From Student_Term__c]);
	}

	global void execute(Database.BatchableContext BC, List<Student_Term__c> scope) {

		for (Student_Term__c st : scope) {
			if (st.college_or_university__c != null && st.college_or_university__r.recordType.name == 'College/University' && groupMap.get('grp_' + st.college_or_university__c) != null) {
				CommunitiesUserPermissionService.ContactShareMatch existingContactSharingRule = null;
				if(existingGroupSharingRulesMap.get(groupMap.get('grp_' + st.college_or_university__c).Id) != null) {
					existingContactSharingRule = existingGroupSharingRulesMap.get(groupMap.get('grp_' + st.college_or_university__c).Id).get(st.application__r.student_name__c);
				}

				if (existingContactSharingRule == null) {
					system.debug('making sharing rule');
					ContactShare cs = new ContactShare();
					cs.contactAccessLevel = 'Edit';
					cs.userOrGroupId = groupMap.get('grp_' + st.college_or_university__c).Id;
					cs.contactId = st.application__r.student_name__c;
					csList.add(cs);
					CommunitiesUserPermissionService.ContactShareMatch csm = new CommunitiesUserPermissionService.ContactShareMatch();
					csm.matchFound = true;
					csm.rule = cs;
					if(existingGroupSharingRulesMap.get(groupMap.get('grp_' + st.college_or_university__c).Id) == null) {
						existingGroupSharingRulesMap.put(groupMap.get('grp_' + st.college_or_university__c).Id, new Map<Id,CommunitiesUserPermissionService.ContactShareMatch>());
					}
					existingGroupSharingRulesMap.get(groupMap.get('grp_' + st.college_or_university__c).Id).put(st.application__r.student_name__c, csm);
				} else {
					existingContactSharingRule.matchFound = true;
					System.debug('Existing Rule ' + existingContactSharingRule);
				}
			} else {
				system.debug('Could not find University group');
			}
		}
		//list<ContactShare> toDelete = new list<ContactShare>();
		//for(Map<Id,CommunitiesUserPermissionService.ContactShareMatch> grp : existingGroupSharingRulesMap.values()) {
		//	for(CommunitiesUserPermissionService.ContactShareMatch csm : grp.values()) {
		//		if(!csm.matchFound && csm.contactShareId != null) {
		//			ContactShare cs = new ContactShare();
		//			cs.Id = csm.contactShareId;
		//			toDelete.add(cs);
		//		}
		//	}
		//}
		//delete toDelete;
	}

	global void finish(Database.BatchableContext BC) {
		System.debug(csList);
		insert csList;
	}
}