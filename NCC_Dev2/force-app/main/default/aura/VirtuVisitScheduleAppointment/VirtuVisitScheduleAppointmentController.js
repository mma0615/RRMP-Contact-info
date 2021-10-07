({
    handleMouseHover: function(component, event, helper) {
        var my = event.srcElement.id;
        component.set("v.reId",my);
        helper.getDoctorLayout(component, event, helper)
    },
    handleMouseOut: function(component, event, helper) {
        component.set("v.hoverRow",-1);
        component.set("v.togglehover",false);
    },

	 doInit : function(component, event, helper) {
        var url_string = location.href;
        
        if(url_string.includes("id")){
            var contactId = (url_string.split('id=')[1]).slice(0,18);
            var serviceId = '';
            var practiceId = '';
            var reason = '';
            var displayPractice = false;
            //check service id in URL
            if(url_string.includes('serviceId=')){
                serviceId = (url_string.split('serviceId=')[1]).slice(0,18);
            }
            //check practice id in URL
            if(url_string.includes('practiceId=')){
                practiceId = (url_string.split('practiceId=')[1]).slice(0,18);
            }
            if(url_string.includes('reason=')){
                reason = (url_string.split('reason=')[1]);
                reason = reason.split('&')[0];
            }
            if(url_string.includes('displayPractice')){
                displayPractice = true;
            }
            if(contactId != null){
                component.set('v.contactId',contactId);
                helper.getContactRecord(component, contactId);
                //Selecting Service
                if(serviceId != '' && reason == '' && practiceId == '' && !displayPractice){
                    component.set("v.serviceId", serviceId);
                    helper.getServiceRecord(component, serviceId);
                    //get reasons in Service Record selected
                    //helper.setPicklistValues(component, "Encounter Reason");
                }
                //if Selected Service has displayPractice = true
                else if(serviceId != '' && displayPractice){
                    component.set("v.displayPractice", displayPractice);
                    helper.getServiceRecord(component, serviceId);
                    helper.getServicePractices(component, serviceId);
                }
                //Selecting Practice
                else if(practiceId != '' && reason == ''){
                    component.set("v.practiceId", practiceId);
                    component.set("v.serviceId", serviceId);
                    //helper.getPracticeServices(component, practiceId);
                    helper.getPracticeDoctors(component, serviceId, practiceId);
                }
                //Selecting Service and Reason 
                else if(serviceId != '' && reason != ''){
                    component.set("v.serviceId", serviceId);
                    component.set("v.reason", reason);
                    reason = reason.replace("+", " ");
                    helper.getAllDoctors(component, serviceId, reason);
                }
                //Show all Services and Practice Management
                else{
                    helper.getAllServices(component, contactId);
                    //helper.getAllPracticeManagement(component, contactId);
                }
            }
        }
	},
})