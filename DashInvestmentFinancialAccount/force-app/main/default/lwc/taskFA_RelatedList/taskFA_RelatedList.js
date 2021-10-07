/*********************
*   taskFA_RelatedList.js
*   @author:        Minh H Ma
*   @date:          11/25/2020
*   descrtiption:   This is taskFA_RelatedList.js which displays the related list 
*                   dynamically from fieldset
*
*   Update History:
*   11/25/2020  Intial Version
*********************/
import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

// importing from Apex Class
import getRecords from '@salesforce/apex/LWC_DynamicRelatedListController.getRecords';

/******** Passing in these below const  */
const PARENAPITNAME = 'Account';
const CHILDAPINAME = 'OASP__Financial_Account__c';
const CHILDPARENTFIELD = 'OASP__OAS_Household__c';
const FIELDSET = 'FA_Set';
const RELATIONSHIPLABELNAME = 'Financial Accounts';
const SCALE = [1, 10, 100, 1000, 10000, 100000];
/******** Passing in these below const  */

export default class TaskFA_RelatedList extends NavigationMixin(LightningElement) 
{
    @api recordId;
    parentId;

    data = [];
    dataLength;
    error;
    iconName;
    objectLabel;
    relationshipName;
    relationshipLabelName = RELATIONSHIPLABELNAME;

    @track columns = [
        { label: 'Id', fieldName: 'Id' },
        { label: 'Name', fieldName: 'Name' }
    ];

    @wire(getRecords, {recordId: '$recordId',
        parentAPIName: PARENAPITNAME,
        childAPIName: CHILDAPINAME,
        childParentField: CHILDPARENTFIELD,
        fieldSet: FIELDSET } )
        wiredRecords(result) 
        {
            if (result.data) 
            {
                console.log('Json Result: ' + JSON.stringify(result.data));
                this.error = undefined;
                this.populateData(result.data);                
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

        /***** Setting data to display */
        this.data = new Array();
        var tempRecords = tempRecord.listRecord;
        tempRecords.forEach(record => 
        {                
            var temprecord = JSON.parse(JSON.stringify(record));
            console.log('*** Before Record: ' + JSON.stringify(record)); 
            temprecord.Id = '/' + record.Id;
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

        if (this.data.length > 0)
            this.dataLength = this.data.length;
        else
        {
            this.error = 'No record Found...';
            this.dataLength = 0;
        }
            
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
                objectApiName: CHILDAPINAME
            }
        });
    }

    handleCreateRecord() 
    {
        this[NavigationMixin.Navigate](
        {
            type: 'standard__objectPage',
            attributes: 
            {
                objectApiName: CHILDAPINAME,
                actionName: 'new'
            }
        });
    }

    handleRowAction(event) 
    {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (this.rowActionHandler) {
            this.rowActionHandler.call()
        } else {
            switch (actionName) {
                case "delete":
                    this.handleDeleteRecord(row);
                    break;
                case "edit":
                    this.handleEditRecord(row);
                    break;
                default:
            }
        }
    }

    handleEditRecord(row) 
    {
        this[NavigationMixin.Navigate](
            {
            type: 'standard__recordPage',
            attributes: 
            {
                recordId: row.Id,
                objectApiName: CHILDAPINAME,
                actionName: 'edit'
            }
        });
    }

    handleDeleteRecord(row) {
        const newEditPopup = this.template.querySelector("c-related-list-delete-popup");
        newEditPopup.recordId = row.Id;
        newEditPopup.recordName = row.Name;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.show();
    }

    handleRefreshData() {
        this.init();
    }
}