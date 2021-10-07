import { LightningElement} from 'lwc';
import getMaterials from '@salesforce/apex/MaterialsController.getMaterials';

export default class MaterialsList extends LightningElement {
    materials;
    eventId;

    connectedCallback(){
        const url = new URL(window.location.href);
        this.eventId = url.searchParams.get("id");
        this.handleGetMaterials();
    }

    handleGetMaterials(){
        console.log('result -- ');
        getMaterials({
            eventId : this.eventId
        })
            .then(result =>{
                console.log('result -- ' + result);
                this.materials = JSON.parse(result);
            })
            .catch(error =>{
                console.log('ERROR');
            })
    }
}