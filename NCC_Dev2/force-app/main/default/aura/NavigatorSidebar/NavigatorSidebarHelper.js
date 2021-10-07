({
    // TODO: update tab image dynamically
    navigationClick : function(component, event, helper){
        const navigationName = event.getParam('navigationName');
        const navigationLink = event.getParam('navigationLink');
        console.log(navigationLink);
        let navigationData = component.get('v.navigationData');
        navigationData = _.map(navigationData, function(item){
            if(item.name !== navigationName){
                item.isSelected = false;
                return item;
            }
            item.isSelected = true;
            return item;
        })
        component.set('v.navigationData', navigationData);
        // if navigation item has a link redirect to the link
        if(navigationLink){
            location.href = navigationLink;
        }
    },

    initNavigatorAttributes : function(component, event, helper){
        const url_string = document.location.href;
        const navTabs = event.getParam('navigatorTabs');
        const contact = event.getParam('contact');
        const navigatorRecord = event.getParam('navigatorRecord');
        if(navTabs){
            let items = [];
            for (let i = 0; i < navTabs.length; i++) {
                let tab = navTabs[i];
                tab.label = tab.Name;
                tab.name = tab.Name.toLowerCase().replace(' ','_');
                if(tab.Page_URL__c){
                    let contactId = contact.Contact_Id__c;
                    let token = contact.Login_Token__c;
                    tab.href = tab.Page_URL__c+'?id='+navigatorRecord.Id+'&contactId='+contactId+'&token='+token;
                    
                    let baseUrl = url_string.substring(0,url_string.indexOf('?'));
                    if(baseUrl === tab.Page_URL__c){
                        tab.isSelected = true;
                    }
                }
                if(tab.Expanded_Items__c){
                    tab.Expanded_Items__c = tab.Expanded_Items__c.split('\n');
                }
                items.push(tab);
            }
            //populate sidebar
            component.set('v.navigationData', items);
        }
        if(navigatorRecord){
            component.getElement().style.setProperty('--theme-color1', navigatorRecord.Theme_Color_1__c);
            component.getElement().style.setProperty('--theme-color2', navigatorRecord.Theme_Color_2__c);
            component.getElement().style.setProperty('--theme-color3', navigatorRecord.Theme_Color_3__c);
            component.getElement().style.setProperty('--theme-color3-intense', helper.increaseBrightness(navigatorRecord.Theme_Color_3__c, -100));
        }

    },
    
    increaseBrightness : function(hex, percent){
        // strip the leading # if it's there
        hex = hex.replace(/^\s*#|\s*$/g, '');
    
        // convert 3 char codes --> 6, e.g. `E0F` --> `EE00FF`
        if(hex.length == 3){
            hex = hex.replace(/(.)/g, '$1$1');
        }
    
        var r = parseInt(hex.substr(0, 2), 16),
            g = parseInt(hex.substr(2, 2), 16),
            b = parseInt(hex.substr(4, 2), 16);
    
        return '#' +
           ((0|(1<<8) + r + (256 - r) * percent / 100).toString(16)).substr(1) +
           ((0|(1<<8) + g + (256 - g) * percent / 100).toString(16)).substr(1) +
           ((0|(1<<8) + b + (256 - b) * percent / 100).toString(16)).substr(1);
    },

    showToastError : function(message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type" : "error",
            "message": message
        });
        toastEvent.fire();
    },

    logError : function(errors){
        if (errors) {
            if (errors[0] && errors[0].message) {
                // log the error passed in to AuraHandledException
                let errorMessage = "Error message: " + errors[0].message
                console.log(errorMessage);
                return errorMessage;
            }
            else{
                console.log("Unknown error", JSON.stringify(errors));
                return "Unknown error", JSON.stringify(errors);
            }
        } else {
        	console.log("Unknown error", JSON.stringify(errors));
            return "Unknown error", JSON.stringify(errors);
        }
	},

})