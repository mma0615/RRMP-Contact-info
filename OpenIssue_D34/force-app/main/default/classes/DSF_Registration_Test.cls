/**
 * Created by ahasic on 01/19/2020.
 */
@isTest
public with sharing class DSF_Registration_Test {

    public static testMethod void registration(){
        // Arrange
        Account a = new Account();
        a.Name = 'testAcc';
        insert a;

        Contact c = new Contact();
        c.LastName = 'Last';
        c.accountId = a.Id;
        insert c;

        // Act
        DSF_Registration.registration('fName', 'lName', 'prefName', 'test@echots.com', c.Id, a.Id);

        // Assert 
    }

}