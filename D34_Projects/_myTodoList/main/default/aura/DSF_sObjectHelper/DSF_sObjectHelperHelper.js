/*
 * Created by ahasic on 10/28/2019.
 */
({
    getSelectOptions: function(component) {
        var action = component.get("c.getSelectOptions");
        action.setParams({
            objObject: {
                sobjectType: component.get("v.object")
            },
            fld: component.get("v.fields"),
            sortOptions: component.get("v.orderByFields") == "true",
            defaultOption: component.get("v.addDefaultOption")
        });

        var options = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            var field = component.get("v.fields");
            var outputType = component.get("v.outputType");

            if (state === "SUCCESS") {
                var responseValues = response.getReturnValue();

                if (outputType == "LabelValue") {
                    for (var i = 0; i < responseValues.length; i++) {
                        options.push({
                            class: "optionClass",
                            label: responseValues[i],
                            value: responseValues[i]
                        });
                    }

                    component.set("v.output", options);
                } else {
                    component.set("v.output", response.getReturnValue());
                }
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    getSObject: function(component) {
        var action = component.get("c.getSObject");
        var outputType = component.get("v.outputType");
        var fields = component.get("v.fields");
        var addDefaultOption = component.get("v.addDefaultOption");

        action.setParams({
            objectName: component.get("v.object"),
            fields: component.get("v.fields"),
            conditions: component.get("v.conditions"),
            sortFields: component.get("v.orderByFields"),
            groupByFields: component.get("v.groupByFields"),
            recordCount: component.get("v.limit")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {

                if (outputType == "LabelValue") {
                    var responseValues = response.getReturnValue();
                    var valueIdField =
                        component.get("v.valueIdField") == undefined ?
                        fields :
                        component.get("v.valueIdField");

                    var options = [];
                    if (addDefaultOption) {
                        options.push({
                            class: "optionClass",
                            label: "All",
                            value: null
                        });
                    }

                    for (var i = 0; i < responseValues.length; i++) {
                        options.push({
                            class: "optionClass",
                            label: responseValues[i][fields],
                            value: responseValues[i][valueIdField]
                        });
                    }

                    component.set("v.output", options);
                } else {
                    var options = response.getReturnValue();
                    if (addDefaultOption) {
                        var myObject = new Object();
                        let defaultOption = component.get("v.defaultOption").split(",");
                        myObject[defaultOption[0]] = defaultOption[1];
                        options.unshift(myObject);
                    }
                    if (outputType == "Single") {
                        if (options.length > 0) component.set("v.output", options[0]);
                        else component.set("v.output", null);
                    } else component.set("v.output", options);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    saveSObject: function(component) {
        var action = component.get("c.saveSObject");
        //debugger;
        action.setParams({
            objectValue: component.get("v.output")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {} else if (state === "ERROR") {}
        });

        $A.enqueueAction(action);
    },

    saveSObjectList: function(component) {
        this.saveSObjectList(component, component.get("v.sObjectList"));
    },

    saveSObjectList: function(component, sobjectList) {
        var action = component.get("c.savesObjectList");
        action.setParams({
            sObjectsList: sobjectList
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('sObjectsList inserted succesffully!');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    } else if (errors[0] && errors[0].pageErrors.length > 0) {
                        errors[0].pageErrors.forEach(function(pageError) {
                            console.log('Error Status Code = ' + pageError.statusCode);
                            console.log('Error Message = ' + pageError.message);
                        });
                    }
                } else {
                    console.log("Unknown error");
                }
            }

            //set response value to component attribute if any conditional logic needs to be done on error or success
            component.set("v.actionResponse", response);
        });

        $A.enqueueAction(action);
    },

    updateSObjectList: function(component, sobjectList) {
        var action = component.get("c.updateObjectList");
        action.setParams({
            sObjectsList: sobjectList
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                console.log('sObjectsList updated succesffully!');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    } else if (errors[0] && errors[0].pageErrors.length > 0) {
                        errors[0].pageErrors.forEach(function(pageError) {
                            console.log('Error Status Code = ' + pageError.statusCode);
                            console.log('Error Message = ' + pageError.message);
                        });
                    }
                } else {
                    console.log("Unknown error");
                }
            }

            //set response value to component attribute if any conditional logic needs to be done on error or success
            component.set("v.actionResponse", response);
        });

        $A.enqueueAction(action);
    }
});