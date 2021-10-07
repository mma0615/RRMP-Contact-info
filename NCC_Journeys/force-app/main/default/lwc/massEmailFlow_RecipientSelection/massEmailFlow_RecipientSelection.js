import { api, LightningElement } from 'lwc';
import searchContactRecipient from '@salesforce/apex/MassEmailFlow_Utility.searchContactRecipient';
import getLookupResultsById from '@salesforce/apex/MassEmailFlow_Utility.getLookupResultsById';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class MassEmailFlow_RecipientSelection extends LightningElement {
    isMultipleEntry = true;
    _contactList = [];
    initialSelection = [];

    @api
    get contactList(){
        return this._contactList;
    }
    set contactList(contacts){
        this._contactList = contacts;
    }

    connectedCallback(){
        // console.log('rendering!');
        // if user have selected previously and goes back from Screen 3 to Screen 2
        if(this.contactList.length !== 0){
            getLookupResultsById({initialLookupIds: this.contactList})
                .then(result => {
                    this.initialSelection = result;
                    // console.log('Initial Selection', this.initialSelection);
                })
                .catch(error => {
                    console.log('Error', error);
                })
        }
    }

    handleContactSearch(event){
        const lookupElement = event.target;
        searchContactRecipient(event.detail)
            .then(results => {
                lookupElement.setSearchResults(results);
                //console.log(JSON.stringify(results));
            })
            .catch(error => {
                // TODO: handle error
                console.log(error);
            });
    }

    handleContactSelect(event){
        try{
            const selection = event.target.getSelection();
            this.initialSelection = selection;
            this.contactList = selection.map(item => {
                console.log(item);
                return item.id;
            });
            
            console.log('Contact List', this.contactList);
            const attributeChangeEvent = new FlowAttributeChangeEvent('contactList', this._contactList);
            this.dispatchEvent(attributeChangeEvent);
        }catch(error){
            console.log('error', error);
        }
    }

    handleRemoveRecipient(event){
        console.log(JSON.stringify('data-target-id', event.target.dataset.targetId));
        this.initialSelection = this.initialSelection.filter(item => item.id !== event.target.dataset.selectedId);
        this.contactList = this.contactList.filter(item => item !== event.target.dataset.selectedId);
        console.log(JSON.stringify(this.initialSelection));
        console.log(JSON.stringify(this.contactList));
    }

}