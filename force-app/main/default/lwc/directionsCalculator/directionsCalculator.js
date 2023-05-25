import { LightningElement, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GOOGLE_MAPS_API from '@salesforce/resourceUrl/googleMapsApi';

export default class DirectionsCalculator extends LightningElement {
  @track originAddress;
  @track destinationAddress;
  @track directionsResult;

  connectedCallback() {
    Promise.all([
      loadScript(this, GOOGLE_MAPS_API + '/js?key=AIzaSyANYZVpfrfkLU3t1E3udZiwz5ToPUFACnY'),
      loadStyle(this, GOOGLE_MAPS_API + '/css')
    ])
      .then(() => {
        // Google Maps API loaded successfully
      })
      .catch(error => {
        console.error('Error loading Google Maps API', error);
        this.showToast('Error', 'Failed to load Google Maps API', 'error');
      });
  }

  initializeAutocomplete() {
    const originInput = this.template.querySelector('lightning-input[label="Origin Address"]');
    const destinationInput = this.template.querySelector('lightning-input[label="Destination Address"]');

    const originAutocomplete = new google.maps.places.Autocomplete(originInput);
    const destinationAutocomplete = new google.maps.places.Autocomplete(destinationInput);

    originAutocomplete.addListener('place_changed', () => {
      this.originAddress = originAutocomplete.getPlace().formatted_address;
    });

    destinationAutocomplete.addListener('place_changed', () => {
      this.destinationAddress = destinationAutocomplete.getPlace().formatted_address;
    });
  }

  handleOriginChange(event) {
    this.originAddress = event.target.value;
  }

  handleDestinationChange(event) {
    this.destinationAddress = event.target.value;
  }

  getDirections() {
    // Pass address information to the Apex class using JavaScript remoting
    // Replace `apexMethodName` with the actual Apex method name
    // Replace `apexClassName` with the actual Apex class name
    apexMethodName({ originAddress: this.originAddress, destinationAddress: this.destinationAddress })
      .then(result => {
        this.directionsResult = result;
      })
      .catch(error => {
        console.error(error);
        this.showToast('Error', 'Failed to get directions', 'error');
      });
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}
