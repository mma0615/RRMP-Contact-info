import { LightningElement, wire } from 'lwc';
import getSurvey from '@salesforce/apex/CCESurveyController.getSurvey';
import createResponse from '@salesforce/apex/CCESurveyController.createResponse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CCE_LOGO from '@salesforce/resourceUrl/Change_Cloud_Events_Logo';
import FOOTER_LOGO from '@salesforce/resourceUrl/communityEventFooterLogo';

export default class SurveyDetails extends LightningElement {
    eventId;
    surveyName;
    campaignId;
    showButton = false;
    result = {};
    showSpinner = false;
    firstname = '';
    lastname = '';
    dateOfSession = '';
    facility = '';
    email = '';
    CCE_LOGO = CCE_LOGO;
    SURVEY_LOGO_URL;
    disclaimerText;
    spinnerHeight;
    FOOTER_LOGO = FOOTER_LOGO;
    showNoSurveyMessage = false;

    constructor() {
        super();
        const url = new URL(window.location.href);
        this.eventId = url.searchParams.get('id');
    }

    connectedCallback() {
        this.showSpinner = true;
        getSurvey({
            eventId: this.eventId
        })
            .then((rs) => {
                if (rs != null) {
                    let result = JSON.parse(rs);
                    this.campaignId = result.Survey.Campaign__c;
                    this.disclaimerText = result.Survey.Disclaimer__c;
                    this.surveyName = result.Survey.Name;
                    let questions = result.Survey.Survey_Questions__r.records;
                    // Processing ContentVersion data to display survey logo
                    // 25/05/2020 Jasmine - Hide header as requested in task #00157
                    // if (!this.isBlank(result.BlobWrapper)){
                    //     let surveyIMG = this.template.querySelector("[data-id=dynamicLogo");
                    //     const contentType = 'image/' + result.BlobWrapper.FileType.toLowerCase();
                    //     const blob = this.b64toBlob(result.BlobWrapper.VersionData, contentType);
                    //     const blobUrl = URL.createObjectURL(blob);
                    //     surveyIMG.src = blobUrl;
                    // }
                    for (let i = 0; i < questions.length; i++) {
                        let questionId = questions[i].Id;
                        let label = questions[i].Description__c;
                        let type = questions[i].Question_Type__c;
                        let options =
                            questions[i].Options__c != undefined
                                ? questions[i].Options__c.split(/\r?\n/)
                                : [];
                        let max =
                            questions[i].Max_Value__c != undefined
                                ? questions[i].Max_Value__c
                                : 0;
                        let min =
                            questions[i].Min_Value__c != undefined
                                ? questions[i].Min_Value__c
                                : 0;
                        let step =
                            questions[i].Step__c != undefined
                                ? questions[i].Step__c
                                : 1;
                        this.createElement(
                            questionId,
                            type,
                            label,
                            options,
                            min,
                            max,
                            step
                        );
                    }
                    const bodyElement = this.template.querySelector('.body');
                    bodyElement.querySelectorAll('input').forEach((ip) => {
                        ip.addEventListener(
                            'change',
                            this.handleOnClick.bind(this)
                        );
                    });

                    this.showButton = true;
                    this.showSpinner = false;
                    this.error = undefined;
                } else {
                    setTimeout(() => {
                        this.template.querySelector('.survey').style.display =
                            'none';
                        this.showNoSurveyMessage = true;
                    }, 1000);
                }
            })
            .catch((error) => {
                this.showNotification(
                    'Oops!',
                    "Something's not right. Please contact the administrator for help.",
                    'error',
                    'pester'
                );
            });
    }

