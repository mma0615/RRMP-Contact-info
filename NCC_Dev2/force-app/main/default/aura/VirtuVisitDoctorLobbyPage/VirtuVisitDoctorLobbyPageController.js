({
    saveMyMedications: function(component, event, helper) {
        var connectId = component.get("v.connectId");
        var myMedications = component.get("v.myMedications");
        
        helper.createConnectNotes(component, event, helper, connectId, myMedications);
    },
    
    expandAmazon: function(component, event, helper) {
        var amazonMenu = component.find("right");
        $A.util.toggleClass(amazonMenu, "right-toggle");

        var conSched = component.find("consultation-schedule");
        $A.util.toggleClass(conSched, "consultation-schedule-toggle");

        var conTeam = component.find("consultation-team");
        $A.util.toggleClass(conTeam, "consultation-team-toggle");

        var uploadFile = component.find("upload-file");
        $A.util.toggleClass(uploadFile, "upload-file-toggle");

        var timerHolder = component.find("timerHolder");
        $A.util.toggleClass(timerHolder, "timerHolder-toggle");

        var minimize = component.find("minimize");
        $A.util.toggleClass(minimize, "minimize-toggle");

        var maximize = component.find("maximize");
        $A.util.toggleClass(maximize, "maximize-toggle");

    },

    doInit: function(component, event, helper) {

        document.body.style.background = '#525659';
        //document.body.style.background = '#1797c0';
        var url_string = document.location.href;
        var connectId = (url_string.split('id=')[1]).slice(0, 18);
        console.log('connectId' + connectId);

        component.set("v.connectId", connectId);
        component.set("v.defaultProfilePic", window.location.origin + '/profilephoto/005/F');

        helper.setSFTimezone(component, event, helper)
            .then(function(result) {

                let action = component.get("c.fetchTelemeetStartDate");
                action.setParams({
                    "recId": connectId //component.get("v.recordId")
                });
                action.setCallback(this, function(response) {
                    let state = response.getState();
                    if (state == 'SUCCESS') {

                        var SFTimeZone = component.get("v.SFTimeZoneMap");
                        var result = response.getReturnValue();
                        var startDate = result.Start_Date_Time__c;
                        var endDate = result.End_Date_Time__c;
                        var timeZone = result.Time_Zone__c;

                        component.set("v.telemeet", result);
                        const hrefPattern = new RegExp('href="([^"]*)');
                        const internalMeetUrl = result.Meeting_URL2__c.match(hrefPattern)[1];
                        const decodedURI = internalMeetUrl.replace('&amp;', '&');
                        const participantMeetUrl = decodedURI.substr(0, decodedURI.indexOf('&n=')) + "&n=" + encodeURIComponent(result.Contact__r.Name);
                        component.set("v.amazonchime", participantMeetUrl);

                        //timeZone = (timeZone == 'PT' ? 'Pacific/Pitcairn' : (timeZone == 'PDT' ? 'America/Los_Angeles' : timeZone));
                        timeZone = SFTimeZone.get(timeZone);
                        //console.log('timeZone>>'+timeZone);
                        //console.log('Result : ' +startDate);
                        let getTimeZoneSidKey = component.get("c.getTimeZoneSidKey");
                        /*convertDate.setParams({
                            "StartDate" : startDate,
                            "TelTimeZone" : timeZone
                        });*/
                        getTimeZoneSidKey.setCallback(this, function(response) {
                            let state = response.getState();
                            if (state == 'SUCCESS') {

                                var TimeZoneSidKey = response.getReturnValue();

                                component.set("v.timeZoneSidKey", TimeZoneSidKey);

                                const changeTimezone = (dateToChange, timeZone) => {
                                    //console.log(dateToChange);
                                    var here = dateToChange;
                                    var invdate = new Date(here.toLocaleString('en-US', {
                                        timeZone: timeZone
                                    }));
                                    var diff = here.getTime() - invdate.getTime();
                                    return new Date(here.getTime() - diff);
                                };



                                //end date
                                var telEndDate = changeTimezone(new Date(endDate), TimeZoneSidKey);
                                console.log('Converted StartDate: ' + telEndDate);
                                var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                                var monthNameEnd = months[telEndDate.getMonth()];
                                var dateNumberEnd = telEndDate.getDate();
                                var yearNumberEnd = telEndDate.getFullYear();
                                var hoursNumberEnd = telEndDate.getHours();
                                var minutesNumberEnd = telEndDate.getMinutes();
                                var secondsNumberEnd = telEndDate.getSeconds();

                                //console.log('Month Name: ' +monthName+' Date: '+dateNumber+' Year: '+yearNumber+ 'Time: '+ hoursNumber+':'+minutesNumber+':'+secondsNumber);
                                //var closeDateVar = monthName+' '+dateNumber+' '+yearNumber;
                                var telEndDateVar = monthNameEnd + ' ' + dateNumberEnd + ' ' + yearNumberEnd + ' ' + hoursNumberEnd + ':' + minutesNumberEnd + ':' + secondsNumberEnd + ' ';
                                //var opptyCloseDate = new Date( closeDateVar+" 00:00:00 ");
                                var telEndDateVarN = new Date(telEndDateVar);


                                //start date
                                var telStartDate = changeTimezone(new Date(startDate), TimeZoneSidKey);
                                console.log('Converted StartDate: ' + telStartDate);
                                var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                                var monthName = months[telStartDate.getMonth()];
                                var dateNumber = telStartDate.getDate();
                                var yearNumber = telStartDate.getFullYear();
                                var hoursNumber = telStartDate.getHours();
                                var minutesNumber = telStartDate.getMinutes();
                                var secondsNumber = telStartDate.getSeconds();

                                //console.log('Month Name: ' +monthName+' Date: '+dateNumber+' Year: '+yearNumber+ 'Time: '+ hoursNumber+':'+minutesNumber+':'+secondsNumber);
                                //var closeDateVar = monthName+' '+dateNumber+' '+yearNumber;
                                var telStartDateVar = monthName + ' ' + dateNumber + ' ' + yearNumber + ' ' + hoursNumber + ':' + minutesNumber + ':' + secondsNumber + ' ';
                                //var opptyCloseDate = new Date( closeDateVar+" 00:00:00 ");
                                var telStartDateVarN = new Date(telStartDateVar);

                                //var now_date = new Date();
                                var now_date = changeTimezone(new Date(), timeZone);
                                component.set("v.dateTimeNow", now_date);
                                console.log('Converted Date Today: ' + now_date);

                                var timeDiff = telStartDateVarN.getTime() - now_date.getTime();
                                var timeDiffEnd = telEndDateVarN.getTime() - now_date.getTime();
                                console.log('timeDiffEnd' + timeDiffEnd);

                                var welcomeMessage = '';

                                var patient = result['Contact__r']['Name'];
                                var doctor = result['Resource_Contact__r']['Name'];

                                if (timeDiffEnd <= 0) {
                                    component.set("v.telStatus", 'Connect Ended');
                                    component.set("v.isCountdown", false);
                                    component.set("v.isStarted", false);
                                    component.set("v.msg", 'Connect Ended');

                                    welcomeMessage = 'Connect Ended' + ', ' + doctor + '!';
                                    component.set("v.welcomeMessage", welcomeMessage);
                                }
                                //telemeet started
                                else if (timeDiff <= 0 && timeDiffEnd >= 0) {
                                    //component.set("v.telStatus",'Time remaining to end Connect');
                                    component.set("v.isCountdown", false);
                                    component.set("v.isStarted", true);
                                    //component.set("v.msg",'Telemeet Started');
                                    helper.countDownAction(component, event, helper, telStartDateVar, telEndDateVar, timeZone, 'started');
                                }
                                //telemeet countdown
                                else {
                                    //component.set("v.telStatus",'Remaining to end Connect');
                                    component.set("v.isCountdown", true);
                                    component.set("v.isStarted", false);
                                    helper.countDownAction(component, event, helper, telStartDateVar, telEndDateVar, timeZone, 'countdown');
                                }

                            } else {
                                console.log('ERROR:');
                                console.log(response.getError());
                            }

                        });
                        $A.enqueueAction(getTimeZoneSidKey);
                    } else {
                        console.log('ERROR:');
                        console.log(response.getError());
                    }
    
                    //Call getConnectAgenda
                    var getConnectAgenda = component.get('c.getConnectAgenda');
                    $A.enqueueAction(getConnectAgenda);
                    
                    
                    //Call getConnectParticipants
                    var getConnectParticipants = component.get('c.getConnectParticipants');
                    $A.enqueueAction(getConnectParticipants);
    
    				//Call getConnectFiles
                    var getConnectFiles = component.get('c.getConnectFiles');
                    $A.enqueueAction(getConnectFiles);
                });
                $A.enqueueAction(action);

            });

       

        /*
        //Get Connect Agenda
        let connectAgenda = component.get("c.fetchConnectAgenda");
        connectAgenda.setParams({
            "recId" : connectId
        });
        connectAgenda.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    var duration = row.Start_Time__c;
                    var milliseconds = parseInt((duration % 1000) / 100),
                        //seconds = Math.floor((duration / 1000) % 60),
                        minutes = Math.floor((duration / (1000 * 60)) % 60),
                        hours = Math.floor((duration / (1000 * 60 * 60)) % 24);
                    
                    hours = (hours < 10) ? "0" + hours : hours;
                    minutes = (minutes < 10) ? "0" + minutes : minutes;
                    //seconds = (seconds < 10) ? "0" + seconds : seconds;
                    
                    var meridiem = (hours >= 12 ? ' pm' : ' am');
                    hours = (hours >= 12 ? hours - 12 : hours);
                    hours = (hours == 0 ? '12' : hours);
                    
                    row.StartTime =  hours + ":" + minutes + meridiem;
                    
                    var duration2 = row.End_Time__c;
                    var milliseconds = parseInt((duration2 % 1000) / 100),
                        //seconds = Math.floor((duration2 / 1000) % 60),
                        minutes = Math.floor((duration2 / (1000 * 60)) % 60),
                        hours = Math.floor((duration2 / (1000 * 60 * 60)) % 24);
                    
                    hours = (hours < 10) ? "0" + hours : hours;
                    minutes = (minutes < 10) ? "0" + minutes : minutes;
                    //seconds = (seconds < 10) ? "0" + seconds : seconds;
                    
                    meridiem = (hours >= 12 ? ' pm' : ' am');
                    hours = (hours >= 12 ? hours - 12 : hours);
                    hours = (hours == 0 ? '12' : hours);

                    
                    row.EndTime =  hours + ":" + minutes + meridiem;
                    
                    if(row.Contact__c){
                        row.Contact = " with " + row.Contact__r.Name;
                    }
                }
                
                component.set("v.connectAgenda",result);
                console.log(result);
            }
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
            
        });
        $A.enqueueAction(connectAgenda);*/
    },

    getConnectAgenda: function(component, event, helper) {
        //Get Connect Agenda
        let connectAgenda = component.get("c.fetchConnectAgenda");
        connectAgenda.setParams({
            "recId": component.get("v.connectId")
        });
        connectAgenda.setCallback(this, function(response) {
            let state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();

                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    var duration = row.Start_Time__c;
                    var milliseconds = parseInt((duration % 1000) / 100),
                        //seconds = Math.floor((duration / 1000) % 60),
                        minutes = Math.floor((duration / (1000 * 60)) % 60),
                        hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

                    hours = (hours < 10) ? "0" + hours : hours;
                    minutes = (minutes < 10) ? "0" + minutes : minutes;
                    //seconds = (seconds < 10) ? "0" + seconds : seconds;

                    var meridiem = (hours >= 12 ? 'pm' : 'am');
                    hours = (hours >= 12 ? hours - 12 : hours);
                    hours = (hours == 0 ? '12' : hours);

                    row.StartTime = hours + ":" + minutes + meridiem;

                    var duration2 = row.End_Time__c;
                    var milliseconds = parseInt((duration2 % 1000) / 100),
                        //seconds = Math.floor((duration2 / 1000) % 60),
                        minutes = Math.floor((duration2 / (1000 * 60)) % 60),
                        hours = Math.floor((duration2 / (1000 * 60 * 60)) % 24);

                    hours = (hours < 10) ? "0" + hours : hours;
                    minutes = (minutes < 10) ? "0" + minutes : minutes;
                    //seconds = (seconds < 10) ? "0" + seconds : seconds;

                    meridiem = (hours >= 12 ? 'pm' : 'am');
                    hours = (hours >= 12 ? hours - 12 : hours);
                    hours = (hours == 0 ? '12' : hours);


                    row.EndTime = hours + ":" + minutes + meridiem;

                    if (row.Contact__c) {
                        row.Contact = " with " + row.Contact__r.Name;
                    }
                    row.Count = i + 1;
                }

                component.set("v.connectAgenda", result);
                //console.log(result);
            } else {
                console.log('ERROR:');
                console.log(response.getError());
            }

        });
        $A.enqueueAction(connectAgenda);
    },
        	
    getConnectFiles: function(component, event, helper) {
        //Get Connect Files
        let connectFiles = component.get("c.fetchConnectFiles");
        connectFiles.setParams({
            "connectId": component.get("v.connectId")
        });
        connectFiles.setCallback(this, function(response) {
            let state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.connectFiles", result);
            } else {
                console.log(response.getError());
                console.log(response.getError()[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(connectFiles);
        
    },

    getConnectParticipants: function(component, event, helper) {
        //Get Connect Agenda
        let connectParticipant = component.get("c.fetchConnectParticipant");
        connectParticipant.setParams({
            "recId": component.get("v.connectId")
        });
        connectParticipant.setCallback(this, function(response) {
            let state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.connectParticipant", result);
            } else {
                console.log(response.getError());
                console.log(response.getError()[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(connectParticipant);
        
        //Get Connect's Practice Management: Telehealth Consultation Group
        let telehealthConsultationGroup = component.get("c.fetchTelehealthConsultationGroup");
        telehealthConsultationGroup.setParams({
            "recId": component.get("v.telemeet").Practice_Management__c
        });
        telehealthConsultationGroup.setCallback(this, function(response) {
            let state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.telehealthConsulGrp", result);
            } else {
                console.log(response.getError());
                console.log(response.getError()[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(telehealthConsultationGroup);
    },


    /*
    handleConfirmDialog : function(component, event, helper) {
        var conAgeId = event.target.id;
        component.set('v.connectAgendaId', conAgeId);
        document.getElementById(conAgeId).checked = false;
        
        component.set('v.showConfirmDialog', true);
        helper.getConnectAgendaRecord(component, conAgeId);
    },
    handleConfirmDialogYes : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        var connectAgendaId = component.get('v.connectAgendaId');
        
        var action = component.get("c.completeConnectAgenda");
        action.setParams({
            "recordId": connectAgendaId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();  
            }
            else{
                console.log(response.getError());
                console.log(response.getError()[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleConfirmDialogNo : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        component.set('v.connectAgendaId', null);
    },*/




})