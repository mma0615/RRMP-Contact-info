/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import FIRSTNAME_FIELD from '@salesforce/schema/Lead.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Lead.LastName';
import COMPANY_FIELD from '@salesforce/schema/Lead.Company';
import EMAIL_FIELD from '@salesforce/schema/Lead.Email';
import createArticle from '@salesforce/apex/addArticleApex.createArticle';
import getTarget from '@salesforce/apex/addArticleApex.getChildCategoriesofTarget';
import getTopics from '@salesforce/apex/addArticleApex.getChildCategoriesofTopic';
import getSource from '@salesforce/apex/addArticleApex.getChildCategoriesofSource';
import getAttribute from '@salesforce/apex/addArticleApex.getChildCategoriesofAttributes';
import saveFile from '@salesforce/apex/addArticleApex.saveFile';
import savePdf from '@salesforce/apex/addArticleApex.savePdf';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const DELAY = 7000;
export default class addArticle extends NavigationMixin(LightningElement) {

    @track title = '';
    @track urlName = '';
    @track urlOne = '';
    @track source = '';
    @track summary = '';
    @track otherTopic = '';
    @track otherTarget = '';
    @track otherSource = '';
    @track otherSource_attribute = '';
    @track description = '';
    @track firstname = FIRSTNAME_FIELD;
    @track lastname = LASTNAME_FIELD;
    @track company = COMPANY_FIELD;
    @track email = EMAIL_FIELD;
    @track selectedFirst=[];
    @track selectedSecond = [];
    @track selectedThird = [];
    @track selectedFourth=[];
    @track showInformation = [];
    @track urlTwos;
    @track urlThrees;
    @track fourthess;
    @track fivthes;
    @track showOtherTarget = false;
    @track showOtherTopic = false;
    @track showOtherSource = false;
    @track showOthersource_Att = false;
    @track selectedlist = [];
    @track message;
    @track showContact = true;
    @track spinner = false;
    @track fileName = '';
    @track pdfName = '';
    @track delayTimeout;
    @track UploadFile = 'Upload File';
    @track items = [];
    @track itemSource = [];
    @track itemTarget = [];
    @track itemAttribute = [];
    