    createElement(questionId, type, label, options, min, max, step) {
        if (type == 'Text') {
            let div = document.createElement('div');
            div.classList.add('slds-form-element');
            div.innerHTML = `<label class="slds-form-element__label"></label>`;
            let childDiv = document.createElement('div');
            childDiv.classList.add('slds-form-element__control');
            childDiv.innerHTML = `<input type="text" required="" class="slds-input" name="${label}" placeholder="${label}" data-question-id="${questionId}"/>`;
            div.appendChild(childDiv);
            let helpTextDiv = document.createElement('div');
            helpTextDiv.innerHTML = 'This field is required';
            helpTextDiv.style.display = 'none';
            helpTextDiv.style.color = '#c23934';
            helpTextDiv.setAttribute('data-error-id', label);
            div.appendChild(helpTextDiv);
            const body = this.template.querySelector('.body');
            body.appendChild(div);
        } else if (type == 'Radio') {
            let fieldset = document.createElement('fieldset');
            fieldset.innerHTML = `<legend class="slds-form-element__legend slds-form-element__label">${label}</legend>`;
            let form = document.createElement('div');
            form.classList.add('slds-form-element__control');
            fieldset.appendChild(form);
            for (let i = 0; i < options.length; i++) {
                let value = options[i];
                let span = document.createElement('span');
                let optionId = this.makeid(5);
                span.classList.add('slds-radio');
                span.innerHTML = `<input type="radio" id="${optionId}" value="${value}" name="${label}" required="" data-question-id="${questionId}"/>
                                                        <label class="slds-radio__label" for="${optionId}">
                                                            <span class="slds-radio_faux"></span>
                                                            <span class="slds-form-element__label">${value}</span>
                                                        </label>`;
                form.appendChild(span);
            }
            let helpTextDiv = document.createElement('div');
            helpTextDiv.innerHTML = 'This field is required';
            helpTextDiv.style.display = 'none';
            helpTextDiv.style.color = '#c23934';
            helpTextDiv.setAttribute('data-error-id', label);
            form.appendChild(helpTextDiv);
            const body = this.template.querySelector('.body');
            body.appendChild(fieldset);
        } else if (type == 'Range') {
            let div = document.createElement('div');
            div.classList.add('slds-form-element');
            div.innerHTML = `<label class="slds-form-element__label">${label}</label>`;
            let childDiv = document.createElement('div');
            childDiv.classList.add('slds-form-element__control');
            let rangeId = this.makeid(5);
            childDiv.innerHTML = `<div class="slds-slider">
                                    <span class="slds-form-element__label" aria-hidden="true">${min}</span>
                                    <input type="range" required="" class="slds-slider__range" name="${label}" min="${min}" 
                                    max="${max}" step="${step}" data-range-id="${rangeId}" data-question-id="${questionId}"/>
                                    <span class="slds-form-element__label" aria-hidden="true">${max}</span>
                                </div>`;
            div.appendChild(childDiv);
            let helpTextDiv = document.createElement('div');
            helpTextDiv.innerHTML = 'This field is required';
            helpTextDiv.style.display = 'none';
            helpTextDiv.style.color = '#c23934';
            helpTextDiv.setAttribute('data-error-id', label);
            div.appendChild(helpTextDiv);
            const body = this.template.querySelector('.body');
            body.appendChild(div);
            // Set default value for range question, otherwise if the user picks the default value and does not move the slider, required error will still be thrown upon submission
            let rangeComponent = this.template.querySelector(
                `[data-range-id="${rangeId}"]`
            );
            rangeComponent.defaultValue = min;
            const rangeDefaultAnswer = {};
            rangeDefaultAnswer.Question = label;
            rangeDefaultAnswer.Answer = min;
            this.result[questionId] = rangeDefaultAnswer;
        } else if (type == 'Picklist') {
            let div = document.createElement('div');
            div.classList.add('slds-form-element');
            div.innerHTML = `<label class="slds-form-element__label">${label}</label>`;

            let childDiv = document.createElement('div');
            childDiv.classList.add('slds-form-element__control');

            let selectDiv = document.createElement('select');
            selectDiv.name = label;
            selectDiv.classList.add('slds-select');
            selectDiv.setAttribute('data-question-id', questionId);
            selectDiv.setAttribute('required', '');
            selectDiv.innerHTML = `<option value="">Please select</option>`;
            for (let i = 0; i < options.length; i++) {
                let value = options[i];
                let option = document.createElement('option');
                option.innerHTML = value;
                option.value = value;
                selectDiv.appendChild(option);
            }
            let selectContainer = document.createElement('div');
            selectContainer.appendChild(selectDiv);
            selectContainer.classList.add('slds-select_container');
            selectContainer.addEventListener(
                'change',
                this.handleOnClick.bind(this)
            );
            // selectContainer.setAttribute('data-question-id', questionId);

            childDiv.appendChild(selectContainer);

            let helpTextDiv = document.createElement('div');
            helpTextDiv.innerHTML = 'This field is required';
            helpTextDiv.style.display = 'none';
            helpTextDiv.style.color = '#c23934';
            helpTextDiv.setAttribute('data-error-id', label);
            childDiv.appendChild(helpTextDiv);

            div.appendChild(childDiv);
            const body = this.template.querySelector('.body');
            body.appendChild(div);
        }
    }

