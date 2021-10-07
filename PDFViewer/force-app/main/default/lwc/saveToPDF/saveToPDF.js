import { LightningElement, api } from 'lwc';
import generatePDF from '@salesforce/apex/PDFViewController.generatePDF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SaveToPDF extends LightningElement 
{
    @api formId;
    @api recordId;
    @api richText;
    @api formParameters;

    /*
    connectedCallback()
    {
        this.formId = 'Form202_CustomEmail';
        this.formParameters = '{"contactname":"Sean Forbes", "accountname":"Edge Emergency","repname":"Tim Pitman","createddate":"12/21/2020",' +
            '"batterlist":[{ "id": "1001", "type": "Regular" },{ "id": "1002", "type": "Chocolate" },' +
            '{ "id": "1003", "type": "Blueberry" },{ "id": "1004", "type": "Devil\s Food" }]}';
    }
    */

    handleFormChange(event) 
    {
        this.formId = event.target.value;
    }

    handleIdChange(event) 
    {
        this.recordId = event.target.value;
    }

    handleTextchange(event) 
    {
        this.richText = event.target.value;
    }

    handleFormParameters(event) 
    {
        this.formParameters = event.target.value;
    }

    saveAsPdf()
    {
        console.log('saveAsPdf ==> formId=' + this.formId);
        console.log('saveAsPdf ==> recordId=' + this.recordId);
        console.log('saveAsPdf ==> richText=' + this.richText);
        console.log('saveAsPdf ==> formParameters=' + this.formParameters);

        //this.formId = 'Form202_CusttomEmail';
        //this.richText ='{"contactname":"Sean Forbes", "accountname":"Edge Emergency","repname":"Tim Pitman","createddate":"12/21/2020"}';

        //this.helper.saveAsPdf(this.formId, this.recordId, this.richText);
        // calling apex method
        generatePDF({formId: this.formId, recordId: this.recordId, formParameters: this.formParameters})
        .then((result)=>
        {
            this.PDFFile = result;
            console.log('PDFFile id=' + this.PDFFile.Id);
            //show success message
            this.dispatchEvent(
                new ShowToastEvent(
                {
                    title: 'Success',
                    message: 'PDF generated successfully with Id:' + this.PDFFile.Id,
                    variant: 'success',
                }),
            );
        })
        .catch(error=>
        {
        //show error message
            this.dispatchEvent(
                new ShowToastEvent(
                {
                    title: 'Error creating PDFFile record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        })


    }
}