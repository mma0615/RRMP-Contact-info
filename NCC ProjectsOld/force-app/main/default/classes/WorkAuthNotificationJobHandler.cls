public class WorkAuthNotificationJobHandler {
    
    private static final String AUTH_EMAIL_TEMPLATE_NAME = 'WorkAuthorizationWeeklyEmail';

    public static void sendWorkAuthNotification(){
         List<Krow__Project_Resources__c> projectResources = [SELECT Krow__Active__c, Krow__User__c, Krow__User__r.Email  
                                    FROM Krow__Project_Resources__c 
                                    WHERE Krow__Active__c = true
                                    AND Id IN (SELECT Krow__Project_Resource__c FROM Krow__Task_Assignment__c 
                                                WHERE Krow__Project_Resource__r.Krow__Active__c = true  AND 
                                                      Krow__Project__r.Krow__Project_Status__c NOT IN ('Complete', 'Canceled', 'Pipeline') AND
                                                      Krow__Project__r.ExcludeFromWorkAuthorizationEmail__c != true AND 
                                                      Krow__Project__r.Krow__Archived__c = false AND
                                                      Krow__Status__c NOT IN ('Rejected','Closed'))];
        Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE name = :AUTH_EMAIL_TEMPLATE_NAME ].get(0).Id;
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        for(Krow__Project_Resources__c projectResource : projectResources){
            if(projectResource.Krow__User__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //System.debug('projectResource.Krow__User__c '+projectResource.Krow__User__c);
                mail.setTargetObjectId(projectResource.Krow__User__c); // The ID of the contact, lead, or user to which the email will be sent. 
                mail.setTemplateId(emailTemplateId);
                //mail.toAddresses = new String[] {'jeremy.watso@drakya.com', 'suryansh.gupta@drakya.com'};
                //mail.toAddresses = new String[] {'elaine.dueland@nationalcoordinationcenter.com', 'jeremy.watso@drakya.com'};
                //mail.toAddresses = new String[] {'suryansh.gupta@drakya.com'};
                mail.toAddresses = new String[] {projectResource.Krow__User__r.Email};
                mail.setSaveAsActivity(false);
                mail.setWhatId(projectResource.Id); 
                //mail.setBccSender(false);
                mail.setTreatTargetObjectAsRecipient(false);    
                mailsToSend.add(mail);
            }
        }
        System.debug('mailsToSend '+mailsToSend);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(mailsToSend);
        }
    }
}