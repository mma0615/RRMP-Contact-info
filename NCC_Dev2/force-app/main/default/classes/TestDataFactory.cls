public class TestDataFactory {
    public static Compass_Setting__c createCSData(Integer recordCounter) {
        Compass_Setting__c record = new Compass_Setting__c(
            Name 						= 'Default Settings',
            Email_Sender_Name__c 		= 'Default Name',
            Notify_User__c				=  UserInfo.getUserId(),
            Notify_Emails__c			= 'test@gmail.com'
        );
        return record;
    }
    public static Campaign__c createCampaign(Integer recordCounter) {
        Campaign__c record = new Campaign__c(
            Name = 'Test Campaign' + recordCounter
        );
        return record;
    }
    public static Apex_Trigger_Switch__c createTriggerSwitch(String operationName) {
        Apex_Trigger_Switch__c record = new Apex_Trigger_Switch__c(
            Name					= operationName,
            Active__c				= true
        );
        
        return record;
    }
    //update every time a new switch is added
    public static List<Apex_Trigger_Switch__c> createAllTriggerSwitch() {
        List<Apex_Trigger_Switch__c> apexSwitchRecords = new List<Apex_Trigger_Switch__c>();
        apexSwitchRecords.add(TestDataFactory.createTriggerSwitch('EventTrigger'));
        apexSwitchRecords.add(TestDataFactory.createTriggerSwitch('SessionParticipantTrigger'));
         apexSwitchRecords.add(TestDataFactory.createTriggerSwitch('ParticipantTrigger'));
        return apexSwitchRecords;
    }
}