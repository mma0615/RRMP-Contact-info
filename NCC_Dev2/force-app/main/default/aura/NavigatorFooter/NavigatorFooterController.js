({
    handleNavigatorRecord : function(component, event, helper){
        try{
            helper.initNavigatorAttributes(component, event);
        }
        catch(e){
            helper.showToastError(helper.logError('NavigatorFooter: ' + e.message));
        }
    }
})