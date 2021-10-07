import { LightningElement} from 'lwc';
import getMaterials from '@salesforce/apex/MaterialsController.getMaterials';
import getMaterialsGrouped from '@salesforce/apex/MaterialsController.getMaterialsGrouped';
import getEventDetail from '@salesforce/apex/MaterialsController.getEvent';


export default class MaterialsList extends LightningElement {
		eventRecord;
		showGrouped = false;
		materials;
		materialsGrouped;
		eventId;

		connectedCallback(){
				const url = new URL(window.location.href);
				this.eventId = url.searchParams.get("id");
				this.handleGetMaterials();
				this.handleGetMaterialsGrouped();
				this.handleEventDetail();

		}

		handleEventDetail(){
				getEventDetail({
						eventId : this.eventId
				})
						.then(result =>{
						this.eventRecord = JSON.parse(result);
						console.log('this.eventRecord' + this.eventRecord);
						this.showGrouped = this.eventRecord.Sessions_with_General_Materials__c;
						console.log('this.showGrouped' + this.showGrouped);
				})
						.catch(error =>{
						console.log('ERROR' + error.message);
				})
		}	

		handleGetMaterials(){
				getMaterials({
						eventId : this.eventId
				})
						.then(result =>{
						this.materials = JSON.parse(result);
				})
						.catch(error =>{
						console.log('ERROR' + error.message);
				})
		}

		handleGetMaterialsGrouped(){
				console.log('result -- ');
				getMaterialsGrouped({
						eventId : this.eventId
				})
						.then(result =>{
						console.log('result -- ' + result);
						this.materialsGrouped = JSON.parse(result);
				})
						.catch(error =>{
						console.log('ERROR' + error.message);
				})
		}

		handledownloadall(){
				console.log('materials -- ' + this.materials);
				for(let i=0; i<this.materials.length; i++){
						console.log(this.materials[i].Title);
						window.open(this.materials[i].DownloadURL, '_blank');
				}			
		}

		toggleMaterial(event){
				var groupName = event.target.title;
				this.template.querySelector('div[name="'+groupName+'"]').classList.toggle('slds-hide');
				if(event.target.iconName === "utility:chevrondown"){
						event.target.iconName="utility:chevronup";
				}else{
						event.target.iconName="utility:chevrondown";
				}
		}
}