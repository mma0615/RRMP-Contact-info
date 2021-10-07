({
    doInit: function(component, event, helper) {
        var url = new URL(window.location.href);
        
         var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            console.log('!@# Parameter: ' + sParameterName[0] + ' - ' + sParameterName[1]);
            if (sParameterName[0] === 'journeyId') {
                //sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
                component.set("v.journeyID",sParameterName[1] );
            }
        }
        
        
        var journeyId;
        
        if(component.get("v.journeyID") == null){
            journeyId = 'a581F000000OLuZQAW';
        }else{
            journeyId = component.get("v.journeyID");  
        }
        
        console.log('!@# journeyID: ' + journeyId);
        
        helper.getUserJourney(component,journeyId);
        
    }
})