import { LightningElement, api } from 'lwc';

import loadAnswersAll from '@salesforce/apex/importDataFromCSVController.loadAnswersAll';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class ImportSurveyAnswers extends LightningElement 
{
    @api recordId;

    importData = false;
    data;

    errMessage;
    
    fileDataA;
    fileNameA;

    UploadFile = 'Upload CSV File';
    showLoadingSpinner = false;
    isTrue = false;

    MAX_FILE_SIZE = 1500000;

    handleImportButton()
    {
        this.importData = true;
    }

    handleFilesChangeA(event) 
    {
        const file = event.target.files[0];
        this.fileNameA = file.name;
        console.log('fileNameA: ' + this.fileNameA);
        var reader = new FileReader()
        reader.onloadend = () => {
            var base64 = reader.result;
            this.fileDataA = base64;
        }
        reader.readAsText(file); 
    }

    handleSave()
    {   
        if (!this.fileNameA)
            this.displayMessage('Error', 
            'Must upload at least 1 file...', 
            'error');
        else if (this.fileNameA && this.fileNameA.indexOf('.csv') == -1 ) 
            this.displayMessage('Error', 
                'Can ONLY upload files with extention of csv...', 
                'error');
        else
            this.saveTheFiles();
    }

    saveTheFiles()
    {
        this.showLoadingSpinner = true;

        console.log('recordId: ' + this.recordId);
        console.log('fileDataA: ' + JSON.stringify(this.fileDataA));
        loadAnswersAll({ fileDataA : JSON.stringify(this.fileDataA) })
        .then(result=>
            {
                console.log('result ====> ' + result);
                if (result) 
                {
                    this.errMessage = (result + ' ').split(',');
                    this.displayMessage('Error while uploading File(s)', result, 'error');
                }
                else
                {
                    this.isTrue = false;
                    this.showLoadingSpinner = false;
                    this.displayMessage('Success', 'Files Uploaded Successfully...', 'success');
                    this.importData = false;
                }
                
            })
        .catch(error => 
            {
                console.log(error);
                this.displayMessage('Error while uploading File(s)', error.message, 'error');
            });
    }

    displayMessage (tit, msg, vari)
    {
        this.showLoadingSpinner = false;
        console.log('Error event: ' + msg);
        this.dispatchEvent(
            new ShowToastEvent({
                title: tit,
                message: msg,
                variant: vari,
            }),
        );
    }
}