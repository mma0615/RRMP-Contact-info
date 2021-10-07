import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

// importing from Apex Class
import getRecords from '@salesforce/apex/FinancialAccountController.getRecords';

// importing to refresh the apex if any record changes the datas
import {refreshApex} from '@salesforce/apex';

const OBJECT_NAME = 'OASP__Financial_Account__c';

const CONST_FIELDS = 'Id, Name, OASP__OAS_Registration__c, OASP__OAS_Registration__r.Name, ' +
            'OASP__OAS_Account_Type__c, OASP__OAS_Account_Value__c, OASP__OAS_Model_Name__c ';


/*******
 *      { label: 'Case', fieldName: 'LinkName', type: 'url', typeAttributes: {label: { fieldName: 'CaseNumber' }, target: '_top'} },
        { label: 'Contact Name', fieldName: 'Contact_LinkName', type: 'url', typeAttributes: {label: { fieldName: "Contact_Name" }, target: '_top'}},
 
 */

export default class TaskFinancialAccount extends NavigationMixin(LightningElement)
{

    @track CONST_COLUMNS = [
        { label: 'Financial Account Name', fieldName: 'Id', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_top'} },
        { label: 'Registration', fieldName: 'RegistrationId', type: 'url', typeAttributes: {label: { fieldName: 'RegistrationName' }, target: '_top'} },
        { label: 'Account Type', fieldName: 'OASP__OAS_Account_Type__c'},
        { label: 'Account Value', fieldName: 'OASP__OAS_Account_Value__c', type: 'currency'},
        { label: 'Model', fieldName: 'OASP__OAS_Model_Name__c'}
        
    ]

    @track data = [];
    @track error;

    @api recordId
    @api parentId;
    @api flexipageRegionWidth;

    @wire(getRecords, {parmId: '$recordId', fields: CONST_FIELDS } )
        wiredRecords(result) 
        {
            if (result.data) 
            {
                this.populateData(result.data);
                this.error = undefined;
                
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
        console.log('Json Result: ' + JSON.stringify(record));
        
        var tempRecord = JSON.parse(JSON.stringify(record));
        
        this.parentId = tempRecord.parentId;
        console.log('*** parentId: ' + this.parentId);

        this.data = new Array();
        var FinancialAccounts = tempRecord.FinancialAccounts;
        FinancialAccounts.forEach(FinancialAccount => 
        {
            console.log('*** Before Record: ' + JSON.stringify(FinancialAccount));
            var tempFArecord = JSON.parse(JSON.stringify(FinancialAccount)); 
            tempFArecord.Id = '/' + FinancialAccount.Id;

            tempFArecord.RegistrationId = '/' + tempFArecord.OASP__OAS_Registration__c;
            tempFArecord.RegistrationName = tempFArecord.OASP__OAS_Registration__r.Name;

            //console.log('**** Registrations Id: ' + tempFArecord.OASP__OAS_Registration__r.Id);
            //console.log('**** Registrations Name: ' + tempFArecord.OASP__OAS_Registration__r.Name);

            this.data.push(tempFArecord);
            console.log('*** After tempFArecord: ' + JSON.stringify(tempFArecord));
            
        });

        //this.data = JSON.stringify(tempRecord.FinancialAccounts);
        //console.log('*** data: ' + this.data);
    }


    handleGotoRelatedList() 
    {
        this[NavigationMixin.Navigate](
        {
            type: "standard__recordRelationshipPage",
            attributes: 
            {
                recordId: this.parentId,
                relationshipApiName: 'OASP__Financial_Accounts__r', //this.state.parentRelationshipApiName,
                actionName: "view",
                objectApiName: this.OBJECT_NAME //this.sobjectApiName
            }
        });
    }

    
}