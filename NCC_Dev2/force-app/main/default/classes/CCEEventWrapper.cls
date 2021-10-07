public class CCEEventWrapper {
    
    @AuraEnabled
    public String EventExternalId {get; set;}
    @AuraEnabled
    public String HeroUrl {get; set;}
    @AuraEnabled
    public String CampaignLogoUrl {get; set;}
    @AuraEnabled
    public String title {get; set;}

    @AuraEnabled
    public String firstName {get; set;}

    @AuraEnabled
    public String subtitle {get; set;}
    @AuraEnabled
    public Time StartTime {get; set;}
    @AuraEnabled
    public Time EndTime {get; set;}
    @AuraEnabled
    public String Description {get; set;}
    @AuraEnabled
    public String Street {get; set;}
    @AuraEnabled
    public String City {get; set;}
    @AuraEnabled
    public String PostalCode {get; set;}
    @AuraEnabled
    public String State {get; set;}
    @AuraEnabled
    public String Country {get; set;}
    @AuraEnabled
    public String LocationName {get; set;}   
    @AuraEnabled
    public String SurveyId {get; set;}
    @AuraEnabled
    public String contactTag {get; set;}
    @AuraEnabled
    public String contactMessage {get; set;}
    @AuraEnabled
    public List<SessionDetail> SessionList {get; set;}
    @AuraEnabled
    public String StartDateTime {get; set;}
    @AuraEnabled
    public String EndDateTime {get; set;}
    @AuraEnabled
    public String CampaignStatus {get; set;}
    
    
    public class SessionDetail {
        
        @AuraEnabled
        public Boolean isHeader {get; set;}
        @AuraEnabled
        public Id participantSessionId {get; set;}
        @AuraEnabled
        public Boolean isAttended {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String subtitle {get; set;}
        @AuraEnabled
        public String SessionDate {get; set;}
        @AuraEnabled
        public String SessionMonth {get; set;}  
        @AuraEnabled
        public String StartTime {get; set;}
        @AuraEnabled
        public String EndTime {get; set;}
        @AuraEnabled
        public String TimeZone {get; set;}
        
    }
    
}