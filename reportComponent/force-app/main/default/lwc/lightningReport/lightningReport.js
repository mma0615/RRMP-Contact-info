import { LightningElement, wire } from 'lwc';

import getReportResponse from '@salesforce/apex/lightningReportsController.getReportResponse';

export default class LightningReport extends LightningElement {

    reportId = '00O5w000009hYYvEAM';

    reportData;
    error;

    @wire(getReportResponse, {reportId: '$reportId'} )
        wiredRecords(result) 
        {
            if (result.data) 
            {
                console.log('Json Result: ' + result.data);
                this.reportData = JSON.parse(result.data);
                this.error = undefined;    
            } 
            else if (result.error) 
            {
                console.log('Json Error: ' + JSON.stringify(result.error));
                this.reportData = undefined;
                this.error = result.error;
            }
        }
}