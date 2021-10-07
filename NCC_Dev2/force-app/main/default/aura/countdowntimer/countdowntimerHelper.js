({
    createConnectNotes : function(component, event, helper, connectId, myMedications) {
        var action = component.get("c.createConnectNotes");
        action.setParams({
            'connectId': connectId,
            'myMedications': myMedications
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                
                console.log('result: '+result);
            }//if 
            else{
                console.log('ERROR:');
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    setSFTimezone : function(component, event, helper) {
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var sfTimeZone = component.get("c.getSFTimezone");
                sfTimeZone.setCallback(this,function(response){
                    var state = response.getState();
                    if(state == 'SUCCESS'){
                        var result = response.getReturnValue();
                        let SFTimeZoneMap = new Map();
                        for(var key in result){
                            SFTimeZoneMap.set(key, result[key]);
                        }
                        component.set("v.SFTimeZoneMap", SFTimeZoneMap);
                        resolve(state);
                    }
                    else{
                        console.log('ERROR:');
                        console.log(response.getError());
                    }
                });
                $A.enqueueAction(sfTimeZone);
            })
        );
        
    },
    countDownAction : function(component, event, helper, startDate, endDate, timeZone, status) {
        
        var interval = window.setInterval(
            $A.getCallback(function() {
                const changeTimezone = (dateToChange, timeZone) => {
                    var here = dateToChange;
                    var invdate = new Date(here.toLocaleString('en-US', {
                        timeZone: timeZone
                    }));
                    
                	var diff = here.getTime() - invdate.getTime();
                
                	return new Date(here.getTime() - diff);
            	};
                           
				var welcomeMessage = '';
				var patient = component.get("v.telemeet")['Contact__r']['Name'];
				var patientFirstName = component.get("v.telemeet")['Contact__r']['FirstName'];
				var doctor = component.get("v.telemeet")['Resource_Contact__r']['Name'];
            
                var startDateNew = new Date(startDate);
                var endDateNew = new Date(endDate);
        		
                var dateToday = changeTimezone(new Date(), timeZone);
                
                //console.log('startDate>>>'+newCloseDate);
                //console.log('dateToday>>>'+dateToday);
                var now_date = dateToday;
                var timeDiff = startDateNew.getTime() - now_date.getTime();
                var timeDiffEnd = endDateNew.getTime()-now_date.getTime();
        
        		//console.log('timeDiff'+timeDiff);
        
        		//telemeet is on countdown
                var seconds=Math.floor(timeDiff/1000); // seconds
        		////console.log('seconds'+seconds);
        		if(status == 'countdown' && seconds >= 0){
                    
                    
                    //more than 1 hour before telemeet
                    if(seconds < 3600 && seconds > 2700){
                       //welcomeMessage = 'Looking forward to our Connect'+', '+patient+'!';
                       welcomeMessage = 'Looking forward to our connect, '+patient+'!';
                    }
                    //45 minutes to go
                    else if(seconds < 2701 && seconds > 1800){
                       //welcomeMessage = 'Please wait for more minutes 1'+', '+patient+'!';
                       welcomeMessage = 'Looking forward to our connect, '+patient+'!';
                    }
                    //30 minutes
                    else if(seconds < 1801 && seconds > 900){
                       //welcomeMessage = 'Please wait for more minutes 2'+', '+patient+'!';
                       welcomeMessage = 'Looking forward to our connect, '+patient+'!';
                    }
                    //15 minutes
                    else if(seconds < 901 && seconds > 600){
                       //welcomeMessage = 'Your Connect is almost Ready'+', '+patient+'!';
                       welcomeMessage = 'Looking forward to our connect, '+patient+'!';
                    }
                    //10 minutes
                    else if(seconds < 601 && seconds > 300){
                       //welcomeMessage = 'Be Ready'+', '+patient+'!';
                       welcomeMessage = 'Looking forward to our connect, '+patient+'!';
                    }
                    //5 minutes
                    else if(seconds < 301 && seconds > 0){
                        welcomeMessage = 'Hang on, Connect is about to start, '+patient+'!';
                    }
                    else{
                        welcomeMessage = 'Looking forward to our connect, '+patientFirstName+'!';
                            
                    }
                    
                    
                    var minutes=Math.floor(seconds/60); //minute
                    var hours=Math.floor(minutes/60); //hours
                    var days=Math.floor(hours/24); //days
                    component.set("v.isCountdown",true);
                    component.set("v.isStarted",false);
                    hours %=24; 
                    minutes %=60;
                    seconds %=60;
                    ////console.log('minutes'+minutes);
                    
                    component.set("v.day",days);
                    component.set("v.hour",hours);
                    component.set("v.minute",minutes);
                    component.set("v.second",seconds);
                    component.set("v.welcomeMessage", welcomeMessage);
                    component.set("v.telStatus",'Your Connection Will Start In');
                }
        
        		//telemeet is on going
        		else if(status == 'started' || seconds < 0){
                    component.set("v.isCountdown",false);
                    component.set("v.isStarted",true);
                    //enddate
                    //console.log('timeDiffEnd'+timeDiffEnd);
                    var secondsEnd=Math.floor(timeDiffEnd/1000); // seconds
                    var minutesEnd=Math.floor(secondsEnd/60); //minute
                    var hoursEnd=Math.floor(minutesEnd/60); //hours
                    var daysEnd=Math.floor(hoursEnd/24); //days
                
                    hoursEnd %=24; 
                    minutesEnd %=60;
                    secondsEnd %=60;
                    component.set("v.day",daysEnd );
                    component.set("v.hour",hoursEnd );
                    component.set("v.minute",minutesEnd);
                    component.set("v.second",secondsEnd);
                    //console.log('minutesEnd'+minutesEnd);
                    //enddate
                    component.set("v.telStatus",'Connect Ongoing');
                    welcomeMessage = 'Welcome to Connect'+', '+patient+'!';
                    component.set("v.welcomeMessage", welcomeMessage);
                }
        		
			   ////console.log('seconds'+seconds);                
               if(secondsEnd < 0){
                    component.set("v.isCountdown",false);
                    component.set("v.isStarted",false);
                    component.set("v.msg",'Telemeet Ended..');
                   	component.set("v.telStatus",'Connect Ended');
                    welcomeMessage = 'Connect Ended'+', '+patient+'!';
                    component.set("v.welcomeMessage", welcomeMessage);
                    clearInterval(interval);
                }
        		else if(seconds < 0){
                    component.set("v.isCountdown",false);
                    component.set("v.isStarted",true);
                    status = 'started';
                    component.set("v.msg",'Connect Started.');
                    component.set("v.telStatus",'Connect Ongoing');
                }
			}), 1000);   
	},
 
     getConnectAgendaRecord : function(component, conAgeId){
        var action = component.get("c.searchForConAgeRecord");
        action.setParams({
            "recordId": conAgeId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();    
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    
                } 
                var starttime;
                var endtime;
                
                var duration = rows.Start_Time__c;
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
                
                starttime =  hours + ":" + minutes + meridiem;
                
                var duration2 = rows.End_Time__c;
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
                
                
                endtime =  hours + ":" + minutes + meridiem;
                
                component.set("v.castarttime", starttime);
                component.set("v.caendtime", endtime);
                component.set("v.description", rows.Description__c);
            }
        });
        $A.enqueueAction(action);
    },
 
 })