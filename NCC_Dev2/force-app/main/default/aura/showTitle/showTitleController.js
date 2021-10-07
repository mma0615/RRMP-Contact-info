({
    doInit:function(component, event, helper) {
        var dataId=component.get('v.recordId');
        component.set('v.articleids',dataId);
        console.log('dataId',dataId);                
        //ShowTitle
		var actionTitle = component.get("c.showTitle");
        actionTitle.setParams({ getId : dataId})
        actionTitle.setCallback(this, function(response) {
            var states = response.getState();
            if(states === 'SUCCESS') {
                component.set("v.title",response.getReturnValue());
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(actionTitle);
        
    },
})