/**
 * Created by Joe on 6/17/2020.
 */

@isTest
public class TestUtility {
    /*   --- Test utility to assist with data setup for test methods
    */
    private static TestUtility self;
    public static TestUtility getInstance() {
        if (self == null) self = new TestUtility();

        return self;
    }

    public list<Contact> createTestStudents(list<Account> accList) {
        Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        list<Contact> objList = new list<Contact>();
        for(integer i = 0; i < accList.size(); i++) {
            Contact obj = new Contact();
            obj.lastName = 'Contact ' + i;
            obj.firstName = 'Test';
            obj.recordTypeId = stRT;
            objList.add(obj);
        }
        insert objList;
        return objList;
    }


    public list<Contact> createTestContacts(list<Account> accList) {
        Id genRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId();
        list<Contact> objList = new list<Contact>();
        for(integer i = 0; i < accList.size(); i++) {
            Contact obj = new Contact();
            obj.lastName = 'Uni User ' + i;
            obj.firstName = 'Test';
            obj.accountId = accList[i].Id;
            obj.recordTypeId = genRT;
            objList.add(obj);
        }
        insert objList;
        return objList;
    }

    public list<Account> createTestAccounts(integer testSize) {
        Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
        list<Account> objList = new list<Account>();
        for(integer i = 0; i < testSize; i++) {
            Account obj = new Account();
            obj.recordTypeId = collRT;
            obj.name = 'Test Account ' + i;
            objList.add(obj);
        }
        insert objList;
        return objList;
    }

    public list<Application__c> createTestApplications(list<Contact> conList, Account anAcct) {
        Id stRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        list<Application__c> objList = new list<Application__c>();
        for(integer i = 0; i < conList.size(); i++) {
            if(conList[i].recordTypeId == stRT) {
                Application__c obj = new Application__c();
                obj.student_name__c = conList[i].Id;
                obj.Mid_Year_Transfer_School__c = anAcct.Id;
                objList.add(obj);
            }
        }
        insert objList;
        return objList;
    }

    public list<Student_Term__c> createTestStudent_Terms(list<Application__c> appList, list<Account> uniList) {
        Id collRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('College/University').getRecordTypeId();
        list<Student_Term__c> objList = new list<Student_Term__c>();
        for(integer i = 0; i < appList.size(); i++) {
            Student_Term__c obj = new Student_Term__c();
            // obj.college_or_university__c = uniList[i].Id;
            obj.college_or_university__c = appList[i].Mid_Year_Transfer_School__c;
            obj.Term_Eligibility_Status__c = 'Finalist';
            obj.Application__c = appList[i].Id;
            obj.term_end_date__c = Date.today()+90;
            obj.Term_Start_Date__c = Date.today()-90;
            obj.Term_Semester__c = Math.mod(i, 2) == 0 ? 'Fall' : 'Spring';
            obj.Has_Student_Completed_4_Year_Degree__c = 'No';
            obj.Program_Enrolled__c = 'Certificate';
            obj.Applied_for_ASSET__c = 'No';
            obj.isCurrentTerm__c = true;
            objList.add(obj);
        }
        insert objList;
        return objList;
    }
}