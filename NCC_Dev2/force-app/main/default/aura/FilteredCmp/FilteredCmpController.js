({
    doInit : function(component, event, helper) {
        
        /*component.set('v.timeFilterOption', [
            			{ label: 'None', value: 'None' },
                        { label: 'Day', value: 'Day' },
                        { label: 'Week', value: 'Week' },
            			{ label: 'Month', value: 'Month' },
                        { label: 'Year', value: 'Year' },
            			{ label: 'Custom', value: 'Custom' }
                    ]); */
        
        //used to return the field values
        var action = component.get("c.fieldReturn");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var items = [];
                var response = response.getReturnValue(); 
              
                component.set("v.LabelsName",response);
               
                
                for (var key in response) {
                    if (response.hasOwnProperty(key)) {
                        items.push({value: response[key]+ ' ~ ' +key+ ';', label:key});
                    }
                };
                component.set("v.options", items);
                
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(action);
        
        
        //return the timezone of user
        var actions = component.get("c.getUserTimeZone");
        actions.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                component.set("v.getTimeZoneData", response.getReturnValue());
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(actions);
        
        
        //get the custom setting data onload
        var actionss = component.get("c.getCustomSetting");
        actionss.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                
                var res=JSON.parse(response.getReturnValue());
                
                var resApi = [];
                var resLabel = [];
                var MapOfValues = [];
                for(var i=0 ;i<res.getApi.length;i++)
                {
                    MapOfValues.push({ key: res.getLabel[i], value: res.getOperator[i] });
                }
                component.set("v.ReturnMap",MapOfValues);
               
              
                for(var key in res.getApi){
                   
                    
                    resApi.push(res.getApi[key])
                }
                for(var key in res.getLabel){
                   
                    resLabel.push(res.getLabel[key])
                }
                //component.set("v.Checking2",true);
                //component.set("v.Checking1",false);
                component.set("v.showFilter", resLabel);
                var LengthOfList = component.get("v.showFilter");
              
                if(LengthOfList.length>1)
                {
                    component.set("v.checkNumberInList",true);
                }
                component.set("v.customSettingFilter", resLabel);
                component.set("v.showFilterSet", resLabel);
                
                component.set("v.filterSet",resLabel);
                component.set("v.Query" ,resApi);
                component.set("v.filterQuery" ,resApi);
                
                component.set("v.doneBtn", false);
                component.set("v.showCount", true);
                
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(actionss);
        
        //get the record count onload
        var count = component.get("c.getCountDataOnload");
        count.setParams({Operator : component.get("v.CheckOperator")});
        count.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
               
                component.set("v.countRecords" ,response.getReturnValue());
            }
            
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(count);
        
        /*var load = component.get("c.getCustomSettingOnLoad");
        load.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                if(response.getReturnValue() === 'success'){
                    component.set("v.showTime" ,true);
                }
                else{
                    component.set("v.showTime" ,false);
                }
                
                
            }
            
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(load);*/
        var updateCustomSetting = component.get("c.UpdateCustomSettingwhenLoad");
        
        updateCustomSetting.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                console.log('success',response.getReturnValue());
            }
        });
        $A.enqueueAction(updateCustomSetting);
    },
    
    
    
    /*handleTimeFilter:function (component, event) {
        var selectedFilterValue = event.getParam("value");
        console.log('selectedFilterValue ' ,selectedFilterValue);
        if(selectedFilterValue === 'Custom'){
            var elements = document.getElementsByClassName("myTest");
            elements[0].style.display = 'block';
            var elementss = document.getElementsByClassName("myTest1");
            elementss[0].style.display = 'block';
            var elementsss = document.getElementsByClassName("myTest2");
            elementsss[0].style.display = 'block';
            
        }
        else{
            var elements = document.getElementsByClassName("myTest");
            elements[0].style.display = 'none';
            var elementss = document.getElementsByClassName("myTest1");
            elementss[0].style.display = 'none';
            var elementsss = document.getElementsByClassName("myTest2");
            elementsss[0].style.display = 'none';
            
        }
        component.set("v.TimeFilter", selectedFilterValue); 
        var action = component.get("c.setDateFilterValue");
        action.setParams({ dateFilter : selectedFilterValue});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                console.log('success');              
            }
            
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(action);
    },
    
    
    handleDate: function (component, event) {
        var startDate = component.find("dateFieldFrom").get("v.value");
        component.set("v.startDate", startDate);  
        var DueDate = component.find("dateFieldTo").get("v.value");
        component.set("v.dueDate", DueDate); 
       
    },
    getDate:function (component, event) {
        if((component.get("v.startDate") !== undefined) && (component.get("v.dueDate") !== undefined)){
            var actions = component.get("c.dueDate");
            actions.setParams({StartDate : component.get("v.startDate"), DueDate : component.get("v.dueDate")});
            actions.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    if(response.getReturnValue() == 'not success'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'StartDate must be less than duedate',
                            duration:' 2000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();  
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Time Filter is saved successfully',
                            duration:' 2000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        
                    }
                }
                
                else {
                    alert('Error in getting data');
                }
            });
            $A.enqueueAction(actions);
            
        }
        else if((component.get("v.startDate") === undefined) || (component.get("v.dueDate") === undefined)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please fill the dates',
                duration:' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire(); 
            
        }
        
    },*/
    
    
    
    
    //get the value on onchange from first combobox
    /* handleChange: function (component, event) {
        var inputCmp1 = component.find("field1");
        var value1 = inputCmp1.get("v.value");
        console.log('value1',value1);
        if (value1 !== undefined || value1 !== '') {
            inputCmp1.setCustomValidity("");
            inputCmp1.reportValidity();
        } 
        
        component.set("v.OperatorValue" , '');
        component.set("v.selectedValues" , '');
        var selectedOptionValue = event.getParam("value");
        console.log('selectedOptionValue');
        component.set("v.fieldvalue", selectedOptionValue);
        var action = component.get("c.fieldTypeReturn");
        action.setParams({ fieldName : selectedOptionValue});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                
                //return the datatype of selected field and change the datatype of third combobox on the basis of datatype
                for (var key in response.getReturnValue()) {
                    var Type = key + '';
                    if (Type !== "PICKLIST") {
                        component.set("v.showTextValueTwo", false); 
                        component.set("v.showTextValueOne", true);
                        if(Type === 'TEXTAREA'){
                            component.set("v.getSubfilterType", 'TEXT'); 
                        }
                        else{
                            component.set("v.getSubfilterType", Type);
                        }
                        
                        
                    }
                    else {
                        component.set("v.showTextValueTwo", false);
                        component.set("v.showTextValueOne", false); 
                        component.set("v.getSubfilterType", Type); 
                        
                        component.set("v.showTabledata", response.getReturnValue()[key]);
                        var getShowtable=component.get("v.showTabledata");
                        var listOfDta=[];
                        for (let i = 0; i < getShowtable.length; i++) {
                            listOfDta.push({ label: getShowtable[i], value: getShowtable[i] })
                        }
                        component.set("v.showDataTypeSubfilter", listOfDta);       
                    }
                    
                    
                }
                var typeData =  component.get("v.getSubfilterType");
                
                //retrun the operator list on the basis of datatype
                if (typeData === 'BOOLEAN' || typeData === 'PICKLIST' || typeData === 'ID') {
                    component.set('v.OperatorOptions', [
                        { label: 'Equals', value: 'Equals' },
                        { label: 'Not Equals to', value: 'Not Equals to' } 
                    ]); 
                }
                else if (typeData === 'DOUBLE' || typeData === 'CURRENCY' || typeData === 'REFERENCE' || typeData === 'DATETIME' || typeData === 'DATE') {
                    component.set('v.OperatorOptions', [
                        { label: 'Equals', value: 'Equals' },
                        { label: 'Not Equals to', value: 'Not Equals to' },
                        { label: 'less than', value: 'less than' },
                        { label: 'greater than', value: 'greater than' },
                        { label: 'less or equal', value: 'less or equal' },
                        { label: 'greater or equal', value: 'greater or equal' }
                    ]);
                }
                    else {
                        component.set('v.OperatorOptions', [
                            { label: 'Equals', value: 'Equals' },
                            { label: 'Not Equals to', value: 'Not Equals to' },
                            { label: 'less than', value: 'less than' },
                            { label: 'greater than', value: 'greater than' },
                            { label: 'less or equal', value: 'less or equal' },
                            { label: 'greater or equal', value: 'greater or equal' },
                            { label: 'Contains', value: 'Contains' },
                        ]);
                            }
                            }
                            })
                            $A.enqueueAction(action);
                            } ,*/
    
    
    handleChangeOperator: function (component, event) {
        
        //used to remove the custom validity
        var inputCmp1 = component.find("field2");
        var value1 = inputCmp1.get("v.value");
        
        if (value1 !== undefined || value1 !== '') {
            inputCmp1.setCustomValidity("");
            inputCmp1.reportValidity();
        } 
        
        var selectedOptionValue = event.getParam("value");
        component.set("v.OperatorValue", selectedOptionValue);
    },
    
    getValuesData: function(component, event, helper) {
        var inputCmp1 = component.find("values");
        var value1 = inputCmp1.get("v.value");
        
        if (value1 !== undefined || value1 !== '') {
            inputCmp1.setCustomValidity("");
            inputCmp1.reportValidity();
        } 
        //end
        
        //get the selected operator value from second combobox
        var inputValue = component.find("values").get("v.value");
        component.set("v.selectedValues", inputValue);
        component.set("v.getSelectedValued", inputValue);
        
    },
    
    //used to get the selected value of picklist
    handleChangepickVal:function(component, event, helper) {
        var inputCmp1 = component.find("field4");
        var value1 = inputCmp1.get("v.value");
        
        if (value1 !== undefined || value1 !== '') {
            inputCmp1.setCustomValidity("");
            inputCmp1.reportValidity();
        } 
        
        var selectpickvalue = event.getParam("value");
        component.set("v.selectedValues", selectpickvalue);
        component.set("v.getSelectedValued", selectpickvalue);
        
    },
    
    //used to show the record on ui in datatable
    getRecord:function(component, event, helper) {
        component.set('v.toggleSpinner', true);
        component.set('v.columns', [
            {label: 'VA EHRM SG Inventory_Status', fieldName: 'VA_EHRM_SG_Inventory_Status__c'},
            {label: 'VA EHRM SG Inventory_Step', fieldName: 'VA_EHRM_SG_Inventory_Step__c'},
            {label: 'VA EHRM SG Inventory_Draft_Start_Date', fieldName: 'VA_EHRM_SG_Inventory_Draft_Start_Date__c'},
            {label: 'VA EHRM SG Inventory_Hand_Off_Start_Date', fieldName: 'VA_EHRM_SG_Inventory_Hand_Off_Start_Date__c'},
            {label: 'VA EHRM SG Inventory_Initiate_Start_Date', fieldName: 'VA_EHRM_SG_Inventory_Initiate_Start_Date__c'},
            {label: 'VA EHRM SG Inventory_Package_Start_Date', fieldName: 'VA_EHRM_SG_Inventory_Package_Start_Date__c'},
            {label: 'VA EHRM SG Inventory_Prepare_Start_Date', fieldName: 'VA_EHRM_SG_Inventory_Prepare_Start_Date__c'},
            {label: 'VA EHRM SG Inventory_Preview_Start_Date', fieldName: 'VA_EHRM_SG_Inventory_Preview_Start_Date__c'},
            {label: 'VA EHRM SG Inventory_Receive_Start_Date', fieldName: 'VA_EHRM_SG_Inventory_Receive_Start_Date__c'},
            {label: 'VA EHRM SG Inventory_Draft_Due_Date', fieldName: 'VA_EHRM_SG_Inventory_Draft_Due_Date__c'},
            {label: 'VA EHRM SG Inventory_Hand_Off_Due_Date', fieldName: 'VA_EHRM_SG_Inventory_Hand_Off_Due_Date__c'},
            {label: 'VA EHRM SG Inventory_Initiate_Due_Date', fieldName: 'VA_EHRM_SG_Inventory_Initiate_Due_Date__c'},
            {label: 'VA EHRM SG Inventory_Package_Due_Date', fieldName: 'VA_EHRM_SG_Inventory_Package_Due_Date__c'},
            {label: 'VA EHRM SG Inventory_Preview_Due_Date', fieldName: 'VA_EHRM_SG_Inventory_Preview_Due_Date__c'},
            {label: 'VA EHRM SG Inventory_Receive_Due_Date', fieldName: 'VA_EHRM_SG_Inventory_Receive_Due_Date__c'},
            {label: 'VA EHRM SG Inventory_Title', fieldName: 'VA_EHRM_SG_Inventory_Title__c'},
            {label: 'VA EHRM SG Inventory_Update_Priority', fieldName: 'VA_EHRM_SG_Inventory_Update_Priority__c'},
            {label: 'VA EHRM SG Council_Workgroup', fieldName: 'VA_EHRM_SG_Council_Workgroup__c'}
        ]);
        
        var filteredData = [];
        var OperatorData = component.get("v.CheckOperator");
        
        var count = component.get("c.getCountDataOnDone");
        count.setParams({ Operator : OperatorData })
        count.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                component.set("v.countRecordsOnDone" ,response.getReturnValue());
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(count);
        var operatorsData = component.get("v.CheckOperator")
        var action = component.get("c.getRecordData");
        action.setParams({Operator:operatorsData});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var pageSize = component.get("v.pageSize");
                component.set('v.toggleSpinner', false);
                component.set("v.listOfRecords", response.getReturnValue());
                if(component.get("v.listOfRecords").length < 1){
                    component.set("v.showCount", false);
                    component.set("v.showList", true);
                }else{
                    component.set("v.showCount", false);
                    component.set("v.showList", false);
                }
                
                
                if(component.get("v.listOfRecords").length > 3){
                    component.set("v.showButton",true);
                }
                component.set("v.totalRecords", component.get("v.listOfRecords").length);
                component.set("v.startPage", 0);                
                component.set("v.endPage", pageSize - 1);
                var PagList = [];
                for ( var i=0; i< pageSize; i++ ) {
                    if ( component.get("v.listOfRecords").length> i )
                        PagList.push(response.getReturnValue()[i]);    
                }
                component.set('v.PaginationList', PagList);
                
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    //pagination  button
    next: function (component, event, helper) {
        var sObjectList = component.get("v.listOfRecords");
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
    },
    
    //pagination button
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.listOfRecords");
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
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
    },
    
    //used to removed the filter on the basis of current value
    changeFilter:function(component, event, helper) {
       // component.set("v.Checking2",false);
        //component.set("v.Checking1",true);
        component.set("v.showCount", false);
        component.set("v.fieldvalue" , '');
        component.set("v.inputValue", "");
        component.set("v.OperatorValue" , '');
        component.set("v.selectedValues" , '');
        
        component.set("v.selectedOption", "");
        component.set("v.OperatorOptions",'');
        component.set("v.showDataTypeSubfilter",'');
        component.set("v.showTextValueTwo",true);
        var cmpTarget = component.find('Crossbutton');
        $A.util.addClass(cmpTarget, 'changeMe');
        var currentIndex = event.getSource().get("v.value");
        var index1;
        var index2;
        var index3;
        var index4;
        var index5;
        var queryData = component.get("v.Query");
        var showfiltered = component.get("v.showFilter")
        var filteredQue = component.get("v.filterQuery")
        
        var actions = component.get("c.deleteCustomData");
        actions.setParams({ indexData : currentIndex});
        actions.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                console.log('success' ,response.getReturnValue())
            }
            else {
                alert('Error in getting index');
            }
        });
        $A.enqueueAction(actions);
        
        
        
        if(showfiltered.length > 2)
        {
            component.set("v.checkNumberInList",true);
        }
        if (showfiltered.length === 1) {
            
            component.set("v.doneBtn", true);
            component.set("v.showList", true);
            component.set("v.showButton", false);
            component.set("v.listOfRecords", '');
            component.set("v.PaginationList", '');
            component.set("v.showTime", false);
        }
        
        for (var k = 0; k < showfiltered.length; k++) {
            if (showfiltered[k].includes(currentIndex.split('-')[0])) {
                index1 = k;
            } else {
                continue;
            }
        }
        
        showfiltered.splice(index1, 1);
        component.set("v.showFilter" ,showfiltered);
        
        
        queryData.splice(index1, 1);
        component.set("v.Query" ,queryData);
        
        
        filteredQue.splice(index1, 1);
        component.set("v.filterQuery" ,filteredQue);
        
        
        var filteredset = component.get("v.filterSet");
        for (var k = 0; k < filteredset.length; k++) {
            if (filteredset[k].includes(currentIndex.split('-')[0])) {
                index4 = k;
            } else {
                continue;
            }
        }
        filteredset.splice(index4, 1);
        component.set("v.filterSet" ,filteredset);
        
        var showFilt = component.get("v.showFilterSet");
        for (let k = 0; k < showFilt.length; k++) {
            if (showFilt[k].includes(currentIndex.split('-')[0])) {
                index5 = k;
            } else {
                continue;
            }
        }
        showFilt.splice(index5, 1);
        component.set("v.showFilterSet" ,showFilt);
        
        
    },
    
    //used to show the filter on add  button click
    Addfilter: function(component, event, helper) {
       // component.set("v.Checking2",false);
       // component.set("v.Checking1",true);
        component.set("v.showTime", true);
        component.set("v.showCount", false);
        var inputCmp1 = component.find("combobox-id-11");
       
        var inputCmp2 = component.find("field2");
        var value2 = inputCmp2.get("v.value");
        var inputCmp3 = component.find("field3");
        var inputCmp4 = component.find("values");
        var inputCmp5 = component.find("field4");
        var value4 = component.get("v.selectedValues");
        //  var OperatorValue = component.find("SelectOperator");
        // var value5 = OperatorValue.get("v.value");
        //console.log('value5',value5);
        var flag = false; 
        
        //show custom validity error if any of the field is empty
        var typeData =  component.get("v.getSubfilterType");
        var SelectedValues = component.get("v.inputValue");
        if (SelectedValues === undefined || SelectedValues === '') 
        {
           
            component.set("v.Check","");
            flag = true;
        }
        else 
        {
          component.set("v.Check","some");
          inputCmp1.set("v.errors", null);
        }
        /*
        if(value5 === '' || value5 === undefined)
        {
            flag = true;
        }
        */
        if (value2 === undefined || value2 === '') {
            inputCmp2.setCustomValidity("Enter the value");
            inputCmp2.reportValidity();
            flag = true;
        } 
        
        if (typeData === 'PICKLIST') 
        {
            if (value4 === undefined || value4 === '') {
                inputCmp5.setCustomValidity("Enter the value");
                inputCmp5.reportValidity();
                flag = true;
            } 
        }
        else if (typeData === 'DOUBLE' || typeData === 'CURRENCY' || typeData === 'REFERENCE' || typeData === 'DATETIME' || typeData === 'DATE' ||
                 typeData === 'STRING' || typeData === 'NUMBER' || typeData === 'BOOLEAN' || typeData === 'ID') {
            
            if (value4 === undefined || value4 === '') {
                inputCmp4.setCustomValidity("Enter the value");
                inputCmp4.reportValidity();
                flag = true;
            } 
        }
            else if(typeData === 'TEXT'){
                
                if (value4 === undefined || value4 === '') {
                    inputCmp3.setCustomValidity("Enter the value");
                    inputCmp3.reportValidity();
                    flag = true;
                } 
            }
        
        
        
        if (flag) {
            return;
        }
        
        var getSelectedValue;
        var queriesFiltered = [];
        var filterSetData = [];
        var getQuery = [];
        var selectedField = component.get("v.fieldvalue");
        
        var getOperator = component.get("v.OperatorValue");
        
        var getDataType = component.get("v.getSubfilterType");
        
        var getValues = component.get("v.selectedValues");
       
        var timezone = component.get("v.getTimeZoneData");
       
        //used to create the filter
        if (getOperator === 'Equals') {
            var setValue;
            if (getDataType === 'DOUBLE' || getDataType === 'BOOLEAN' || getDataType === 'CURRENCY' || getDataType === 'DATETIME' || getDataType === 'DATE') {
                if (getDataType === 'DATETIME' || getDataType === 'DATE') {
                    
                    setValue = getValues;
                    //  getSelectedValue = new Date(getValues).toLocaleString("en-US", { timeZone: timezone });
                    getSelectedValue = new Date(getValues).toLocaleString("en-US");
                    
                    
                    component.set("v.getSelectedValued", getSelectedValue);
                    if (getDataType === 'DATE') {
                        var dateValue = getSelectedValue.split(',')
                        getSelectedValue = dateValue[0];
                        component.set("v.getSelectedValued", getSelectedValue);
                    }
                }
                else {
                    setValue = getValues;
                }
            }
            else {
                setValue = '\'' + getValues + '\'';
            }
            if(component.get("v.filterQuery").length < 1){
                queriesFiltered.push(selectedField + ' = ' + setValue);
            }
            else{
                for( var i=0 ; i< component.get("v.filterQuery").length ; i++){
                    queriesFiltered.push(component.get("v.filterQuery")[i]);
                }
                queriesFiltered.push(selectedField + ' = ' + setValue);
                
            }
            getQuery.push(selectedField + ' = ' + setValue);
            component.set("v.filterQuery", queriesFiltered);
            
        } 
        else if (getOperator === 'Not Equals to') {
            let setValue;
            if (getDataType === 'DOUBLE' || getDataType === 'BOOLEAN' || getDataType === 'CURRENCY' || getDataType === 'DATETIME' || getDataType === 'DATE') {
                if (getDataType === 'DATETIME' || getDataType === 'DATE') {
                    setValue = getValues;
                    //getSelectedValue = new Date(getValues).toLocaleString("en-US", { timeZone: timezone });
                    getSelectedValue = new Date(getValues).toLocaleString("en-US");
                    
                    component.set("v.getSelectedValued", getSelectedValue);
                    if (getDataType === 'DATE') {
                        var dateValue = getSelectedValue.split(',')
                        getSelectedValue = dateValue[0];
                        component.set("v.getSelectedValued", getSelectedValue);
                    }
                }
                else {
                    setValue = getValues;
                }
            }
            else {
                setValue = '\'' + getValues + '\'';
            }
            
            if(component.get("v.filterQuery").length < 1){
                queriesFiltered.push(selectedField + ' != ' + setValue);
            }
            else{
                for( var i=0 ; i< component.get("v.filterQuery").length ; i++){
                    queriesFiltered.push(component.get("v.filterQuery")[i]);
                }
                queriesFiltered.push(selectedField + ' != ' + setValue);
                
            }
            getQuery.push(selectedField + ' != ' + setValue);
            component.set("v.filterQuery", queriesFiltered);
        } 
            else if (getOperator === 'less than') {
                let setValue;
                if (getDataType === 'DOUBLE' || getDataType === 'BOOLEAN' || getDataType === 'CURRENCY' || getDataType === 'DATETIME' || getDataType === 'DATE') {
                    if (getDataType === 'DATETIME' || getDataType === 'DATE') {
                        setValue = getValues;
                        // getSelectedValue = new Date(getValues).toLocaleString("en-US", { timeZone: timezone });
                        getSelectedValue = new Date(getValues).toLocaleString("en-US");
                        component.set("v.getSelectedValued", getSelectedValue);
                        if (getDataType === 'DATE') {
                            var dateValue = getSelectedValue.split(',')
                            getSelectedValue = dateValue[0];
                            component.set("v.getSelectedValued", getSelectedValue);
                        }
                    }
                    else {
                        setValue = getValues;
                    }
                }
                else {
                    setValue = '\'' + getValues + '\'';
                }
                
                if(component.get("v.filterQuery").length < 1){
                    queriesFiltered.push(selectedField + ' < ' + setValue);
                }
                else{
                    for( var i=0 ; i< component.get("v.filterQuery").length ; i++){
                        queriesFiltered.push(component.get("v.filterQuery")[i]);
                    }
                    queriesFiltered.push(selectedField + ' < ' + setValue);                
                }
                getQuery.push(selectedField + ' < ' + setValue);
                component.set("v.filterQuery", queriesFiltered);
            } 
                else if (getOperator === 'greater than') {
                    let setValue;
                    if (getDataType === 'DOUBLE' || getDataType === 'BOOLEAN' || getDataType === 'CURRENCY' || getDataType === 'DATETIME' || getDataType === 'DATE') {
                        if (getDataType === 'DATETIME' || getDataType === 'DATE') {
                            setValue = getValues;
                            // getSelectedValue = new Date(getValues).toLocaleString("en-US", { timeZone: timezone });
                            getSelectedValue = new Date(getValues).toLocaleString("en-US");
                            component.set("v.getSelectedValued", getSelectedValue);
                            if (getDataType === 'DATE') {
                                var dateValue = getSelectedValue.split(',')
                                getSelectedValue = dateValue[0];
                                component.set("v.getSelectedValued", getSelectedValue);
                            }
                        }
                        else {
                            setValue = getValues;
                        }
                    }
                    else {
                        setValue = '\'' + getValues + '\'';
                    }
                    
                    if(component.get("v.filterQuery").length < 1){
                        queriesFiltered.push(selectedField + ' > ' + setValue);
                    }
                    else{
                        for( var i=0 ; i< component.get("v.filterQuery").length ; i++){
                            queriesFiltered.push(component.get("v.filterQuery")[i]);
                        }
                        queriesFiltered.push(selectedField + ' > ' + setValue);                
                    }
                    getQuery.push(selectedField + ' > ' + setValue);
                    component.set("v.filterQuery", queriesFiltered);
                    
                }
                    else if (getOperator === 'less or equal') {
                        let setValue;
                        if (getDataType === 'DOUBLE' || getDataType === 'BOOLEAN' || getDataType === 'CURRENCY' || getDataType === 'DATETIME' || getDataType === 'DATE') {
                            if (getDataType === 'DATETIME' || getDataType === 'DATE') {
                                setValue = getValues;
                                //getSelectedValue = new Date(getValues).toLocaleString("en-US", { timeZone: timezone });
                                getSelectedValue = new Date(getValues).toLocaleString("en-US");
                                component.set("v.getSelectedValued", getSelectedValue);
                                if (getDataType === 'DATE') {
                                    var dateValue = getSelectedValue.split(',')
                                    getSelectedValue = dateValue[0];
                                    component.set("v.getSelectedValued", getSelectedValue);
                                }
                            }
                            else {
                                setValue = getValues;
                            }
                        }
                        else {
                            setValue = '\'' + getValues + '\'';
                        }
                        
                        if(component.get("v.filterQuery").length < 1){
                            queriesFiltered.push(selectedField + ' <= ' + setValue);
                        }
                        else{
                            for( var i=0 ; i< component.get("v.filterQuery").length ; i++){
                                queriesFiltered.push(component.get("v.filterQuery")[i]);
                            }
                            queriesFiltered.push(selectedField + ' <= ' + setValue);                
                        }
                        getQuery.push(selectedField + ' <= ' + setValue);
                        component.set("v.filterQuery", queriesFiltered);
                    } 
                        else if (getOperator === 'greater or equal') {
                            let setValue;
                            if (getDataType === 'DOUBLE' || getDataType === 'BOOLEAN' || getDataType === 'CURRENCY' || getDataType === 'DATETIME' || getDataType === 'DATE') {
                                if (getDataType === 'DATETIME' || getDataType === 'DATE') {
                                    setValue = getValues;
                                    //  getSelectedValue = new Date(getValues).toLocaleString("en-US", { timeZone: timezone });
                                    getSelectedValue = new Date(getValues).toLocaleString("en-US");
                                    component.set("v.getSelectedValued", getSelectedValue);
                                    if (getDataType === 'DATE') {
                                        var dateValue = getSelectedValue.split(',')
                                        getSelectedValue = dateValue[0];
                                        component.set("v.getSelectedValued", getSelectedValue);
                                    }
                                }
                                else {
                                    setValue = getValues;
                                }
                            }
                            else {
                                setValue = '\'' + getValues + '\'';
                            }
                            
                            
                            if(component.get("v.filterQuery").length < 1){
                                queriesFiltered.push(selectedField + ' >= ' + setValue);
                            }
                            else{
                                for( var i=0 ; i< component.get("v.filterQuery").length ; i++){
                                    queriesFiltered.push(component.get("v.filterQuery")[i]);
                                }
                                queriesFiltered.push(selectedField + ' >= ' + setValue);                
                            }
                            getQuery.push(selectedField + ' >= ' + setValue);
                            component.set("v.filterQuery", queriesFiltered);
                            
                        }
                            else if (getOperator === 'Contains') {
                                let likeOperator = '\'%' + getValues + '%\''
                                
                                
                                if(component.get("v.filterQuery").length < 1){
                                    queriesFiltered.push(selectedField + ' like ' + likeOperator);
                                }
                                else{
                                    for( var i=0 ; i< component.get("v.filterQuery").length ; i++){
                                        queriesFiltered.push(component.get("v.filterQuery")[i]);
                                    }
                                    queriesFiltered.push(selectedField + ' like ' + likeOperator);                
                                }
                                getQuery.push(selectedField + ' like ' + likeOperator);
                                component.set("v.filterQuery", queriesFiltered);
                                
                            } 
        
       
        
        var message;
        var index = selectedField.indexOf("~");
       
        var index2 = selectedField.indexOf(";");
       
        selectedField = selectedField.replace(";","")
       
        selectedField = selectedField.slice(index+1, selectedField.length);
       
        
        var fil = [];
       
        for(var key in getQuery){
            if(getQuery[key].includes("~")){
                var split1 = getQuery[key].split('~');
                var split2 = split1[1].split(';');
                concate = split1[0]+split2[1];
                fil.push(concate);
                
            }
            else{
                fil.push(getQuery[key]);
            }
            
        }

        
        
        var filteredData = component.get("v.filterQuery");
       
        var concate;
        var filtered=[];
        for(var key in filteredData){
            if(filteredData[key].includes("~")){
                var split1 = filteredData[key].split('~');
                var split2 = split1[1].split(';');
                concate = split1[0]+split2[1];
                filtered.push(concate);
                
            }
            else{
                filtered.push(filteredData[key]);
            }
            
        }
        
        let setquery = new Set();
        for (var keys in filtered) {
            setquery.add(filtered[keys].trim());
        }
        
        
        component.set("v.Query" , Array.from(setquery));
        component.set("v.filterQuery", component.get("v.Query"));
        
        if(component.get("v.filterSet").length < 1){
            filterSetData.push(selectedField + '  ' + getOperator + '  ' + component.get("v.getSelectedValued"));
        }
        else{
            for( var i=0 ; i< component.get("v.filterSet").length ; i++){
                filterSetData.push(component.get("v.filterSet")[i]);
            }
            
            filterSetData.push(selectedField + '  ' + getOperator + '  ' + component.get("v.getSelectedValued"));
            
        }
        
        component.set("v.filterSet" ,filterSetData);
        
        let set = new Set();
        component.set("v.showFilterSet", component.get("v.filterSet"));
        var filters=component.get("v.showFilterSet");                               
        for (var key in filters) {
            set.add(filters[key].trim());
        }
        component.set("v.showFilter", Array.from(set));
      
        var Totaldata = component.get("v.showFilter");
       
        if(Totaldata.length > 1)
        {
            component.set("v.checkNumberInList",true);
        }
        component.set("v.showFilterSet",component.get("v.showFilter"));
        component.set("v.filterSet",component.get("v.showFilter"));
        filterSetData.push(component.get("v.showFilter"));
        /*
        var GetOperator = component.find("SelectOperator");
        var GetOperatorvalue = GetOperator.get("v.value");
        console.log('GetOperatorvalue',GetOperatorvalue);
        */
        var actions = component.get("c.storeData");
        actions.setParams({ Query :fil , LabelQuery :selectedField + '  ' + getOperator + '  ' + component.get("v.getSelectedValued")/*, Operator: GetOperatorvalue */});
        actions.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                console.log('success' ,response.getReturnValue())
                message = response.getReturnValue();
                console.log('messageeeee ' ,message);
                if(message === 'Duplicate filter are not supported'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: message,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    
                }
                
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(actions);
        
        if (component.get("v.showFilter").length > 0) {
            component.set("v.doneBtn", false);
        }
        
    },
    //navigate to gantt chart tab
    viewGantt : function(component, event, helper) {
        /*if((component.get("v.TimeFilter") === 'Custom') && ((component.get("v.startDate") === undefined) || (component.get("v.dueDate") === undefined))){
                                                
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    title : 'Error',
                                                    message: 'Please select the date fields',
                                                    duration:' 3000',
                                                    key: 'info_alt',
                                                    type: 'error',
                                                    mode: 'pester'
                                                });
                                                toastEvent.fire(); 
                                                return;
                                            }*/
                                            
                                            var urlEvent = $A.get("e.force:navigateToURL");
                                            urlEvent.setParams({
                                                "url": "https://ncc.my.salesforce.com/lightning/n/Gantt_Chart"
                                            });
                                            urlEvent.fire();
                                        },
    searchHandler : function (component, event, helper) {
        const searchString = event.target.value;
        if (searchString.length > 0)
        {
            helper.searchRecords(component, searchString);
            //Ensure that not many function execution happens if user keeps typing
            /*
            if (component.get("v.inputSearchFunction")) {
                clearTimeout(component.get("v.inputSearchFunction"));
            }
            var inputTimer = setTimeout($A.getCallback(function () {
            }), 5000);
           component.set("v.inputSearchFunction", inputTimer);
           */
        } else{
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
         },
    
    
    searchHandlerAllLabels : function (component, event, helper) {
      
        const searchString = event.target.value;
        if(component.get("v.openDropDown") == false)
        {
            if (searchString.length === 0)
            {
                
                helper.AllSearchRecords(component, event, helper);
            } 
        }
        else 
        {
            component.set("v.openDropDown",false);
        }
    },
    
    optionClickHandler : function (component, event, helper) {
        const selectedId = event.target.closest('li').dataset.id;
        const selectedValue = event.target.closest('li').dataset.value;
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedId);
        var LabelsName = component.get("v.LabelsName");
        var LabelWithApiName = LabelsName[selectedId] + ' ~ '+selectedId+';';
        
      
        /*
        var inputCmp1 = component.find("combobox-id-11");
        console.log('inputCmp1',inputCmp1);
        var value1 = inputCmp1.get("v.value");
        console.log('value11',value1);
        */
      /*  
        if (LabelWithApiName !== undefined || LabelWithApiName !== '') 
        {
            console.log('This is before');
            inputCmp1.setCustomValidity("");
            console.log('this is after one');
            inputCmp1.reportValidity();
            console.log('This is after');
        } 
        */
        
        component.set("v.OperatorValue" , '');
        component.set("v.selectedValues" , '');
        var selectedOptionValue = LabelWithApiName;
        
        component.set("v.fieldvalue", selectedOptionValue);
        
        var action = component.get("c.fieldTypeReturn");
        action.setParams({ fieldName : selectedOptionValue});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                
                //return the datatype of selected field and change the datatype of third combobox on the basis of datatype
                for (var key in response.getReturnValue()) {
                    var Type = key + '';
                    if (Type !== "PICKLIST") {
                        component.set("v.showTextValueTwo", false); 
                        component.set("v.showTextValueOne", true);
                        if(Type === 'TEXTAREA'){
                            component.set("v.getSubfilterType", 'TEXT'); 
                        }
                        else{
                            component.set("v.getSubfilterType", Type);
                        }
                    }
                    else {
                        component.set("v.showTextValueTwo", false);
                        component.set("v.showTextValueOne", false); 
                        component.set("v.getSubfilterType", Type); 
                        
                        component.set("v.showTabledata", response.getReturnValue()[key]);
                        var getShowtable=component.get("v.showTabledata");
                        var listOfDta=[];
                        for (let i = 0; i < getShowtable.length; i++) {
                            listOfDta.push({ label: getShowtable[i], value: getShowtable[i] })
                        }
                        component.set("v.showDataTypeSubfilter", listOfDta);       
                    }
                    
                    
                }
                var typeData =  component.get("v.getSubfilterType");
                
                //retrun the operator list on the basis of datatype
                if (typeData === 'BOOLEAN' || typeData === 'PICKLIST' || typeData === 'ID') {
                    component.set('v.OperatorOptions', [
                        { label: 'Equals', value: 'Equals' },
                        { label: 'Not Equals to', value: 'Not Equals to' } 
                    ]); 
                }
                else if (typeData === 'DOUBLE' || typeData === 'CURRENCY' || typeData === 'REFERENCE' || typeData === 'DATETIME' || typeData === 'DATE') {
                    component.set('v.OperatorOptions', [
                        { label: 'Equals', value: 'Equals' },
                        { label: 'Not Equals to', value: 'Not Equals to' },
                        { label: 'less than', value: 'less than' },
                        { label: 'greater than', value: 'greater than' },
                        { label: 'less or equal', value: 'less or equal' },
                        { label: 'greater or equal', value: 'greater or equal' }
                    ]);
                }
                    else {
                        component.set('v.OperatorOptions', [
                            { label: 'Equals', value: 'Equals' },
                            { label: 'Not Equals to', value: 'Not Equals to' },
                            { label: 'less than', value: 'less than' },
                            { label: 'greater than', value: 'greater than' },
                            { label: 'less or equal', value: 'less or equal' },
                            { label: 'greater or equal', value: 'greater or equal' },
                            { label: 'Contains', value: 'Contains' },
                        ]);
                            }
                            }
                            })
                            $A.enqueueAction(action);   
                            },
                            clearOption : function (component, event, helper) {
                            component.set("v.openDropDown", false);
                            component.set("v.inputValue", "");
                            component.set("v.selectedOption", "");
                            component.set("v.OperatorValue" , '');
                            component.set("v.selectedValues" , '');
                            component.set("v.OperatorOptions",'');
                            component.set("v.showDataTypeSubfilter",'');
                            component.set("v.showTextValueTwo",true);
                            //var OperatorValue = component.find("SelectOperator");
                            //OperatorValue.set("v.value",'');
                            //console.log('trfdgdgdg');
                    },
                            onChange  : function(component, event, helper)  
                            { 
                            var value =  event. getSource(). get("v.value");
                            component.set("v.CheckOperator",value);
                            var actions = component.get("c.UpdateCustomSetting");
                            actions.setParams({Operator:value});
                            actions.setCallback(this, function(response) {
                            var state = response.getState();
                            if(state === 'SUCCESS') {
                            console.log('success' ,response.getReturnValue())
                            }
                            });
                            $A.enqueueAction(actions);
                            },
                            checkOnClick :function(component, event, helper)  
                            {
                            if(component.get("v.openDropDown") == true)
                            {
                              component.set("v.openDropDown",false);
                            }
                            }
            })