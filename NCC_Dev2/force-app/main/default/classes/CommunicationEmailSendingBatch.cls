global class CommunicationEmailSendingBatch implements Database.Batchable<sObject>, Schedulable{

	/*
    * Name: start
    * Purpose : To query all the Communication records which will satisfy the following condition:
    * Active_c=true & Status='Outbox' & Frequency__c='Scheduled'
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('start[SEND SCHEDULE COMMS]');
		
        Email_Settings__c settings = Email_Settings__c.getOrgDefaults();
        System.debug('*****settings-->'+settings);
		//query Initial Load 5-1 Condition 1
		String query = '';
		
        //check if email sending in settings is active/enabled
        if(settings.isActive__c){
			//query Initial Load 5-1 Condition 1
			query = EmailUtility.getCreatableFieldsSOQL(String.escapeSingleQuotes('Communication__c'), 'Active__c=true AND Frequency__c=\'Scheduled\' AND Status__c=\'Outbox\'');
			
		}
		System.debug('*****query-->'+query);
		return Database.getQueryLocator(query);
	}
    
    /*
    * Name: execute
    * Purpose : to send an email message based on the Communication__c records that we retrieved from the query
    */ 
    global void execute(Database.BatchableContext BC, List<Communication__c> scope){
        system.debug('execute[SEND SCHEDULE COMMS]');
		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
		//Map<Id, String> buildFailRecordsMessages = new Map<Id, String>();
		List<Communication__c> buildFailRecordsMessages = new List<Communication__c>();
		
        Email_Settings__c settings = Email_Settings__c.getOrgDefaults();
        EmailUtility.settings= settings;
        String orgWideEmailId = null;
        if(settings.Default_Org_Wide_Email_Id__c != null){
			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: settings.Default_Org_Wide_Email_Id__c];
            if ( owea.size() > 0 ) {
          		orgWideEmailId = owea[0].id;
            }
        }
		
		//retrieve Communication_Recipient__c
        Map<Id, List<Communication_Recipient__c>> recipientPerCommsMap = new Map<Id, List<Communication_Recipient__c>>();
        for(Communication_Recipient__c recipient: [SELECT Id, 
            											Journey_Participant__c, 
                                                   		Journey_Participant__r.Contact__c, 
                                                   		Journey_Participant__r.Contact__r.Email,
                                                   		CC_Communication__c
													FROM Communication_Recipient__c
                                                   WHERE CC_Communication__c IN: scope
                                                  ])
        {
			//group each Communication_Recipient__c per CC_Communication__c
            List<Communication_Recipient__c> recipients = new List<Communication_Recipient__c>();
            if(recipientPerCommsMap.containsKey(recipient.CC_Communication__c)){
                recipients = recipientPerCommsMap.get(recipient.CC_Communication__c);
            }
            recipients.add(recipient);
            recipientPerCommsMap.put(recipient.CC_Communication__c, recipients);
        }
		
		//iterate thru scope
        for(Communication__c comm : scope){
            if(comm.Active__c && comm.Frequency__c==EmailUtility.COMM_FREQUENCY_SCHEDULED && comm.Status__c==EmailUtility.COMM_STATUS_OUTBOX){
				//build emailMessages
				Map<String, Object> buildResponse = EmailUtility.buildCommunicationEmailMessage(comm, recipientPerCommsMap, orgWideEmailId);
				if(buildResponse.containsKey('hasError')){
					Boolean hasError = (Boolean)buildResponse.get('hasError');
					if(!hasError){
						Messaging.SingleEmailMessage email = (Messaging.SingleEmailMessage)buildResponse.get('emailMessage');
						emailMessages.add(email);
					}
					else{
						//handling built errors
						List<String> messages = (List<String>)buildResponse.get('messages');
						//buildFailRecordsMessages.put(comm.Id, string.join(messages,','));
						
						DateTime failedDateTime = datetime.now();
						comm.Status__c = EmailUtility.COMM_STATUS_FAILED;//'Failed';
						String statusDetail = failedDateTime.format() 
												+': Email Sending Failed. \n Error/s: ' 
												+string.join(messages,',')+ '\n' 
												+comm.Status_Detail__c;
						comm.Status_Detail__c = statusDetail.length()>=255? (statusDetail.substring(0,250)+'...'): statusDetail;
						buildFailRecordsMessages.add(comm);
					}
				}
			}
		}
		
		//send emailMessage
		Map<String, Object> sendingResponse = null;
        if(!emailMessages.isEmpty()){
			sendingResponse  = EmailUtility.sendEmailMessage_SingleEmailMessage(emailMessages);
        }
		
		//process response
		if(sendingResponse!=null && sendingResponse.containsKey('hasError')){
			Boolean hasError = (Boolean)sendingResponse.get('hasError');
			Set<Id> successIds = new Set<Id>();
			Map<String, Object> failedResults = new Map<String, Object>();
			if(!hasError){
				Map<String, Object> resultMap =(Map<String, Object>)sendingResponse.get('resultMap');
				
				for(String whatId : resultMap.keySet()){
				   Messaging.SendEmailResult result = (Messaging.SendEmailResult)resultMap.get(whatId);
					if(result.isSuccess()){
						successIds.add(whatId);
					}
					else{
						failedResults.put(whatId, result);
					}
				}
			}
			else{
				//overall sending failed
				//error occured
				system.debug('execute[OVERALL SENDING ERROR]-->'+string.join((List<String>)sendingResponse.get('messages'),','));
				//buildFailRecordsMessages.put(comm.Id, string.join(messages,','));
			}
			//post-sending processing
			if(successIds.size()>0){
				Map<String, Object> successDMLResults = EmailUtility.updateSuccessComms(successIds);
			}
			if(failedResults.size()>0){
				Map<String, Object> failedDMLResults = EmailUtility.updateFailedComms(failedResults);
			}
		}
		
		//process build error and overall sending error
		if(buildFailRecordsMessages.size()>0){
			update buildFailRecordsMessages;	
		}
	}
	
	global void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext sc)
    {
        Database.executeBatch(new CommunicationEmailSendingBatch());
    }
}