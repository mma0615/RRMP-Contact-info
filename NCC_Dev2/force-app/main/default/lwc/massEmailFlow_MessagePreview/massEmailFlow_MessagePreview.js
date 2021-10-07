import { LightningElement, api } from 'lwc';
import getOrgWideEmailAddresses from '@salesforce/apex/CompassEmailController.getOrgWideEmailAddress';
import getEmailTemplates from '@salesforce/apex/CompassEmailController.getEmailTemplates';
const EMAILBODY_CHANGES_DELAY = 500;
const LINEBREAKS = '<br>';
export default class MassEmailFlow_MessagePreview extends LightningElement {

    senderOptions = [];
    emailTemplateOptions = [];
    _emailTemplateList = [];
    _sender = '';
    _subject = '';
    _emailBody = '';
    _emailTemplateId = '';
    isLoading = true;

    @api
    get subject(){
        return this._subject;
    }
    set subject(content){
        this._subject = content;
    }

    @api
    get sender(){
        return this._sender;
    }
    set sender(email){
        this._sender = email;
    }

    @api
    get emailBody(){
        return this._emailBody;
    }
    set emailBody(content){
        this._emailBody = content;
    }

    @api
    get emailTemplateId(){
        return this._emailTemplateId;
    }
    set emailTemplateId(id){
        this._emailTemplateId = id;
    }

    connectedCallback(){
        this.isLoading = true;
        this.loadOrgWideEmail();
        this.loadEmailTemplates();
    }

    loadOrgWideEmail(){
        getOrgWideEmailAddresses()
            .then((result) => {
                this.senderOptions = result.map((item) => {
                    return { label: `${item.DisplayName} <${item.Address}>`, value: item.Address}
                });
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            })
    }

    loadEmailTemplates(){
        getEmailTemplates()
            .then((result) => {
                console.log(result);
                this._emailTemplateList = result;
                this.emailTemplateOptions = result.map((item) => {
                    return { label: item.Name, value: item.Id}
                });
                this.isLoading = false;
                if(this.emailTemplateId) this.template.querySelector('.email-template-combo-box').value = this.emailTemplateId;
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            })
    }

    handleSenderChange(event){
        this.sender = event.target.value;
    }

    handleSubjectChange(event){
        this.subject = event.target.value;
    }

    handleTemplateChange(event){
        this.emailTemplateId = event.target.value;
        this._emailTemplateList.forEach(item => {
            if(item.Id === event.target.value){
                if(item.HtmlValue){
                    this.emailBody = item.HtmlValue;
                }else{
                    this.emailBody = item.Body.replace(/(?:\r\n|\r|\n)/g, '<br></br>');
                }
                console.log('Email Body', this.emailBody);
                this.subject = item.Subject;
            }
        });
    }

    handleEmailBodyChange(event){
        this.emailBody = event.target.value;
    }

}