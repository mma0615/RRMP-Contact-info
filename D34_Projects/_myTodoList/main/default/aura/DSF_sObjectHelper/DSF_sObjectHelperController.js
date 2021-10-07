/**
 * Created by ahasic on 10/28/2019.
 */
({
    doInit: function(component, event, helper) {

        if (component.get('v.methodName') == 'getSelectOptions') {
            helper.getSelectOptions(component);
        }

        if (component.get('v.methodName') == 'getSObject') {
            helper.getSObject(component);
        }

        if (component.get('v.methodName') == 'saveSObject') {
            helper.saveSObject(component);
        }

        if (component.get('v.methodName') == 'saveSObjectList') {
            helper.saveSObjectList(component);
        }
    },

    saveSObjects: function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.saveSObjectList(component, params.listOfObjects);
        }
    },

    updateSObjects: function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            helper.updateSObjectList(component, params.listOfObjects);
        }
    }
})