import { LightningElement } from 'lwc';
import getcampaignEvents from '@salesforce/apex/linktreeController.getcampaignEvents';

export default class LinktreeDetail extends LightningElement {
    
    campaignId;
    campaignEvents = [];
    error;

    constructor() {
        super();
        const url = new URL(window.location.href);
        this.campaignId = url.searchParams.get('id');
        console.log('CampaignId: ' + this.campaignId);
    }

    connectedCallback() {
        getcampaignEvents({
            campaignId: this.campaignId
        })
        .then((result) => {
            if (result != null) {
                this.campaignEvents = result;
                console.log(this.campaignEvents);
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }
}