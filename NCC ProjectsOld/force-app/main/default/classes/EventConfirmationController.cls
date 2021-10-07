/**
@author Jasmine Nguyen
@date 31 August 2020
@group NCC
@description Event Confirmation Template
@revision   Jasmine Nguyen - 05 Septemper: Added helper to abstract some data query from main controller
**/

public with sharing class EventConfirmationController {
    public String campaignMemberId;
    public List<EventConfirmationHelper.SessionWrapper> Sessions;

    public String campaignOwnerId {get;set;} 
    public String campaignId {get;set;}
    public String defined_format {get;set;} 
    public String FormattedDatetime;
    public String startOrEndDate {get; set;}

    public EventConfirmationController(){
    
    }

    public void setcampaignMemberId(String cpMemberId){
        campaignMemberId = cpMemberId;
        if (campaignMemberId != null){
            List<EventConfirmationHelper.SessionWrapper> returnedSessions = EventConfirmationHelper.getSessionsDetails(campaignMemberId); 
            if (returnedSessions.size() > 0) Sessions = returnedSessions;   
        }
    } 

    public String getcampaignMemberId(){
        return campaignMemberId; 
    }

 
	public List<EventConfirmationHelper.SessionWrapper> getSessions() {
		return Sessions;
    }

    // Format event Start Time based on event's owner timezone
    public String getFormattedDatetime() {
        return EventConfirmationHelper.getFormattedDateTimeHelper(campaignOwnerId, campaignId, startOrEndDate, defined_format);
    }
}