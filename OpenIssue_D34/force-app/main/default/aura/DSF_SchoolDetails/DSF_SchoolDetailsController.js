({
    doInit: function (component, event, helper) {
        helper.getSchools(component, event, helper);
        helper.getCurrentApplication(component, event, helper);
    },

    openModal  : function (component, event, helper) {
        let backdrop = component.find("backdrop");
        let modal    = component.find("modal");
        $A.util.addClass(backdrop, "slds-backdrop--open");
        $A.util.addClass(modal, "slds-fade-in-open"); 
    },

    closeModal : function (component, event, helper) {
        helper.closeModal(component, event, helper);
    }, 

    updateCollege: function(component, event, helper) {
        helper.updateApp(component, event, helper);
    }, 

    userAndApplicationLoaded : function (component, event, helper) {
        var currentUser = component.get('v.currentUser');
        var application = component.get('v.application');

        if(currentUser == null || currentUser == undefined || application == null || application == undefined) 
            return;

        if(currentUser.Contact != null) {
            var portalPageAccess = currentUser.Contact.Application_Portal_Page_Access__c;
    
            let disabledBasedOnApplication = true;
    
            if(application != null && application.School_Name__c != null && application.School_Name__r.Name != null) {
                var accountImgName = application.School_Name__r.Name.toLowerCase().replace(/& /g,'and ').replace(/- /g,'').replace(/ /g,'_');
                component.set('v.collegeImageName', accountImgName);
                disabledBasedOnApplication = false;
            }
    
            if( !(portalPageAccess == 'Current Submitted for Review' || portalPageAccess == 'Current Finalist') ){
                disabledBasedOnApplication = true;
            } else {
                disabledBasedOnApplication = false;
            }
                
            $A.localizationService.getToday($A.get("$Locale.timezone"), function (today) {
                let endDate = $A.localizationService.formatDate($A.get("$Label.c.DSF_College_Choice_Edit_End_Date"));
                today = $A.localizationService.formatDate(today);
                let disabledAfterEndDate = $A.localizationService.isAfter(today, endDate);
                component.set('v.disableChangeBtn', disabledAfterEndDate || disabledBasedOnApplication);
            });                
        }         
    }, 

})