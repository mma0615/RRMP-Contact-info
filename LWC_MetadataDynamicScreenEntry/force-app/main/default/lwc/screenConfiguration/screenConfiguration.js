import { LightningElement, api, wire } from 'lwc';

// importing from Apex Class
import getRecords from '@salesforce/apex/screenConfigurationController.getRecords';

export default class ScreenConfiguration extends LightningElement 
{
    @api screenName = 'Form 7200-05';

    lwcData;
    error;

    @wire(getRecords, {screenName: 'Form 7200-05'} )
        wiredRecords(result) 
        {
            if (result.data) 
            {
                console.log('Json Result: ' + JSON.stringify(result.data));
                this.populateData(result.data);                
                this.error = undefined;
            } 
            else if (result.error) 
            {
                console.log('Json Error: ' + JSON.stringify(result.error));
                this.lwcData = undefined;
                this.error = result.error;
            }
        }

    populateData(record) 
        {
            this.lwcData = record;
            console.log('lwcData length: ' + this.lwcData.listScreenElement.length);
            console.log('lwcData: ' + JSON.stringify(this.lwcData.listScreenElement));

        }
}