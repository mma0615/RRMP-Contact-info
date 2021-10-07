({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        //console.log('telemeetId'+recordId);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:DoctorAvailabilityBuilder",
            componentAttributes: {
                contactId : recordId
            }
        });
        evt.fire();
    },
})