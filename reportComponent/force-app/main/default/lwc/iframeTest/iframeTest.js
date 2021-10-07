import { LightningElement, api } from 'lwc';

export default class IframeTest extends LightningElement {
    @api sysId = '202';
    theIframe;

    get fullUrl() {

    return '/lightning/r/Report/00O5w000009hYYvEAM/view?queryScope=userFolders';
    }

    @api isReloaded = false;


renderedCallback() {
    console.log('rendred callback called' + this.theIframe);
        if(this.theIframe==undefined){
            this.theIframe =  this.template.querySelector('iframe');
            this.theIframe.onload = ()=>{
                console.log('Onload called'+this.isReloaded);

                if(!this.isReloaded){
                    this.isReloaded = true;
                    this.theIframe.src = this.theIframe.src ;

                }
            }
        }   

    }
}