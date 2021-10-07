({
    doInit : function(component, event, helper) {
        component.set("v.currUserId", $A.get("$SObjectType.CurrentUser.Id"));
    },
    handleContactUpdated : function(component, event, helper) {
        let rawContact = component.get("v.contact");
        let events = [
            {EventName: rawContact.Event_Name_1__c, EventDetails: rawContact.Event_Details_1__c, DateTime: new Date(rawContact.Date_and_Time_01__c), Location: rawContact.Location_1__c},
            {EventName: rawContact.Event_Name_2__c, EventDetails: rawContact.Event_Details_2__c, DateTime: new Date(rawContact.Date_and_Time_02__c), Location: rawContact.Location_2__c},
            {EventName: rawContact.Event_Name_3__c, EventDetails: rawContact.Event_Details_3__c, DateTime: new Date(rawContact.Date_and_Time_03__c), Location: rawContact.Location_3__c}
        ];
        let currentDT = new Date();
        
        events = events.filter(e => e.EventName != null && e.DateTime > currentDT).sort((a, b) => a.DateTime - b.DateTime);

        for (let e in events) {
            let hours = events[e].DateTime.getHours();
            let minutes = events[e].DateTime.getMinutes();
            let ampm = hours > 11 ? 'PM' : 'AM';
            hours = hours % 12;
            hours = hours ? hours : 12;
            minutes = minutes < 10 ? '0' + minutes : minutes;
            let strTime = hours + ':' + minutes + ' ' + ampm;
            events[e].DateTime = events[e].DateTime.toString().substring(0, 16) + strTime;
        }

        component.set("v.eventsList", events);

        component.set("v.isContactLoaded", true);
    },
    handleUserLoaded : function(component, event, helper) {
        let currUser = component.get("v.currUser");
        if (currUser.ContactId == null) {
            component.set("v.isContactLoaded", true);
        }
    }
})