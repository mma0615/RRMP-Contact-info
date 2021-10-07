({
    setDefaultMonthDate : function(component, event, helper){
        let today = new Date();
        const currentMonthDate = $A.localizationService.formatDate(today, "MMMM yyyy");
        component.set('v.monthDate', currentMonthDate);
        component.set('v.selectedDate', today);
    },
    
    updateMonthDate : function(component, event, helper, addSubtractMonth){
        component.set('v.isLoading', true);
        let today = new Date();
        // adding or subtracting month
        let selectedDate = component.get('v.selectedDate');
        selectedDate = helper.addMonths(selectedDate, addSubtractMonth);
        if(today.getMonth() === selectedDate.getMonth() && today.getFullYear() === selectedDate.getFullYear()){
            component.set('v.isCurrentMonth', true);
            selectedDate.setDate(today.getDate());
        }
        else{
            component.set('v.isCurrentMonth', false);
            selectedDate.setDate(1);
        }
        component.set('v.selectedDate', selectedDate);

        // displaying month date
        const currentMonthDate = $A.localizationService.formatDate(selectedDate, "MMMM yyyy");
        component.set('v.monthDate', currentMonthDate);

        helper.getEvents(component, event, helper);
    },

    getEvents : function(component, event, helper) {
        let url_string = document.location.href;
        const urlParams = new URLSearchParams(url_string);
        const contactId = urlParams.get('contactId');

        let currDate = component.get('v.selectedDate');
        const year = currDate.getFullYear();
        const month = currDate.getMonth();
        const day = currDate.getDate();
        const currDateObj = {day, month, year, currDate};

        const action = component.get('c.getEventsAndSessions');
        action.setParams({ contactId, month, year });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS'){
                let returnValue = response.getReturnValue();
                helper.displayEventsAndSessions(component, helper, returnValue, currDateObj);
            }
            else{
                helper.showToastError(helper.logError(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    displayEventsAndSessions : function(component, helper, returnValue, currDateObj){
        let events = returnValue;
        let eventsToDisplay = [];

        let today = new Date();
        today.setHours(0,0,0,0);
        if(events){
            currDateObj.currDate.setHours(0,0,0,0);
            const daysInMonth = helper.getDaysInMonth(currDateObj.month, currDateObj.year);
            try{
            // Day Loop
                for(let i=currDateObj.day; i<=daysInMonth; i++){
                    // setup date for the current iteration
                    let iDate = new Date(currDateObj.year, currDateObj.month, i);
                    iDate.setHours(0,0,0,0);
                    let displayDate = $A.localizationService.formatDate(iDate, "dd EEE");
                    let dateString = displayDate.split(' ');
                    let dateNumber = dateString[0];
                    let dayOfTheWeek = dateString[1].toUpperCase();
                    let eventsOfTheDay = [];
                    // Background Color CSS
                    const todayStr = today.getDate() + '/' + today.getMonth() + '/' + today.getFullYear();
                    const iDateStr = iDate.getDate() + '/' + iDate.getMonth() + '/' + iDate.getFullYear();
                    let backgroundColor = todayStr === iDateStr ? 'event-today' : 'event-upcoming';

                    // Event Loop
                    events.forEach(function(eventSessionWrap){
                        let sessions = [];
                            // Session Loop
                            if(eventSessionWrap.sessions && eventSessionWrap.sessions.length){
                                eventSessionWrap.sessions.forEach(function(session){
                                    let sessionStartDate = new Date(session.Start_Date_Time__c);
                                    let sessionEndDate = new Date(session.End_Date_Time__c);
                                    sessionStartDate.setHours(0,0,0,0);
                                    sessionEndDate.setHours(0,0,0,0);

                                    if(sessionStartDate <= iDate && sessionEndDate >= iDate){
                                        session.startTime = helper.formatAMPM(session.Start_Date_Time__c);
                                        session.endTime = helper.formatAMPM(session.End_Date_Time__c);
                                        sessions.push(session);
                                    }
                                });
                                if(sessions.length){
                                    let eventObj = { event : eventSessionWrap.event, sessions };
                                    eventsOfTheDay.push(eventObj);
                                }
                            }
                            else if(eventSessionWrap.isSingleEvent){
                                let eventStartDate = new Date(eventSessionWrap.event.Start_Date_Time__c);
                                let eventEndDate = new Date(eventSessionWrap.event.End_Date_Time__c);
                                eventStartDate.setHours(0,0,0,0);
                                eventEndDate.setHours(0,0,0,0);
                                if(eventStartDate <= iDate && eventEndDate >= iDate){
                                    eventSessionWrap.event.startTime = helper.formatAMPM(eventSessionWrap.event.Start_Date_Time__c);
                                    eventSessionWrap.event.endTime = helper.formatAMPM(eventSessionWrap.event.End_Date_Time__c);
                                    let eventObj = { event : eventSessionWrap.event, sessions : null , isSingleEvent : eventSessionWrap.isSingleEvent };
                                    eventsOfTheDay.push(eventObj);
                                }
                            }
                    });
                    if(eventsOfTheDay.length) eventsToDisplay.push({ dateNumber, dayOfTheWeek, eventsOfTheDay, backgroundColor });
                }
                component.set('v.events', eventsToDisplay);
                component.set('v.isLoading', false);
            }
            catch(e){
                console.log('error: ' + e.message);
            }
        }
    },

    getDaysInMonth : function(month,year) {
       return new Date(year, month, 0).getDate();
    },
    
    addMonths : function(date, months) {
        var d = date.getDate();
        date.setMonth(date.getMonth() + +months);
        if (date.getDate() != d) {
          date.setDate(0);
        }
        return date;
    },

    formatAMPM : function(dateStr) {
        let timeStr = dateStr.split('T')[1];
        let splittedTime = timeStr.split(':');
        let hours = parseInt(splittedTime[0]);
        let minutes = parseInt(splittedTime[1]);
        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0'+minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        return strTime;
    },
      
    showToastError : function(message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type" : "error",
            "message": message
        });
        toastEvent.fire();
    },

    logError : function(errors){
        if (errors) {
            if (errors[0] && errors[0].message) {
                // log the error passed in to AuraHandledException
                let errorMessage = "Error message: " + errors[0].message
                console.log(errorMessage);
                return errorMessage;
            }
            else{
                console.log("Unknown error", JSON.stringify(errors));
                return "Unknown error", JSON.stringify(errors);
            }
        } else {
        	console.log("Unknown error", JSON.stringify(errors));
            return "Unknown error", JSON.stringify(errors);
        }
	},
})