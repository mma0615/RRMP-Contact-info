import { LightningElement, api } from 'lwc';

export default class MaterialsDetails extends LightningElement {
    @api title;
    @api description;
    @api url;

    handleDownload(){
        window.open(this.url, "_blank");
    }
}