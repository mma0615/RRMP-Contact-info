({
    doInit : function(component, event, helper) {
        
        var actions = component.get("c.getTrendingArticles");
        actions.setCallback(this, function(response) {
            var states = response.getState();
            if(states === 'SUCCESS') {
                
                var getResult = JSON.parse(response.getReturnValue());
                
                var mapOfListValues1 = [];
                for (let key in getResult) {
                    mapOfListValues1.push({ key: key, value: getResult[key] });
                    
                }
                if(getResult.length == 0){
                    component.set("v.showData",true);
                }
                else{
                    component.set("v.showData",false);
                }
                component.set("v.mostrecent",mapOfListValues1);
            }
            else {
                alert('Error in getting mostrecent');
            }
        });
        $A.enqueueAction(actions);
        
        var actions = component.get("c.allArticles");
        actions.setCallback(this, function(response) {
            var states = response.getState();
            if(states === 'SUCCESS') {
                component.set("v.allArticles",response.getReturnValue());
            }
            else {
                alert('Error in getting allArticles');
            }
        });
        $A.enqueueAction(actions);
        
        
    },
    
    
    navigateToMyComponent : function(component, event, helper) {
        var showDesc= false; 
        var ctarget = event.currentTarget;
        var id = ctarget.dataset.value;
        console.log('valueee id ' ,id );
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": id,
            "slideDevName": "Detail"
        });
        navEvt.fire();
        console.log('navigate');
        
    },
    
    
    createContent: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "https://cfkm1-nationalcoordinationcenter.cs26.force.com/coronafacts/s/corona-facts-articles"
        });
        urlEvent.fire();
    },
    
    handleClick : function (component, event, helper) {
        var showDesc= true; 
        component.set("v.showDesc",showDesc); 
    },
    
    trendChange: function (component, event, helper) 
    {
        var sourceattributeing=event.currentTarget.value;
        console.log('sourceattributeing ' ,sourceattributeing)
        if(sourceattributeing=='Views')
        {	component.set('v.selectedTrend',false);
         var actions = component.get("c.getTrendingArticles");
         actions.setCallback(this, function(response) {
             var states = response.getState();
             if(states === 'SUCCESS') {
                 console.log('Views')
                 var getResult = JSON.parse(response.getReturnValue());
                 
                 var mapOfListValues1 = [];
                 for (let key in getResult) {
                     mapOfListValues1.push({ key: key, value: getResult[key] });
                     
                 }
                 if(getResult.length == 0){
                     component.set("v.showData",true);
                 }
                 else{
                     component.set("v.showData",false);
                 }
                 component.set("v.mostrecent",mapOfListValues1);
                 console.log('Views ' ,mapOfListValues1);
                 // component.set("v.mostrecent",response.getReturnValue());
             }
             else {
                 alert('Error in getting data');
             }
         });
         $A.enqueueAction(actions); 
        }
        else if(sourceattributeing=='Recent')
        {	component.set('v.selectedTrend',false);
         var actions = component.get("c.getRecentArticles");
         actions.setCallback(this, function(response) {
             var states = response.getState();
             if(states === 'SUCCESS') {
                 console.log('Recent')
                 var getResult = JSON.parse(response.getReturnValue());
                 
                 var mapOfListValues1 = [];
                 for (let key in getResult) {
                     mapOfListValues1.push({ key: key, value: getResult[key] });
                     
                 }
                 if(getResult.length == 0){
                     component.set("v.showData",true);
                 }
                 else{
                     component.set("v.showData",false);
                 }
                 component.set("v.mostrecent",mapOfListValues1);
                 console.log('Recent ' ,mapOfListValues1);
                 //component.set("v.mostrecent",response.getReturnValue());
             }
             else {
                 alert('Error in getting data');
             }
         });
         $A.enqueueAction(actions);  
        }
            else if(sourceattributeing=='Rated')
            {	component.set('v.selectedTrend',true);
             var actions = component.get("c.getMostRatedArticles");
             actions.setCallback(this, function(response) {
                 var states = response.getState();
                 if(states === 'SUCCESS') {
                     console.log('Rated')
                     var getResult = JSON.parse(response.getReturnValue());
                     
                     var mapOfListValues1 = [];
                     for (let key in getResult) {
                         mapOfListValues1.push({ key: key, value: getResult[key] });
                         
                     }
                     if(getResult.length == 0){
                         component.set("v.showData",true);
                     }
                     else{
                         component.set("v.showData",false);
                     }
                     component.set("v.mostrecent",mapOfListValues1);
                     console.log('Rated ' ,mapOfListValues1);
                     //component.set("v.mostrecent",response.getReturnValue());
                 }
                 else {
                     alert('Error in getting data');
                 }
             });
             $A.enqueueAction(actions); 
            }
        
        
    }
})