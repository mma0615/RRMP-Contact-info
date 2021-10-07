public without sharing class DSF_MyToDoList_FAFSAProof_Topic {
    @AuraEnabled
    public static String saveFafsa(FAFSA_Detail__c fafsa){
        insert fafsa;
        return fafsa.Id;
    }

    @AuraEnabled
    public static Boolean updateFafsa(FAFSA_Detail__c fafsa){
        update fafsa;
        return true;
    }
}