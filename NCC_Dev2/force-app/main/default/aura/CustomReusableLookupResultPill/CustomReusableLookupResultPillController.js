({   
    clear : function(component, event, helper){
        var selectedRecord = component.get("v.selectedRecord");
        
        var parentEvent = component.getEvent("unselectedRecordEvent");
        parentEvent.setParams({"unselectedRecord" : selectedRecord});  
        parentEvent.fire();

        component.set("v.selectedRecord", {});
    },

    doInit : function(component, event, helper){
        console.log(JSON.stringify(component.get("v.listOfSelectedRecords")));
    }
})