    // Update user details upon input
    handleChange(event) {
        const field = event.target.name;
        if (field === 'dateOfSession') {
            this.dateOfSession = event.target.value;
        } else if (field === 'facility') {
            this.facility = event.target.value;
        } else if (field === 'email') {
            this.email = event.target.value;
        } else if (field === 'firstname') {
            this.firstname = event.target.value;
        } else if (field === 'lastname') {
            this.lastname = event.target.value;
        }
    }

    // Update survey answers upon input
    handleOnClick(event) {
        const userAnswer = {};
        userAnswer.Question = event.target.name;
        userAnswer.Answer = event.target.value;
        const questionId = event.target.getAttribute('data-question-id');
        this.result[questionId] = userAnswer;
        this.validationOnChange(questionId, event.target.name);
    }

    handleSubmit() {
        if (this.isContactDetailsValid() && this.isSurveyInputValid()) {
            this.disableButton();
            const contact = {};
            contact.firstname = this.firstname;
            contact.lastname = this.lastname;
            contact.email = this.email;
            contact.Facility__c = this.facility;

            createResponse({
                eventId: this.eventId,
                contactDetails: JSON.stringify(contact),
                result: JSON.stringify(this.result),
                campaignId: this.campaignId,
                dateOfSession: this.dateOfSession,
            })
                .then((result) => {
                    this.showNotification(
                        'Success!',
                        'Your response has been submitted.',
                        'success',
                        'pester'
                    );
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);
                })
                .catch((error) => {
                    if (error)
                        this.showNotification(
                            'Oops!',
                            "Something's not right. Please contact the administrator for help.",
                            'error',
                            'pester'
                        );
                });
        }
    }

    // Toast message method
    showNotification(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        });
        this.dispatchEvent(evt);
    }

    // Verify if required contact details have been correctly filled in
    isContactDetailsValid() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }

    // Verify if all survey questions have been answered
    isSurveyInputValid() {
        var isValid = true;
        const bodyElement = this.template.querySelector('.body');
        const elements = bodyElement.querySelectorAll('input, select');
        elements.forEach((ip) => {
            const questionId = ip.dataset.questionId;
            if (
                ip.required &&
                (this.result[questionId] === undefined ||
                    this.isBlank(this.result[questionId]))
            ) {
                this.toggleErrorMessage(ip.name, 'on');
                isValid = false;
            } else {
                this.toggleErrorMessage(ip.name, 'off');
            }
        });
        return isValid;
    }

    // Validate survey question on change
    validationOnChange(questionId, elementName) {
        if (
            this.result[questionId] != undefined ||
            this.isBlank(this.result[questionId])
        ) {
            this.toggleErrorMessage(elementName, 'off');
        }
    }

    // Check if string is blank
    isBlank(str) {
        return !str || /^\s*$/.test(str);
    }

    // Check if email is valid
    isEmailValid(email) {
        let isEmailValid = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(
            email
        );
        return isEmailValid;
    }

    // Disable button
    disableButton() {
        this.showSpinner = true;
        const button = this.template.querySelector('.slds-button');
        button.classList.add('disabled');
    }

    // Convert base64 string to blob
    b64toBlob(b64Data, contentType = '', sliceSize = 512) {
        const byteCharacters = atob(b64Data);
        const byteArrays = [];

        for (
            let offset = 0;
            offset < byteCharacters.length;
            offset += sliceSize
        ) {
            const slice = byteCharacters.slice(offset, offset + sliceSize);

            const byteNumbers = new Array(slice.length);
            for (let i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }

            const byteArray = new Uint8Array(byteNumbers);
            byteArrays.push(byteArray);
        }

        const blob = new Blob(byteArrays, { type: contentType });
        return blob;
    }

    // Toggle error visiblity
    toggleErrorMessage(elementId, onOrOff) {
        const errorElement = this.template.querySelector(
            `[data-error-id="${elementId}"]`
        );
        errorElement.style.display = onOrOff === 'on' ? 'unset' : 'none';
    }

    // Generate random id for radio options dom
    makeid(length) {
        let result = '';
        let characters =
            'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let charactersLength = characters.length;
        for (let i = 0; i < length; i++) {
            result += characters.charAt(
                Math.floor(Math.random() * charactersLength)
            );
        }
        return result;
    }
}