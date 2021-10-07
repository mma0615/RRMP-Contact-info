/**
 * ContactHandler
 * @author Capgemini GS / Minh Ma (minh.ma@capgemini-gs.com)
 * @date 01/07/2021
 * @description This is a utility class that is used in Contact trigger 
 *
 * Update History:
 * 01/07/2021 - Initial Version
 */
public with sharing class ContactHandler {

    public void onBeforeInsert( List<Contact> newRecordsIn )
    {
        insertCourseToBlackBoard(newRecordsIn);
    }

    public void onBeforeUpdate( List<Contact> newRecordsIn, Map<Id, Contact> oldRecordsMapIn )
    {
        //insertCourseToBlackBoard(newRecordsIn);
    }

    public void onAfterInsert( List<Contact> newRecordsIn )
    {}

    public void onAfterUpdate( List<Contact> newRecordsIn, Map<Id, Contact> oldRecordsMapIn )
    {}

    private void insertCourseToBlackBoard(List<Contact> newRecordsIn)
    {
        for (Contact oContact : newRecordsIn)
        {
            /*
            string apiKey = '0b5eaf067a29e2659a031943d4b05473';
            string requestEndPoint = 'http://api.openweathermap.org/data/2.5/weather';
            requestEndPoint += '?q=' + 'London,uk';
            requestEndPoint += '&APPID=' + apiKey;
    
            Http http = new Http();
            HttpRequest request = new Httprequest();
            request.setEndPoint(requestEndPoint);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            
            // Successfull
            if (response.getStatusCode() == 200) {
                oContact.Blackboard_User_Id__c = 'Updated xxxx';
                }
            else {
                oContact.addError('Rest API call failed. Please contact System administrator...');
            }
            */
            
        }
        
    }
}
