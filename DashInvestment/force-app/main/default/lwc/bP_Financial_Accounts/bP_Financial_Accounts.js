import { LightningElement, wire, api } from 'lwc';
import getFinancialAccounts from '@salesforce/apex/businessProcessController.getFinancialAccounts';

export default class BP_Financial_Accounts extends LightningElement 
{
    @api recordId;
    financialAccounts

    @wire(getFinancialAccounts, { Id: '$recordId' })
        financialAccounts;
}