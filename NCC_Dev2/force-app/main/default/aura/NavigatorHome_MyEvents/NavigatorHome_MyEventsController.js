({
    doInit : function(component, event, helper) {
        try{
            helper.setDefaultMonthDate(component, event, helper);
            helper.getEvents(component, event, helper);
        }
        catch(e){
            console.error(e.message);
        }
    },

    handlePrevious : function(component, event, helper){
        helper.updateMonthDate(component, event, helper, -1);
    },

    handleNext : function(component, event, helper){
        helper.updateMonthDate(component, event, helper, 1);
    },

})