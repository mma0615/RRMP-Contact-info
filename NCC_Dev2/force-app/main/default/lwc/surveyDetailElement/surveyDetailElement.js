import { LightningElement, api, track } from 'lwc';

const TYPE_TEXT = "Text";
const TYPE_RADIO = "Radio";
const TYPE_RANGE = "Range";

export default class SurveyDetailElement extends LightningElement {
    @api questionId;
    @api type;
    @api label;
    @api options;
    @api min;
    @api max;
    @api step;
    @api questionTitle;
    @api isRequiredField = false;
    @api isIndependentSurvey = false;
    labelFont = '';
    labelClass = 'slds-form-element__label question-label is-inline';

    isText = false;
    isRange = false;
    isRadio = false;
    isPicklist = false;
    optionsWithRandomIds = [];
    rangeId = '';
    isShowRequired = false;

    connectedCallback() {
        if (this.type === TYPE_TEXT) {
            this.isText = true;
        } else if (this.type === TYPE_RADIO) {
            this.isRadio = true;

            for (let i = 0; i < this.options.length; i++) {
                let optionWithId = {value : this.options[i], id : this.makeId(5)};
                this.optionsWithRandomIds.push(optionWithId);
            }

            this.labelClass += ' slds-form-element__legend';

        } else if (this.type === TYPE_RANGE) {
            this.isRange = true;
            this.rangeId = this.makeId(5);
        } else {
            this.isPicklist = true;
        }

        if (this.isIndependentSurvey){
            this.labelClass += ' standalone-survey-font';
            this.labelFont = 'font: 18px/24px Calibri, Regular !important;';
            this.detailElementStyle = 'detailElementIndependent';
        } else {
            this.detailElementStyle = 'detailElement';
        }

        if (this.label.includes("<p>")){
            this.label = this.label.replace("<p>", "").replace("</p>","");
        }
    }

    handleChange(event){
        let elementValue = event.target.value;
        let elementName = event.target.name;

        let isFieldValueValid = this.validationOnChange(elementName, elementValue);

        const changeEvent = new CustomEvent('inputchange', {
            detail: {eventObj : event, isValid : isFieldValueValid}
        });
        
        this.dispatchEvent(changeEvent);
    }

    makeId(length) {
        let result = '';
        let characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let charactersLength = characters.length;
        for (let i = 0; i < length; i++) {
            result += characters.charAt(
                Math.floor(Math.random() * charactersLength)
            );
        }
        return result;
    }

    validationOnChange(elementName, elementValue) {
        let isValid = false;

        if (elementValue !== undefined && !this.isBlank(elementValue)) {
            this.toggleErrorMessage(elementName, 'off');
            isValid = true;
        } else {
            this.toggleErrorMessage(elementName, 'on');
        }

        return isValid;
    }

    isBlank(str) {
        return !str || /^\s*$/.test(str);
    }

    @api
    toggleErrorMessage(elementId, isErrorMessageShown) {
        if (this.questionId === elementId) {
            this.isShowRequired = isErrorMessageShown;
        }
    }
}