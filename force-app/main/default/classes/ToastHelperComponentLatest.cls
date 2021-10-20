public class ToastHelperComponentLatest{
/*
//Helper HTML
<template>
    <div class="slds-modal__content slds-p-around_medium">
        <lightning-spinner if:true={loading} size="medium" variant="brand" alternative-text="Loading" style = "top:50%;bottom:50%"></lightning-spinner>  
          <h3><b>Would you like to request Written Consent for this Account?</b></h3>
          <lightning-input type="date"
              date-style="short"
              name="inputDate"
              value={todaysDate} 
              data-id="requestedStartDate"
              label="Requested Start Date:"
              placeholder="MM/DD/YYYY"
              min={todaysDate}
              max={maxDate}
              message-when-value-missing="Requested Start Date cannot be blank"
              required >
          </lightning-input>
    </div>
    <footer class="slds-modal__footer">
            <lightning-button-group>
                    <lightning-button variant="brand" 
                    data-id="submitButton" 
                    disabled={isSubmitActionDisabled}
                    label="Submit" 
                    onclick={handleSubmit} >
                </lightning-button>
                <lightning-button 
                    data-id="swcCancel" 
                    label="Cancel" 
                    onclick={handleCancel}>
                </lightning-button>
            </lightning-button-group>
    </footer>
</template>

//JS
import { LightningElement, api, track } from "lwc";
import "c/checkBrowser";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord } from "lightning/uiRecordApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { formatDate } from 'c/journeyDateValidation';
import calculateRequestedEndDate from './signedWrittenConsentEndDateCalculation';
import SIGNEDWRITTENCONSENT_OBJECT from '@salesforce/schema/SignedWrittenConsent__c';
import ACCOUNT_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Account__c';
import INITIATEDFROM_FIELD from '@salesforce/schema/SignedWrittenConsent__c.InitiatedFromId__c';
import REQUESTSTARTDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestStartDate__c';
import REQUESTENDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestEndDate__c';
import REQUESTEXPIRATIONDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestExpireDate__c';
import REQUESTEDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestedDate__c';
import STATUS_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Status__c';
import SWCSTATUS_FIELD from '@salesforce/schema/Account.SignedWrittenConsentStatus__c';
import SWCREQUESTEDDATE_FIELD from '@salesforce/schema/Account.SignedWrittenConsentRequestedDate__c';
import EDITINVFP_FIELD from '@salesforce/schema/Account.Edit_In_VFP__c';
import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
const REQUEST_SUCCESS = "Requested Consent Successfully";
const EXCEPTION_MESSAGE =
    "An unexpected error has occurred. Please contact your normal support channel for assistance.";

export default class SignedWrittenConsent extends LightningElement {
    @api billingState;
    @api recordId;
    @api accountId;
    @track isSubmitActionDisabled = false;
    @track loading;
    @track todaysDate = formatDate(new Date());
    @track maxDate = formatDate(
        new Date(new Date().setMonth(new Date().getMonth() + 13))
    );

    handleSubmit() {
        const allValid = [
            ...this.template.querySelectorAll("[data-id='requestedStartDate']")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.processSubmit();
        }
    }

    processSubmit() {
        this.isSubmitActionDisabled = true;
        this.loading = true;
        const dateFieldValue = this.template.querySelector(
            "[data-id='requestedStartDate']"
        ).value;
        const requestedStartDate = new Date(dateFieldValue);
        const requestedEndDate = calculateRequestedEndDate(
            new Date(dateFieldValue),
            this.billingState
        );
        this.updateAccount();
        this.createSignedWrittenConsent(requestedStartDate, requestedEndDate);

    }

    createSignedWrittenConsent(requestedStartDate, requestedEndDate) {
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
        fields[INITIATEDFROM_FIELD.fieldApiName] = this.recordId;
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = requestedStartDate;
        fields[REQUESTENDDATE_FIELD.fieldApiName] = requestedEndDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = requestedEndDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        fields[REQUESTEDDATE_FIELD.fieldApiName] = this.todaysDate;
        const recordInput = { apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(() => {
                this.loading = false;
                this.showToastEvent("", REQUEST_SUCCESS, "success");
                this.handleCancel();
            })
            .catch(() => {
                this.showToastEvent("", 'Create Record: ' + EXCEPTION_MESSAGE, "error");
                this.handleCancel();
            });
    }

    updateAccount() {
        const fields = {};
        fields[ACCOUNTID_FIELD.fieldApiName] = this.accountId;
        fields[SWCSTATUS_FIELD.fieldApiName] = "Requested";
        fields[SWCREQUESTEDDATE_FIELD.fieldApiName] = this.todaysDate;
        fields[EDITINVFP_FIELD.fieldApiName] = true;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(new CustomEvent("refreshtab", { bubbles: true, composed: true }));
            })
            .catch(() => {
                this.showToastEvent("", 'Update Record: ' + EXCEPTION_MESSAGE, "error");
            });
    }

    handleCancel() {
        //close the modal
        this.dispatchEvent(new CustomEvent("cancel", { bubbles: true, composed: true }));
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

//signedWrittenConsentEndDateCalculation.JS
const CONSENT_STATE_LIST = ['IL','CA','CO'];
export default function calculateRequestedEndDate(requestedEndDate, billingState) {
    if (CONSENT_STATE_LIST.includes(billingState)) {
      requestedEndDate = new Date(
        requestedEndDate.setDate(requestedEndDate.getDate() + 29)
      );
    } else {
      requestedEndDate = new Date(
        requestedEndDate.setDate(requestedEndDate.getDate() + 89)
      );
    }
    return requestedEndDate;
  }
  
//JourneyDateValidation.Js
export function calculateJourneyStartDate(dateToCalculate){
    var dayOfWeek = dateToCalculate.getDay();
    var dateOfMonth = dateToCalculate.getDate();
    var hour = dateToCalculate.getHours();
    var thisWeek = 7;
    var nextWeek = 14;
    var thisWeekend = 6;
    var dayNoon = 12;
    var returnValue;
    var addDays;
    if((dayOfWeek < thisWeekend) || (dayOfWeek === thisWeekend && hour <= dayNoon)){
        addDays = thisWeek - dayOfWeek;
        returnValue = new Date(dateToCalculate.setDate(dateOfMonth + addDays));
    }else{
        addDays = nextWeek - dayOfWeek;
        returnValue = new Date(dateToCalculate.setDate(dateOfMonth + addDays));    
    }
    return new Date(returnValue.toDateString());
}

export function formatDate(dateToFormat){
    let dd = dateToFormat.getDate();
    let mm = dateToFormat.getMonth() + 1; 
    const yyyy = dateToFormat.getFullYear();
    if(dd<10){
        dd=`0${dd}`;
    } 
    if(mm<10){
        mm=`0${mm}`;
    }
    return `${yyyy}-${mm}-${dd}`;
}

export function addYears(currentDate, nYear){
    var dateObject = new Date(currentDate);
    var day = dateObject.getDate();
    dateObject.setHours(20); // avoid date calculation errors
    dateObject.setMonth(dateObject.getMonth() + 1, 0);
    // set day number to min of either the original one or last day of month
    dateObject.setDate(Math.min(day, dateObject.getDate())); 
    dateObject.setFullYear(dateObject.getFullYear() + nYear);
    return dateObject.toISOString().split('T')[0];
}

// function to format date in MM/DD/YYYY
export function formattedDateMMDDYYYY(dateToFormat){
    let dd = dateToFormat.getDate() + 1;
    let mm = dateToFormat.getMonth() + 1; 
    const yyyy = dateToFormat.getFullYear();
    if(dd<10){
        dd=`0${dd}`;
    } 
    if(mm<10){
        mm=`0${mm}`;
    }
    return `${mm}/${dd}/${yyyy}`;
}
 ////JourneyDateValidation.Js Ends here
  
//Jest
import { createElement } from 'lwc';
import signedWrittenConsent from 'c/signedWrittenConsent';
import { formatDate } from 'c/journeyDateValidation';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import SIGNEDWRITTENCONSENT_OBJECT from '@salesforce/schema/SignedWrittenConsent__c';
import ACCOUNT_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Account__c';
import INITIATEDFROM_FIELD from '@salesforce/schema/SignedWrittenConsent__c.InitiatedFromId__c';
import REQUESTSTARTDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestStartDate__c';
import REQUESTENDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestEndDate__c';
import REQUESTEXPIRATIONDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestExpireDate__c';
import REQUESTEDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestedDate__c';
import STATUS_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Status__c';
import SWCSTATUS_FIELD from '@salesforce/schema/Account.SignedWrittenConsentStatus__c';
import SWCREQUESTEDDATE_FIELD from '@salesforce/schema/Account.SignedWrittenConsentRequestedDate__c';
import EDITINVFP_FIELD from '@salesforce/schema/Account.Edit_In_VFP__c';
import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
import { updateRecord } from 'lightning/uiRecordApi';

jest.mock(
    'lightning/uiRecordApi.updateRecord',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-signed-written-consent', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty. This is needed for promise timing when calling imperative Apex.
    function flushPromises() {
        //eslint-disable-next-line no-undef
        return new Promise(resolve => setImmediate(resolve));
    }

    it('test component is loaded', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'IL';
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            const requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
            expect(requestedStartDate.min).toEqual(formatDate(new Date()));
            expect(requestedStartDate.max).toEqual(formatDate(
                new Date(new Date().setMonth(new Date().getMonth() + 13))
            ));
            const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
            expect(submitButton.disabled).toEqual(false);
        });
    });

    it('test record not saved when date field is empty', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        document.body.appendChild(element);
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));
        return Promise.resolve().then(() => {
            expect(createRecord).not.toHaveBeenCalled();
        });
    });

    it('test record not saved when date field is invalid', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        document.body.appendChild(element);
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = formatDate(
            new Date(new Date().setMonth(new Date().getDay() - 2))
        );
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));
        return Promise.resolve().then(() => {
            expect(createRecord).not.toHaveBeenCalled();
        });
    });

    it('test success scenario for Illinois state on submit click', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'IL';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };
        const SHOW_TOAST_PARAMETERS = {
            title: '',
            message: 'Requested Consent Successfully',
            variant: 'success'
        };
        const showToastHander = jest.fn();
        const spinner = element.shadowRoot.querySelector("spinner");
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        createRecord.mockResolvedValue();
        const fields = {};
        fields[ACCOUNTID_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[SWCREQUESTEDDATE_FIELD.fieldApiName] = formatDate(new Date());
        fields[EDITINVFP_FIELD.fieldApiName] = true;
        fields[SWCSTATUS_FIELD.fieldApiName] = "Requested";
        const UPDATE_REC_PARAMS = {
            fields
        };

        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));
        const refreshTabEvt = jest.fn();
        element.addEventListener('refreshtab', refreshTabEvt);
        return flushPromises().then(() => {
            expect(spinner).toBeNull();
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(submitButton.disabled).toBeTruthy();
            expect(updateRecord).toHaveBeenCalledTimes(1);
            expect(updateRecord).toHaveBeenCalledWith(UPDATE_REC_PARAMS);
            expect(refreshTabEvt).toHaveBeenCalled();
            expect(refreshTabEvt.mock.calls[0][0].bubbles).toBeTruthy();
            expect(refreshTabEvt.mock.calls[0][0].composed).toBeTruthy();
        });
    });

    it('test success scenario for California state on submit click', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'CA';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };

        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 29));
        const SHOW_TOAST_PARAMETERS = {
            title: '',
            message: 'Requested Consent Successfully',
            variant: 'success'
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        createRecord.mockResolvedValue();
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[INITIATEDFROM_FIELD.fieldApiName] = '0062F00000AIHMfQAP';
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = startDate;
        fields[REQUESTEDDATE_FIELD.fieldApiName] = formatDate(new Date());
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        const CREATE_REC_PARAMS = {
            apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName,
            fields
        };
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));

        return flushPromises().then(() => {
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            expect(createRecord).toHaveBeenCalledWith(CREATE_REC_PARAMS);
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(submitButton.disabled).toBeTruthy();
        });
    });

    it('test success scenario for Colarado state on submit click', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'CO';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };

        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 29));
        const SHOW_TOAST_PARAMETERS = {
            title: '',
            message: 'Requested Consent Successfully',
            variant: 'success'
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        createRecord.mockResolvedValue();
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[INITIATEDFROM_FIELD.fieldApiName] = '0062F00000AIHMfQAP';
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = startDate;
        fields[REQUESTEDDATE_FIELD.fieldApiName] = formatDate(new Date());
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        const CREATE_REC_PARAMS = {
            apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName,
            fields
        };
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));

        return flushPromises().then(() => {
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            expect(createRecord).toHaveBeenCalledWith(CREATE_REC_PARAMS);
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(submitButton.disabled).toBeTruthy();
        });
    });

    it('test success scenario for New York state on submit click', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'NY';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };

        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 89));
        const SHOW_TOAST_PARAMETERS = {
            title: '',
            message: 'Requested Consent Successfully',
            variant: 'success'
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        createRecord.mockResolvedValue();
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[INITIATEDFROM_FIELD.fieldApiName] = '0062F00000AIHMfQAP';
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = startDate;
        fields[REQUESTEDDATE_FIELD.fieldApiName] = formatDate(new Date());
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        const CREATE_REC_PARAMS = {
            apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName,
            fields
        };
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));

        return flushPromises().then(() => {
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            expect(createRecord).toHaveBeenCalledWith(CREATE_REC_PARAMS);
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(submitButton.disabled).toBeTruthy();
        });
    });

    it('verify cancel event', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        document.body.appendChild(element);
        const cancelButton = element.shadowRoot.querySelector("[data-id='swcCancel']");
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        cancelButton.dispatchEvent(new CustomEvent('click'));
        return Promise.resolve().then(() => {
            expect(handleCancel).toHaveBeenCalledTimes(1);
            const selectEvent = handleCancel.mock.calls[0][0];
            expect(selectEvent.bubbles).toBeTruthy();
            expect(selectEvent.composed).toBeTruthy();
        });
    });

    it("test exception scenario on submit click", () => {
        const element = createElement("c-signed-written-consent", { is: signedWrittenConsent }); //Create an element
        document.body.appendChild(element);
        const startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        const requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };
        const SHOW_TOAST_PARAMETERS = {
            title: "",
            message: "Create Record: An unexpected error has occurred. Please contact your normal support channel for assistance.",
            variant: "error"
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener("cancel", handleCancel);
        createRecord.mockRejectedValue();
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent("click"));
        return flushPromises().then(() => {
            expect(createRecord).toHaveBeenCalled();
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
        });
    });

    it("test exception scenario on update", () => {
        const element = createElement("c-signed-written-consent", { is: signedWrittenConsent }); //Create an element
        document.body.appendChild(element);
        const startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        const requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };
        const SHOW_TOAST_PARAMETERS = {
            title: "",
            message: "Update Record: An unexpected error has occurred. Please contact your normal support channel for assistance.",
            variant: "error"
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        updateRecord.mockRejectedValue();
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent("click"));
        return Promise.resolve().then(() => {
            return Promise.resolve().then(() => {
                expect(updateRecord).toHaveBeenCalled();
                expect(showToastHander).toHaveBeenCalled();
                expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            });
        });
    });
});

//LATEST
//HTML
<template>
    <div class="slds-modal__content slds-p-around_medium">
        <lightning-spinner if:true={loading} size="medium" variant="brand" alternative-text="Loading" style = "top:50%;bottom:50%"></lightning-spinner>  
          <h3><b>Would you like to request Written Consent for this Account?</b></h3>
          <lightning-input type="date"
              date-style="short"
              name="inputDate"
              value={minDate} 
              data-id="requestedStartDate"
              label="Requested Start Date:"
              placeholder="MM/DD/YYYY"
              min={minDate}
              message-when-range-underflow = {minValueMessage}
              max={maxDate}
              message-when-range-overflow = {maxValueMessage}
              message-when-value-missing="Requested Start Date cannot be blank"        
              required >
          </lightning-input>
    </div>
    <footer class="slds-modal__footer">
            <lightning-button-group>
                <lightning-button variant="brand" 
                    data-id="submitButton" 
                    disabled={isSubmitActionDisabled}
                    label="Submit" 
                    onclick={handleSubmit} >
                </lightning-button>
                <lightning-button 
                    data-id="swcCancel" 
                    label="Cancel" 
                    onclick={handleCancel}>
                </lightning-button>
            </lightning-button-group>
    </footer>
</template>

//JS FILE
import { LightningElement, api, track } from "lwc";
import "c/checkBrowser";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord } from "lightning/uiRecordApi";
import { updateRecord } from 'lightning/uiRecordApi';
import { formatDate, formattedDateMMDDYYYY } from 'c/journeyDateValidation';
import calculateRequestedEndDate from './signedWrittenConsentEndDateCalculation';
import SIGNEDWRITTENCONSENT_OBJECT from '@salesforce/schema/SignedWrittenConsent__c';
import ACCOUNT_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Account__c';
import INITIATEDFROM_FIELD from '@salesforce/schema/SignedWrittenConsent__c.InitiatedFromId__c';
import REQUESTSTARTDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestStartDate__c';
import REQUESTENDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestEndDate__c';
import REQUESTEXPIRATIONDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestExpireDate__c';
import REQUESTEDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestedDate__c';
import STATUS_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Status__c';
import SWCSTATUS_FIELD from '@salesforce/schema/Account.SignedWrittenConsentStatus__c';
import SWCREQUESTEDDATE_FIELD from '@salesforce/schema/Account.SignedWrittenConsentRequestedDate__c';
import EDITINVFP_FIELD from '@salesforce/schema/Account.Edit_In_VFP__c';
import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
const REQUEST_SUCCESS = "Requested Consent Successfully";
const EXCEPTION_MESSAGE =
    "An unexpected error has occurred. Please contact your normal support channel for assistance.";

export default class SignedWrittenConsent extends LightningElement {
    @api billingState;
    @api recordId;
    @api accountId;
    @api minDate;
    @api isSubmitActionDisabled;
    //@track minValueMessage;
    //@track maxValueMessage;
    loading;
    todaysDate = formatDate(new Date());
    @track maxDate = formatDate(
        new Date(new Date().setMonth(new Date().getMonth() + 13))
    );

    renderedCallback() {  
        if(!this.minValueMessage) {
            this.minValueMessage = "Value must be "+formattedDateMMDDYYYY(new Date(this.minDate))+" or later";
        }
        if(!this.maxValueMessage) {
            this.maxValueMessage = "Value must be "+formattedDateMMDDYYYY(new Date(this.maxDate))+" or later";
        }
    }

    get maxValueMessage() {
        return "Value must be "+formattedDateMMDDYYYY(new Date(this.maxDate))+" or later";
    }

    get minValueMessage() {
        return "Value must be "+formattedDateMMDDYYYY(new Date(this.minDate))+" or later";
    }

    handleSubmit() {
        const allValid = [
            ...this.template.querySelectorAll("[data-id='requestedStartDate']")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.processSubmit();
        }
    }

    processSubmit() {
        this.isSubmitActionDisabled = true;
        this.loading = true;
        const dateFieldValue = this.template.querySelector(
            "[data-id='requestedStartDate']"
        ).value;
        const requestedStartDate = new Date(dateFieldValue);
        const requestedEndDate = calculateRequestedEndDate(
            new Date(dateFieldValue),
            this.billingState
        );
        this.updateAccount();
        this.createSignedWrittenConsent(requestedStartDate, requestedEndDate);

    }

    createSignedWrittenConsent(requestedStartDate, requestedEndDate) {
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
        fields[INITIATEDFROM_FIELD.fieldApiName] = this.recordId;
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = requestedStartDate;
        fields[REQUESTENDDATE_FIELD.fieldApiName] = requestedEndDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = requestedEndDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        fields[REQUESTEDDATE_FIELD.fieldApiName] = this.todaysDate;
        const recordInput = { apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(() => {
                this.loading = false;
                this.showToastEvent("", REQUEST_SUCCESS, "success");
                this.handleCancel();
            })
            .catch(() => {
                this.showToastEvent("", 'Create: ' + EXCEPTION_MESSAGE, "error");
                this.handleCancel();
            });
    }

    updateAccount() {
        const fields = {};
        fields[ACCOUNTID_FIELD.fieldApiName] = this.accountId;
        fields[SWCSTATUS_FIELD.fieldApiName] = "Requested";
        fields[SWCREQUESTEDDATE_FIELD.fieldApiName] = this.todaysDate;
        fields[EDITINVFP_FIELD.fieldApiName] = true;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(new CustomEvent("refreshtab", { bubbles: true, composed: true }));
            })
            .catch(() => {
                this.showToastEvent("", 'Update: ' + EXCEPTION_MESSAGE, "error");
            });
    }

    handleCancel() {
        //close the modal
        this.dispatchEvent(new CustomEvent("cancel", { bubbles: true, composed: true }));
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

//JEST
import { createElement } from 'lwc';
import signedWrittenConsent from 'c/signedWrittenConsent';
import { formatDate , formattedDateMMDDYYYY} from 'c/journeyDateValidation';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import SIGNEDWRITTENCONSENT_OBJECT from '@salesforce/schema/SignedWrittenConsent__c';
import ACCOUNT_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Account__c';
import INITIATEDFROM_FIELD from '@salesforce/schema/SignedWrittenConsent__c.InitiatedFromId__c';
import REQUESTSTARTDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestStartDate__c';
import REQUESTENDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestEndDate__c';
import REQUESTEXPIRATIONDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestExpireDate__c';
import REQUESTEDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestedDate__c';
import STATUS_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Status__c';
import SWCSTATUS_FIELD from '@salesforce/schema/Account.SignedWrittenConsentStatus__c';
import SWCREQUESTEDDATE_FIELD from '@salesforce/schema/Account.SignedWrittenConsentRequestedDate__c';
import EDITINVFP_FIELD from '@salesforce/schema/Account.Edit_In_VFP__c';
import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
import { updateRecord } from 'lightning/uiRecordApi';

jest.mock(
    'lightning/uiRecordApi.updateRecord',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-signed-written-consent', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty. This is needed for promise timing when calling imperative Apex.
    function flushPromises() {
        //eslint-disable-next-line no-undef
        return new Promise(resolve => setImmediate(resolve));
    }

    it('test component is loaded', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'IL';
        element.minDate = formatDate(new Date());
        element.isSubmitActionDisabled = false;
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            const requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
            expect(requestedStartDate.min).toEqual(formatDate(new Date()));
            expect(requestedStartDate.max).toEqual(formatDate(
                new Date(new Date().setMonth(new Date().getMonth() + 13))
            ));
            const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
            expect(submitButton.disabled).toEqual(false);
        });
    });

    it('test record not saved when date field is empty', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        document.body.appendChild(element);
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));
        return Promise.resolve().then(() => {
            expect(createRecord).not.toHaveBeenCalled();
        });
    });

    it('test record not saved when date field is invalid', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.minDate = formatDate(new Date());        
        document.body.appendChild(element);
        
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = formatDate(
            new Date(new Date().setMonth(new Date().getDay() - 2))
        );
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));
        const todaysDate = formatDate(new Date());
        return Promise.resolve().then(() => {
            expect(requestedStartDate.messageWhenRangeUnderflow).toStrictEqual('Value must be '+formattedDateMMDDYYYY(new Date(todaysDate))+' or later');
            expect(createRecord).not.toHaveBeenCalled();
        });
    });

    it('test update success scenario for Illinois state on submit click', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'IL';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };
        const SHOW_TOAST_PARAMETERS = {
            title: '',
            message: 'Requested Consent Successfully',
            variant: 'success'
        };
        const showToastHander = jest.fn();
        const spinner = element.shadowRoot.querySelector("spinner");
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        createRecord.mockResolvedValue();
        const fields = {};
        fields[ACCOUNTID_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[SWCREQUESTEDDATE_FIELD.fieldApiName] = formatDate(new Date());
        fields[EDITINVFP_FIELD.fieldApiName] = true;
        fields[SWCSTATUS_FIELD.fieldApiName] = "Requested";
        const UPDATE_REC_PARAMS = {
            fields
        };

        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));
        const refreshTabEvt = jest.fn();
        element.addEventListener('refreshtab', refreshTabEvt);
        return flushPromises().then(() => {
            expect(spinner).toBeNull();
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(submitButton.disabled).toBeTruthy();
            expect(updateRecord).toHaveBeenCalledTimes(1);
            expect(updateRecord).toHaveBeenCalledWith(UPDATE_REC_PARAMS);
            expect(refreshTabEvt).toHaveBeenCalled();
            expect(refreshTabEvt.mock.calls[0][0].bubbles).toBeTruthy();
            expect(refreshTabEvt.mock.calls[0][0].composed).toBeTruthy();
        });
    });

    it('test create success scenario for Illinois state on submit click', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'IL';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };
        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 29));
        const SHOW_TOAST_PARAMETERS = {
            title: '',
            message: 'Requested Consent Successfully',
            variant: 'success'
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        createRecord.mockResolvedValue();
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[INITIATEDFROM_FIELD.fieldApiName] = '0062F00000AIHMfQAP';
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = startDate;
        fields[REQUESTEDDATE_FIELD.fieldApiName] = formatDate(new Date());
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        const CREATE_REC_PARAMS = {
            apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName,
            fields
        };
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));

        return flushPromises().then(() => {
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            expect(createRecord).toHaveBeenCalledWith(CREATE_REC_PARAMS);
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(submitButton.disabled).toBeTruthy();
        });
    });

    it('test success scenario for California state on submit click', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'CA';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };

        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 29));
        const SHOW_TOAST_PARAMETERS = {
            title: '',
            message: 'Requested Consent Successfully',
            variant: 'success'
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        createRecord.mockResolvedValue();
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[INITIATEDFROM_FIELD.fieldApiName] = '0062F00000AIHMfQAP';
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = startDate;
        fields[REQUESTEDDATE_FIELD.fieldApiName] = formatDate(new Date());
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        const CREATE_REC_PARAMS = {
            apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName,
            fields
        };
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));

        return flushPromises().then(() => {
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            expect(createRecord).toHaveBeenCalledWith(CREATE_REC_PARAMS);
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(submitButton.disabled).toBeTruthy();
        });
    });

    it('test success scenario for Colorado state on submit click', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'CO';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };

        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 29));
        const SHOW_TOAST_PARAMETERS = {
            title: '',
            message: 'Requested Consent Successfully',
            variant: 'success'
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        createRecord.mockResolvedValue();
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[INITIATEDFROM_FIELD.fieldApiName] = '0062F00000AIHMfQAP';
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = startDate;
        fields[REQUESTEDDATE_FIELD.fieldApiName] = formatDate(new Date());
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        const CREATE_REC_PARAMS = {
            apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName,
            fields
        };
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));

        return flushPromises().then(() => {
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            expect(createRecord).toHaveBeenCalledWith(CREATE_REC_PARAMS);
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(submitButton.disabled).toBeTruthy();
        });
    });

    it('test success scenario for New York state on submit click', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.billingState = 'NY';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };

        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 89));
        const SHOW_TOAST_PARAMETERS = {
            title: '',
            message: 'Requested Consent Successfully',
            variant: 'success'
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        createRecord.mockResolvedValue();
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[INITIATEDFROM_FIELD.fieldApiName] = '0062F00000AIHMfQAP';
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = startDate;
        fields[REQUESTEDDATE_FIELD.fieldApiName] = formatDate(new Date());
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        const CREATE_REC_PARAMS = {
            apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName,
            fields
        };
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));

        return flushPromises().then(() => {
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            expect(createRecord).toHaveBeenCalledWith(CREATE_REC_PARAMS);
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(submitButton.disabled).toBeTruthy();
        });
    });

    it('verify cancel event', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        document.body.appendChild(element);
        const cancelButton = element.shadowRoot.querySelector("[data-id='swcCancel']");
        const handleCancel = jest.fn();
        element.addEventListener('cancel', handleCancel);
        cancelButton.dispatchEvent(new CustomEvent('click'));
        return Promise.resolve().then(() => {
            expect(handleCancel).toHaveBeenCalledTimes(1);
            const selectEvent = handleCancel.mock.calls[0][0];
            expect(selectEvent.bubbles).toBeTruthy();
            expect(selectEvent.composed).toBeTruthy();
        });
    });

    it("test exception scenario on submit click", () => {
        const element = createElement("c-signed-written-consent", { is: signedWrittenConsent }); //Create an element
        document.body.appendChild(element);
        const startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        const requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };
        const SHOW_TOAST_PARAMETERS = {
            title: "",
            message: "Create: An unexpected error has occurred. Please contact your normal support channel for assistance.",
            variant: "error"
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        const handleCancel = jest.fn();
        element.addEventListener("cancel", handleCancel);
        createRecord.mockRejectedValue();
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent("click"));
        return flushPromises().then(() => {
            expect(createRecord).toHaveBeenCalled();
            expect(handleCancel).toHaveBeenCalledTimes(1);
            expect(showToastHander).toHaveBeenCalled();
            expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
        });
    });

    it("test exception scenario on update", () => {
        const element = createElement("c-signed-written-consent", { is: signedWrittenConsent }); //Create an element
        document.body.appendChild(element);
        const startDate = new Date(new Date().setDate(new Date().getDay() + 1));
        const requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function () {
            return true;
        };
        const SHOW_TOAST_PARAMETERS = {
            title: "",
            message: "Update: An unexpected error has occurred. Please contact your normal support channel for assistance.",
            variant: "error"
        };
        const showToastHander = jest.fn();
        element.addEventListener(ShowToastEventName, showToastHander);
        updateRecord.mockRejectedValue();
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent("click"));
        return Promise.resolve().then(() => {
            return Promise.resolve().then(() => {
                expect(updateRecord).toHaveBeenCalled();
                expect(showToastHander).toHaveBeenCalled();
                expect(showToastHander.mock.calls[0][0].detail).toEqual(SHOW_TOAST_PARAMETERS);
            });
        });
    });
}); 
*/
/*
//Updated JS
import { LightningElement, api, track } from "lwc";
import "c/checkBrowser";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord } from "lightning/uiRecordApi";
//import { updateRecord } from 'lightning/uiRecordApi';
import { formatDate, formattedDateMMDDYYYY } from 'c/journeyDateValidation';
import updateOpportunitySwc from '@salesforce/apex/LWC_SignedWrittenConsent.updateOpportunitySwc';
import calculateRequestedEndDate from './signedWrittenConsentEndDateCalculation';
import SIGNEDWRITTENCONSENT_OBJECT from '@salesforce/schema/SignedWrittenConsent__c';
import ACCOUNT_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Account__c';
import INITIATEDFROM_FIELD from '@salesforce/schema/SignedWrittenConsent__c.InitiatedFromId__c';
import REQUESTSTARTDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestStartDate__c';
import REQUESTENDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestEndDate__c';
import REQUESTEXPIRATIONDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestExpireDate__c';
import REQUESTEDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestedDate__c';
import STATUS_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Status__c';
//import SWCSTATUS_FIELD from '@salesforce/schema/Account.SignedWrittenConsentStatus__c';
//import SWCREQUESTEDDATE_FIELD from '@salesforce/schema/Account.SignedWrittenConsentRequestedDate__c';
//import EDITINVFP_FIELD from '@salesforce/schema/Account.Edit_In_VFP__c';
//import ACCOUNTID_FIELD from '@salesforce/schema/Account.Id';
const REQUEST_SUCCESS = "Requested Consent Successfully";
const EXCEPTION_MESSAGE =
    "An unexpected error has occurred. Please contact your normal support channel for assistance.";

export default class SignedWrittenConsent extends LightningElement {
    @api billingState;
    @api recordId;
    @api accountId;
    @api minDate;
    @api isSubmitActionDisabled;
    @api oppOwnerId;
    loading;
    todaysDate = formatDate(new Date());
    @track maxDate = formatDate(
        new Date(new Date().setMonth(new Date().getMonth() + 13))
    );

    get maxValueMessage() {
        return "Value must be "+formattedDateMMDDYYYY(new Date(this.maxDate))+" or earlier";
      }
  
    get minValueMessage() {
        return "Value must be "+formattedDateMMDDYYYY(new Date(this.minDate))+" or later";
      }

    handleSubmit() {
        const allValid = [
            ...this.template.querySelectorAll("[data-id='requestedStartDate']")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.processSubmit();
        }
    }

    processSubmit() {
        this.isSubmitActionDisabled = true;
        this.loading = true;
        const dateFieldValue = this.template.querySelector(
            "[data-id='requestedStartDate']"
        ).value;
        const requestedStartDate = new Date(dateFieldValue);
        const requestedEndDate = calculateRequestedEndDate(
            new Date(dateFieldValue),
            this.billingState
        );
        //this.updateAccount();
        this.updateOpportunities();
        this.createSignedWrittenConsent(requestedStartDate, requestedEndDate);

    }

    createSignedWrittenConsent(requestedStartDate, requestedEndDate) {
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
        fields[INITIATEDFROM_FIELD.fieldApiName] = this.recordId;
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = requestedStartDate;
        fields[REQUESTENDDATE_FIELD.fieldApiName] = requestedEndDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = requestedEndDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        fields[REQUESTEDDATE_FIELD.fieldApiName] = this.todaysDate;
        const recordInput = { apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(() => {
                this.loading = false;
                this.showToastEvent("", REQUEST_SUCCESS, "success");
                this.handleCancel();
            })
            .catch(() => {
                this.showToastEvent("", 'Create: ' + EXCEPTION_MESSAGE, "error");
                this.handleCancel();
            });
    }

    updateOpportunities(){
        alert(this.accountId);
        alert(this.oppOwnerId);
        updateOpportunitySwc({ accountId: this.accountId, ownerId: this.oppOwnerId})
        .then(result => {
            if (result) {
                this.dispatchEvent(new CustomEvent("refreshtab", { bubbles: true, composed: true }));
            } else {
                this.showToastEvent("", 'Update: ' + EXCEPTION_MESSAGE, "error");
            }
        });
    }
    
    updateAccount() {
        const fields = {};
        fields[ACCOUNTID_FIELD.fieldApiName] = this.accountId;
        fields[SWCSTATUS_FIELD.fieldApiName] = "Requested";
        fields[SWCREQUESTEDDATE_FIELD.fieldApiName] = this.todaysDate;
        fields[EDITINVFP_FIELD.fieldApiName] = true;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(new CustomEvent("refreshtab", { bubbles: true, composed: true }));
            })
            .catch(() => {
                this.showToastEvent("", 'Update: ' + EXCEPTION_MESSAGE, "error");
            });
    }

    handleCancel() {
        //close the modal
        this.dispatchEvent(new CustomEvent("cancel", { bubbles: true, composed: true }));
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

//Latest
import { LightningElement, api, track } from "lwc";
import "c/checkBrowser";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord } from "lightning/uiRecordApi";
import { formatDate, formattedDateMMDDYYYY } from 'c/journeyDateValidation';
import updateOpportunitySwc from '@salesforce/apex/LWC_SignedWrittenConsent.updateOpportunitiesSwc';
import calculateRequestedEndDate from './signedWrittenConsentEndDateCalculation';
import SIGNEDWRITTENCONSENT_OBJECT from '@salesforce/schema/SignedWrittenConsent__c';
import ACCOUNT_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Account__c';
import INITIATEDFROM_FIELD from '@salesforce/schema/SignedWrittenConsent__c.InitiatedFromId__c';
import REQUESTSTARTDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestStartDate__c';
import REQUESTENDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestEndDate__c';
import REQUESTEXPIRATIONDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestExpireDate__c';
import REQUESTEDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestedDate__c';
import STATUS_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Status__c';
const REQUEST_SUCCESS = "Requested Consent Successfully";
const EXCEPTION_MESSAGE =
    "An unexpected error has occurred. Please contact your normal support channel for assistance.";

export default class SignedWrittenConsent extends LightningElement {
    @api billingState;
    @api recordId;
    @api accountId;
    @api minDate;
    @api isSubmitActionDisabled;
    @api oppOwnerId;
    loading;
    todaysDate = formatDate(new Date());
    @track maxDate = formatDate(
        new Date(new Date().setMonth(new Date().getMonth() + 13))
    );

    get maxValueMessage() {
        return "Value must be "+formattedDateMMDDYYYY(new Date(this.maxDate))+" or earlier";
      }
  
    get minValueMessage() {
        return "Value must be "+formattedDateMMDDYYYY(new Date(this.minDate))+" or later";
      }

    handleSubmit() {
        const allValid = [
            ...this.template.querySelectorAll("[data-id='requestedStartDate']")
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.processSubmit();
        }
    }

    processSubmit() {
        this.isSubmitActionDisabled = true;
        this.loading = true;
        const dateFieldValue = this.template.querySelector(
            "[data-id='requestedStartDate']"
        ).value;
        const requestedStartDate = new Date(dateFieldValue);
        const requestedEndDate = calculateRequestedEndDate(
            new Date(dateFieldValue),
            this.billingState
        );
        this.updateOpportunities();
        this.createSignedWrittenConsent(requestedStartDate, requestedEndDate);

    }

    createSignedWrittenConsent(requestedStartDate, requestedEndDate) {
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
        fields[INITIATEDFROM_FIELD.fieldApiName] = this.recordId;
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = requestedStartDate;
        fields[REQUESTENDDATE_FIELD.fieldApiName] = requestedEndDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = requestedEndDate;
        fields[STATUS_FIELD.fieldApiName] = "Requested";
        fields[REQUESTEDDATE_FIELD.fieldApiName] = this.todaysDate;
        const recordInput = { apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(() => {
                this.loading = false;
                this.showToastEvent("", REQUEST_SUCCESS, "success");
                this.handleCancel();
            })
            .catch(() => {
                this.showToastEvent("", EXCEPTION_MESSAGE, "error");
                this.handleCancel();
            });
    }

    updateOpportunities(){
        updateOpportunitySwc({ accountId: this.accountId, ownerId: this.oppOwnerId})
        .then(result => {
            if (result) {
                this.dispatchEvent(new CustomEvent("refreshtab", { bubbles: true, composed: true }));
            } else {
                this.showToastEvent("", EXCEPTION_MESSAGE, "error");
            }
        });
    }
    
    createRecord(recordInput)
            .then(() => {
                this.updateOpportunities();            
            })
            .catch(() => {
                this.showToastEvent("", EXCEPTION_MESSAGE, "error");
                this.handleCancel();
            });
    }

    //update signed written consent fields in opportunities specific to agent's office
    updateOpportunities(){
        updateOpportunitySwc({ accountId: this.accountId, ownerId: this.oppOwnerId})
        .then(result => {
            if (result) {
                this.loading = false;
                this.showToastEvent("", REQUEST_SUCCESS, "success");
                this.handleCancel();
                this.dispatchEvent(new CustomEvent("refreshtab", { bubbles: true, composed: true }));
            } else {
                this.showToastEvent("", EXCEPTION_MESSAGE, "error");
                this.handleCancel();
            }
        });
    }

    handleCancel() {
        //close the modal
        this.dispatchEvent(new CustomEvent("cancel", { bubbles: true, composed: true }));
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
//APex
@AuraEnabled
    public static Boolean updateOpportunitiesSwc(Id accountId, Id ownerId){
        try {
            List<Opportunity> updateOpprtunityList = new List<Opportunity>();
            for(Opportunity oppty : [Select id,OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c from Opportunity
                                     where AccountId =:accountId AND OwnerId = :ownerId]){
                                         
                            oppty.OppSignedWrittenConsentStatus__c = 'Requested';
                            oppty.OppSignedWrittenConsentRequestedDate__c = System.today();
                            updateOpprtunityList.add(oppty);
                }
            
            if(!updateOpprtunityList.isEmpty() && Schema.sObjectType.Opportunity.isUpdateable()){
                update updateOpprtunityList;
            }
            return true;
        }
        catch (Exception signedWrittenConsentException) {             
            LoggingService.logHandledException(signedWrittenConsentException, CLASS_NAME, UPDATESWC_METHOD_NAME, System.LoggingLevel.ERROR);
            return false;
        }        
    }
    
//new
private static void processSwcUpdatesOnOpportunityAndTask(List<Opportunity> opportunityList){
        Set<String> opportunityStageSet = new Set<String>{'Closed', 'Closed Won'};
        List<Opportunity> oppListToUpdate = new List<Opportunity> ();        
        Set<Id> swcAccountIdSet = new Set<Id>();
        Set<Id> opportunityOwnerIdSet = new Set<Id>();
        Map<String,Set<String>> accountIdToOwnerIdListMap = new Map<String,Set<String>>();

        for(Opportunity opptyRecord : opportunityList){
            swcAccountIdSet.add(opptyRecord.AccountId);
            opportunityOwnerIdSet.add(opptyRecord.OwnerId);
            if(!accountIdToOwnerIdListMap.containsKey(opptyRecord.AccountId)) {
                accountIdToOwnerIdListMap.put(opptyRecord.AccountId, new Set<String>());
            }
            accountIdToOwnerIdListMap.get(opptyRecord.AccountId).add(opptyRecord.OwnerId);
        }
        
        // Closed and Closed won should be handled only for Date Captured
        for(Opportunity oppRecordToUpdate : [Select id from Opportunity where StageName Not IN: opportunityStageSet AND OwnerId IN: opportunityOwnerIdSet
                                                        And AccountId IN :swcAccountIdSet AND Opportunity.Account.persondonotcall = true AND Opportunity.Account.BillingState = 'TX']) {                                                
            if(accountIdToOwnerIdListMap.containsKey(taskToCancel.AccountId) && 
                accountIdToOwnerIdListMap.get(taskToCancel.AccountId).contains(taskToCancel.OwnerId)){
            oppRecordToUpdate = updateOppSwcAndDateCapturedFields(oppRecordToUpdate);
            oppListToUpdate.add(oppRecordToUpdate);                                             
        }

        updateOpportunityList(oppListToUpdate);
        cancelSwcGrantedTask(swcAccountIdSet, opportunityOwnerIdSet);
    }    
*/

}