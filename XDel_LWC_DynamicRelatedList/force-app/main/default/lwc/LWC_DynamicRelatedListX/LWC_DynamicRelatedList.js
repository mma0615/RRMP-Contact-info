import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

// importing from Apex Class
import getRecords from '@salesforce/apex/LWC_DynamicRelatedListController.getRecords';

const OBJECT_PARENAPITNAME = 'Account';
const OBJECT_CHILDAPINAME = 'Opportunity';
const OBJECT_CHILDPARENTFIELD = 'AccountId';
const OBJECT_FIELDSET = 'Oppo_FieldSet';

export default class LWC_DynamicRelatedList extends NavigationMixin(LightningElement) 
{
    @api recordId;
    parentId;

    data = [];
    error;
    iconName;
    objectLabel;

    @track columns = [
        { label: 'Id', fieldName: 'Id' },
        { label: 'Name', fieldName: 'Name' }
    ];

    @wire(getRecords, {recordId: '$recordId',
        parentAPIName: OBJECT_PARENAPITNAME,
        childAPIName: OBJECT_CHILDAPINAME,
        childParentField: OBJECT_CHILDPARENTFIELD,
        fieldSet: OBJECT_FIELDSET } )
        wiredRecords(result) 
        {
            if (result.data) 
            {
                console.log('Json Result: ' + JSON.stringify(result.data));
                this.populateData(result.data);                
                this.error = undefined;
                console.log(result.data);
            } 
            else if (result.error) 
            {
                this.data = undefined;
                this.error = result.error;
                console.log(error);
            }
        }

    populateData(record) 
    {
        console.log('Json Result Record: ' + JSON.stringify(record));
        
        var tempRecord = JSON.parse(JSON.stringify(record));

        this.parentId = tempRecord.parentId;
        this.iconName = tempRecord.iconName;
        this.objectLabel = tempRecord.objectLabel;

        /***** setting column lables & links */
        var colRecords = JSON.parse(tempRecord.listColumns); 
        this.columns = []
        for (let x in colRecords) 
        {
            this.columns.push(colRecords[x])
            console.log('*** Columns: ' + colRecords[x]);
        }

        /***** Setting data to display */
        this.data = new Array();
        var tempRecords = tempRecord.listRecords;
        tempRecords.forEach(record => 
            {                
                var temprecord = JSON.parse(JSON.stringify(record));
                console.log('*** Before Record: ' + temprecord); 
                temprecord.Id = '/' + record.Id;
    
                this.data.push(temprecord);
                console.log('*** After Record: ' + JSON.stringify(temprecord));
                
            });

        console.log('***data ' + this.data);

    }

    handleGotoRelatedList() 
    {
        this[NavigationMixin.Navigate](
            {
            type: "standard__recordRelationshipPage",
            attributes: 
            {
                recordId: this.parentId,
                relationshipApiName: 'Opportunities',   
                actionName: "view",
                objectApiName: this.objectApiName
            }
        });
    }

    


    /*******
    handleFieldTypes() 
    {
        getFieldTypes({objectName: OBJECT_NAME})
            .then(result => 
            {                        
                //console.log(result);
                //console.log(JSON.parse(result));
                let cols = JSON.parse(result);
                this.columns = []
                //console.log(cols);
                for (let x in cols) 
                {
                    this.columns.push(cols[x])
                    console.log(cols[x]);
                }   
                console.log(this.columns);
                   
            })
            .catch(error => 
            {
                console.log('***** handleFieldTypes Error: ' + error);
            });
    }





    

    

    generateLinks(records) 
    {
        this.data = new Array();
        records.forEach(record => 
        {
            console.log('*** Before Record: ' + JSON.stringify(record));
            var tempRecords = JSON.parse(JSON.stringify(record)); 
            tempRecords.Id = '/' + record.Id;
            this.data.push(tempRecords);
            console.log('*** After tempRecords: ' + JSON.stringify(tempRecords));  
        });
    
    }
    */
}