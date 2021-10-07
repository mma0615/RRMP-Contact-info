# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)



# **************  Default ORG: DashInvestmentSandBox ******************

sfdx force:source:deploy -m ApexClass:FinancialAccountController,ApexClass:FinancialAccountControllerTest -l RunLocalTests -u DashInvestmentProd




import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
// importing from Apex Class
import getRecords from '@salesforce/apex/FinancialAccountController.getRecords';

// importing to refresh the apex if any record changes the datas
import {refreshApex} from '@salesforce/apex';

const OBJECT_NAME = 'OASP__Financial_Account__c';

const CONST_COLUMNS = [
    { label: 'RegistrationId', fieldName: 'OASP__OAS_Registration__c', type:"text"},
    { label: 'Account Type', fieldName: 'OASP__OAS_Account_Type__c', type:"text"},
    
]

const CONST_FIELDS = 'Id, Name, OASP__OAS_Registration__c, OASP__OAS_Registration__r.Name, ' +
            'OASP__OAS_Account_Type__c, OASP__OAS_Account_Value__c';

export default class TaskFinancialAccount extends LightningElement 
{
    @track data = [];
    @track error;

    @api recordId
    @api parentId;

    @wire(getRecords, {parmId: '$recordId', fields: CONST_FIELDS } )
        wiredRecords(result) 
        {
            if (result.data) 
            {
                this.generateLinks(result.data);
                this.error = undefined;
                console.log('Json Result: ' + JSON.stringify(result.data));
            } 
            else if (result.error) 
            {
                this.data = undefined;
                this.error = result.error;
                console.log(error);
            }
        }

    generateLinks(record) 
    {
        this.data = new Array();
        var tempRecord = JSON.parse(JSON.stringify(record));
        this.parentId = tempRecord.parentId;
        console.log('*** parentId: ' + this.parentId);
        this.data = tempRecord.FinancialAccounts;
        console.log('*** data: ' + this.data);

        tempRecord.FinancialAccounts.forEach(FinancialAccounts => 
        {
            console.log('*** Before Record: ' + JSON.stringify(record));
            var tempRecords = JSON.parse(JSON.stringify(record)); 
            tempRecords.LinkName = '/' + record.Id;
            this.data.push(tempRecords);
            console.log('*** After tempRecords: ' + JSON.stringify(tempRecords));  
        });
    
    }

    
}
