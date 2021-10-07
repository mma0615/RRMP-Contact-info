@ IsTest(SeeAllData = true) public with sharing class LightningLoginFormControllerTest {
    
    @IsTest
	static void testLoginWithInvalidCredentials() {
		System.assertEquals('blank', LightningLoginFormController.login('abc', 'fakepwd', null));
	}

	@IsTest
	static void LightningLoginFormControllerInstantiation() {
		LightningLoginFormController controller = new LightningLoginFormController();
		System.assertNotEquals(controller, null);
	}

	@IsTest
	static void testIsUsernamePasswordEnabled() {
		System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
	}

	@IsTest
	static void testIsSelfRegistrationEnabled() {
		System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
	}

	@IsTest
	static void testGetSelfRegistrationURL() {
		System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
	}

	@IsTest
	static void testAuthConfig() {
		Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
		System.assertNotEquals(null, authConfig);
    }
    
    @IsTest
	static void checkIfUsernameExists() {
		LightningLoginFormController.checkIfUsernameExists('test-dsf@example.com'); 
    }

    @IsTest
	static void setExperienceId() {
		LightningLoginFormController.setExperienceId(''); 
    }

    @IsTest
	static void getForgotPasswordUrl() {
		LightningLoginFormController.getForgotPasswordUrl(); 
    }

    @IsTest
	static void changePassword() {
        

       //wrong reference to hardcoded value of ECHO Error deploying changeset.SV - 4/13 , Changed to use Profile
       //  List<User> usersList = [SELECT Id, Name, Email FROM User WHERE Username LIKE '%echots%' LIMIT 1];
        List<User> usersList = [SELECT Id, Name, Email FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name = 'Customer Community User - STUDENT') AND isActive = true LIMIT 1];
      
        System.runAs(usersList[0]){
            LightningLoginFormController.changePassword('Test123..aa');  
        }

    }

    @IsTest
	static void resetPassword() {
        List<User> testUser = [SELECT Id, Name, Email FROM User WHERE profileId IN (SELECT id FROM Profile WHERE Name = 'Customer Community User - STUDENT') AND isActive = true LIMIT 1];
		LightningLoginFormController.resetPassword(testUser[0].Name);
        //LightningLoginFormController.resetPassword('dev-dsf@echots.com'); 
    } 
}