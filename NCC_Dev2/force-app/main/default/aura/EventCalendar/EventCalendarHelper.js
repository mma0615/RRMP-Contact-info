({
    getEvents : function (component){
        //var testId = '00303000004lz2xAAA'; //Test
        let url_string = document.location.href;
        const urlParams = new URLSearchParams(url_string);
        const testId = urlParams.get('contactId');
        if(testId == null){
        }
        else{
            var action = component.get('c.getEventList');
            action.setParams({'contactId' : testId});
            var eventDataList = [];
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS")
                {
                    var data = response.getReturnValue();
                    for(var dataCounter = 0; dataCounter < data.length; dataCounter++){
                        var bgColor;
                        if(data[dataCounter].status == 'Responded') bgColor = 'green';
                        else if(data[dataCounter].status == 'Invited') bgColor = 'Orange';
                            else if(data[dataCounter].status == 'Attended') bgColor = 'blue';
                        eventDataList.push({
                            'id':data[dataCounter].eventId,
                            'start':data[dataCounter].eventStart,
                            'end':data[dataCounter].eventEnd,
                            'title':data[dataCounter].name+ ' (' + data[dataCounter].timezone+')',
                            'color': bgColor,
                            'editable': true
                        });
                    }  
                    component.set('v.events', eventDataList);
                    this.printCalendar(component, eventDataList);
                }
                else if (state === "ERROR") { 
                let errors = response.getError();
                let message = 'Error on loading calendar'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                   message = errors[0].message;
                }
                this.showToast('Oops!', message, "error", "pester");
                
            }
            });
            $A.enqueueAction(action);
        }
        
    },
    printCalendar: function(component, eventData){        
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = yyyy + '-' + mm + '-' + dd;
        let m = moment();
        $('#calendar').fullCalendar({
            contentHeight: 630, 
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,agendaWeek,agendaDay,listWeek'
            },
            defaultDate: m.format(),
            editable: true,
            eventLimit: true,
            events:eventData,
            startEditable : true,
            eventDrop: $A.getCallback(function(event, delta, revertFunc, jsEvent, ui, view ) {
             alert(event.title + " was dropped on " + event.start.format());
            debugger;
        }),
           
        });
        
    }, 
    
    showToast : function(title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type,
            "mode" : mode
        });
        toastEvent.fire();
    },
})