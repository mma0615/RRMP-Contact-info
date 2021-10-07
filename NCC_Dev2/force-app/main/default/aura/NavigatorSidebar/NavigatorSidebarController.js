({
    init : function (component, event, helper) {
        let url_string = document.location.href;
        component.set('v.currentUrl',url_string);
    },

    // afterScriptsLoaded : function(component, event, helper){
    //     helper.getNavigatorDetails(component,event,helper); 
    // },

    handleNavigationItemClick : function(component, event, helper){
        helper.navigationClick(component, event, helper);
    },

    handleNavigatorRecord : function(component, event, helper){
        try{
            helper.initNavigatorAttributes(component, event, helper);
        }
        catch(e){
            console.error('NavigatorSidebar: ', e.message);
        }
    }
});