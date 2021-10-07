global class CompassSettingController {
    public CompassSettingController(ApexPages.StandardController controller) {
     
    }
    public PageReference constructParams(){
        Compass_Setting__c currentRecord;
        PageReference pageRef = new PageReference('/apex/CompassSettingPage');
        pageRef.setRedirect(true);
        
        try{
            currentRecord = [SELECT Id, Email_Sender_Id__c FROM Compass_Setting__c WHERE Name = 'Default Settings'];
            pageRef.getParameters().put('Id',currentRecord.Id);

        }catch(exception e){
            Compass_Setting__c newRecord = new Compass_Setting__c();
            newRecord.Name = 'Default Settings';
            newRecord.Email_Sender_Name__c = UserInfo.getOrganizationName();
            newRecord.Notify_User__c = UserInfo.getUserId();
            newRecord.Notify_Emails__c =  UserInfo.getUserEmail();
            
            if(newRecord != NULL){
                insert newRecord;
            }
            pageRef.getParameters().put('Id',newRecord.Id);

        }

        if(ApexPages.currentPage().getParameters().get('id') != NULL){
            return NULL;
        }else{
            return pageRef;
            
        }
    }
}