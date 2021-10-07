({
	
    getInTouchPublic : function(component, event, helper) { 

        /*let navService = component.find("navService"); 

        let pageReference = 
        {
            type: 'comm__namedPage',
            attributes:
            {
                pageName: 'get-in-touch'
            },
            "state": {
                'language': helper.getParameterByName('language')
            }
        };

        navService.navigate(pageReference); 
        */
        
        let evt = $A.get("e.c:DSF_ShowContactUsEVT");
        evt.setParams({"showContactUs": true});
        evt.fire();  
    }
 
})