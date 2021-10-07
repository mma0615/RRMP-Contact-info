/*********************
*   LWC_DynamicRelatedList.js
*   @author:        Minh H Ma
*   @date:          11/25/2020
*   descrtiption:   This is LWC_DynamicRelatedList.js which displays the related list 
*                   from dynamically from fieldset
*
*   Update History:
*   11/25/2020  Intial Version
*********************/
import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

// importing from Apex Class
import getRecords from '@salesforce/apex/LWC_DynamicRelatedListController.getRecords';

/******** Passing in these below const  */

// row actions
const actions = [
    { label: 'View', name: 'view'}, 
    { label: 'Edit', name: 'edit'}, 
    { label: 'Delete', name: 'delete'}
];

const actionCol = [{type: 'action', typeAttributes: { rowActions: actions },}]

/******** Passing in these below const  */

export default class LWC_DynamicRelatedList extends NavigationMixin(LightningElement) 
{
    @api recordId;
    @api PARENAPITNAME = 'Krow__Invoice__c';
    @api CHILDAPINAME = 'Krow__Invoice_Line_Item__c';
    @api CHILDPARENTFIELD = 'Krow__Invoice__c';
    @api FIELDSET = 'InvoiceLineItemFieldSet';
    @api RELATIONSHIPLABELNAME = 'Invoice_Line_Items';

    parentId;

    data = [];
    error;
    iconName;
    objectLabel;
    relationshipName;
    //relationshipLabelName = this.RELATIONSHIPLABELNAME;

    columns = [
        { label: 'Id', fieldName: 'Id' },
        { label: 'Name', fieldName: 'Name' }
    ];

    columns2 = [
        { label: 'Id', fieldName: 'Id' },
        { label: 'Name', fieldName: 'Name' },
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        }
    ];

    @wire(getRecords, {recordId: '$recordId',
        parentAPIName: '$PARENAPITNAME',
        childAPIName: '$CHILDAPINAME',
        childParentField: '$CHILDPARENTFIELD',
        fieldSet: '$FIELDSET' } )
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
        this.relationshipName = tempRecord.relationshipName;

        /***** setting column lables & links */
        var colRecords = JSON.parse(tempRecord.listColumn); 
        this.columns = []
        for (let x in colRecords) 
        {
            this.columns.push(colRecords[x])
            console.log('*** Columns: ' + colRecords[x]);
        }
        /* adding Action column */
        //this.columns.push(actionCol[0]);

        /***** Setting data to display */
        this.data = new Array();
        var tempRecords = tempRecord.listRecord;
        tempRecords.forEach(record => 
            {                
                var temprecord = JSON.parse(JSON.stringify(record));
                console.log('*** Before Record: ' + JSON.stringify(record)); 
                temprecord.Id_Link = '/' + record.Id;
                for (const propertyName in temprecord) 
                {
                    const propertyValue = record[propertyName];
                    if (typeof propertyValue === 'object') 
                    {
                        temprecord[propertyName + '_Id'] = '/' + propertyValue.Id;
                        temprecord[propertyName + '_Name'] = propertyValue.Name;
                    }
                }
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
                relationshipApiName: this.relationshipName,   
                actionName: "view",
                objectApiName: this.CHILDAPINAME
            }
        });
    }

    

    handleEditRecord(row, recMode) 
    {
        //alert('Record Id: ' + row.Id);

        this[NavigationMixin.Navigate](
            {
            type: 'standard__recordPage',
            attributes: 
            {
                recordId: row.Id,
                objectApiName: this.CHILDAPINAME,
                actionName: recMode
            }
        });

        alert('Record Id: ' + row.Id);
        this.handleRefreshData();
    }

    handleRefreshData() 
    {
        this.init();
    }

}