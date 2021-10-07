({
    doInit : function(component, event, helper) {
        component.set("v.currentYear", new Date($A.get("$Label.c.DSF_App_Season_End_Date")).getFullYear());

        helper.loadFafsaFromSF(component, event, helper);
    },
    onAppListLoad: function (component, event, helper) {
        component.set('v.application', component.get('v.applicationList')[0]);
    },
  
    onStudentTermLoad: function (component, event, helper) {
        component.set('v.studentTerm', component.get('v.studentTermList')[0]);
    },

    onStartEndDateConfLoad: function (component, event, helper) {
        let confList =  component.get('v.startEndDateConfList');
        let confMap = {};
        for(let i = 0; i < confList.length; i++) {
            confMap[confList[i].MasterLabel] = confList[i];
        }
        component.set('v.startEndDateConfMap', confMap);
    },

    handleCheckboxChange: function (component, event, helper) {
        let isChecked = event.getSource().get('v.checked');
        let display = isChecked ? 'none' : 'flex';
        let toDoListItems = document.querySelectorAll('div[data-isPending="false"]');
        toDoListItems.forEach(el => {
            el.style.display = display;
        });
    },

    doApplicationUpdate: function (component, event, helper) {
        let fieldToUpdateMap = event.getParam("fieldToUpdate");
        let applicationToUpdate = component.get("v.applicationToUpdate");
        for (let field in fieldToUpdateMap){
            applicationToUpdate[field] = fieldToUpdateMap[field]
        }
        component.find("applicationUpdater").saveRecord(function(saveResult) {
            if(saveResult.state === 'SUCCESS' || saveResult.state === 'DRAFT') {
                component.find('applicationLoader').reloadList();
            }
        })
    },

    refreshFafsa: function (component, event, helper) {
        helper.loadFafsaFromSF(component, event, helper);
    },
})