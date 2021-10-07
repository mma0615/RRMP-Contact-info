({
	init : function(component, event, helper) {
		try{
			helper.getNavigatorDetails(component, helper);
		}
		catch(e){
			helper.showToastError(helper.logError(e.message));
		}
	}
})