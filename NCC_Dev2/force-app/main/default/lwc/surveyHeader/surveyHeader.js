import { LightningElement } from 'lwc';
import COMMUNITY_HEADER_LOGO from '@salesforce/resourceUrl/communityEventHeaderLogo';
import getSurveyLogo from '@salesforce/apex/CCESurveyController.getSurveyLogo';

export default class SurveyHeader extends LightningElement {
    communityHeaderLogo = COMMUNITY_HEADER_LOGO;
    surveyCode;
    surveyLogo;

    constructor() {
        super();
        const url = new URL(window.location.href);
        this.surveyCode = url.searchParams.get('code');
    }

    connectedCallback() {
        getSurveyLogo({
            code: this.surveyCode
        })
        .then((result) => {
            if (result != null) {
                this.surveyLogo = result;
                console.log(this.surveyLogo);
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }
}