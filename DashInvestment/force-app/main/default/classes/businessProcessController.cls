public with sharing class businessProcessController 
{
    @AuraEnabled(cacheable=true)
    public list<Account> getFinancialAccounts(id RecordId) 
    {
        return [
            SELECT AccountId, Id, FirstName, LastName, Title, Phone, Email
            FROM Contact
            WHERE AccountId = :accId
            WITH SECURITY_ENFORCED
        ];
    }

    

}
