({
    retrieveContactsJourney : function(component, contact_Id) {
        let retrieveContactJourney = component.get("c.getContactJourney");
        retrieveContactJourney.setParams({
            contactId: contact_Id
        });

        retrieveContactJourney.setCallback(this, function (response) {
            let state = response.getState();
            console.log('!@# Return: ' + state);
            if (state === "SUCCESS") {
                let contactJourney = response.getReturnValue();
                console.log('!@# contactJourney: ' + JSON.stringify(contactJourney));
                component.set('v.contactHasJourney', contactJourney.hasJourney);
                component.set('v.JourneyURL', contactJourney.communityURL);
                let sPageURL = decodeURIComponent(window.location.search.substring(1));
                let journeyURL;

                component.set("v.showSpinner", false);
                
                if(contactJourney.journeyId !== undefined){
                    journeyURL = component.get('v.JourneyURL') + '/s/navigator-journey?journeyId='+ contactJourney.journeyId + '&' + sPageURL;
                    location.href = journeyURL;
                }else{
                    component.set('v.listJourney', contactJourney.lstJourney);
                    console.log('!@# lstJourney size : ' + contactJourney.lstJourney.length);
                    let JourneyRecords = [];
                    let journeyList = component.get("v.listJourney");
                    for(let i = 0; i < journeyList.length; i++){
                        console.log('!@# Journey Id: ' + journeyList[i].Id );
                        let jId = journeyList[i].Id;
                        journeyURL = component.get('v.JourneyURL') + '/s/navigator-journey?journeyId='+ jId + '&' + sPageURL;
                        JourneyRecords.push({
                            value: journeyURL,
                            key: journeyList[i].Journey__r.Name
                        });
                        console.log('!@# New URL: ' + journeyURL);

                    }
                    component.set('v.ListJourneyRecords', JourneyRecords);
                }
            }
        });
        $A.enqueueAction(retrieveContactJourney);

    }
})