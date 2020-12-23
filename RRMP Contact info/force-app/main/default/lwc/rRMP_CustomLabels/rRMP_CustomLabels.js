import { LightningElement, track } from 'lwc';
// importing Custom Label
import Message from '@salesforce/label/c.Message';
import Contact_Email from '@salesforce/label/c.Contact_Email';
import Contact_Number from '@salesforce/label/c.Contact_Number';
import Fax_Number from '@salesforce/label/c.Fax_Number';

// importing from Apex Class
import updateLabel from '@salesforce/apex/RRMP_Contact_informationController.updateLabel';

export default class RRMP_CustomLabels extends LightningElement 
{
    @track label = 
    {
        Message,
        Contact_Email,
        Contact_Number,
        Fax_Number
    };

    error;

    @track isModalOpen = false;
    editAllow = true;

    handleMessageChange(event) 
    {
        this.label.Message = event.target.value;
    }

    handleEmailChange(event) 
    {
        this.label.Contact_Email = event.target.value;
    }

    handlePhoneChange(event) 
    {
        this.label.Contact_Number = event.target.value;
    }

    handleFaxChange(event) 
    {
        this.label.Fax_Number = event.target.value;
    }

    openModal() 
    {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }

    cancel() 
    {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;

        
    }
    
    submit() 
    {
        
        updateLabel({listLabel: JSON.stringify(this.label)})
        .then((result) => {
            this.label = result;
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.label = undefined;
        });

        this.isModalOpen = false;
        //console.log('submitDetails ==> Message=' + JSON.stringify(this.label) );


    }
}