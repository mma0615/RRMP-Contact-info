@isTest
public class CompassSettingControllerTest {
    @isTest static void testController(){
        List<Compass_Setting__c> compSum = new List<Compass_Setting__c>();
        Compass_Setting__c compRec = TestDataFactory.createCSData(1);
       
        insert compRec;
        system.debug(compRec);
        
        Test.StartTest(); 
        PageReference pageRef = Page.OrgWideAddressPage; 
        //pageRef.getParameters().put('id', String.valueOf(compRec.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(compRec.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(compRec);
        CompassSettingController oc = new CompassSettingController(sc);
        
        oc.constructParams();
        Test.StopTest();

        
    }
    @isTest static void createCompassTest(){
        List<Compass_Setting__c> compSum = new List<Compass_Setting__c>();
        Compass_Setting__c compRec = new Compass_Setting__c(Name = 'Test');
        insert compRec;
        system.debug(compRec);
        
        Test.StartTest(); 
        PageReference pageRef = Page.OrgWideAddressPage; 
        //pageRef.getParameters().put('id', String.valueOf(compRec.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(compRec.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(compRec);
        CompassSettingController oc = new CompassSettingController(sc);
        
        oc.constructParams();
        Test.StopTest();

        
    }
}