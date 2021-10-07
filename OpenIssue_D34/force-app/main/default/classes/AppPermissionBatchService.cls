global class AppPermissionBatchService implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    // This class runs the process of creating Application-based permissions, to give College Partners the permission
    //  to see students for their colleges based on applications rather than student terms. This allows partners to
    //   see students with applications for future attendanced.
	global Map<String, Group> groupMap;
	global Map<String, Map<Id,CommunitiesUserPermissionService.ContactShareMatch>> existingGroupSharingRulesMap;
	global List<ContactShare> csList;

  global static String scheduleBatchJob(String cron) {
    AppPermissionBatchService SC = new AppPermissionBatchService();
    String cron_exp = cron != null ? cron : '0 0 0/1 1/1 * ? *';
    return System.schedule('Application based Permissions Batch Job', cron_exp, SC);
  }

  global static void executeBatchOnDemand(Integer batchSize) {
    AppPermissionBatchService batch = new AppPermissionBatchService();
  	Id batchprocessId = Database.executeBatch(batch, batchSize);
  }
    

	global void execute(SchedulableContext sc) {
    Id batchprocessId = Database.executeBatch(this, 10000);
  }

	global AppPermissionBatchService() {

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		CommunitiesUserPermissionService.userPermissionsForCommunity();
		groupMap = CommunitiesUserPermissionService.getUniversityGroups();
		existingGroupSharingRulesMap = CommunitiesUserPermissionService.getExistingGroupSharingRules(groupMap);
		csList = new List<ContactShare>();
        if (Test.isRunningTest()) return Database.getQueryLocator([Select Id, student_name__c, School_Name__c, Mid_Year_Transfer_School__c,
                                         Mid_Year_Transfer_Status__c,Application_Submission_Year__c,
                                         School_Name__r.recordtype.name,
                                         Mid_Year_Transfer_School__r.recordtype.name
                                       	From Application__c
                                        Where student_name__r.LastName LIKE 'AppPermContact%' AND 
                                         student_name__r.FirstName LIKE 'Test' AND 
                                         ((School_Name__c != null AND 
                                               School_Name__r.recordtype.name LIKE 'College/University') OR
                                         	(Mid_Year_Transfer_School__c != null AND 
                                               Mid_Year_Transfer_Status__c like 'Approved' AND
                                               Mid_Year_Transfer_School__r.recordtype.name LIKE 'College/University'))
                                        ]);
        else return Database.getQueryLocator([Select Id, student_name__c, School_Name__c, Mid_Year_Transfer_School__c,
                                         Mid_Year_Transfer_Status__c, Application_Submission_Year__c,
                                         School_Name__r.recordtype.name,
                                         Mid_Year_Transfer_School__r.recordtype.name
                                       	From Application__c
                                        Where ((School_Name__c != null AND 
                                               School_Name__r.recordtype.name LIKE 'College/University') OR
                                         	(Mid_Year_Transfer_School__c != null AND 
                                               Mid_Year_Transfer_Status__c like 'Approved' AND
                                               Mid_Year_Transfer_School__r.recordtype.name LIKE 'College/University'))
                                        ]);

	}

    global void checkCollege(ID college,ID studentID){
        CommunitiesUserPermissionService.ContactShareMatch existingContactSharingRule = null;
        if(existingGroupSharingRulesMap.get(groupMap.get('grp_' + college).Id) != null) {
            existingContactSharingRule = existingGroupSharingRulesMap.get(groupMap.get('grp_' + college).Id).get(studentID);
        }
        
        if (existingContactSharingRule == null) {
            system.debug('making sharing rule');
            ContactShare cs = new ContactShare();
            cs.contactAccessLevel = 'Edit';
            cs.userOrGroupId = groupMap.get('grp_' + college).Id;
            cs.contactId = studentID;
            csList.add(cs);
            CommunitiesUserPermissionService.ContactShareMatch csm = new CommunitiesUserPermissionService.ContactShareMatch();
            csm.matchFound = true;
            csm.rule = cs;
            if(existingGroupSharingRulesMap.get(groupMap.get('grp_' + college).Id) == null) {
                existingGroupSharingRulesMap.put(groupMap.get('grp_' + college).Id, new Map<Id,CommunitiesUserPermissionService.ContactShareMatch>());
            }
            existingGroupSharingRulesMap.get(groupMap.get('grp_' + college).Id).put(studentID, csm);
        } else {
            existingContactSharingRule.matchFound = true;
            System.debug('Existing Rule ' + existingContactSharingRule);
        }
    }
         
	global void execute(Database.BatchableContext BC, List<Application__c> scope) {
		for (Application__c ap : scope) {
            // check school_name and Mid_Year_transfer, each calling the same method.
            // 
            System.debug('School Name: '+ap.School_Name__c+', groupMap get result: '+groupMap.get('grp_' + ap.School_Name__c));
			if (ap.School_Name__c != null && groupMap.get('grp_' + ap.School_Name__c) != null) {
				checkCollege(ap.School_Name__c,ap.student_name__c);
			}
            System.debug('School Name: '+ap.Mid_Year_Transfer_School__c+', groupMap get result: '+
                         groupMap.get('grp_' + ap.Mid_Year_Transfer_School__c));
			if (ap.Mid_Year_Transfer_School__c != null && ap.Mid_Year_Transfer_Status__c == 'Approved' && 
              groupMap.get('grp_' + ap.Mid_Year_Transfer_School__c) != null) {
				checkCollege(ap.Mid_Year_Transfer_School__c,ap.student_name__c);
			}
            
		}
        system.debug('cslist' +  csList);
        if (!csList.isEmpty()) insert csList;
        cslist.clear();
        
	}

	global void finish(Database.BatchableContext BC) {
		//System.debug(csList);
		//if (! csList.isEmpty()) insert csList;
	}

}