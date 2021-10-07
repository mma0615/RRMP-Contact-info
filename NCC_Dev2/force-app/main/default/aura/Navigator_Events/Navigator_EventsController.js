({
    doInit : function(component, event, helper) {
        
        let sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        let sURLVariables = sPageURL.split("&"); //Split by & so that you get the key value pairs separately in a list
        let sParameterName;
        let i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split("="); //to split the key from the value.

            if (sParameterName[0] === "contactId") {
                component.set("v.contactId", sParameterName[1]);
            }
            if (sParameterName[0] === "filter") {
                component.set("v.filter", sParameterName[1]);
            }

        }
        let contact_Id = component.get("v.contactId");
        let eventFilter = component.get("v.filter");

        if(eventFilter !== undefined && eventFilter !== ""){
            let strFilter = eventFilter.replace("+", " ");
            component.set("v.eventHeader", "My " + strFilter);
        }

        helper.retrieveContactsEvent(component, contact_Id);
    }
})