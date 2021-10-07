import { LightningElement } from 'lwc';
import COMMUNITY_HEADER_LOGO from '@salesforce/resourceUrl/communityEventHeaderLogo';
import getcampaignName from '@salesforce/apex/linktreeController.getcampaignName';

export default class LinktreeHeader extends LightningElement {
    communityHeaderLogo = COMMUNITY_HEADER_LOGO;
    campaignId;
    campaignLogo ='https://ncc--c.documentforce.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=0681U00000Iw7IU&operationContext=DELIVERY&contentId=05T1U00001kxDw8&page=0&d=/a/1U000000PsY0/B7tExGte9gjx3jk4FtE1icpF_aKdFnCa0C7Q4YoKWSs&oid=00D1U000000G62i&dpt=null&viewId=';
    campaignName = 'Test test test';

    constructor() {
        super();
        const url = new URL(window.location.href);
        this.campaignId = url.searchParams.get('id');
        console.log('CampaignId: ' + this.campaignId);
    }

    
    connectedCallback() {
        getcampaignName({
            id: this.campaignId
        })
        .then((result) => {
            if (result != null) {
                this.campaignName = result;
                console.log(this.campaignName);
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }
    
}