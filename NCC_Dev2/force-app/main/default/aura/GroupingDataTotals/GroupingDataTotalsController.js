({
    doInit : function(component, event, helper) {
		var factMap = component.get("v.factMap");
		if( factMap ){
			var groupingKey = component.get("v.groupingKey");
            component.set("v.dataTotals", factMap[groupingKey+"!T"].aggregates)
            console.log('***dataTotals: ' + JSON.stringify( component.get("v.dataTotals")));
		}

		var columnLabels = component.get("v.columnLabels");
		var dataTotals = component.get("v.dataTotals");
		var dataTotalWLabels = new Array();
		var int = 0
		
		dataTotals.forEach(record => 
            {                
                var temprecord = JSON.parse(JSON.stringify(record));
                console.log('*** Before Record: ' + JSON.stringify(record)); 
                temprecord.value = temprecord.label;
				temprecord.label = columnLabels[int];
                
                console.log('*** After Record: ' + JSON.stringify(temprecord));
                dataTotalWLabels.push(temprecord);
				int = int + 1;
            });
		
		component.set("v.dataTotals", dataTotalWLabels)
		console.log('****columnLabels: ' + columnLabels);
		console.log('****dataTotalWLabels: ' + dataTotalWLabels);
		console.log('****dataTotals: ' + component.get("v.dataTotals"));	
			
	},
})