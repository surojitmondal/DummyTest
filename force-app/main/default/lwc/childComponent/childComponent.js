import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
// import { CurrentPageReference } from 'lightning/navigation';
const EXCEPTION_MESSAGE = 'An unexpected error has occurred. Please contact your normal support channel for assistance.';
export default class childComponent extends LightningElement {
    // @track recordId;
    // @wire(CurrentPageReference)
    // setCurrentPageReference(currentPageReference) {
    //     this.currentPageReference = currentPageReference;
    // }
    // connectedCallback() {
    //     this.recordId = this.currentPageReference.state.c__recordId;
    //     console.log("URL Parameters => ", this.currentPageReference.state);
    // }
    @api recordId;
    accountId;
    stateCode;
    displayErrorMsg;
    requested;
    @track requestedEndDate;
    @track todaysDate = this.formatDate(new Date());
    @wire(getRecord, {
        recordId: '$recordId',
        fields: ['Opportunity.AccountId', 'Opportunity.Account.BillingState']
    })
    wiredRecord(result) {
        this.wiredopportunityResult = result;
        if (result.error) {
            this.displayErrorMsg = EXCEPTION_MESSAGE;
        }
        if (result.data) {
            this.displayErrorMsg = '';
            this.opportunityData = result.data;
            this.accountId = this.opportunityData.fields.AccountId.value;
            this.stateCode = this.opportunityData.fields.Account.value.fields.BillingState.value;
        }
    }
    formatDate(dateToFormat) {
        let dd = dateToFormat.getDate();
        let mm = dateToFormat.getMonth() + 1;
        const yyyy = dateToFormat.getFullYear();
        if (dd < 10) {
            dd = `0${dd}`;
        }
        if (mm < 10) {
            mm = `0${mm}`;
        }
        return `${yyyy}-${mm}-${dd}`;
    }

    handleSubmit() {
        var dateFieldValue = this.template.querySelector("[data-id='reuestedStartDate']")
        let requestedEndDate = null;
        if (this.stateCode !== 'CA' && this.stateCode !== 'CO' && this.stateCode !== 'IL') {
            requestedEndDate = dateFieldValue.addDays(30);
        }
        else {
            requestedEndDate = dateFieldValue.addDays(90);
        }
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleCancel() {
        //close the modal
        this.dispatchEvent(buildCancelEvent());
    }

    showToastEvent(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}