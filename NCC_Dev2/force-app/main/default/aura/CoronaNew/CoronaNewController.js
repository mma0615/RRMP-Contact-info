({
    doInit : function(component, event, helper)
    {
        component.set('v.toggleSpinner', true);
        var action = component.get('c.onLoadmethod');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                var pageSize = component.get("v.pageSize");
                var getResult = JSON.parse(response.getReturnValue());
                component.set('v.toggleSpinner', false);
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
                
                if(getResult.length > 8){
                    component.set("v.showAllButtons",true);
                }
                component.set("v.ListOfArticles",mapOfListValues1);
                component.set("v.data",mapOfListValues1);  
                
                component.set("v.totalRecords", component.get("v.ListOfArticles").length);
                component.set("v.startPage", 0);                
                component.set("v.endPage", pageSize - 1);
                var PagList = [];
                for ( var i=0; i< pageSize; i++ ) {
                    if ( component.get("v.ListOfArticles").length> i )
                        PagList.push(JSON.parse(response.getReturnValue())[i]);    
                }
                var mapOfListValues2 = [];
                for (let key in PagList) {
                    mapOfListValues2.push({ key: key, value: PagList[key] });
                    
                }
                component.set('v.PaginationList', mapOfListValues2);     
                component.set('v.PaginationListData', mapOfListValues2);  
                
            }
            else
            {
                
                console.log("This is an error part");
            }
        });
        $A.enqueueAction(action);
        
        
        var action = component.get('c.getChildCategoriesofTopic');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                var getResultWrapper = JSON.parse(response.getReturnValue());
                 var mapOfListValues1 = [];
                for (let key in getResultWrapper) {
                    mapOfListValues1.push({ key: key, value: getResultWrapper[key] });
                    
                }
                component.set("v.getTopicCategories",mapOfListValues1);
                
            }
            else
            {
                
                console.log("This is an error part");
            }
        });
        $A.enqueueAction(action);
        
        
        var action = component.get('c.getChildCategoriesofSource');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                var getResultWrapper = JSON.parse(response.getReturnValue());
                 var mapOfListValues1 = [];
                for (let key in getResultWrapper) {
                    mapOfListValues1.push({ key: key, value: getResultWrapper[key] });
                    
                }
                component.set("v.getSourceCategories",mapOfListValues1);
                
            }
            else
            {
                
                console.log("This is an error part");
            }
        });
        $A.enqueueAction(action);
        
        
        
        
    },
    
    
    
    
    //Pagination buttons start here
    next: function (component, event, helper) {
        var sObjectList = component.get("v.ListOfArticles");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i = end + 1; i < end + pageSize + 1; i++ ) {
            if ( sObjectList.length > i ) {
                PagList.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
        console.log('paglination next map' ,PagList);
    },
    
    
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.ListOfArticles");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i= start-pageSize; i < start ; i++ ) {
            if ( i > -1 ) {
                PagList.push(sObjectList[i]);
                counter ++;
            } else {
                start++;
            }
        }
        console.log('paglination previous' ,PagList);
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
    },
    
    
    //Pagination buttons end here
    
    
    
    //Pagination buttons start here
    nextSearch: function (component, event, helper) {
        var sObjectList = component.get("v.filteredSearch");
        console.log('objectlist ' ,sObjectList);
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i = end + 1; i < end + pageSize + 1; i++ ) {
            if ( sObjectList.length > i ) {
                PagList.push(sObjectList[i]);
            }
            counter ++ ;
        }
        console.log('paglination next' ,PagList);
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
        console.log('paglination next map' ,PagList);
    },
    
    
    previousSearch: function (component, event, helper) {
        var sObjectList = component.get("v.filteredSearch");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i= start-pageSize; i < start ; i++ ) {
            if ( i > -1 ) {
                PagList.push(sObjectList[i]);
                counter ++;
            } else {
                start++;
            }
        }
        console.log('paglination previous' ,PagList);
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
    },
    
    
    
    onChange2 : function(component, event, helper)
    {
        component.set("v.showAllButtons",false);
        component.set("v.showAllButtons",true);
        component.set("v.showButton",true);
        component.set('v.toggleSpinner', true);
        var topic =event.currentTarget.value;
        component.set("v.Topics",topic);
        
        
        var action = component.get('c.changemethod'); 
        action.setParams({ 
            topic : component.get('v.Topics'),
            source: component.get('v.Sources'),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                var pageSize = component.get("v.pageSize");
                var getResult = JSON.parse(response.getReturnValue());
                component.set('v.toggleSpinner', false);
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
                if(getResult.length <= 8){
                    console.log('enter length greater than 8');
                    component.set("v.showAllButtons",false);
                }
                component.set("v.ListOfArticles",mapOfListValues1); 
                component.set("v.data",mapOfListValues1);
                component.set("v.totalRecords", component.get("v.ListOfArticles").length);
                component.set("v.startPage", 0);                
                component.set("v.endPage", pageSize - 1);
                console.log('pageSize',pageSize)
                var PagList = [];
                for ( var i=0; i< pageSize; i++ ) {
                    if ( component.get("v.ListOfArticles").length> i )
                        PagList.push(JSON.parse(response.getReturnValue())[i]);    
                }
                console.log('paglist ' ,PagList);
                var mapOfListValues2 = [];
                for (let key in PagList) {
                    mapOfListValues2.push({ key: key, value: PagList[key] });
                    
                }
                 console.log('mapOfListValues2 ' ,mapOfListValues2);
                component.set('v.PaginationList', mapOfListValues2);  
                component.set('v.PaginationListData', mapOfListValues2);  
                
                
                
                
            }
            else
            {
                console.log("This is an error part");
            }
        });
        $A.enqueueAction(action);
    },
    
   onChange3 : function(component, event, helper)
    {
        component.set("v.showAllButtons",true);
        component.set("v.showButton",true);
        component.set('v.toggleSpinner', true);
        var sourcing = event.currentTarget.value;
        component.set("v.Sources",sourcing);
        var action = component.get('c.changemethod'); 
        action.setParams({
            topic : component.get('v.Topics'),
            source: component.get('v.Sources'),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS")
            {
                var pageSize = component.get("v.pageSize");
                var getResult = JSON.parse(response.getReturnValue());
                component.set('v.toggleSpinner', false);
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
                if(getResult.length <= 8){
                    component.set("v.showAllButtons",false);
                }
                component.set("v.ListOfArticles",mapOfListValues1); 
                component.set("v.data",mapOfListValues1);
                component.set("v.totalRecords", component.get("v.ListOfArticles").length);
                component.set("v.startPage", 0);  
                component.set("v.endPage", pageSize - 1);
                var PagList = [];
                for ( var i=0; i< pageSize; i++ ) {
                    if ( component.get("v.ListOfArticles").length> i )
                        PagList.push(JSON.parse(response.getReturnValue())[i]);    
                }
                 
                var mapOfListValues2 = [];
                for (let key in PagList) {
                    mapOfListValues2.push({ key: key, value: PagList[key] });
                    
                }
                 
                component.set('v.PaginationList', mapOfListValues2);  
                component.set('v.PaginationListData', mapOfListValues2);  
            }
            else
            {
                console.log("This is an error part");
            }
        });
        $A.enqueueAction(action);
    },
    
    
   
    
    
    
    
    doFilter: function(component) {  
        //data showing in table  
        try{
            
            var allData = component.get("v.data");
            // all data featched from apex when component loaded  
            var data = component.get("v.ListOfArticles"); 
            
            var PaginationListData = component.get("v.PaginationListData"); 
            //Search tems  
            var searchKey = component.get("v.filter");  
            // check is data is not undefined and its lenght is greater than 0  
            if(data !=undefined || data.length>0){  
                // filter method create a new array tha pass the test (provided as function)  
                var filtereddata = allData.filter(word => (!searchKey) || word.value.Title.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);  
            }
            
            component.set("v.filteredSearch" ,filtereddata);
            
            // set new filtered array value to data showing in the table.  
            //component.set("v.PaginationList", filtereddata); 
            
            window.setTimeout(
                $A.getCallback(function() {
                    var pageSize = component.get("v.pageSize");
                    component.set("v.totalRecords", filtereddata.length);
                    component.set("v.startPage", 0);  
                    component.set("v.endPage", pageSize - 1);
                    var PagList = [];
                    for ( var i=0; i< pageSize; i++ ) {
                        
                        for(var j=0; j< data.length; j++){
                            if ( (component.get("v.ListOfArticles").length> i) && (component.get("v.ListOfArticles")[j] === (filtereddata)[i]))
                                PagList.push((filtereddata)[i]);    
                        }}
                    
                    console.log('PagList ' ,PagList);
                    component.set('v.PaginationList', PagList);
                    if(component.get("v.PaginationList").length == 0)
                    {
                        document.getElementById('errorname').innerHTML="No content found";
                        component.set("v.showAllButtons",false);
                    }
                    else
                    {
                        
                        document.getElementById('errorname').innerHTML="";
                        if(filtereddata.length <= 8){
                            component.set("v.showAllButtons",false);
                        }
                        else{
                            component.set("v.showAllButtons",true);
                        	component.set("v.showButton",false);
                        }
                         
                    }
                    
                    
                    // check if searchKey is blank  
                    if(searchKey == ''){
                        if(data.length <= 8){
                            component.set("v.showAllButtons",false);
                        }
                        else{
                            component.set("v.showAllButtons",true);
                        	component.set("v.showButton",true);
                        }
                         
                        // set unfiltered data to data in the table.  
                        component.set("v.PaginationList",PaginationListData);  
                    }
                    
                }), 900
            );
            
        }
        
        catch(e){}
    }, 
    
    navigateToMyComponent: function(component, event, helper){
        var showDesc= false; 
        var ctarget = event.currentTarget;
        var id = ctarget.dataset.value;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": id,
            "slideDevName": "Detail"
        });
        navEvt.fire();
        
    },
    handleClick : function (component, event, helper) {
        var showDesc= true; 
        component.set("v.showDesc",showDesc); 
    },
    
})