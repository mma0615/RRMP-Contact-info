/**
 * Created by ahasic on 9/24/19.
 */
({
    doInit : function(component, event, helper) {

        //Split fields and create array of String for passing to LDS
        var fields = component.get('v.fields');
        var fieldsSplit = fields.split(',');
        var output = new Array();

        fieldsSplit.forEach(function(f){
            output.push(f);
        });

        if(output.length > 0){
            component.set('v.queryFields', output);
        }

        //Check current URL and set User Id appropriately
        var urlToCheck = window.location.hostname;
        urlToCheck = urlToCheck.toLowerCase();
        
        if(urlToCheck.indexOf('sitepreview') >= 0 || urlToCheck.indexOf('livepreview') >= 0){
            //Set default User Id when testing using Community Builder
            component.set('v.userId', $A.get("$Label.c.DSF_Default_User"));
        } else {
            component.set('v.userId', $A.get("$SObjectType.CurrentUser.Id"));
        }
    },
})