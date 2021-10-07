({
    doInit : function(component, event, helper) {
        try{
            helper.initializeAttributes(component, event, helper);
        }
        catch(e){
            console.error('NavigatorHome_About: ' + e.message);
        }
    }
})