    selectedRecords;
    filesUploaded = [];
    pdfUploaded = [];
    file;
    fileContents;
    listOfOtherFields = [];
    firstSelect;
    secondSelect;
    thirdSelect;
    fourthSelect;
    fileReader;
    content;
    contentPdf;
    pdf;
    pdfContents;
    pdfReader;
    pdfcontent;
    MAX_FILE_SIZE = 1200000;

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }

    get pdfFormat() {
        return ['.pdf'];
    }

    rec = {

        Title: this.title,
        UrlName: this.urlName,
        Article_URL_1__c: this.urlOne,
        Source__c: this.source,
        Summary: this.summary,
        Additional_Topic__c: this.otherTopic,
        Additional_Target_Audience__c: this.otherTarget,
        Additional_Source__c: this.otherSource,
         Additional_Source_Attribute__c: this.otherSource_attribute,
        Description__c: this.description
    }
    recContact = {
        FirstName: this.firstname,
        LastName: this.lastname,
        Company: this.company,
        Email: this.email
    }


    @wire(getTarget)
    wiredTarget({ error, data }) {
        if (data) {

            console.log('data ', data);
            var getResultss = JSON.parse(data);
            console.log('getResultss ', getResultss);
            var mapOfListValues = [];
            for (let key in getResultss) {
                mapOfListValues.push({ key: key, value: getResultss[key] });
            }
            console.log('mapp ', mapOfListValues);
            for (var keys in mapOfListValues) {
                //console.log('id=' + data[i].Id);
                this.itemTarget = [...this.itemTarget, { value: mapOfListValues[keys].value, label: mapOfListValues[keys].key }];
            }
            console.log('itemTarget   ', this.itemTarget);
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    //getter property from statusOptions which return the items array
    get targetValues() {
        console.log(this.itemTarget);
        return this.itemTarget;
    }



    @wire(getTopics)
    wiredTopics({ error, data }) {
        if (data) {

            console.log('data ', data);
            var getResult = JSON.parse(data);
            console.log('getResult ', getResult);
            var mapOfListValues = [];
            for (let key in getResult) {
                mapOfListValues.push({ key: key, value: getResult[key] });
            }
            console.log('mapp ', mapOfListValues);
            for (var keys in mapOfListValues) {
                //console.log('id=' + data[i].Id);
                this.items = [...this.items, { value: mapOfListValues[keys].value, label: mapOfListValues[keys].key }];
            }
            console.log('item   ', this.items);
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    //getter property from statusOptions which return the items array
    get topicValues() {
        console.log(this.items);
        return this.items;
    }



    @wire(getSource)
    wiredSource({ error, data }) {
        if (data) {

            console.log('data ', data);
            var getResult = JSON.parse(data);
            console.log('getResult ', getResult);
            var mapOfListValues = [];
            for (let key in getResult) {
                mapOfListValues.push({ key: key, value: getResult[key] });
            }
            console.log('mapp ', mapOfListValues);
            for (var keys in mapOfListValues) {
                //console.log('id=' + data[i].Id);
                this.itemSource = [...this.itemSource, { value: mapOfListValues[keys].value, label: mapOfListValues[keys].key }];
            }
            console.log('itemSource   ', this.itemSource);
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    //getter property from statusOptions which return the items array
    get sourceValues() {
        console.log(this.itemSource);
        return this.itemSource;
    }
    


    @wire(getAttribute)
    wiredAttribute({ error, data }) {
        if (data) {

            console.log('data ', data);
            var getResult = JSON.parse(data);
            console.log('getResult ', getResult);
            var mapOfListValues = [];
            for (let key in getResult) {
                mapOfListValues.push({ key: key, value: getResult[key] });
            }
            console.log('mapp ', mapOfListValues);
            for (var keys in mapOfListValues) {
                //console.log('id=' + data[i].Id);
                this.itemAttribute = [...this.itemAttribute, { value: mapOfListValues[keys].value, label: mapOfListValues[keys].key }];
            }
            console.log('itemAttribute   ', this.itemAttribute);
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    //getter property from statusOptions which return the items array
    get attributeValues() {
        console.log(this.itemAttribute);
        return this.itemAttribute;
    }

    /* get topicValues() {
         return [
             { label: 'All', value: 'Topic' },
             { label: 'Economics', value: 'Economics' },
             { label: 'Future Planning', value: 'Future_Planning' },
             { label: 'General', value: 'General' },
             { label: 'How to Help', value: 'How_to_Help' },
             { label: 'Managing Grief and Death', value: 'Managing_Grief_and_Death' },
             { label: 'Mental Health', value: 'Mental_Health' },
             { label: 'Prevention', value: 'Prevention' },
             { label: 'Resources and Statistics', value: 'Resources_and_Statistics' },
             { label: 'Risk', value: 'Risk' },
             { label: 'Symptoms and Actions', value: 'Symptoms_and_Actions' },
             { label: 'Testing', value: 'Testing' },
             { label: 'Treatment', value: 'Treatment' },
             { label: 'Virus and Disease', value: 'Virus_and_Disease' },
             { label: 'Additional Topic', value: 'Additional_Topic__c' }
         ]
     }*/


    // get sourceValues() {
    //     return [
    //         { label: 'All', value: 'Source' },
    //         { label: 'Yale CORE', value: 'Yale_CORE' },
    //         { label: 'JAMA', value: 'JAMA' },
    //         { label: 'Additional Source', value: 'Additional_Source__c' }
    //     ]
    // }



    handleFirstName(event) {
        var firstNameField = this.template.querySelector('[data-id="firstname"]');
        this.recContact.FirstName = event.target.value;

        if (this.recContact.FirstName !== [] || this.recContact.FirstName !== undefined || this.recContact.FirstName !== '') {
            firstNameField.setCustomValidity("");
            firstNameField.reportValidity();
        }
    }
    handleLastName(event) {
        var lastNameField = this.template.querySelector('[data-id="lastname"]');
        this.recContact.LastName = event.target.value;
        if (this.recContact.LastName !== [] || this.recContact.LastName !== undefined || this.recContact.LastName !== '') {
            lastNameField.setCustomValidity("");
            lastNameField.reportValidity();
        }
    }
    handleCompany(event) {
        var companyField = this.template.querySelector('[data-id="company"]');
        this.recContact.Company = event.target.value;
        if (this.recContact.FirstName !== [] || this.recContact.FirstName !== undefined || this.recContact.FirstName !== '') {
            companyField.setCustomValidity("");
            companyField.reportValidity();
        }
    }
    handleEmail(event) {
        var emailField = this.template.querySelector('[data-id="email"]');
        this.recContact.Email = event.target.value;
        if (this.recContact.FirstName !== [] || this.recContact.FirstName !== undefined || this.recContact.FirstName !== '') {
            emailField.setCustomValidity("");
            emailField.reportValidity();
        }
    }




    handleNext() {
        var firstNameField = this.template.querySelector('[data-id="firstname"]');
        var firstNameValue = firstNameField.value;
        var lastNameField = this.template.querySelector('[data-id="lastname"]');
        var lastNameValue = lastNameField.value;
        var companyField = this.template.querySelector('[data-id="company"]');
        var companyValue = companyField.value;
        var emailField = this.template.querySelector('[data-id="email"]');
        var emailValue = emailField.value;
        var flag = false;
        if (firstNameValue.length === 0 || firstNameValue === '' || firstNameValue === undefined) {

            firstNameField.setCustomValidity("Complete this field");
            firstNameField.reportValidity();
            flag = true;
        }
        if (lastNameValue.length === 0 || lastNameValue === '' || lastNameValue === undefined) {

            lastNameField.setCustomValidity("Complete this field");
            lastNameField.reportValidity();
            flag = true;
        }
        if (companyValue.length === 0 || companyValue === '' || companyValue === undefined) {

            companyField.setCustomValidity("Complete this field");
            companyField.reportValidity();
            flag = true;
        }
        if (emailValue.length === 0 || emailValue === '' || emailValue === undefined) {

            emailField.setCustomValidity("Complete this field");
            emailField.reportValidity();
            flag = true;
        }
        if (flag) {
            return;
        }
        this.selectedFirst = this.selectedFirst;

        this.showContact = false;
    }
    handleback() {
        this.showContact = true;
    }

    handleTitle(event) {
        var titleField = this.template.querySelector('[data-id="title"]');
        this.rec.Title = event.target.value;
        if (this.rec.Title !== [] || this.rec.Title !== undefined || this.rec.Title !== '') {
            titleField.setCustomValidity("");
            titleField.reportValidity();
        }
    }

    handleSummary(event) {
        var summaryField = this.template.querySelector('[data-id="summary"]');
        this.rec.Summary = event.target.value;
        if (this.rec.Summary !== [] || this.rec.Summary !== undefined || this.rec.Summary !== '') {
            summaryField.setCustomValidity("");
            summaryField.reportValidity();
        }
    }

    handleUrl(event) {
        var urlField = this.template.querySelector('[data-id="url"]');
        this.rec.UrlName = event.target.value;
        if (this.rec.UrlName !== [] || this.rec.UrlName !== undefined || this.rec.UrlName !== '') {
            urlField.setCustomValidity("");
            urlField.reportValidity();
        }
    }

    handleSource(event) {
        var sourceField = this.template.querySelector('[data-id="source"]');
        this.rec.Source__c = event.target.value;
        if (this.rec.Source__c !== [] || this.rec.Source__c !== undefined || this.rec.Source__c !== '') {
            sourceField.setCustomValidity("");
            sourceField.reportValidity();
        }
    }


    handleUrlOne(event) {
        var FirstURL = this.template.querySelector('[data-id="urlOne"]');
        this.rec.Article_URL_1__c = event.target.value;
        if (this.rec.Article_URL_1__c !== [] || this.rec.Article_URL_1__c !== undefined || this.rec.Article_URL_1__c !== '') {
            FirstURL.setCustomValidity("");
            FirstURL.reportValidity();
        }
    }

    handleUrltwo(event) {
        this.urlTwos = event.target.value;
    }

    handleUrlThree(event) {
        this.urlThrees = event.target.value;
    }

    handleUrlFourth(event) {
        this.fourthess = event.target.value;
    }

    handleUrlFivth(event) {
        this.fivthes = event.target.value;
    }



    handledescChange(event) {
        this.rec.Description__c = event.target.value;
    }

    onChange1(event) {

        this.firstSelect = event.detail.value;
        var titleField = this.template.querySelector('[data-id="Target_Audiences"]');
        if(this.firstSelect !== 'Additional_Target_Audience__c'){
            if (this.selectedFirst.length >= 8) {
                titleField.setCustomValidity("You cannot select more than eight categories");
                titleField.reportValidity();
            }
            else {
                this.selectedFirst.push(this.firstSelect);
                let setquery = new Set();
                for (var keys in this.selectedFirst) {
                    setquery.add(this.selectedFirst[keys]);
                }
                this.selectedFirst = Array.from(setquery);
        }
    }
        else{
            this.listOfOtherFields.push(this.firstSelect);
            this.showOtherTarget = true;
        }

    }

    onChange2(event) {

        this.secondSelect = event.detail.value;
        var titleField = this.template.querySelector('[data-id="Topic_id"]');
        if (this.secondSelect !== 'Additional_Topic__c') {
            if (this.selectedSecond.length >= 8) {
                titleField.setCustomValidity("You cannot select more than eight categories");
                titleField.reportValidity();
            }
            else {
                this.selectedSecond.push(this.secondSelect);
                let setquery = new Set();
                for (var keys in this.selectedSecond) {
                    setquery.add(this.selectedSecond[keys]);
                }
                this.selectedSecond = Array.from(setquery);
                // if(this.selectedSecond.length === 8){
                //     this.disabledSource =true;
                // }
            }
            console.log('slectedtopic ', this.showInformation)

        }
        else {
            this.listOfOtherFields.push(this.secondSelect);
            this.showOtherTopic = true;
        }

    }
    onChange3(event) {
        this.thirdSelect = event.detail.value;
        var titleField = this.template.querySelector('[data-id="Source_id"]');
        if (this.thirdSelect !== 'Additional_Source__c') {
            if (this.selectedThird.length >= 8) {
                titleField.setCustomValidity("You cannot select more than eight categories");
                titleField.reportValidity();
            }
            else {

                this.selectedThird.push(this.thirdSelect);
                let setquery = new Set();
                for (var keys in this.selectedThird) {
                    setquery.add(this.selectedThird[keys]);
                }
                this.selectedThird = Array.from(setquery);
                // if(this.selectedThird.length === 8){
                //     this.disabledSource =true;
                // }

            }
            
            console.log('sourceInfor ', this.showInformation)
        }

        else {
            this.listOfOtherFields.push(this.thirdSelect);
            this.showOtherSource = true;
        }

    }

    onChange4(event) {
        var attributeValidity = this.template.querySelector('[data-id="Source_Attribute_id"]');
        this.fourthSelect = event.detail.value;
        if(this.fourthSelect !== 'Additional_Source_Attribute__c'){
            if (this.selectedFourth.length >= 8) {
                attributeValidity.setCustomValidity("You cannot select more than eight categories");
                attributeValidity.reportValidity();
            }
            else {
            this.selectedFourth.push(this.fourthSelect);
            let setquery = new Set();
                for (var keys in this.selectedFourth) {
                    setquery.add(this.selectedFourth[keys]);
                }
                this.selectedFourth = Array.from(setquery);
        }}

        else {
            this.listOfOtherFields.push(this.fourthSelect);
            this.showOthersource_Att = true;
        }

    }

    removeFirstPill(event) {
        var targetValidity = this.template.querySelector('[data-id="Target_Audiences"]');
        var ab=[];
        ab=this.selectedFirst;
        const index = ab.indexOf(event.target.name);
        this.selectedFirst.splice(index,1);
        if(this.selectedSecond.length <= 8){
            targetValidity.setCustomValidity("");
            targetValidity.reportValidity();
        }
    }


    removeSecondPill(event) {
        var topicValidity = this.template.querySelector('[data-id="Topic_id"]');
        var ab = [];
        ab = this.selectedSecond;
        const index = ab.indexOf(event.target.name);
        this.selectedSecond.splice(index, 1);
        if(this.selectedSecond.length <= 8){
            //this.disabledSource = false;
            topicValidity.setCustomValidity("");
            topicValidity.reportValidity();
        }
    }

    removeThirdPill(event) {
        var sourceValidity = this.template.querySelector('[data-id="Source_id"]');
        var ab = [];
        ab = this.selectedThird;
        const index = ab.indexOf(event.target.name);
        this.selectedThird.splice(index, 1);
        if(this.selectedThird.length <= 8){
            //this.disabledTopic = false;
            sourceValidity.setCustomValidity("");
            sourceValidity.reportValidity();
        }
    }

    removeFourthPill(event) {
        var attributeValidity = this.template.querySelector('[data-id="Source_Attribute_id"]');
        var ab=[];
        ab=this.selectedFourth;
        const index = ab.indexOf(event.target.name);
        this.selectedFourth.splice(index,1);
        if(this.selectedFourth.length <= 8){
            //this.disabledTopic = false;
            attributeValidity.setCustomValidity("");
            attributeValidity.reportValidity();
        }
    }


    handleOtherTarget(event) {
        var otherTarget = this.template.querySelector('[data-id="otherTarget"]');
        this.rec.Additional_Target_Audience__c = event.target.value;
        if (this.rec.Additional_Target_Audience__c !== [] || this.rec.Additional_Target_Audience__c !== undefined || this.rec.Additional_Target_Audience__c !== '') {
            otherTarget.setCustomValidity("");
            otherTarget.reportValidity();
        }
    }

    handleOtherTopic(event) {
        var otherTopic = this.template.querySelector('[data-id="otherTopic"]');
        this.rec.Additional_Topic__c = event.target.value;
        if (this.rec.Additional_Topic__c !== [] || this.rec.Additional_Topic__c !== undefined || this.rec.Additional_Topic__c !== '') {
            otherTopic.setCustomValidity("");
            otherTopic.reportValidity();
        }
    }

    handleOtherSource(event) {
        var otherSource = this.template.querySelector('[data-id="otherSource"]');
        this.rec.Additional_Source__c = event.target.value;
        if (this.rec.Additional_Source__c !== [] || this.rec.Additional_Source__c !== undefined || this.rec.Additional_Source__c !== '') {
            otherSource.setCustomValidity("");
            otherSource.reportValidity();
        }
    }

    handleOtherSource_att(event) {
        var otherSourceAtt = this.template.querySelector('[data-id="otherSourceAtt"]');
        this.rec.Additional_Source_Attribute__c = event.target.value;
        if (this.rec.Additional_Source_Attribute__c !== [] || this.rec.Additional_Source_Attribute__c !== undefined || this.rec.Additional_Source_Attribute__c !== '') {
            otherSourceAtt.setCustomValidity("");
            otherSourceAtt.reportValidity();
        }
    }


    handleClick() {
        var titleField = this.template.querySelector('[data-id="title"]');
        var titleValue = titleField.value;
        var urlField = this.template.querySelector('[data-id="url"]');
        var urlValue = urlField.value;
        var sourceField = this.template.querySelector('[data-id="source"]');
        var sourceValue = sourceField.value;
        var summaryField = this.template.querySelector('[data-id="summary"]');
        var summaryValue = summaryField.value;
        var descField = this.template.querySelector('[data-id="desc"]');
        var descValue = descField.value;
        var FirstURL = this.template.querySelector('[data-id="urlOne"]');
        var URLValue = FirstURL.value;
        var fileupload = this.template.querySelector('[data-id="fileupload"]');
        var fileuploadValue = fileupload.value;
        var targetValidity = this.template.querySelector('[data-id="Target_Audiences"]');
        var topicCategory = this.template.querySelector('[data-id="Topic_id"]');
        var sourceCategory = this.template.querySelector('[data-id="Source_id"]');
        var attributeValidity = this.template.querySelector('[data-id="Source_Attribute_id"]');
        
        
        var flag = false;

        if (fileuploadValue.length === 0 || fileuploadValue === '' || fileuploadValue === undefined) {
            this.fileName = 'Please select the file'
            flag = true;
        }
        if (fileuploadValue.length !== 0 || fileuploadValue !== '' || fileuploadValue !== undefined) {
            this.file = this.filesUploaded[0];
            if (this.file.size > this.MAX_FILE_SIZE) {
                this.fileName = 'File Size is too long,insert upto 1.5MB';
                flag = true;
            }
        }
        if (this.pdfUploaded.length > 0) {
            this.pdf = this.pdfUploaded[0];
            if (this.pdf.size > this.MAX_FILE_SIZE) {
                this.pdfName = 'File Size is too long,insert upto 1.5MB';
                flag = true;
            }
        }

        if (titleValue.length === 0 || titleValue === '' || titleValue === undefined) {

            titleField.setCustomValidity("Complete this field");
            titleField.reportValidity();
            flag = true;
        }
        if (URLValue.length === 0 || URLValue === '' || URLValue === undefined) {

            FirstURL.setCustomValidity("Complete this field");
            FirstURL.reportValidity();
            flag = true;
        }
        var regex = '^([a-zA-Z0-9-]+\[a-zA-Z0-9-])+(\/[a-zA-Z0-9-]+\/?)*$';
        if (urlValue.length !== 0 || urlValue !== '' || urlValue !== undefined) {
            if (!urlValue.match(regex)) {
                urlField.setCustomValidity("URL field must contain hyphen between the words e.g. my-url-name and should not be duplicate");
                urlField.reportValidity();
                flag = true;
            }
            else {

            }
        }
        this.selectedlist = [];



        if (urlValue.length === 0 || urlValue === '' || urlValue === undefined) {

            urlField.setCustomValidity("Complete this field");
            urlField.reportValidity();
            flag = true;
        }
        if (summaryValue.length === 0 || summaryValue === '' || summaryValue === undefined) {

            summaryField.setCustomValidity("Complete this field");
            summaryField.reportValidity();
            flag = true;
        }
        if (sourceValue.length === 0 || sourceValue === '' || sourceValue === undefined) {

            sourceField.setCustomValidity("Complete this field");
            sourceField.reportValidity();
            flag = true;
        }
        if (descValue === 0 || descValue === '' || descValue === undefined) {
            const event = new ShowToastEvent({
                title: 'Write some description'
            });
            this.dispatchEvent(event);
            flag = true;
        }
        if (this.selectedFirst.length > 0) {

            for(var key in this.selectedFirst){
                this.selectedlist.push(this.selectedFirst[key]);
            }

        }

        if (this.selectedSecond.length > 0) {
            for (var key in this.selectedSecond) {
                this.selectedlist.push(this.selectedSecond[key]);
                console.log('topic ', this.selectedlist);
            }
        }
        if (this.selectedThird.length > 0) {
            for (var key in this.selectedThird) {
                this.selectedlist.push(this.selectedThird[key]);
                console.log('source ', this.selectedlist);
            }
        }

        if (this.selectedFourth.length > 0) {
            for(var key in this.selectedFourth){
                this.selectedlist.push(this.selectedFourth[key]);
                }
        }


        if (this.selectedlist.length > 8) {
            const event = new ShowToastEvent({
                title: 'You cannot select more than eight categories',
                duration: '70000'

            });
            this.dispatchEvent(event);
            this.selectedlist = [];
            flag = true;
        }
        
        console.log('this.selectedlist ', this.selectedlist);
        if (flag) {
            return;
        }

        var first = false;
        var second = false;
        var third = false;
        var fourth = false;
        for (var keys in this.listOfOtherFields) {
            if (this.listOfOtherFields[keys] === 'Additional_Target_Audience__c') {
                first=true;

            }
            if (this.listOfOtherFields[keys] === 'Additional_Topic__c') {
                second = true;

            }
            if (this.listOfOtherFields[keys] === 'Additional_Source__c') {
                third = true;

            }
            if (this.listOfOtherFields[keys] === 'Additional_Source_Attribute__c') {
                fourth=true;

            }
        }
        if(!first){
            this.rec.Additional_Target_Audience__c = 'None';
        }
        if (!second) {
            this.rec.Additional_Topic__c = 'None';
        }
        if (!third) {
            this.rec.Additional_Source__c = 'None';
        }
        if(!fourth){
            this.rec.Additional_Source_Attribute__c = 'None';
        }
        if (this.selectedFirst.length <= 8) {
            targetValidity.setCustomValidity("");
            targetValidity.reportValidity();
        }

        if (this.selectedSecond.length <= 8) {
            topicCategory.setCustomValidity("");
            topicCategory.reportValidity();
        }

        if (this.selectedThird.length <= 8) {
            sourceCategory.setCustomValidity("");
            sourceCategory.reportValidity();
        }
        if (this.selectedFourth.length <= 8) {
            attributeValidity.setCustomValidity("");
            attributeValidity.reportValidity();
        }



        if (this.urlTwos === '' || this.urlTwos === undefined || this.urlTwos === []) {
            this.urlTwos = 'Nothing'
        }
        if (this.fourthess === '' || this.fourthess === undefined || this.fourthess === []) {
            this.fourthess = 'Nothing'
        }
        if (this.urlThrees === '' || this.urlThrees === undefined || this.urlThrees === []) {
            this.urlThrees = 'Nothing'
        }
        if (this.fivthes === '' || this.fivthes === undefined || this.fivthes === []) {
            this.fivthes = 'Nothing'
        }
        this.spinner = true;

        createArticle({ acc: this.rec, lead: this.recContact, urlTwo: this.urlTwos, urlThrees: this.urlThrees, urlForth: this.fourthess, urlFiv: this.fivthes, target: this.selectedlist })
            .then(result => {
                this.message = result;
                this.error = undefined;
                if (this.message.includes('Error ') === false) {
                    if (this.filesUploaded.length > 0) {
                        this.handleSave();

                    }
                    window.clearTimeout(this.delayTimeout);

                    this.delayTimeout = setTimeout(() => {
                        this.spinner = false;
                        this.rec.Title = '';
                        this.rec.UrlName = '';
                        this.rec.Source__c = '';
                        this.rec.Summary = '';
                        this.rec.Article_URL_1__c = '';
                        this.urlTwos = '';
                        this.urlThrees = '';
                        this.fourthess = '';
                        this.fivthes = '';
                        this.listOfOtherFields = [];

                        this.rec.Additional_Source_Attribute__c = '';
                        this.rec.Additional_Source__c = '';
                        this.rec.Additional_Target_Audience__c = '';
                        this.rec.Additional_Topic__c = '';
                        if (this.selectedFirst.lenght > 0) {
                            this.selectedFirst = [];
                            this.showOtherTarget = false;
                        }
                        if (this.selectedSecond.length > 0) {
                            this.selectedSecond = [];
                            this.showOtherTopic = false;
                        }
                        if (this.selectedThird.length > 0) {
                            this.selectedThird = [];
                            this.showOtherSource = false;
                        }
                        if (this.selectedFourth.length > 0) {
                            this.selectedFourth = [];
                            this.showOthersource_Att = false;
                        }
                        if (this.selectedlist !== []) {
                            this.selectedFirst = [];
                            this.selectedSecond = [];
                            this.selectedThird = [];
                            this.selectedFourth = [];

                        }

                        this.selectedlist = [];
                        this.rec.Description__c = '';
                        this.fileName = '';
                        this.pdfName = '';
                        this.filesUploaded = '';
                        this.pdfUploaded = '';

                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'Home'
                            }
                        });
                    }, DELAY);
                }
                else {
                    this.spinner = false;
                    this.selectedlist = [];
                    const showError = new ShowToastEvent({
                        title: 'Error!!',
                        message: this.message,
                        variant: 'error',
                        duration: '70000',
                    });
                    this.dispatchEvent(showError);
                }

            })
    }


    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    handleSave() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            console.log('File Size is too long');
            //  return;
        }
        // create a FileReader object 
        this.fileReader = new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);

            saveFile({ idParent: this.message, strFileName: this.file.name, base64Data: encodeURIComponent(this.fileContents) })
                .then(result => {
                    //this.spinner=false;
                    if (this.pdfUploaded.length > 0) {
                        this.handleSavePdf();
                    }
                    // Showing Success message after file insert
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!!',
                            message: 'Thanks for submitting the Article',
                            variant: 'success',
                        }),
                    );


                })

                .catch(error => {
                    // Showing errors if any while inserting the files
                    window.console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while uploading Image',
                            message: error.message,
                            variant: 'error',
                        }),
                    );
                });

        });


        this.fileReader.readAsDataURL(this.file);

    }

    handlePdfChange(event) {
        if (event.target.files.length > 0) {
            this.pdfUploaded = event.target.files;
            this.pdfName = event.target.files[0].name;
        }
    }

    handleSavePdf() {
        this.pdf = this.pdfUploaded[0];
        if (this.pdf.size > this.MAX_FILE_SIZE) {
            console.log('size of file ', this.pdf.size)
            // return;
        }
        // create a FileReader object 
        this.pdfReader = new FileReader();
        // set onload function of FileReader object  
        this.pdfReader.onloadend = (() => {
            this.pdfContents = this.pdfReader.result;
            let base64 = 'base64,';
            this.contentPdf = this.pdfContents.indexOf(base64) + base64.length;
            this.pdfContents = this.pdfContents.substring(this.contentPdf);
            savePdf({ idParent: this.message, strFileName: this.pdfName, base64Data: encodeURIComponent(this.pdfContents) })
                .then(result => {

                })
                .catch(error => {
                    // Showing errors if any while inserting the files
                    window.console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while uploading pdf',
                            message: error.message,
                            variant: 'error',
                        }),
                    );
                });
        });

        this.pdfReader.readAsDataURL(this.pdf);

    }


}