public without sharing class DSF_Registration {
    
    @AuraEnabled
    public static string registration(String firstName, String lastName, String preferredName, String email, String contactId, String accountId){

            Profile customerPortalManagerProfile = [
                SELECT Id
                FROM Profile
                WHERE Name = :Label.DSF_Active_Portal_Student_Community_Profile_Name
            ]; 

            Contact c = new Contact(Id=contactId);
            c.Email = email;
            c.Preferred_Name__c = preferredName;
            update c;

            User user = new User(
                email = email,
                emailencodingkey = 'UTF-8',
                lastname = lastname,
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                profileid = customerPortalManagerProfile.Id,
                contactId = contactId,
                FirstName = firstname,
                timezonesidkey = 'America/Los_Angeles', // to check if timezone key is the correct one
                username = email,
                CommunityNickname = email.replace('@', '').replace('.', ''),
                Preferred_Name__c = preferredName
            );

            String userId = '';
            if (accountId != null) {
                userId = Site.createExternalUser(user, accountId);
            }
            
            return !String.isEmpty(userId) ? 'User Created Successfully' : 'User Creation Problem';
    }
}