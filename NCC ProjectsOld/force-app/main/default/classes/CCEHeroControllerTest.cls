@isTest 
public class CCEHeroControllerTest {
    
    @isTest private static void getEventDetailsMethod(){
        
        Account newAccount = new Account();
        newAccount.Name = 'Location';
        newAccount.BillingStreet = '222 Lonsdale Street';
        newAccount.BillingCity = 'Melbourne';
        newAccount.BillingPostalCode = '3000';
        newAccount.BillingState = 'VIC';
        newAccount.BillingCountry = 'Australia';
        insert newAccount;
        
        system.debug('--- newAccount ' + newAccount);
        
        Campaign campaignRecord = new Campaign();
        campaignRecord.Event_Id__c = 'kkjdu34301';
        campaignRecord.Name= 'Evendra123';
        campaignRecord.Subtitle__c= 'Evendra123';
        campaignRecord.Hero_Image_URL__c= 'https://www.google.com';
        campaignRecord.Campaign_Logo_URL__c= 'https://www.google.com';
        campaignRecord.Description__c= 'Evendra123';
        campaignRecord.Contact_Us_Tag_Line__c= 'Evendra123';
        campaignRecord.Contact_Us_Message__c= 'Evendra123';
        campaignRecord.Location__c = newAccount.Id;
        campaignRecord.Start_Date_Time__c = DateTime.newInstance(2020, 08, 29, 9, 30, 0);
        campaignRecord.End_Date_Time__c = DateTime.newInstance(2020, 08, 29, 18, 30, 0);
        insert campaignRecord;
        
        system.debug('--- campaignRecord ' + campaignRecord);
        
        Campaign campaignRecord2 =  [SELECT 	Name,
                                     Subtitle__c,
                                     Event_Id__c
                                     FROM Campaign WHERE Id =:campaignRecord.Id];
        
        system.debug('--- campaignRecord2 ' + campaignRecord2);
        
        Test.startTest();
        CCEHeroController.getEventDetails(campaignRecord2.Event_Id__c);
        Test.stopTest();
        
    }
    
    @isTest private static void getEventSessionMethod(){
        
        Account newAccount = new Account();
        newAccount.Name = 'Location';
        newAccount.BillingStreet = '222 Lonsdale Street';
        newAccount.BillingCity = 'Melbourne';
        newAccount.BillingPostalCode = '3000';
        newAccount.BillingState = 'VIC';
        newAccount.BillingCountry = 'Australia';
        insert newAccount;
        
        system.debug('--- newAccount ' + newAccount);
        
        Campaign campaignRecord = new Campaign();
        campaignRecord.Event_Id__c = 'kkjdu34304';
        campaignRecord.Name= 'Evendra123';
        campaignRecord.Subtitle__c= 'Evendra123';
        campaignRecord.Hero_Image_URL__c= 'https://www.google.com';
        campaignRecord.Campaign_Logo_URL__c= 'https://www.google.com';
        campaignRecord.Description__c= 'Evendra123';
        campaignRecord.Contact_Us_Tag_Line__c= 'Evendra123';
        campaignRecord.Contact_Us_Message__c= 'Evendra123';
        campaignRecord.Location__c = newAccount.Id;
        campaignRecord.Start_Date_Time__c = DateTime.newInstance(2020, 08, 29, 9, 30, 0);
        campaignRecord.End_Date_Time__c = DateTime.newInstance(2020, 08, 29, 18, 30, 0);
        insert campaignRecord;
        
        Campaign campaignRecord2 =  [SELECT 	Name,
                                     Subtitle__c,
                                     Event_Id__c
                                     FROM Campaign WHERE Id =:campaignRecord.Id];
        
        Campaign campaignRecord3 = new Campaign();
        campaignRecord3.Event_Id__c = 'kkjdu34305';
        campaignRecord3.ParentId = campaignRecord.Id;
        campaignRecord3.Name= 'Evendra123';
        campaignRecord3.Subtitle__c= 'Evendra123';
        campaignRecord3.Hero_Image_URL__c= 'https://www.google.com';
        campaignRecord3.Campaign_Logo_URL__c= 'https://www.google.com';
        campaignRecord3.Description__c= 'Evendra123';
        campaignRecord3.Contact_Us_Tag_Line__c= 'Evendra123';
        campaignRecord3.Contact_Us_Message__c= 'Evendra123';
        campaignRecord3.Location__c = newAccount.Id;
        campaignRecord3.Start_Date_Time__c = DateTime.newInstance(2020, 08, 29, 9, 30, 0);
        campaignRecord3.End_Date_Time__c = DateTime.newInstance(2020, 08, 29, 18, 30, 0);
        insert campaignRecord3;
        
        Test.startTest();
        CCEHeroController.getEventSession(campaignRecord2.Event_Id__c);
        Test.stopTest(); 
        
    }
    @isTest private static void getSpeakerDetailsMethod(){
        
        Account newAccount = new Account();
        newAccount.Name = 'Location';
        newAccount.BillingStreet = '222 Lonsdale Street';
        newAccount.BillingCity = 'Melbourne';
        newAccount.BillingPostalCode = '3000';
        newAccount.BillingState = 'VIC';
        newAccount.BillingCountry = 'Australia';
        insert newAccount;
        
        Contact newContact = new Contact();
        newContact.FirstName = 'Joe';
        newContact.LastName = 'Joe';
        insert newContact;
        
        
        
        Campaign campaignRecord = new Campaign();
        campaignRecord.Event_Id__c = 'kkjdu34302';
        campaignRecord.Name= 'Evendra123';
        campaignRecord.Subtitle__c= 'Evendra123';
        campaignRecord.Hero_Image_URL__c= 'https://www.google.com';
        campaignRecord.Campaign_Logo_URL__c= 'https://www.google.com';
        campaignRecord.Description__c= 'Evendra123';
        campaignRecord.Contact_Us_Tag_Line__c= 'Evendra123';
        campaignRecord.Contact_Us_Message__c= 'Evendra123';
        campaignRecord.Location__c = newAccount.Id;
        campaignRecord.Start_Date_Time__c = DateTime.newInstance(2020, 08, 29, 9, 30, 0);
        campaignRecord.End_Date_Time__c = DateTime.newInstance(2020, 08, 29, 18, 30, 0);
        insert campaignRecord;
        
        
        Event_Role__c newEventRole = new Event_Role__c();
        newEventRole.Show_in_Event_Site__c = true;
        newEventRole.Role__c = 'Speaker';
        newEventRole.Contact__c = newContact.Id;
        newEventRole.Campaign__c = campaignRecord.Id ;
        insert newEventRole;
        
        Campaign campaignRecord2 =  [SELECT 	Name,
                                     Subtitle__c,
                                     Event_Id__c
                                     FROM Campaign WHERE Id =:campaignRecord.Id];
        
        
        Test.startTest();
        CCEHeroController.getSpeakerDetails(campaignRecord2.Event_Id__c);
        Test.stopTest(); 
        
    }
    
}