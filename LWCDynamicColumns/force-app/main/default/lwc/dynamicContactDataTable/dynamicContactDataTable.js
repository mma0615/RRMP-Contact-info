import { LightningElement, track, wire, api } from 'lwc';


// importing Apex Class
import getContacts from '@salesforce/apex/contactController.getContacts';
import getFieldTypes from '@salesforce/apex/contactController.getFieldTypes';

const objectName = 'Contact';


export default class CustomHTMLDatatable extends LightningElement 
{
    @api recordId;
    @api accountid;
    @api contactid;
    @track data = [];
    @track error;
    @track columns = [
        { label: 'Id', fieldName: 'Id' },
        { label: 'Name', fieldName: 'Name' },
        { label: 'Phone', fieldName: 'Phone', type: 'PHONE' },
        { label: 'Email', fieldName: 'Email', type: 'EMAIL' }
    ];

    @wire(getContacts)
        wiredContacts(result) 
        {
            if (result.data) 
            {
                this.data = result.data;
                this.handleFieldTypes();
                this.error = undefined
                console.log(result.data);
            } 
            else if (result.error) 
            {
                this.data = undefined;
                this.error = result.error;
                console.log(error);
            }
        }

        handleFieldTypes() 
        {
            getFieldTypes({objectName: objectName})
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
                    console.log('***** Error: ' + error);
                });
        }

}