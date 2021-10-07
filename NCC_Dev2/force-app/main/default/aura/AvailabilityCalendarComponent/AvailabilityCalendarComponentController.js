({
    confirmAvailability: function(component, event, helper) {

        var selectedConAva = (event.target.id).replace('confirmed', '');
        //var parserDate = parseInt(selectedConAva);
        //alert('Selected Contact Availability: \n'+ new Date(parserDate));
        //alert('Selected Contact Availability: \n'+ selectedConAva);
        component.set("v.contactAvailability", selectedConAva);
        console.log('selectedConAva'+selectedConAva);
    },
    handleSubmit: function(component, event, helper) {
        component.set('v.confirmSchedule',true);
        helper.handleSubmit(component, event, helper);
    },
    selectAvailability: function(component, event, helper) {
        var conAva = event.target.id;

        var conAvaIdToConfirm = conAva + "toConfirm";
        var conAvaIdConfirmed = conAva + "confirmed";

        var conavatime = document.getElementsByClassName("conava-time");
        for (var i = 0; i < conavatime.length; i++) {
            conavatime[i].setAttribute("style", "width: 100%");
        }
        var btnConfirm = document.getElementsByClassName("btn-confirm");
        for (var i = 0; i < btnConfirm.length; i++) {
            btnConfirm[i].setAttribute("style", "display: none");
        }
        var btnTime = document.getElementById(conAva);
        btnTime.setAttribute("style", "width: 50%");
        var btnConfirm = document.getElementById(conAvaIdConfirmed);
        btnConfirm.setAttribute("style", "display: block; width: 50%");
    },

    prev: function(component, event, helper) {
        var dateTodayFull = component.get("v.dateTodayFull");
        const date = new Date(dateTodayFull);
        const date2 = new Date();
        var dateToday = (date2.getMonth() + 1) + '-' + date2.getDate() + '-' + date2.getFullYear();
        date.setMonth(date.getMonth() - 1);

        date.setDate(1);

        var monthDays = component.find("daysValue");

        const lastDay = new Date(
            date.getFullYear(),
            date.getMonth() + 1,
            0
        ).getDate();

        const prevLastDay = new Date(
            date.getFullYear(),
            date.getMonth(),
            0
        ).getDate();

        const firstDayIndex = date.getDay();

        const lastDayIndex = new Date(
            date.getFullYear(),
            date.getMonth() + 1,
            0
        ).getDay();

        const nextDays = 7 - lastDayIndex - 1;

        const months = [
            "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December",
        ];

        component.set("v.year", date.getFullYear());
        component.set("v.month", months[date.getMonth()]);
        component.set("v.dateToday", new Date().toDateString());

        component.find('daysValue').set('v.body', []);

        for (let x = firstDayIndex; x > 0; x--) {
            var prevMonthDate = (date.getMonth() == 0 ? (date.getMonth() + 12) + '-' + `${prevLastDay - x + 1}` + '-' + (date.getFullYear() - 1) : date.getMonth() + '-' + `${prevLastDay - x + 1}` + '-' + date.getFullYear());
            var pastDate = (new Date(dateToday) > new Date(prevMonthDate) ? 1 : 0);
            $A.createComponent(
                "aura:html", {
                    'tag': 'div',
                    'body': `${prevLastDay - x + 1}`,
                    'HTMLAttributes': {
                        "class": "prev-date" + (pastDate == 1 ? " disable" : ""),
                        "onclick": (pastDate != 1 ? component.getReference("c.selectDate") : ""),
                        "id": prevMonthDate
                    }
                },
                function(buttonComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        // Finding the div by aura:id and pushing newly created component into it.
                        var outerDiv = component.find('daysValue').get('v.body');
                        outerDiv.push(buttonComponent);
                        component.find('daysValue').set('v.body', outerDiv);
                    }
                }
            );
        }

        for (let i = 1; i <= lastDay; i++) {
            if (i === new Date().getDate() && date.getMonth() === new Date().getMonth() && date.getFullYear() === new Date().getFullYear()) {
                var monthDateToday = ((date.getMonth() + 1) >= 13 ? (date.getMonth() + 1) % 12 + '-' + `${i}` + '-' + (date.getFullYear() + 1) : (date.getMonth() + 1) + '-' + `${i}` + '-' + date.getFullYear());
                $A.createComponent(
                    "aura:html", {
                        'tag': 'div',
                        'aura:id': monthDateToday,
                        'body': `${i}`,
                        'HTMLAttributes': {
                            "class": "today-",
                            "onclick": component.getReference("c.selectDate"),
                            "id": monthDateToday
                        }
                    },
                    function(buttonComponent, status, errorMessage) {
                        if (status === "SUCCESS") {
                            // Finding the div by aura:id and pushing newly created component into it.
                            var outerDiv = component.find('daysValue').get('v.body');
                            outerDiv.push(buttonComponent);
                            component.find('daysValue').set('v.body', outerDiv);
                        }
                    }
                );
            } else {
                var monthDate = ((date.getMonth() + 1) >= 13 ? (date.getMonth() + 1) % 12 + '-' + `${i}` + '-' + (date.getFullYear() + 1) : (date.getMonth() + 1) + '-' + `${i}` + '-' + date.getFullYear());
                var pastDate = (new Date(dateToday) > new Date(monthDate) ? 1 : 0);
                $A.createComponent(
                    "aura:html", {
                        'tag': 'div',
                        'aura:id': monthDate,
                        'body': `${i}`,
                        'HTMLAttributes': { /*"id":`${i}`,*/
                            "onclick": (pastDate != 1 ? component.getReference("c.selectDate") : ""),
                            "id": monthDate,
                            "class": (pastDate == 1 ? " disable" : "")
                        }
                    },
                    function(buttonComponent, status, errorMessage) {
                        if (status === "SUCCESS") {
                            // Finding the div by aura:id and pushing newly created component into it.
                            var outerDiv = component.find('daysValue').get('v.body');
                            outerDiv.push(buttonComponent);
                            component.find('daysValue').set('v.body', outerDiv);
                        }
                    }
                );
            }
        }

        for (let j = 1; j <= nextDays; j++) {
            var nextMonthDate = ((date.getMonth() + 2) >= 13 ? (date.getMonth() + 2) % 12 + '-' + `${j}` + '-' + (date.getFullYear() + 1) : (date.getMonth() + 2) + '-' + `${j}` + '-' + date.getFullYear());
            var pastDate = (new Date(dateToday) > new Date(nextMonthDate) ? 1 : 0);
            $A.createComponent(
                "aura:html", {
                    'tag': 'div',
                    'body': `${j}`,
                    'HTMLAttributes': {
                        "class": "next-date" + (pastDate == 1 ? " disable" : ""),
                        "onclick": (pastDate != 1 ? component.getReference("c.selectDate") : ""),
                        "id": nextMonthDate
                    }
                },
                function(buttonComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        // Finding the div by aura:id and pushing newly created component into it.
                        var outerDiv = component.find('daysValue').get('v.body');
                        outerDiv.push(buttonComponent);
                        component.find('daysValue').set('v.body', outerDiv);
                    }
                }
            );
        }
        component.set("v.dateTodayFull", date);

        var selectDate = component.get('c.selectDate');
        $A.enqueueAction(selectDate);
    },
    next: function(component, event, helper) {
        var dateTodayFull = component.get("v.dateTodayFull");
        const date = new Date(dateTodayFull);

        const date2 = new Date();
        var dateToday = (date2.getMonth() + 1) + '-' + date2.getDate() + '-' + date2.getFullYear();

        date.setMonth(date.getMonth() + 1);

        date.setDate(1);

        var monthDays = component.find("daysValue");

        const lastDay = new Date(
            date.getFullYear(),
            date.getMonth() + 1,
            0
        ).getDate();

        const prevLastDay = new Date(
            date.getFullYear(),
            date.getMonth(),
            0
        ).getDate();

        const firstDayIndex = date.getDay();

        const lastDayIndex = new Date(
            date.getFullYear(),
            date.getMonth() + 1,
            0
        ).getDay();

        const nextDays = 7 - lastDayIndex - 1;

        const months = [
            "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December",
        ];
            
        component.set("v.year", date.getFullYear());
        component.set("v.month", months[date.getMonth()]);
        component.set("v.dateToday", new Date().toDateString());

        component.find('daysValue').set('v.body', []);

        for (let x = firstDayIndex; x > 0; x--) {
            var prevMonthDate = (date.getMonth() == 0 ? (date.getMonth() + 12) + '-' + `${prevLastDay - x + 1}` + '-' + (date.getFullYear() - 1) : date.getMonth() + '-' + `${prevLastDay - x + 1}` + '-' + date.getFullYear());
            var pastDate = (new Date(dateToday) > new Date(prevMonthDate) ? 1 : 0);
            $A.createComponent(
                "aura:html", {
                    'tag': 'div',
                    'body': `${prevLastDay - x + 1}`,
                    'HTMLAttributes': {
                        "class": "prev-date" + (pastDate == 1 ? " disable" : ""),
                        "onclick": (pastDate != 1 ? component.getReference("c.selectDate") : ""),
                        "id": prevMonthDate
                    }
                },
                function(buttonComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        // Finding the div by aura:id and pushing newly created component into it.
                        var outerDiv = component.find('daysValue').get('v.body');
                        outerDiv.push(buttonComponent);
                        component.find('daysValue').set('v.body', outerDiv);
                    }
                }
            );
        }

        for (let i = 1; i <= lastDay; i++) {
            if (i === new Date().getDate() && date.getMonth() === new Date().getMonth() && date.getFullYear() === new Date().getFullYear()) {
                var monthDateToday = ((date.getMonth() + 1) >= 13 ? (date.getMonth() + 1) % 12 + '-' + `${i}` + '-' + (date.getFullYear() + 1) : (date.getMonth() + 1) + '-' + `${i}` + '-' + date.getFullYear());
                $A.createComponent(
                    "aura:html", {
                        'tag': 'div',
                        'aura:id': monthDateToday,
                        'body': `${i}`,
                        'HTMLAttributes': {
                            "class": "today-",
                            "onclick": component.getReference("c.selectDate"),
                            "id": monthDateToday
                        }
                    },
                    function(buttonComponent, status, errorMessage) {
                        if (status === "SUCCESS") {
                            // Finding the div by aura:id and pushing newly created component into it.
                            var outerDiv = component.find('daysValue').get('v.body');
                            outerDiv.push(buttonComponent);
                            component.find('daysValue').set('v.body', outerDiv);
                        }
                    }
                );
            } else {
                var monthDate = ((date.getMonth() + 1) >= 13 ? (date.getMonth() + 1) % 12 + '-' + `${i}` + '-' + (date.getFullYear() + 1) : (date.getMonth() + 1) + '-' + `${i}` + '-' + date.getFullYear());
                var pastDate = (new Date(dateToday) > new Date(monthDate) ? 1 : 0);
                $A.createComponent(
                    "aura:html", {
                        'tag': 'div',
                        'aura:id': monthDate,
                        'body': `${i}`,
                        'HTMLAttributes': { /*"id":`${i}`, */
                            "onclick": (pastDate != 1 ? component.getReference("c.selectDate") : ""),
                            "id": monthDate,
                            "class": (pastDate == 1 ? " disable" : "")
                        }
                    },
                    function(buttonComponent, status, errorMessage) {
                        if (status === "SUCCESS") {
                            // Finding the div by aura:id and pushing newly created component into it.
                            var outerDiv = component.find('daysValue').get('v.body');
                            outerDiv.push(buttonComponent);
                            component.find('daysValue').set('v.body', outerDiv);
                        }
                    }
                );
            }
        }

        for (let j = 1; j <= nextDays; j++) {
            var nextMonthDate = ((date.getMonth() + 2) >= 13 ? (date.getMonth() + 2) % 12 + '-' + `${j}` + '-' + (date.getFullYear() + 1) : (date.getMonth() + 2) + '-' + `${j}` + '-' + date.getFullYear());
            var pastDate = (new Date(dateToday) > new Date(nextMonthDate) ? 1 : 0);
            $A.createComponent(
                "aura:html", {
                    'tag': 'div',
                    'body': `${j}`,
                    'HTMLAttributes': {
                        "class": "next-date" + (pastDate == 1 ? " disable" : ""),
                        "onclick": (pastDate != 1 ? component.getReference("c.selectDate") : ""),
                        "id": nextMonthDate
                    }
                },
                function(buttonComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        // Finding the div by aura:id and pushing newly created component into it.
                        var outerDiv = component.find('daysValue').get('v.body');
                        outerDiv.push(buttonComponent);
                        component.find('daysValue').set('v.body', outerDiv);
                    }
                }
            );
        }
        component.set("v.dateTodayFull", date);

        var selectDate = component.get('c.selectDate');
        $A.enqueueAction(selectDate);
    },
    selectDate: function(component, event, helper) {
        var SFTimeZone = component.get("v.SFTimeZoneMap");
        //console.log(SFTimeZone)
		
        var selectedTimeZone = component.find("selectedTimeZone").get("v.value");
        console.log('selectedTimeZone' + selectedTimeZone);
        console.log(SFTimeZone);
        var onLoadDate = new Date();
        var targetDate;
        var targetDateTime;

        //highlight selected date DIV
        var selDateRemove = document.getElementsByClassName("today");

        for (var i = 0; i < selDateRemove.length; i++) {
            selDateRemove[i].classList.remove("today");
        }

        //when date is selected
        if (event != undefined && event.target.tagName != 'SELECT') {
            console.log('event.target.id' + event.target.id);
            var selDate = document.getElementById(event.target.id);
            if (event.target.tagName != 'SELECT') {
                selDate.classList.add("today");
            }
            targetDate = event.target.id;
            targetDateTime = new Date(event.target.id);
        }
        //onload
        else if (event == undefined && (component.get("v.selectedDate")).toString() == (new Date()).toString()) {
            targetDate = (onLoadDate.getMonth() + 1) + '-' + onLoadDate.getDate() + '-' + onLoadDate.getFullYear();
            targetDateTime = onLoadDate;
        } else if (event != undefined && event.target.tagName == 'SELECT') {
            var selDate = component.get("v.selectedDate");
            targetDate = (selDate.getMonth() + 1) + '-' + selDate.getDate() + '-' + selDate.getFullYear();
            targetDateTime = onLoadDate;
        } else if (event == undefined && (component.get("v.selectedDate")).toString() != (new Date()).toString()) {
            var selDate = component.get("v.selectedDate");
            targetDate = (selDate.getMonth() + 1) + '-' + selDate.getDate() + '-' + selDate.getFullYear();
            targetDateTime = new Date(targetDate);
            var calDate = component.find(targetDate);
            if (calDate != undefined) {
                //$A.util.removeClass(calDate, "hasSchedule");
            }
        }
        var x = document.getElementsByClassName("hasSchedule");
        Array.prototype.forEach.call(x, function(el) {
            //el.classList.remove("hasSchedule");
        });
        component.set("v.selectedDate", targetDateTime);

        var selectedDateAdd = targetDateTime.getFullYear() + '-' + (targetDateTime.getMonth() + 1) + '-' + targetDateTime.getDate();
        component.set("v.selectedDateAdd", selectedDateAdd);
        //console.log('non event'+(targetDateTime.getMonth()+1)+'-'+targetDateTime.getDate()+'-'+targetDateTime.getFullYear());

        var selDate = document.getElementById((targetDateTime.getMonth() + 1) + '-' + targetDateTime.getDate() + '-' + targetDateTime.getFullYear());
        if (selDate != undefined) {
            selDate.classList.add("today");
        }
        var calDate = component.find((targetDateTime.getMonth() + 1) + '-' + targetDateTime.getDate() + '-' + targetDateTime.getFullYear());
        if (calDate != undefined) {
            $A.util.addClass(calDate, "today");
        }

        var action = component.get("c.getContactAvailability");
        action.setParams({
            "conId": component.get("v.resourceId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result'+JSON.stringify(result));
                var resultFinal = [];
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    var timeZone = row.Time_Zone__c;
                    //var timeZone = row.Contact__r.Availability_Time_Zone__c;
                    var contactTimeZone = row.Contact__r.Availability_Time_Zone__c;
                    var orgTimeZone = row.Contact__r.Organization_Time_Zone__c;
                    row.timeZone = timeZone;
                    var startDate = row.Start_Date_Time__c;
                    var endDate = row.End_Date_Time__c;
                    var status = row.Status__c;
                    row.Status = (status == 'Completed' || status == 'Scheduled' ? "disabled" : "");

                    timeZone = SFTimeZone.get(timeZone);
                    //Contact Timezone/Company Timezone
                    //var TimeZoneSidKey = 'America/New_York';
                    var TimeZoneSidKey = SFTimeZone.get(contactTimeZone);
                    var orgTimeZoneSidKey = SFTimeZone.get(orgTimeZone);

                    const changeTimezone = (dateToChange, timeZone) => {
                        //console.log(dateToChange);
                        var here = dateToChange;
                        var invdate = new Date(here.toLocaleString('en-US', {
                            timeZone: timeZone
                        }));
                        var diff = here.getTime() - invdate.getTime();
                        return new Date(here.getTime() - diff);
                    };
                    row.StartDate = changeTimezone(new Date(startDate), orgTimeZoneSidKey);
                    //row.StartDate = changeTimezone(new Date(startDate), TimeZoneSidKey);
                    //console.log('3row.StartDate' +  row.StartDate);
                    //row.StartDate = changeTimezone(new Date(startDate), SFTimeZone.get(selectedTimeZone));
                    //row.StartDate = changeTimezone(new Date(startDate), timeZone);

                    //row.StartDate = new Date(startDate);
                    ///console.log('>>>startDate EST' + row.StartDate);

                    //convert based on ConAva TZ
                    var conAvaTZ = changeTimezone(new Date(startDate), timeZone);
                    ///console.log('>>>startDate '+timeZone + conAvaTZ);


                    //convert based on Selected TZ
                    var selectedTZ = changeTimezone(new Date(startDate), SFTimeZone.get(selectedTimeZone));
                    ///console.log('>>>startDate '+ SFTimeZone.get(selectedTimeZone) + selectedTZ);

                    var startMinusconAvaTZ = new Date(conAvaTZ) - new Date(selectedTZ);
                    ///console.log('startMinusconAvaTZ'+startMinusconAvaTZ);

                    //var addTZVal = (row.StartDate).setHours((row.StartDate).getHours() + (-(startMinusconAvaTZ/3600000)));
                    var addTZVal = (row.StartDate).setHours((row.StartDate).getHours() + (-(startMinusconAvaTZ / 3600000)));
                    row.StartDate = new Date(addTZVal);
                    console.log('>>>addTZVal'+row.StartDate);

                    row.StartDateTime = (row.StartDate).getTime();
                    var compStartDate = ((row.StartDate).getMonth() + 1) + '-' + (row.StartDate).getDate() + '-' + (row.StartDate).getFullYear();

                    if (targetDate == compStartDate) {
                        resultFinal.push(row);
                    }

                    var calDate = component.find(compStartDate);
                    if (calDate != undefined) {
                        $A.util.addClass(calDate, "hasSchedule");
                        ///console.log('caldate>>>>>>>>'+calDate);
                    }

                } //for loop

                component.set("v.conAvaList", resultFinal);
                console.log("Availablity Count: " + JSON.stringify(resultFinal.length));
            } //if 
            else {
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },


    doInit: function(component, event, helper) {
        var resourceId = component.get("v.resourceId");
        console.log('resourceId'+resourceId);
        
        helper.setPicklistField(component, event, helper)
        .then(function(result) {
            helper.setSFTimezone(component, event, helper)
            .then(function(result) {
            });
        });
        
        if (resourceId != null) {
                const date = new Date();
                var dateToday = (date.getMonth() + 1) + '-' + date.getDate() + '-' + date.getFullYear();

                component.set("v.selectedDate", new Date());

                const renderCalendar = () => {
                    date.setDate(1);

                    var monthDays = component.find("daysValue");

                    const lastDay = new Date(
                        date.getFullYear(),
                        date.getMonth() + 1,
                        0
                    ).getDate();

                    const prevLastDay = new Date(
                        date.getFullYear(),
                        date.getMonth(),
                        0
                    ).getDate();

                    const firstDayIndex = date.getDay();

                    const lastDayIndex = new Date(
                        date.getFullYear(),
                        date.getMonth() + 1,
                        0
                    ).getDay();

                    const nextDays = 7 - lastDayIndex - 1;

                    const months = [
                        "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December",
                    ];

                    component.set("v.year", date.getFullYear());
                    component.set("v.month", months[date.getMonth()]);
                    component.set("v.dateToday", new Date().toDateString());

                    let days = "";

                    for (let x = firstDayIndex; x > 0; x--) {
                        var prevMonthDate = (date.getMonth() == 0 ? (date.getMonth() + 12) + '-' + `${prevLastDay - x + 1}` + '-' + (date.getFullYear() - 1) : date.getMonth() + '-' + `${prevLastDay - x + 1}` + '-' + date.getFullYear());
                        var pastDate = (new Date(dateToday) > new Date(prevMonthDate) ? 1 : 0);
                        $A.createComponent(
                            "aura:html", {
                                'tag': 'div',
                                'body': `${prevLastDay - x + 1}`,
                                'HTMLAttributes': {
                                    "class": "prev-date" + (pastDate == 1 ? " disable" : ""),
                                    "onclick": (pastDate != 1 ? component.getReference("c.selectDate") : ""),
                                    "id": prevMonthDate
                                }
                            },
                            function(buttonComponent, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    // Finding the div by aura:id and pushing newly created component into it.
                                    var outerDiv = component.find('daysValue').get('v.body');
                                    outerDiv.push(buttonComponent);
                                    component.find('daysValue').set('v.body', outerDiv);
                                }
                            }
                        );
                    }

                    for (let i = 1; i <= lastDay; i++) {
                        if (i === new Date().getDate() && date.getMonth() === new Date().getMonth() && date.getFullYear() === new Date().getFullYear()) {
                            var monthDateToday = ((date.getMonth() + 1) >= 13 ? (date.getMonth() + 1) % 12 + '-' + `${i}` + '-' + (date.getFullYear() + 1) : (date.getMonth() + 1) + '-' + `${i}` + '-' + date.getFullYear());
                            $A.createComponent(
                                "aura:html", {
                                    'tag': 'div',
                                    'aura:id': monthDateToday,
                                    'body': `${i}`,
                                    'HTMLAttributes': {
                                        "class": "today",
                                        "onclick": component.getReference("c.selectDate"),
                                        "id": monthDateToday
                                    }
                                },
                                function(buttonComponent, status, errorMessage) {
                                    if (status === "SUCCESS") {
                                        // Finding the div by aura:id and pushing newly created component into it.
                                        var outerDiv = component.find('daysValue').get('v.body');
                                        outerDiv.push(buttonComponent);
                                        component.find('daysValue').set('v.body', outerDiv);
                                    }
                                }
                            );
                        } else {
                            var monthDate = ((date.getMonth() + 1) >= 13 ? (date.getMonth() + 1) % 12 + '-' + `${i}` + '-' + (date.getFullYear() + 1) : (date.getMonth() + 1) + '-' + `${i}` + '-' + date.getFullYear());
                            var pastDate = (new Date(dateToday) > new Date(monthDate) ? 1 : 0);
                            $A.createComponent(
                                "aura:html", {
                                    'tag': 'div',
                                    'aura:id': monthDate,
                                    'body': `${i}`,
                                    'HTMLAttributes': {
                                        /*"id":`${i}`,*/
                                        "onclick": (pastDate != 1 ? component.getReference("c.selectDate") : ""),
                                        "id": monthDate,
                                        "class": (pastDate == 1 ? "disable" : "")
                                    }
                                },
                                function(buttonComponent, status, errorMessage) {
                                    if (status === "SUCCESS") {
                                        // Finding the div by aura:id and pushing newly created component into it.
                                        var outerDiv = component.find('daysValue').get('v.body');
                                        outerDiv.push(buttonComponent);
                                        component.find('daysValue').set('v.body', outerDiv);
                                    }
                                }
                            );
                        }
                    }

                    for (let j = 1; j <= nextDays; j++) {
                        var nextMonthDate = ((date.getMonth() + 2) >= 13 ? (date.getMonth() + 2) % 12 + '-' + `${j}` + '-' + (date.getFullYear() + 1) : (date.getMonth() + 2) + '-' + `${j}` + '-' + date.getFullYear());
                        $A.createComponent(
                            "aura:html", {
                                'tag': 'div',
                                'body': `${j}`,
                                'HTMLAttributes': {
                                    "class": "next-date",
                                    "onclick": component.getReference("c.selectDate"),
                                    "id": nextMonthDate
                                }
                            },
                            function(buttonComponent, status, errorMessage) {
                                if (status === "SUCCESS") {
                                    // Finding the div by aura:id and pushing newly created component into it.
                                    var outerDiv = component.find('daysValue').get('v.body');
                                    outerDiv.push(buttonComponent);
                                    component.find('daysValue').set('v.body', outerDiv);
                                }
                            }
                        );
                    }
                    component.set("v.dateTodayFull", date);
                };

                renderCalendar();
        }
    },

})