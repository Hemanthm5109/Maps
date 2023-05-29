import { LightningElement, track} from 'lwc';
import getDirections from '@salesforce/apex/AddressInformation.getDirections';

export default class MyMapLWC extends  
LightningElement{
    @track from = '';
    @track to ='';
    @track result;

    handleFromChange(event) {
        this.from=event.target.value;
    }
    handleToChance(event){
        this.to=event.target.value;
    }
    getDirections(){

        getDirections({ from: this.from, 
            to: this.to })
            .then(result => {
                this.result = result;
            })
            .catch(error => {
                // Handle error
                console.error(error);
            });
    }
}


