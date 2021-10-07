@isTest
private class ApplydApplicationFetchJob_Test {

  private static ApplydModel.ApplicationsResponse createApplicationsResponse() {
    ApplydModel.ApplicationsResponse res = new ApplydModel.ApplicationsResponse();
    res.status = 'success';
    res.data = new List<ApplydModel.Application>();
    ApplydModel.Application app = new ApplydModel.Application();
    //app.id = '54bef58c216afa17abfb67f5';
    app.created_at = 42180084;
    app.updated_at = 42309443;
    app.user_id = '54bef506216afa02ab74c335';
    app.app_type = 'renewal_app';
    app.school_year = '2015 - 2016';
    app.status = 'exported';
    app.time_submitted = 42180099;
    app.stu_GradHS = '11/2013 or Earlier';
    app.stu_PrevDSFPayment = 'Yes';
    app.stu_PrevApplied = '';
    app.stu_EmailedType = '';
    app.stu_FirstName = 'Savannah';
    app.stu_MiddleName = 'Hope';
    app.stu_LastName = 'Ducharm';
    app.stu_Suffix = '';
    app.stu_DoB = '09/01/1995';
    app.FA_Eligible = 'Are a United States Citizen';
    app.stu_SSN = '000-00-3019';
    app.stu_SSNCheck = '000-00-3019';
    app.stu_Gender = 'Female';
    app.stu_Address = '3161 Madison Ave.';
    app.stu_Address2 = 'Apartment #N101';
    app.stu_City = 'Boulder';
    app.stu_State = 'COLORADO';
    app.stu_Zip = '80303';
    app.stu_Email = 'Sadu2544@colorado.edu';
    app.stu_PrefPhText = '';
    app.stu_PrefPh = '(720) 275-1952';
    app.stu_PrefPhType = 'Cell';
    app.stu_AltPh = '';
    app.stu_AltPhType = '';
    app.stu_Children = 'No';
    app.stu_TransferFromCommunity = '';
    app.stu_TransferToComYes = '';
    app.stu_Major = 'International Relations';
    app.stu_EDLevel = 'Master\'s Degree';
    app.stu_NewVolunteer = 'Yes';
    app.stu_CollegeAttend = 'University of Colorado Boulder';
    app.form_Spanish = '';
    app.stu_Agree = 'Yes';
    app.stu_Sig = 'Savannah Ducharm';
    app.stu_CollegeID = 'collID1';
    app.p_Agree = '';
    app.p_Sig = '';
    res.data.add(app);
    return res;
  }

  @isTest static void testJob() {
    Applyd_API_Settings__c applydAPISettings = new Applyd_API_Settings__c();
    applydAPISettings.Base_API_URL__c = 'https://www.test.test';
    applydAPISettings.API_Key__c = 'testkey';
    applydAPISettings.Application_Last_Checked_Time__c = Date.newInstance(Date.today().year()-1, 12, 1);
    insert applydAPISettings;

    Map<String, String> headers = new Map<String, String>();
    headers.put('Content-Type', 'application/x-json');

    ApplydModel.ApplicationsResponse applicationsResponseData = createApplicationsResponse();
    SingleRequestMock applicationsResponse = new SingleRequestMock(200, 'Complete', JSON.serialize(applicationsResponseData), headers);
    Test.setMock(HttpCalloutMock.class, applicationsResponse);

    Test.startTest();
    ApplydApplicationFetchJob.schedule('Test Applyd Fetch Job', null);
    Test.stopTest();
  }

}