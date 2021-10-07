import { LightningElement, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import updateFieldUrl from '@salesforce/apex/NavigatorFileUploadController.updateFieldUrl';
import updateObjectFieldUrl from '@salesforce/apex/NavigatorFileUploadController.updateObjectFieldUrl';
import getOptions from '@salesforce/apex/NavigatorFileUploadController.getOptions';

const ACCEPTED_FORMATS = ['.png', '.svg', '.jpeg', '.jpg'];

export default class NavigatorFileUpload extends LightningElement {
    @api recordId;
    @api objectApiName;
    fileLink;
    selectedField;
    _options;


    connectedCallback(){
        getOptions({recordId : this.recordId})
            .then((data) =>{
                console.log(JSON.stringify(data));
                this.options = data.map(item => {
                    return { label : item.label, value : item.value };
                });
            })
            .catch((error) => {
                console.error(JSON.stringify(error));
                const toastEvt = new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error',
                });
                this.dispatchEvent(toastEvt);
            });

    }

    @api
    get options(){
        return this._options;
    }
    set options(fields){
        this._options = fields;
    }
    
    get acceptedFormats(){
        return ACCEPTED_FORMATS;
    }
    
    @api
    get fileUrl(){
        return this.fileLink;
    }

    async handleUploadFinished(event){
        const uploadedFile = event.detail.files;
        console.log('Uploaded File', JSON.stringify(uploadedFile));
        // server call to get the community url and update the field.
        try{
            console.log('Uploaded File ', uploadedFile[0]);
            const file = uploadedFile[0];
            console.log('Navigator Id', this.recordId);
            let response = await updateObjectFieldUrl({ 
                documentId : file.documentId, 
                recordId : this.recordId, 
                objectApiName : this.objectApiName,
                fieldApiName : this.selectedField
            });
            if(response === 'Success'){
                getRecordNotifyChange([{recordId : this.recordId}]);
            }
            else{
                console.error(response);
            }
        }
        catch(e){
            console.error(e.message);
        }
    }

    handleChange(event){
        this.selectedField = event.detail.value;
        console.log(event.detail.value);
    }

}