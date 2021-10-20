public class OpportunitySwc{
//"force-app/main/default/lwc/**/*.js",
    //"!force-app/main/default/lwc/checkBrowser/*",
    //"!force-app/main/default/lwc/checkBrowser/**/*",
    //"!**/node_modules/**"
    //force-app/main/default/lwc/**/*.js': {
/*
// borrowed from the lwc-recipes project
const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');
jestConfig.testPathIgnorePatterns = [...jestConfig.testPathIgnorePatterns, "<rootDir>/.stryker-tmp/"]; // added to keep jest from testing temp stryker folders
module.exports = {
  ...jestConfig,
  collectCoverageFrom: [
    
  ],
  coverageThreshold: {
    global: {
      branches: 100,
      functions: 100,
      lines: 85,
      statements: 85,
    },
    '
      branches: 100,
      functions: 100,
      lines: 85,
      statements: 85,
    },
  },
  moduleNameMapper: {
    '^@salesforce/apex$': '<rootDir>/force-app/test/jest-mocks/apex',
    '^lightning/navigation$':
      '<rootDir>/force-app/test/jest-mocks/lightning/navigation',
    '^lightning/platformShowToastEvent$':
      '<rootDir>/force-app/test/jest-mocks/lightning/platformShowToastEvent',
    '^lightning/uiRecordApi$':
      '<rootDir>/force-app/test/jest-mocks/lightning/uiRecordApi',
    '^lightning/datatable$':
      '<rootDir>/force-app/test/jest-mocks/lightning/datatable/datatable',
    '^c/(.*)': '<rootDir>/force-app/main/default/lwc/$1/$1.js' // added to help stryker find classes under test
  }
};
//HTML
<template>
            <div class="slds-modal__content slds-p-around_medium">
                <lightning-spinner if:true={loading} size="medium" variant="brand" alternative-text="Loading" style = "top:50%;bottom:50%"></lightning-spinner>  
                  <h3><b>Would you like to request Written Consent for this Account?</b></h3>
                  <lightning-input type="date"
                      date-style="short"
                      name="inputDate" 
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


//Java Script
import { LightningElement, api, track } from "lwc";
import "c/checkBrowser";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord } from "lightning/uiRecordApi";
import formatDate from './signedWrittenConsentFormatDate';
import calculateRequestedEndDate from './signedWrittenConsentEndDateCalculation';
import SIGNEDWRITTENCONSENT_OBJECT from '@salesforce/schema/SignedWrittenConsent__c';
import ACCOUNT_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Account__c';
import INITIATEDFROM_FIELD from '@salesforce/schema/SignedWrittenConsent__c.InitiatedFromId__c';
import REQUESTSTARTDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestStartDate__c';
import REQUESTENDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestEndDate__c';
import REQUESTEXPIRATIONDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestExpireDate__c';
import STATUS_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Status__c';
const REQUEST_SUCCESS = "Requested Consent Successfully";
const EXCEPTION_MESSAGE =
  "An unexpected error has occurred. Please contact your normal support channel for assistance.";

export default class SignedWrittenConsent extends LightningElement {
  @api stateCode;
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

  processSubmit(){
    this.isSubmitActionDisabled = true;
    this.loading = true;
    const dateFieldValue = this.template.querySelector(
      "[data-id='requestedStartDate']"
    ).value;
    const requestedStartDate = new Date(dateFieldValue);
    const requestedEndDate = calculateRequestedEndDate(
      new Date(dateFieldValue),
      this.stateCode
    );
    this.createSignedWrittenConsent(requestedStartDate, requestedEndDate);
  }

  createSignedWrittenConsent(requestedStartDate, requestedEndDate) {
    const fields = {};
    fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
    fields[INITIATEDFROM_FIELD.fieldApiName] = this.recordId;
    fields[REQUESTSTARTDATE_FIELD.fieldApiName] = requestedStartDate;
    fields[REQUESTENDDATE_FIELD.fieldApiName] = requestedEndDate;
    fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = requestedEndDate;
    fields[STATUS_FIELD.fieldApiName] = "Active";
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

//JST
//Test
import { createElement } from 'lwc';
import signedWrittenConsent from 'c/signedWrittenConsent';
import formatDate from '../signedWrittenConsentFormatDate';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import SIGNEDWRITTENCONSENT_OBJECT from '@salesforce/schema/SignedWrittenConsent__c';
import ACCOUNT_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Account__c';
import INITIATEDFROM_FIELD from '@salesforce/schema/SignedWrittenConsent__c.InitiatedFromId__c';
import REQUESTSTARTDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestStartDate__c';
import REQUESTENDDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestEndDate__c';
import REQUESTEXPIRATIONDATE_FIELD from '@salesforce/schema/SignedWrittenConsent__c.RequestExpireDate__c';
import STATUS_FIELD from '@salesforce/schema/SignedWrittenConsent__c.Status__c';

//const recordData = require('./data/recordData.json');

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
        element.stateCode = 'IL';
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
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.stateCode = 'IL';
        document.body.appendChild(element);
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));
        return Promise.resolve().then(() => {
            expect(createRecord).not.toHaveBeenCalled();
        });
    });

    it('test record not saved when date field is invalid', () => {
        const element = createElement('c-signed-written-consent', { is: signedWrittenConsent }); //Create an element
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.stateCode = 'IL';
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
        element.stateCode = 'IL';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));        
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function() {
            return true;
          };
        
        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 30));
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
        fields[ACCOUNT_FIELD.fieldApiName] = '001W000000q8h1dIAA';
        fields[INITIATEDFROM_FIELD.fieldApiName] = '0062F00000AIHMfQAP';
        fields[REQUESTSTARTDATE_FIELD.fieldApiName] = startDate;
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Active";
        const CREATE_REC_PARAMS = {
            apiName: SIGNEDWRITTENCONSENT_OBJECT.objectApiName,
            fields
        };        
        requestedStartDate.checkValidity = mockvalidity;
        const submitButton = element.shadowRoot.querySelector("[data-id='submitButton']");
        submitButton.dispatchEvent(new CustomEvent('click'));

        return flushPromises().then(() => {  
            expect(spinner).toBeNull();                
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
        element.stateCode = 'CA';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));        
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function() {
            return true;
          };
        
        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 30));
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
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Active";
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
        element.stateCode = 'CO';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));        
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function() {
            return true;
          };
        
        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 30));
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
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Active";
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
        element.stateCode = 'NY';
        document.body.appendChild(element);
        let startDate = new Date(new Date().setDate(new Date().getDay() + 1));        
        let requestedStartDate = element.shadowRoot.querySelector("[data-id='requestedStartDate']");
        requestedStartDate.value = startDate;
        const mockvalidity = function() {
            return true;
          };
        
        let endDate = new Date(requestedStartDate.value);
        endDate = new Date(endDate.setDate(endDate.getDate() + 90));
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
        fields[REQUESTENDDATE_FIELD.fieldApiName] = endDate;
        fields[REQUESTEXPIRATIONDATE_FIELD.fieldApiName] = endDate;
        fields[STATUS_FIELD.fieldApiName] = "Active";
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
        element.accountId = '001W000000q8h1dIAA'
        element.recordId = '0062F00000AIHMfQAP';
        element.stateCode = 'NY';
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
      const mockvalidity = function() {
        return true;
      };
      const SHOW_TOAST_PARAMETERS = {
        title: "",
        message: "An unexpected error has occurred. Please contact your normal support channel for assistance.",
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
    
});

//DATA
{
    "recordDataForIl" : {
    "apiName": "Opportunity",
    "fields": {
        "AccountId": {
            "value": "001W000000q8h1dIAA"
        },
        "Account": {
            "value": {
                "fields": {
                    "BillingState": {
                        "displayValue": "IL",
                        "value": "IL"
                    }
                }
            }
        }
    }
},
    "recordDataForCa" : {
    "apiName": "Opportunity",
    "fields": {
        "AccountId": {
            "value": "001W000000q8h1dIAA"
        },
        "Account": {
            "value": {
                "fields": {
                    "BillingState": {
                        "displayValue": "CA",
                        "value": "CA"
                    }
                }
            }
        }
    }
},
    "recordDataForCo" : {
    "apiName": "Opportunity",
    "fields": {
        "AccountId": {
            "value": "001W000000q8h1dIAA"
        },
        "Account": {
            "value": {
                "fields": {
                    "BillingState": {
                        "displayValue": "CO",
                        "value": "CO"
                    }
                }
            }
        }
    }
},
    "recordDataForNy" : {
    "apiName": "Opportunity",
    "fields": {
        "AccountId": {
            "value": "001W000000q8h1dIAA"
        },
        "Account": {
            "value": {
                "fields": {
                    "BillingState": {
                        "displayValue": "NY",
                        "value": "NY"
                    }
                }
            }
        }
    }
}
}

//signedWrittenConsentEndDateCalculation
export default function calculateRequestedEndDate(requestedEndDate, stateCode) {
  if (stateCode === "CA" || stateCode === "CO" || stateCode === "IL") {
    requestedEndDate = new Date(
      requestedEndDate.setDate(requestedEndDate.getDate() + 30)
    );
  } else {
    requestedEndDate = new Date(
      requestedEndDate.setDate(requestedEndDate.getDate() + 90)
    );
  }
  return requestedEndDate;
}

//signedWrittenConsnetFormateDate
export default function formatDate(dateToFormat) {
  let dd = dateToFormat.getDate();
  let mm = dateToFormat.getMonth() + 1;
  const yyyy = dateToFormat.getFullYear();
  if (dd < 10) {
    dd = `0${dd}`;
  }
  if (mm < 10) {
    mm = `0${mm}`;
  }
  return `${mm}-${dd}-${yyyy}`;
}

*/
}