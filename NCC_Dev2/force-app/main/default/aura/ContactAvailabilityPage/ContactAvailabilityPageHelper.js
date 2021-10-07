({
    setPicklistValues: function(component, event, helper) {
        //specialty picklist values
        var specialty = component.get("c.getFieldValues");
        /*specialty.setParams({
            "fieldName": "Specialty"
        });*/
        specialty.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var specialtyVal = response.getReturnValue();
                component.set("v.specialtyvalues", specialtyVal);
            }
        });
        $A.enqueueAction(specialty);
        
        
    },
    
    getContactRecord : function(component, contId){
        
        var action = component.get("c.searchForContact");
        action.setParams({
            "recordId": contId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();    
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    row.ContactURL = "/" + row.Id;
                    // checking if any account related data in row
                    /*if (row.Account) {
                        row.AccountURL = "/" + row.AccountId;
                        row.AccountName = row.Account.Name;
                    }*/
                }
                // setting formatted data to the datatable
                component.set("v.contact", rows);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    getConAvaRecord : function(component, conavaId){
        
        console.log('conavaId2'+conavaId);
        var action = component.get("c.searchForConAvaRecord");
        action.setParams({
            "recordId": conavaId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();    
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    
                }
                // setting formatted data to the datatable
                //console.log('rows'+JSON.stringify(rows));
                //component.set("v.subject", rows.Specialties__c + ' - ' + rows.Contact__r.Name);
                component.set("v.castartdate", rows.Start_Date_Time__c);
                component.set("v.caenddate", rows.End_Date_Time__c);
                component.set("v.resourcespecialty", rows.Specialties__c);
                component.set("v.timezone", rows.Time_Zone__c);
                component.set("v.status", rows.Status__c);
                
                component.set("v.contactname", rows.Contact__r.Name);
            }
        });
        $A.enqueueAction(action);
    },
    
    getTelemeetRecord : function(component, telemeetId){
        
        var action = component.get("c.searchForTelemeet");
        action.setParams({
            "recordId": telemeetId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();    
               
                var startdate;
                var contId = '';
                var specialtyVal = '';
                // setting formatted data to the datatable
                //console.log('telemeet'+JSON.stringify(rows));
                if(rows.Encounter__c != null){
                    startdate = rows.Encounter__r.Encounter_Date__c;
                    component.set("v.startdate", startdate);
                    component.set("v.enddate", startdate);
                    specialtyVal = rows.Encounter__r.Resource_Specialty__c;
                    window.setTimeout(
                        $A.getCallback(function() {
                           component.set("v.specialty", specialtyVal);
                        }), 100
                    );
               		//component.set("v.specialty", 'Dental');//rows.Encounter__r.Resource_Specialty__c);
                }
                if(rows.Resource_Contact__c != null){
                    contId = rows.Resource_Contact__c;
                    component.find("contact-recordId").set("v.selectedOption", contId);
                    component.find("contact-recordId").set("v.inputValue", rows.Resource_Contact__r.Name);
                    
                	this.getContactRecord(component, contId);
                    component.set("v.contactname", rows.Resource_Contact__r.Name);
                    
                    var contRec = component.find("contact-recordId");
                    //var conId =contRec.get("v.selectedOption");
                    //console.log('conId'+conId);
                }
                
                //component.set("v.subject", rows.Specialties__c + ' - ' + rows.Contact__r.Name);
                component.set("v.castartdate", rows.Start_Date_Time__c);
                component.set("v.caenddate", rows.End_Date_Time__c);
                component.set("v.timezone", rows.Time_Zone__c);
                component.set("v.status", rows.Status__c);
                
                //component.set("v.resourcespecialty", rows.Specialties__c);
                             
                this.getContactAvailability(component, contId, specialtyVal, startdate, startdate);
                   

            }
        });
        $A.enqueueAction(action);
    },
    
    
    getContactAvailability : function(component, contId, specialty, startdate, enddate){
        
        var action = component.get("c.searchForContactAvailability");
        action.setParams({
            "recordId": contId,
            "specialty": specialty,
            "startdate": startdate,
            "enddate": enddate
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();  
                // setting formatted data to the datatable
                component.set("v.contactAvailability", rows);
                if(rows.length == 0){
                    component.set('v.searchButtonClicked', true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    scheduleMeeting : function(component, contactAvailabilityId, area, otherarea, internalnotes, contId){
        
        var action = component.get("c.scheduleMeeting");
        action.setParams({
            "recordId": contactAvailabilityId,
            "area": area,
            "otherarea": otherarea,
            "internalnotes": internalnotes,
            "contId": contId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();  
                // setting formatted data to the datatable
                component.set("v.error", rows);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateTeleMeet: function(component, contactAvailabilityId, telemeetId){
        console.log('updateTeleMeet');
        var action = component.get("c.updateTelemeet");
        action.setParams({
            "contactAvailabilityId": contactAvailabilityId,
            "telemeetId": telemeetId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();  
                // setting formatted data to the datatable
                console.log('rows'+rows);
        		component.set('v.showConfirmDialogCompleted', true);
            } else{
                console.log('ERROR:');
                component.set("v.error", response.getError());
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})