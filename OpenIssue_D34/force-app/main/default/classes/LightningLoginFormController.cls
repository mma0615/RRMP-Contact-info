public with sharing class LightningLoginFormController {

    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try {
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return 'blank';
        } catch(Exception e) {
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static boolean resetPassword(String username) {
        return Site.forgotPassword(username); 
    } 
    
    @AuraEnabled
    public static String changePassword(String newPass){
        try {
            System.setPassword(userInfo.getUserid(), newPass);
            return 'success';
        } catch (InvalidParameterValueException e) {
            throw new AuraHandledException(e.getMessage().split(':')[1]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage().split(':')[1]);
        }
    }

    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    public static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    } 
    
    @AuraEnabled
    public static String checkIfUsernameExists(String email){
        List<User> listOfusers = [SELECT Id FROM User WHERE Email =: email];
            
        if(listOfusers != null && listOfusers.size() > 0) 
            return 'Username already exist. Username must be unique.';            

        return 'success';
    }
}