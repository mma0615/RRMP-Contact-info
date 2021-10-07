({
    isIphone : function(component, event) {
        var isPhone = $A.get("$Browser.isPhone");
        var onPhone = false;
        component.set('v.isPhone', isPhone);
        
        if(isPhone){
            onPhone = true;
            component.set('v.isPhoneVal', 'background');
        }
        else{
            component.set('v.isPhoneVal', 'background-image');
        }
        return onPhone;
    },

    getUserDetail : function(component, event,PM) {

        var cmpTarget = component.find('compass-topnav-login');
        var cmpTarget2 = component.find('compass-topnav-profile');
        var cmpTarget4 = component.find('compass-topnav-mobile-menu-login');
        var cmpTarget5 = component.find('compass-topnav-mobile-menu-logout');
        var cmpTarget6 = component.find('compass-topnav-mobile-menu-name');
 
        //var cmpTarget3 = component.find('compass-topnav-mobile-menu-avatar');
        //var cmpTarget7 = component.find('compass-topnav-mobile-menu-avatar2');
        
        var action = component.get("c.getParticipantDetailByNumber");

        action.setParams({ 
            participantNumber : PM,
        });

        action.setCallback(this, function(response){
            console.log('callback');
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var resultEvent = response.getReturnValue();

                console.log('----resultEvent' +resultEvent);

                component.set('v.FirstName',resultEvent.Member_Contact__r.FirstName);
                component.set('v.LastName',resultEvent.Member_Contact__r.LastName);


                console.log('---------- Profile_Picture_URL__c' + resultEvent.Member_Contact__r.Profile_Picture_URL__c);

                if(resultEvent.Member_Contact__r.Profile_Picture_URL__c != '' && resultEvent.Member_Contact__r.Profile_Picture_URL__c != null){
                    component.set('v.ProfilePicURL',resultEvent.Member_Contact__r.Profile_Picture_URL__c);
                }else{
                    console.log('---------- no picture');
                    //component.set('v.ProfilePicURL','');
                }

                component.set('v.ContactId',resultEvent.Member_Contact__c);
                console.log('----------resultEvent.Member_Contact__c ' + resultEvent.Member_Contact__c);
                $A.util.toggleClass(cmpTarget, 'compass-topnav-login-dropdown-inactive');
                $A.util.toggleClass(cmpTarget2, 'compass-topnav-login-dropdown-inactive');
                $A.util.toggleClass(cmpTarget4, 'compass-topnav-login-dropdown-inactive');
                $A.util.toggleClass(cmpTarget5, 'compass-topnav-login-dropdown-inactive');
                $A.util.toggleClass(cmpTarget6, 'compass-topnav-login-dropdown-inactive');

                //$A.util.toggleClass(cmpTarget3, 'compass-topnav-login-dropdown-inactive');
                //$A.util.toggleClass(cmpTarget7, 'compass-topnav-login-dropdown-inactive');
            }else{
                console.log('----no user found');
            }
        });

        $A.enqueueAction(action);
    },



})