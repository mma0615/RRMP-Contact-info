({
	setLabel : function(component, event, helper) {
		var level = component.get("v.level")
		var groupingLevelToLabel = component.get("v.groupingLevelToLabel");
		if( groupingLevelToLabel ){
			component.set("v.fieldLabel", groupingLevelToLabel[level] );
			//console.log('***groupingLevelToLabel[level]: ' + JSON.stringify(groupingLevelToLabel[level]));	
		}

		// Set number of total columns
		var factMap = component.get("v.factMap");
		if( factMap )
		{
			console.log('returnValue.factMap: ' + JSON.stringify(factMap));
			component.set("v.numTotalColumns", factMap["T!T"].aggregates.length);
		}

		console.log('***numColumns: ' + component.get("v.numColumns"));
		console.log('***numTotalColumns: ' + component.get("v.numTotalColumns"));
		console.log('***groupings: ' + JSON.stringify(component.get("v.groupings")));
		console.log('***level: ' + level);
		console.log('***groupingLevelToLabel: ' + JSON.stringify(component.get("v.groupingLevelToLabel")));
		console.log('***factMap: ' + JSON.stringify(component.get("v.factMap")));
		
	}
})