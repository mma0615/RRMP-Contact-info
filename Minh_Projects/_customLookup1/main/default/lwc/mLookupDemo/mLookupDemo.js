import { LightningElement, track } from 'lwc';

export default class MLookupDemo extends LightningElement {
    @track accountName;  
    @track accountRecordId;  

    onSelection(event){  
        this.accountName = event.detail.selectedValue;  
        this.accountRecordId = event.detail.selectedRecordId;  
    }  
}