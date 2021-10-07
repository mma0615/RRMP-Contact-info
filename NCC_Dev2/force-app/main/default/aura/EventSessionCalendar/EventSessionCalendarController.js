({
    created : function(component, event, helper) {
        helper.created(component, event);
    },
    
    renderCalendar : function(component, event, helper) {
        
        helper.pullRecId(component, event);
        
        var eventsMap = component.get("v.events");
        $(document).ready(function(){
            var eventArray = [];
            $.each(eventsMap, function(index, value){
                if(component.get('v.eventRecId') == null){
                    component.set('v.eventRecId', value.eventRecId);
                }
                
                console.log('Event: ' + value.title + ' ' + moment(value.startDateTime).format() + "|" + value.startDateTime);
                
                var newEvent = {
                    id : value.Id,
                    trueTitle : value.title,
                    status : value.status,
                    location: value.location,
                    title : value.title + ' | ' + value.status,
                    //start : moment(value.startDateTime).format(),
                    start: moment(value.startDateTime).add(-4, 'hours').utc().format(),
                    //end : moment(value.endDateTime).format(),
                    end : moment(value.endDateTime).add(-4, 'hours').utc().format(),
                    description : value.description,
                    owner : value.owner
                }
                eventArray.push(newEvent);
            });
            var calendarButtons = component.get('v.calendarButtons');
            $('#calendar').fullCalendar({
                header: {
                    left: 'today prev,next',
                    center: 'title',
                    right: calendarButtons
                },
                defaultDate: component.get('v.defaultDate'),
                navLinks: true, // can click day/week names to navigate views
                editable: true,
                eventLimit: true, // allow "more" link when too many events
                weekends: component.get('v.weekends'),
                eventBackgroundColor: component.get('v.eventBackgroundColor'),
                eventBorderColor: component.get('v.eventBorderColor'),
                eventTextColor: component.get('v.eventTextColor'),
                events: eventArray,
                //initialDate: '2018-06-01',
                timezone: 'PST',
                eventClick: function(calEvent, jsEvent, view) {
                    
                    component.set('v.locationVal', '');
                    component.set('v.titleVal', calEvent.trueTitle);
                    component.set('v.descriptionVal', calEvent.description);
                    component.set('v.startDateTimeVal', moment(calEvent.start._d).format());
                    component.set('v.endDateTimeVal', moment(calEvent.end._d).format());
                    component.set('v.idVal', calEvent.id);
                    component.set('v.newOrEdit', 'Edit');
                    component.set('v.titleDisabled', true);
                    component.set('v.locationVal', calEvent.location);
                    helper.openModal(component, event);
                },
                
                eventMouseover: function(event, jsEvent, view){
					if(event.title.includes("| Approved")){
                        event.editable = false;
                        event.resourceEditable = false;
                    }
                },
                
                /*eventMouseout: function(calEvent, jsEvent, view){
                    //alert('Mouse Leave');
                   //component.set("v.isOpen", false);
                }, */
                
                /*eventDragStart: function(event, jsEvent, view){
                    if(event.title.includes("| Approved")){
                        event.editable = false;
                        event.resourceEditable = false; 
                    }
                },*/
                
                eventDrop: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        //"startDateTime" : moment(event.start._i).add(delta).format(),
                        //"endDateTime" : moment(event.end._i).add(delta).format(),
                        "startDateTime" : moment(event.start._i).add(4, 'hours').add(delta).format(),
                        "endDateTime" : moment(event.end._i).add(4, 'hours').add(delta).format(),
                        "description" : event.description,
                        "location" : event.location
                    };
                    helper.upsertEvent(component, evObj);
                },
                eventResize: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        //"startDateTime" : moment(event.start._i).format(),
                        //"endDateTime" : moment(event.end._i).add(delta).format(),
                        "startDateTime" : moment(event.start._i).add(4, 'hours').format(),
                        "endDateTime" : moment(event.end._i).add(4, 'hours').add(delta).format(),
                        "description" : event.description
                    };
                    console.log(evObj.startDateTime);
                    console.log(evObj.endDateTime);
                    helper.upsertEvent(component, evObj);
                },
                dayClick: function(date, jsEvent, view) {
                    component.set('v.idVal', null),
                    component.set('v.titleVal', '');
                    component.set('v.locationVal', '');
                    component.set('v.titleDisabled', false);
                    if (date._f == "YYYY-MM-DD"){
                        //component.set('v.startDateTimeVal', moment(date).format());
                        //component.set('v.endDateTimeVal', moment(date).format());
                        component.set('v.startDateTimeVal', date.format() + 'T00:00:00');
                        component.set('v.endDateTimeVal', date.format()  + 'T02:00');
                    } else {
                        //component.set('v.startDateTimeVal', moment(date.format()).format());
                        //component.set('v.endDateTimeVal', moment(date.format()).add(2, 'hours').format());
                        component.set('v.startDateTimeVal', date.utc().format());
                        component.set('v.endDateTimeVal', date.add(2, 'hours').utc().format());
                    }
                    component.set('v.newOrEdit', 'New');
                    helper.openModal(component, event);
                }
            });
        });
    },
  
    createRecord : function(component, event, helper) {
        var evObj = {
            "title" : component.get('v.titleVal'),
            //"startDateTime" : moment(component.get('v.startDateTimeVal')).format(),
            //"endDateTime" : moment(component.get('v.endDateTimeVal')).format(),
            "startDateTime" : moment(component.get('v.startDateTimeVal')).add(4, 'hours').format(),
            "endDateTime" : moment(component.get('v.endDateTimeVal')).add(4, 'hours').format(),
            "description" : component.get('v.descriptionVal'),
            "location" : component.get('v.locationVal')
        };
        if (component.get('v.idVal')) {
            evObj.id = component.get('v.idVal');
            $('#calendar').fullCalendar( 'removeEvents', component.get('v.idVal') );
        }
        if(evObj.id == null){
            helper.insertEvent(component, evObj, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.saveAndRefresh(component, evObj);
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
        }else{
            helper.upsertEvent(component, evObj, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.saveAndRefresh(component, evObj);
                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
        }

    },
    deleteRecord : function(component, event, helper) {
        helper.deleteEvent(component, event, event.getSource().get("v.value"), function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#calendar').fullCalendar( 'removeEvents', response.getReturnValue());
                helper.closeModal(component, event);
                component.set('v.titleVal','');
                component.set('v.idVal','');
                component.set('v.startDateTimeVal','');
                component.set('v.endDateTimeVal','');
                component.set('v.descriptionVal','');
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
    },
    /*openModal : function(component, event, helper) {
        helper.openModal(component, event);
    },*/
    closeModal : function(component, event, helper) {
        helper.closeModal(component, event);
    },
    signUpRoles : function(component,event,helper){
        helper.openMassSessionPage(component,event);
    },
    saveProposedRecord : function(component, event, helper){
		helper.saveAndRefresh(component, event);
    },
})