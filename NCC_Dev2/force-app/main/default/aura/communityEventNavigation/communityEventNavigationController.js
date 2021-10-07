({
    doInit : function(component, event, helper) {
        
        //helperhelper.isIphone(component, event);
        var parameterURL = '';
        const queryString = decodeURIComponent(window.location.search);
        var eventId = (queryString.split('id=')[1]).split('&')[0];

        component.set('v.eventId', eventId);
        parameterURL = 'id=' + eventId;
        
        var emailstr = '';
        try {
            emailstr = (queryString.split('email=')[1]).split('&')[0];
            parameterURL = parameterURL + '&email=' + emailstr;
        }
        catch(err) {
            emailstr = '';
        }
        
        var PM = '';
        try {
            PM = (queryString.split('pm=')[1]).split('&')[0];
            parameterURL = parameterURL + '&pm=' + PM;
        }
        catch(err) {
            PM = '';
        } 

        //PM='EM-001766';
        //eventId='f3rpn98oEOZ';

        component.set('v.parameterURL', parameterURL);


        var action = component.get("c.getEventDetails");
        
        action.setParams({ 
            eventId : eventId
        });

        action.setCallback(this, function(response){
            console.log('callbek');
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();
                component.set('v.backgroundImageURL', resultEvent.HeroUrl);
                component.set('v.campaignLogoURL', resultEvent.CampaignLogoUrl);
                component.set('v.title', resultEvent.title);
                component.set('v.subtitle', resultEvent.subtitle);
                
                component.set('v.homePageTitle', 'HOME');
                component.set('v.sessionPageTitle', 'SESSIONS');
                component.set('v.materialsPageTitle', 'MATERIALS');
                component.set('v.issueTrackerPageTitle', 'ISSUE TRACKER');
                component.set('v.parkingPageTitle', 'PARKING LOT');
                component.set('v.surveyPageTitle', 'SURVEY');
                component.set('v.contactUsPageTitle', 'CONTACT US');
                
                if(resultEvent.homePageTitle != null || resultEvent.homePageTitle !=  undefined){
                    component.set('v.homePageTitle', resultEvent.homePageTitle);
                }
                if(resultEvent.sessionPageTitle != null || resultEvent.sessionPageTitle !=  undefined){
                    component.set('v.sessionPageTitle', resultEvent.sessionPageTitle);
                }
                if(resultEvent.materialsPageTitle != null || resultEvent.materialsPageTitle !=  undefined){
                    component.set('v.materialsPageTitle', resultEvent.materialsPageTitle);
                }
                if(resultEvent.issueTrackerPageTitle != null || resultEvent.issueTrackerPageTitle !=  undefined){
                    component.set('v.issueTrackerPageTitle', resultEvent.issueTrackerPageTitle);
                }
                if(resultEvent.parkingPageTitle != null || resultEvent.parkingPageTitle !=  undefined){
                    component.set('v.parkingPageTitle', resultEvent.parkingPageTitle);
                }
                if(resultEvent.surveyPageTitle != null || resultEvent.surveyPageTitle !=  undefined){
                    component.set('v.surveyPageTitle', resultEvent.surveyPageTitle);
                }
                if(resultEvent.contactUsPageTitle != null || resultEvent.contactUsPageTitle !=  undefined){
                    component.set('v.contactUsPageTitle', resultEvent.contactUsPageTitle);
                }
                
                if(resultEvent.eventPages){
                    var evantPages = resultEvent.eventPages;
                    if(evantPages.includes('Home')){
                        component.set('v.showHome',true);
                    }
                    if(evantPages.includes('Sessions')){
                        component.set('v.showSession',true);
                    }
                    if(evantPages.includes('Materials')){
                        component.set('v.showMaterials',true);
                    }
                    if(evantPages.includes('Issue Tracker')){
                        component.set('v.showIssue',true);
                    }
                    if(evantPages.includes('Parking Lot')){
                        component.set('v.showParking',true);
                    }
                    if(evantPages.includes('Survey')){
                        component.set('v.showSurvey',true);
                    }
                    if(evantPages.includes('Contact Us')){
                        component.set('v.showContactUs',true);
                    }
                }else{
                    component.set('v.showHome',true);
                    component.set('v.showSession',true);
                    component.set('v.showMaterials',true);
                    component.set('v.showIssue',true);
                    component.set('v.showParking',true);
                    component.set('v.showSurvey',true);
                    component.set('v.showContactUs',true);
                }

                component.set('v.showLogin', resultEvent.showLogin);    

                if(PM != ''){
                    component.set('v.showPhoto', true); 
                    helper.getUserDetail(component, event,PM);
                }

            }
        });

        $A.enqueueAction(action);
        

        
    },
    
    toggleLogin :  function(component, event, helper) {
        var cmpTarget = component.find('compass-topnav-login-card');
        $A.util.toggleClass(cmpTarget, 'compass-topnav-login-dropdown-inactive');
    },

    toggleMobileLogin :  function(component, event, helper) {
        var cmpTarget = component.find('compass-topnav-login-mobile-back');
        var cmpTarget2 = component.find('compass-topnav-mobile-menu');

        $A.util.toggleClass(cmpTarget, 'compass-topnav-login-dropdown-inactive');
        $A.util.toggleClass(cmpTarget2, 'compass-topnav-login-dropdown-inactive');
        
    },

    togglePhoto :  function(component, event, helper) {
        var cmpTarget = component.find('compass-topnav-photo-card');
        $A.util.toggleClass(cmpTarget, 'compass-topnav-photo-dropdown-inactive');
    },
    actionSubmit :  function(component, event, helper) {

        var emailstr = component.get("v.email");
        var eventId = component.get("v.eventId");
        var action = component.get("c.getParticipantDetail");

        action.setParams({ 
            emailstr : emailstr,
            eventId : eventId
        });

        action.setCallback(this, function(response){

            var state = response.getState();
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();
                var URL = window.location.href;
        
                window.location.replace(URL + '&pm=' + resultEvent.Name);
            }
        });

        $A.enqueueAction(action);

    },

    actionLogout :  function(component, event, helper) {
        window.location.replace(window.location.search.replace(/[\?&]pm=[^&]+/, '').replace(/^&/, '?') + window.location.hash);
    },

    handleUploadFinished: function (cmp, event) {
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded");
    }



    
})