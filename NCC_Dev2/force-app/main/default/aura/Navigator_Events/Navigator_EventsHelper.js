({
    retrieveContactsEvent : function(component, contact_Id) {
        let retrieveContactEvents = component.get("c.getContactEvents");
        retrieveContactEvents.setParams({
            contactId: contact_Id,
            strFilter: component.get("v.filter")
        });

        retrieveContactEvents.setCallback(this, function (response) {
            let state = response.getState();

            if (state === "SUCCESS") {
                let contactEvent = response.getReturnValue();
                component.set('v.contactHasEvent', contactEvent.hasEvent);
                component.set('v.EventURL', contactEvent.communityURL);
                let sPageURL = decodeURIComponent(window.location.search.substring(1));
                let eventURL;

                component.set("v.showSpinner", false);
                
                if(contactEvent.eventId !== undefined){
                    eventURL = component.get('v.EventURL') + '/s/navigator-events?id='+ contactEvent.eventId + '&' + sPageURL;
                    location.href = eventURL;
                }else{
                    component.set('v.listEvents', contactEvent.listEvents);
                    let EventRecords = [];
                    let eventList = component.get("v.listEvents");
                    for(let i = 0; i < eventList.length; i++){
                        let eId = eventList[i].Event_Id__c;
                        eventURL = component.get('v.EventURL') + '/s/navigator-events?id='+ eId + '&' + sPageURL;
                        EventRecords.push({
                            value: eventURL,
                            key: eventList[i].Name,
                        });
                    }
                    component.set('v.ListEventRecords', EventRecords);
                }
            }
        });
        $A.enqueueAction(retrieveContactEvents);
    }
})