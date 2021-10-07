public class OrgWideAddressEventController {
    Public string orgWideAddress{get;set;}
    Event__c currentRecord;
    public OrgWideAddressEventController(ApexPages.StandardController controller) {
        currentRecord = [SELECT Id, Email_Sender_Id__c,Email_Sender_Name__c FROM Event__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }
    
    Public List<Selectoption> getSelectedOrgWideAddress(){
        List<Selectoption> orgWideIdList = new List<selectoption>();
        orgWideIdList.add(new selectOption('- None -', '- None -'));
        for(OrgWideEmailAddress orgWide :[SELECT id, Address, DisplayName FROM OrgWideEmailAddress]){
            orgWideIdList.add(new selectoption(orgWide.id,orgWide.Address));
        }
        system.debug('orgWideIdList' + orgWideIdList);
        return orgWideIdList; 
    }
    
    public PageReference save() {
        try{
            OrgWideEmailAddress orgWide = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Id =: orgWideAddress];
            currentRecord.Email_Sender_Name__c = orgWide.DisplayName;
            currentRecord.Email_Sender_Id__c = orgWideAddress;
            update currentRecord;
            system.debug('currentRecord' + currentRecord);
        }catch(exception e){
            system.debug('No organization address found');
            
        }
        return null;

        
    }
}