({
    doInit : function(component, event, helper) {
        var url_string = location.href;
        
        if(url_string.includes("id")){
            var contactId = (url_string.split('id=')[1]);//.slice(0,18);
            if(contactId){
                component.set('v.contacId',contactId);
                helper.getContactRecord(component, contactId);
                helper.getServices(component, contactId);
            }
        }
    },
    
    
    
   
})