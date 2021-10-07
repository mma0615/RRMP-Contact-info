({
    cancelAvailability: function(component, event, helper) {
        component.set("v.addAvailability", false);
    },
    
    addAvailability: function(component, event, helper) {
    	//alert('add');
        component.set("v.addAvailability", true);
    },
    
    saveAvailability: function(component, event, helper) {
        var contactId = component.get('v.contactId');
    	var startTime = component.find("startTime").get("v.value");
    	var endTime = component.find("endTime").get("v.value");
        var timeZone = (component.get('v.timezone') == '' ? 'Pacific Standard Time' : component.get('v.timezone'));
        
        console.log('startTime'+startTime.substring(0,5));
        console.log('endTime'+endTime.substring(0,5));
        console.log('timezone'+timeZone);
        
        var selectedDate = component.get("v.selectedDate");
        var selectedDateFormatted = (selectedDate.getMonth()+1)+'-'+(selectedDate.getDate()+1)+'-'+selectedDate.getFullYear();
        
		console.log('selectedDateFormatted'+selectedDateFormatted);
        
        var timeStart = new Date(selectedDateFormatted +' '+ startTime.substring(0,5));
        var timeEnd = new Date(selectedDateFormatted +' '+ endTime.substring(0,5));
        
        
        var difference = (((timeEnd - timeStart) / 60) /1000) / 60;
        console.log('difference'+difference);
       
        if(difference != 1){
            component.set("v.availabilityError", true); 
            component.set("v.availabilityNotif", "The maximum duration is 60 minutes.");
        }
        else{
            component.set("v.availabilityError", false);
            component.set("v.availabilityNotif", "");
            helper.saveAvailabilityRecord(component, contactId, timeStart, timeEnd, timeZone);
        }
    },
    
    confirmAvailability: function(component, event, helper) {
        
        var selectedConAva = (event.target.id).replace('confirmed','');
        //var parserDate = parseInt(selectedConAva);
        //alert('Selected Contact Availability: \n'+ new Date(parserDate));
        alert('Selected Contact Availability: \n'+ selectedConAva);
        console.log(selectedConAva);
    },
    selectAvailability: function(component, event, helper) {
        var conAva = event.target.id;
        
        var conAvaIdToConfirm = conAva+"toConfirm";
        var conAvaIdConfirmed = conAva+"confirmed";
        
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
        const date  = new Date(dateTodayFull);
        const date2 = new Date();
        var dateToday = (date2.getMonth()+1)+'-'+date2.getDate()+'-'+date2.getFullYear();
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
				"January",
				"February",
				"March",
				"April",
				"May",
				"June",
				"July",
				"August",
				"September",
				"October",
				"November",
				"December",
				];
				
				component.set("v.year", date.getFullYear());
				component.set("v.month", months[date.getMonth()]);
				component.set("v.dateToday", new Date().toDateString());
				
				component.find('daysValue').set('v.body', []);
        
				for (let x = firstDayIndex; x > 0; x--) {
                    var prevMonthDate = (date.getMonth() == 0 ? (date.getMonth()+12)+'-'+`${prevLastDay - x + 1}`+'-'+(date.getFullYear()-1) : date.getMonth()+'-'+`${prevLastDay - x + 1}`+'-'+date.getFullYear());
					var pastDate = (new Date(dateToday) > new Date(prevMonthDate) ? 1 : 0);
                    $A.createComponent(
							"aura:html",{ 
							'tag': 'div',
							'body': `${prevLastDay - x + 1}`,
                        	'HTMLAttributes':{"class":"prev-date"+(pastDate == 1 ? " disable" : ""), "onclick":(pastDate != 1 ? component.getReference("c.selectDate") : ""), "id":prevMonthDate}
						},
						function(buttonComponent, status, errorMessage){
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
					if (i === new Date().getDate() && date.getMonth() === new Date().getMonth() && date.getFullYear() === new Date().getFullYear()){
                        var monthDateToday = ((date.getMonth()+1) >= 13 ?  (date.getMonth()+1)%12  +'-'+`${i}`+'-'+(date.getFullYear()+1) : (date.getMonth()+1)+'-'+`${i}`+'-'+date.getFullYear());
						$A.createComponent(
								"aura:html",{ 
								'tag': 'div',
								'body': `${i}`,
                            	'HTMLAttributes':{"class":"today-", "onclick":component.getReference("c.selectDate"), "id":monthDateToday}
							},
							function(buttonComponent, status, errorMessage){
								if (status === "SUCCESS") {
									// Finding the div by aura:id and pushing newly created component into it.
									var outerDiv = component.find('daysValue').get('v.body');
									outerDiv.push(buttonComponent);
									component.find('daysValue').set('v.body', outerDiv);
								}
							}
						);
					}
					else{
                        var monthDate = ((date.getMonth()+1) >= 13 ?  (date.getMonth()+1)%12  +'-'+`${i}`+'-'+(date.getFullYear()+1) : (date.getMonth()+1)+'-'+`${i}`+'-'+date.getFullYear());
						var pastDate = (new Date(dateToday) > new Date(monthDate) ? 1 : 0);
                        $A.createComponent(
								"aura:html",{ 
								'tag': 'div',
								'body': `${i}`,
                            	'HTMLAttributes':{/*"id":`${i}`,*/ "onclick":(pastDate != 1 ? component.getReference("c.selectDate") : ""), "id":monthDate, "class":(pastDate == 1 ? " disable" : "")}
							},
							function(buttonComponent, status, errorMessage){
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
                  var nextMonthDate = ((date.getMonth()+2) >= 13 ?  (date.getMonth()+2)%12  +'-'+`${j}`+'-'+(date.getFullYear()+1) : (date.getMonth()+2)+'-'+`${j}`+'-'+date.getFullYear());
					var pastDate = (new Date(dateToday) > new Date(nextMonthDate) ? 1 : 0);
                  	$A.createComponent(
							"aura:html",{ 
							'tag': 'div',
							'body': `${j}`,
	                        'HTMLAttributes':{"class":"next-date"+(pastDate == 1 ? " disable" : ""), "onclick":(pastDate != 1 ? component.getReference("c.selectDate") : ""), "id":nextMonthDate}
						},
						function(buttonComponent, status, errorMessage){
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
    },
    next: function(component, event, helper) {
        var dateTodayFull = component.get("v.dateTodayFull");
        const date  = new Date(dateTodayFull);
        
        const date2 = new Date();
        var dateToday = (date2.getMonth()+1)+'-'+date2.getDate()+'-'+date2.getFullYear();
        
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
				"January",
				"February",
				"March",
				"April",
				"May",
				"June",
				"July",
				"August",
				"September",
				"October",
				"November",
				"December",
				];
				
				/*document.querySelector(".date h1").innerHTML = months[date.getMonth()];
				
				document.querySelector(".date p").innerHTML = new Date().toDateString();
				*/
				
				component.set("v.year", date.getFullYear());
				component.set("v.month", months[date.getMonth()]);
				component.set("v.dateToday", new Date().toDateString());
				
				component.find('daysValue').set('v.body', []);
        
				for (let x = firstDayIndex; x > 0; x--) {
                    var prevMonthDate = (date.getMonth() == 0 ? (date.getMonth()+12)+'-'+`${prevLastDay - x + 1}`+'-'+(date.getFullYear()-1) : date.getMonth()+'-'+`${prevLastDay - x + 1}`+'-'+date.getFullYear());
					var pastDate = (new Date(dateToday) > new Date(prevMonthDate) ? 1 : 0);
                    $A.createComponent(
							"aura:html",{ 
							'tag': 'div',
							'body': `${prevLastDay - x + 1}`,
							'HTMLAttributes':{"class":"prev-date"+(pastDate == 1 ? " disable" : ""), "onclick":(pastDate != 1 ? component.getReference("c.selectDate") : ""), "id":prevMonthDate}
						},
						function(buttonComponent, status, errorMessage){
							if (status === "SUCCESS") {
								// Finding the div by aura:id and pushing newly created component into it.
								var outerDiv = component.find('daysValue').get('v.body');
								outerDiv.push(buttonComponent);
								component.find('daysValue').set('v.body', outerDiv);
							}
						}
					);
				}
				
				/*for (let i = 1; i <= lastDay; i++) {
					if (i === new Date().getDate() && date.getMonth() === new Date().getMonth()){
					days += `<div class="today">${i}</div>`;
				}
					else{
					days += `<div id="${i}">${i}</div>`;
				}
				}*/
				
				for (let i = 1; i <= lastDay; i++) {
					if (i === new Date().getDate() && date.getMonth() === new Date().getMonth() && date.getFullYear() === new Date().getFullYear()){
                        var monthDateToday = ((date.getMonth()+1) >= 13 ?  (date.getMonth()+1)%12  +'-'+`${i}`+'-'+(date.getFullYear()+1) : (date.getMonth()+1)+'-'+`${i}`+'-'+date.getFullYear());
						$A.createComponent(
								"aura:html",{ 
								'tag': 'div',
								'body': `${i}`,
								'HTMLAttributes':{"class":"today-", "onclick":component.getReference("c.selectDate"), "id":monthDateToday}
							},
							function(buttonComponent, status, errorMessage){
								if (status === "SUCCESS") {
									// Finding the div by aura:id and pushing newly created component into it.
									var outerDiv = component.find('daysValue').get('v.body');
									outerDiv.push(buttonComponent);
									component.find('daysValue').set('v.body', outerDiv);
								}
							}
						);
					}
					else{
                        var monthDate = ((date.getMonth()+1) >= 13 ?  (date.getMonth()+1)%12  +'-'+`${i}`+'-'+(date.getFullYear()+1) : (date.getMonth()+1)+'-'+`${i}`+'-'+date.getFullYear());
						var pastDate = (new Date(dateToday) > new Date(monthDate) ? 1 : 0);
                    	$A.createComponent(
								"aura:html",{ 
								'tag': 'div',
								'body': `${i}`,
								'HTMLAttributes':{/*"id":`${i}`, */"onclick":(pastDate != 1 ? component.getReference("c.selectDate") : ""), "id":monthDate, "class":(pastDate == 1 ? " disable" : "")}
							},
							function(buttonComponent, status, errorMessage){
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
                  var nextMonthDate = ((date.getMonth()+2) >= 13 ?  (date.getMonth()+2)%12  +'-'+`${j}`+'-'+(date.getFullYear()+1) : (date.getMonth()+2)+'-'+`${j}`+'-'+date.getFullYear());
					var pastDate = (new Date(dateToday) > new Date(nextMonthDate) ? 1 : 0);
                  	$A.createComponent(
							"aura:html",{ 
							'tag': 'div',
							'body': `${j}`,
                        'HTMLAttributes':{"class":"next-date"+(pastDate == 1 ? " disable" : ""), "onclick":(pastDate != 1 ? component.getReference("c.selectDate") : ""), "id":nextMonthDate}
						},
						function(buttonComponent, status, errorMessage){
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
    },
        selectDate: function(component, event, helper) {
            
            var onLoadDate = new Date();
            var targetDate;
            var targetDateTime;
            
            //highlight selected date DIV
            var selDateRemove = document.getElementsByClassName("today");
            
            for (var i = 0; i < selDateRemove.length; i++) {
                selDateRemove[i].classList.remove("today");
            }
            
            
            console.log('component.get("v.selectedDateAfterSave")'+component.get("v.selectedDateAfterSave"));
            //onload
            
            if(event == undefined){
                targetDate = (onLoadDate.getMonth()+1)+'-'+onLoadDate.getDate()+'-'+onLoadDate.getFullYear();
                targetDateTime = onLoadDate;
            }
            /*else if(component.get("v.selectedDateAfterSave") != null && component.get("v.selectedDateAfterSave") != new Date(event.target.id)){
                var onLoadDate = component.get("v.selectedDateAfterSave");
                targetDate = (onLoadDate.getMonth()+1)+'-'+onLoadDate.getDate()+'-'+onLoadDate.getFullYear();
                targetDateTime = onLoadDate;                
            }*/
            //when date is selected
            else{
                var selDate = document.getElementById(event.target.id);
                selDate.classList.add("today");
                console.log('Date Selected: '+event.target.id);
                targetDate = event.target.id;
                targetDateTime = new Date(event.target.id);
            }
            component.set("v.selectedDate",targetDateTime);
            var selectedDateAdd = targetDateTime.getFullYear()+'-'+(targetDateTime.getMonth()+1)+'-'+targetDateTime.getDate();
            component.set("v.selectedDateAdd", selectedDateAdd);
            
            //component.set("v.conAvaList", null);
            var action = component.get("c.getContactAvailability");
            action.setParams({
                "conId" : component.get('v.contactId')//component.get("v.recordId")
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    var result = response.getReturnValue();
                    var resultFinal = [];
                    for (var i = 0; i < result.length; i++) {
                        var row = result[i];
                        var timeZone = row.Time_Zone__c;
                        var startDate = row.Start_Date_Time__c;
                        var endDate = row.End_Date_Time__c;
                        var status = row.Status__c;
                        row.Status = (status == 'Completed' || status == 'Scheduled' ? "disabled" : "");
                        timeZone = (timeZone == 'PT' ? 'Pacific/Pitcairn' : (timeZone == 'PDT' ? 'America/Los_Angeles' : timeZone));
                        
                        var TimeZoneSidKey = 'America/New_York';
                        
                        const changeTimezone = (dateToChange, timeZone) => {
                                //console.log(dateToChange);
                                var here = dateToChange;
                                var invdate = new Date(here.toLocaleString('en-US', {
                                timeZone: timeZone
                            }));
                            var diff = here.getTime() - invdate.getTime();
                            return new Date(here.getTime() - diff);
                        };
                        row.StartDate = changeTimezone(new Date(startDate), TimeZoneSidKey);
                    	row.StartDateTime = (row.StartDate).getTime();	
                    	var compStartDate = ((row.StartDate).getMonth()+1)+'-'+(row.StartDate).getDate()+'-'+(row.StartDate).getFullYear();
                    
                        if(targetDate == compStartDate){
                            resultFinal.push(row);
                        }
                        /*var getTimeZoneSidKey = component.get("c.getTimeZoneSidKey");
                        getTimeZoneSidKey.setCallback(this,function(response){
                            var state = response.getState();
                            
                        console.log('row2'+JSON.stringify(row));
                                if(state == 'SUCCESS'){
                                    var TimeZoneSidKey = response.getReturnValue();
                                    //component.set("v.timeZoneSidKey", TimeZoneSidKey);
                                    
                                    const changeTimezone = (dateToChange, timeZone) => {
                                        //console.log(dateToChange);
                                        var here = dateToChange;
                                        var invdate = new Date(here.toLocaleString('en-US', {
                                        timeZone: timeZone
                                    }));
                                    var diff = here.getTime() - invdate.getTime();
                                    return new Date(here.getTime() - diff);
                                };
                                
                                //start date
                                row.StartDate = changeTimezone(new Date(startDate), TimeZoneSidKey);
                    			row.StartDateTime = (row.StartDate).getTime();	
                    			var compStartDate = ((row.StartDate).getMonth()+1)+'-'+(row.StartDate).getDate()+'-'+(row.StartDate).getFullYear();
                            	
                            	console.log('TimeZoneSidKey'+TimeZoneSidKey);
                                
                            	//var telEndDate = changeTimezone(new Date(endDate), TimeZoneSidKey);
                            	//row.Start_Date_Time__c	= telEndDate+'het';
                            	//component.set("v.endDateTime",telEndDate);
                                //console.log('Converted EndDate: '+telEndDate);
                                if(targetDate == compStartDate){
                                    resultFinal.push(row);
                                    console.log('row'+JSON.stringify(row));
                                    component.set("v.conAvaList", resultFinal);
                                }
                             }                             
                             else{
                                console.log('ERROR:');
                                console.log(response.getError());
                            }
                			console.log("Availablity Count: "+JSON.stringify(resultFinal));
                        });
                        $A.enqueueAction(getTimeZoneSidKey);*/
            			
                		//row.StartDateTime = 'hey'+component.get("v.endDateTime");
                	}//for loop
                
                component.set("v.conAvaList", resultFinal);
                console.log("Availablity Count: "+JSON.stringify(resultFinal.length));
            	}//if 
                else{
                    console.log('ERROR:');
                    console.log(response.getError());
                }
        });
        $A.enqueueAction(action);
},
    
    
    doInit: function(component, event, helper) {
        
        helper.setPicklistValues(component, event, helper);
        
        var contactId = component.get('v.contactId');
        console.log('contactId'+contactId);
        const date = new Date();
        var dateToday = (date.getMonth()+1)+'-'+date.getDate()+'-'+date.getFullYear();
        
        component.set("v.selectedDate",new Date());
        
        var selectedDateAdd = date.getFullYear()+'-'+(date.getMonth()+1)+'-'+date.getDate();
        component.set("v.selectedDateAdd", selectedDateAdd);
        
        var selectDate = component.get('c.selectDate'); 
        $A.enqueueAction(selectDate);
        
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
				"January",
				"February",
				"March",
				"April",
				"May",
				"June",
				"July",
				"August",
				"September",
				"October",
				"November",
				"December",
				];
				
				/*document.querySelector(".date h1").innerHTML = months[date.getMonth()];
				
				document.querySelector(".date p").innerHTML = new Date().toDateString();
				*/
				
				component.set("v.year", date.getFullYear());
				component.set("v.month", months[date.getMonth()]);
				component.set("v.dateToday", new Date().toDateString());
				
				let days = "";
				
				/*for (let x = firstDayIndex; x > 0; x--) {
					days += `<div class="prev-date">${prevLastDay - x + 1}</div>`;
				}*/
				
				for (let x = firstDayIndex; x > 0; x--) {
                    var prevMonthDate = (date.getMonth() == 0 ? (date.getMonth()+12)+'-'+`${prevLastDay - x + 1}`+'-'+(date.getFullYear()-1) : date.getMonth()+'-'+`${prevLastDay - x + 1}`+'-'+date.getFullYear());
					var pastDate = (new Date(dateToday) > new Date(prevMonthDate) ? 1 : 0);
        			$A.createComponent(
							"aura:html",{ 
							'tag': 'div',
							'body': `${prevLastDay - x + 1}`,
							'HTMLAttributes':{"class":"prev-date"+(pastDate == 1 ? " disable" : ""), "onclick":(pastDate != 1 ? component.getReference("c.selectDate") : ""), "id":prevMonthDate}
						},
						function(buttonComponent, status, errorMessage){
							if (status === "SUCCESS") {
								// Finding the div by aura:id and pushing newly created component into it.
								var outerDiv = component.find('daysValue').get('v.body');
								outerDiv.push(buttonComponent);
								component.find('daysValue').set('v.body', outerDiv);
							}
						}
					);
				}
				
				/*for (let i = 1; i <= lastDay; i++) {
					if (i === new Date().getDate() && date.getMonth() === new Date().getMonth()){
					days += `<div class="today">${i}</div>`;
				}
					else{
					days += `<div id="${i}">${i}</div>`;
				}
				}*/
				
				for (let i = 1; i <= lastDay; i++) {
					if (i === new Date().getDate() && date.getMonth() === new Date().getMonth() && date.getFullYear() === new Date().getFullYear()){	
                        var monthDateToday = ((date.getMonth()+1) >= 13 ?  (date.getMonth()+1)%12  +'-'+`${i}`+'-'+(date.getFullYear()+1) : (date.getMonth()+1)+'-'+`${i}`+'-'+date.getFullYear());
						$A.createComponent(
								"aura:html",{ 
								'tag': 'div',
								'body': `${i}`,
								'HTMLAttributes':{"class":"today", "onclick":component.getReference("c.selectDate"), "id":monthDateToday}
							},
							function(buttonComponent, status, errorMessage){
								if (status === "SUCCESS") {
									// Finding the div by aura:id and pushing newly created component into it.
									var outerDiv = component.find('daysValue').get('v.body');
									outerDiv.push(buttonComponent);
									component.find('daysValue').set('v.body', outerDiv);
								}
							}
						);
					}
					else{
                        var monthDate = ((date.getMonth()+1) >= 13 ?  (date.getMonth()+1)%12  +'-'+`${i}`+'-'+(date.getFullYear()+1) : (date.getMonth()+1)+'-'+`${i}`+'-'+date.getFullYear());
                        var pastDate = (new Date(dateToday) > new Date(monthDate) ? 1 : 0);
						$A.createComponent(
								"aura:html",{ 
								'tag': 'div',
								'body': `${i}`,
                            	'HTMLAttributes':{/*"id":`${i}`,*/ "onclick": (pastDate != 1 ? component.getReference("c.selectDate") : ""), "id":monthDate, "class": (pastDate == 1 ? "disable" : "")}
							},
							function(buttonComponent, status, errorMessage){
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
                  var nextMonthDate = ((date.getMonth()+2) >= 13 ?  (date.getMonth()+2)%12  +'-'+`${j}`+'-'+(date.getFullYear()+1) : (date.getMonth()+2)+'-'+`${j}`+'-'+date.getFullYear());
					$A.createComponent(
							"aura:html",{ 
							'tag': 'div',
							'body': `${j}`,
                        	'HTMLAttributes':{"class":"next-date", "onclick":component.getReference("c.selectDate"), "id": nextMonthDate}
						},
						function(buttonComponent, status, errorMessage){
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
 
 		/*document.querySelector(".prev").addEventListener("click", () => {
            date.setMonth(date.getMonth() - 1);
            renderCalendar();
        });
            
            document.querySelector(".next").addEventListener("click", () => {
            date.setMonth(date.getMonth() + 1);
            renderCalendar();
        });*/
 
renderCalendar();
},
    
})