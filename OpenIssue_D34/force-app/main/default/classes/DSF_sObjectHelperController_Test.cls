/**
 * Created by ahasic on 10/28/2019.
 */
@isTest
public with sharing class DSF_sObjectHelperController_Test {
	@testSetup public static void setup()
    {
        List<Contact> lstContacts = new List<Contact>();
        for(integer i = 0;i < 20;i++)
        {
            Contact con = new Contact();
            con.LastName = Datetime.now().format() + i;
            lstContacts.add(con);
        }
        
        Contact con = new Contact();
        con.LastName = Datetime.now().format();
        
        DSF_sObjectHelperController.saveSObject(con);
        DSF_sObjectHelperController.savesObjectList(lstContacts);
        
        for(Contact c : lstContacts)
        {
            c.LastName += '_DSF';
        }
        
        DSF_sObjectHelperController.updateObjectList(lstContacts);
    }
    
    public static testMethod void getSelectOptions(){
        // Arrange

        // Act
        List<String> accountSourceOptions = DSF_sObjectHelperController.getSelectOptions(new Account(), 'AccountSource', true, true);

        // Assert
        System.assert(accountSourceOptions.size() > 0, 'We should get list of AccountSource picklist options');
    }

    public static testMethod void getSObject(){
        // Arrange

        // Act
        List<Account> accounts = DSF_sObjectHelperController.getSObject('Account','Id', 'Name!= null','Id',null,0);

        // Assert
    }
}