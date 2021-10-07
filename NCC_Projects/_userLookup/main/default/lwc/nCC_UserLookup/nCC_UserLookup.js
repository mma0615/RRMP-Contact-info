import { LightningElement, track, api } from 'lwc';

import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from '@salesforce/schema/Project_Task__c.Id';
import OWNERID_FIELD from '@salesforce/schema/Project_Task__c.OwnerId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NCC_UserLookup extends LightningElement {
    @api recordId;
    @track userName;  
    @track userId;

    errorMessage = '';

    onSelection(event){  
        this.userName = event.detail.selectedValue;  
        this.userId = event.detail.selectedRecordId;  
    }

    updateRecord() {

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[OWNERID_FIELD.fieldApiName] = this.userId;

        const recordInput = { fields };
        console.log('recordInput: ' + JSON.stringify(recordInput));
        updateRecord(recordInput)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Owner Updated',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            this.getErrorMessage(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.errorMessage,
                    variant: 'error'
                })
            );
            
        });
        
    }

    getErrorMessage(error)
    {
        console.log('error: ' + JSON.stringify(error));
        this.errorMessage = JSON.parse(JSON.stringify(error)).body.message;
        /*
        errOutput = JSON.parse(JSON.stringify(error)).body.output;
        console.log('errOutput: ' + JSON.stringify(errOutput));
        if (errOutput != null)
        {
            errErrors = JSON.parse(JSON.stringify(errOutput)).errors.message;
            console.log('errErrors: ' + errErrors);
        }
        */
    }
}