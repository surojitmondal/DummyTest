public class AlertToastComponent{
/*

//Alert Toast LWC
//HTML
<template>
    <template if:true={displayToast}>
        <div data-id="toastModal" class="slds-show">
            <div class="slds-notify_container slds-is-absolute">
                <div class="slds-notify slds-notify_toast slds-theme_warning" role="alert">
                    <span class="slds-assistive-text">warning</span>
                    <span
                        class="slds-icon_container slds-icon-utility-warning slds-m-right_small slds-no-flex slds-align-top"
                        title="Description of icon">
                        <lightning-icon icon-name="utility:warning" size="small" variant="inverse"></lightning-icon>
                    </span>
                    <div class="slds-notify__content">
                        <h2 class="slds-text-heading_small " data-id="toastMessage">{warningMessage}
                            <a href="javascript:void(0);" data-id="popHyperLink"
                                onclick={showSignedWrittenConsent}>SIGNED WRITTEN CONSENT</a></h2>
                    </div>
                    <div class="slds-notify__close">
                        <button class="slds-button slds-button_icon slds-button_icon-inverse" title="Close"
                            onclick={closeToast}>
                            <lightning-icon icon-name="utility:close" size="small" variant="inverse"> </lightning-icon>
                            <span class="slds-assistive-text">Close</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </template>
    <c-modal data-id="singnedWrittenConsentModal" header="Request Written Consent?" modal-width="32">
        <c-signed-written-consent data-id="signedWrittenConsent" record-id={recordId} account-id={accountId}
            state-code={billingState} oncancel={handleClose}>
        </c-signed-written-consent>
    </c-modal>
</template>

//Js File
import { LightningElement, wire, api, track } from 'lwc';
import "c/checkBrowser";
import retrieveSObjects from '@salesforce/apex/SObjectRetrieveController.retrieveSObjects';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import CLICK_TO_DIAL_ENABLED from '@salesforce/schema/User.ClickToDialEnabled__c';

const ALLOWED_PROFILE_NAME_LIST = ['2.00 Agent', '2.01 Agent Team Member'];
const SUPPORT_PROFILE_NAME_LIST = ['Developer System Administrator', '1.07 Technical Support', '1.08 Business Support'];
const CONSENT_STATE_LIST = ['IL','CA','CO'];
const TODAYS_DATE = new Date();

export default class SignedWrittenConsentAlertToast extends LightningElement {
    @api recordId;
    @api userId = USER_ID;
    @track displayToast;
    @track isValidUser;
    @track isConsentRequired;
    @track warningMessage;
    @track billingState;
    @track accountId;
    isConsentGranted;
    sObjectRetrieveRequest;
    numberOfDaysToExpire;
    //Using the wire adapter to get the opportunity data.
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [
            "Opportunity.AccountId",
            "Opportunity.Account.PersonDoNotCall",
            "Opportunity.BillingAddressType__c",
            "Opportunity.Account.PersonHomePhone",
            "Opportunity.Account.PersonMobilePhone",
            "Opportunity.Account.Phone",
            "Opportunity.StageName",
            "Opportunity.CreatedDate",
            "Opportunity.DateCaptured__c"
        ]
    })
    wiredRecord({ data }) {
        if (data && data.fields.BillingAddressType__c) {
            this.billingState = data.fields.BillingAddressType__c.value.toUpperCase();
            this.accountId = data.fields.AccountId.value;
            this.validateIfConsentRequired(
                data.fields.Account.value.fields.PersonDoNotCall.value,
                this.billingState,
                data.fields.Account.value.fields.PersonHomePhone.value,
                data.fields.Account.value.fields.PersonMobilePhone.value,
                data.fields.Account.value.fields.Phone.value,
                data.fields.StageName.value,
                data.fields.CreatedDate.value,
                data.fields.DateCaptured__c.value
            );
            this.sObjectRetrieveRequest = this.buildRequest(this.accountId);
            this.showToast();
        }
    }

    //Using the wire adapter to get the logged in user data.
    @wire(getRecord, { recordId: '$userId', fields: [PROFILE_NAME_FIELD, CLICK_TO_DIAL_ENABLED] })
    wiredUser({ data }) {
        if (data && data.fields.ClickToDialEnabled__c) {
            this.validateLoggedInUser(
                data.fields.Profile.value.fields.Name.value,
                data.fields.ClickToDialEnabled__c.value
            );
            this.showToast();
        }
    }

    validateLoggedInUser(profileName, clickToDialEnabled) {
        if (
            (ALLOWED_PROFILE_NAME_LIST.includes(profileName) &&
                clickToDialEnabled) ||
            SUPPORT_PROFILE_NAME_LIST.includes(profileName)
        ) {
            this.isValidUser = true;
        }
    }

    validateIfConsentRequired(personDoNotCall, billingState, personHomePhone, personMobilePhone, phone, opportunityStage, opportunityCreatedDate, opportunityDateCaptured) {
        if (
            personDoNotCall &&
            (personHomePhone || personMobilePhone || phone) &&
            opportunityStage !== "Closed Won" &&
            this.validateOpportunityRecordDate(
                billingState,
                opportunityCreatedDate,
                opportunityDateCaptured
            )
        ) {
            this.isConsentRequired = true;
        }
    }

    validateOpportunityRecordDate(billingState, opportunityCreatedDate, opportunityDateCaptured) {
        let warningMessageStart = "Marketing Consent Expiring ";
        let warningMessageEnd = "Click to request ";
        let dateToCalculate = opportunityDateCaptured ? opportunityDateCaptured : opportunityCreatedDate;        
        let isShowToast = this.isConsentNecessary(dateToCalculate,billingState);       
        if (this.numberOfDaysToExpire === 0) {
            this.warningMessage = warningMessageStart + "Today. " + warningMessageEnd;
        } else {
            this.warningMessage = this.numberOfDaysToExpire === 1 ? warningMessageStart + "in 1 day. " + warningMessageEnd : warningMessageStart + "in " + this.numberOfDaysToExpire + " days. " + warningMessageEnd;
        }
        return isShowToast;
    }

    @wire(retrieveSObjects, { request: '$sObjectRetrieveRequest' })
    signedWrittenConsentRecord(result) {
        if (result && result.data) {
            const signedWrittenConsentRecords = result.data.sobjects;
            this.isConsentGranted = signedWrittenConsentRecords.length === 0 || (signedWrittenConsentRecords[0].Status__c === 'Consent Granted' && this.isConsentNecessary(signedWrittenConsentRecords[0].RequestStartDate__c, this.billingState));
        }
    this.showToast();
    }

    isConsentNecessary(dateToCalculate, billingState){
        let calculatedDays = TODAYS_DATE.getTime() - new Date(dateToCalculate).getTime();
        let numberOfDays = Math.floor(calculatedDays / (1000 * 3600 * 24));
        this.numberOfDaysToExpire = CONSENT_STATE_LIST.includes(billingState) ? 30 - numberOfDays : 90 - numberOfDays;
        let isConsentRequired = CONSENT_STATE_LIST.includes(billingState) ? numberOfDays >= 15 : numberOfDays >= 45 ;
        return isConsentRequired && this.numberOfDaysToExpire >= 0;        
    }

    buildRequest(accountId){
        return {
            sobjectName: 'SignedWrittenConsent__c',
            fieldNames: ['Id','Status__c','RequestStartDate__c'],
            filterCriteriaIn: [{
                enable:true,
                filterFieldName:'Account__c',
                queryNullValues:false,
                filterValues:[accountId],
                filterType:'LIST_OF_STRING'
            }],
            orderByCriteriaIn: [{
                sortedBy: 'CreatedDate',
                sortedDirection: 'DESC',
            }],
            queryLimit:1
        };
    }

    showSignedWrittenConsent() {
        this.closeToast();
        this.findModal().show();
    }

    showToast() {
        if (this.isValidUser && this.isConsentRequired && this.isConsentGranted) {
            this.displayToast = true;
        }
    }

    closeToast() {
        this.displayToast = false;
    }

    handleClose() {
      this.findModal().hide();
    }

    findModal() {
      return this.template.querySelector('[data-id="singnedWrittenConsentModal"]');
  }
}
               
               
//TEST.JS
import { createElement } from 'lwc';
import signedWrittenConsentAlertToast from 'c/signedWrittenConsentAlertToast';
import { getRecord } from 'lightning/uiRecordApi';
import retrieveSObjects from '@salesforce/apex/SObjectRetrieveController.retrieveSObjects';
import { registerLdsTestWireAdapter, registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

let opportunityData = require('./data/opportunityData.json');
let signedWrittenConsentData = require('./data/signedWrittenConsentData.json');
const userData = require('./data/userData.json');

// Register as Apex wire adapter. Some tests verify that provisioned values trigger desired behavior.
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);
const retrieveSObjectsAdapter = registerApexTestWireAdapter(retrieveSObjects);

describe('c-signed-written-consent-alert-toast', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    it('test opportunity record is invoked with the right parameters', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        const GET_RECORD_PARAMS = {
            fields: [
                'Opportunity.AccountId',
                'Opportunity.Account.PersonDoNotCall',
                'Opportunity.BillingAddressType__c',
                'Opportunity.Account.PersonHomePhone',
                'Opportunity.Account.PersonMobilePhone',
                'Opportunity.Account.Phone',
                'Opportunity.StageName',
                'Opportunity.CreatedDate',
                'Opportunity.DateCaptured__c',
                'Opportunity.Phone__c'],
            recordId: '0062F000007O4bqQAC'
        };
        const BUILD_REQUEST_PARAMS = {
            "request": buildRequest('0012F00000EIbhJQAT')
        };
        getRecordAdapter.emit(opportunityData.recordDataForIl);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.consentGrantedRecord);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            element.recordId = '0062F000007O4bqQAC';
            return Promise.resolve().then(() => {
                expect(getRecordAdapter.getLastConfig()).toEqual(GET_RECORD_PARAMS);
                expect(retrieveSObjectsAdapter.getLastConfig()).toEqual(BUILD_REQUEST_PARAMS);
                let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
                expect(toastModal).toBeNull();
            });
        });
    });

    it('test user record is invoked with the right parameters', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        const GET_USER_PARAMS = {
            fields: [
                {
                    "fieldApiName": "Profile.Name",
                    "objectApiName": "User",
                },
                {
                    "fieldApiName": "ClickToDialEnabled__c",
                    "objectApiName": "User",
                }],
            recordId: '0052F000000vkyXQAQ'
        };
        getRecordAdapter.emit(userData.agentProfile);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            element.userId = '0052F000000vkyXQAQ';
            return Promise.resolve().then(() => {
                expect(getRecordAdapter.getLastConfig()).toEqual(GET_USER_PARAMS);
                let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
                expect(toastModal).toBeNull();
            });
        });
    });

    it('test toast shown when opportunity meets criteria and logged in user is Agent and click to dial enabled', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.agentProfile);
        document.body.appendChild(element);
        let oppData = opportunityData.recordDataForIl;
        oppData.fields.CreatedDate.value = new Date(new Date().setDate(new Date().getDate() - 25));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast shown when opportunity meets criteria and logged in user is ATM and click to dial enabled', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.agentTeamMemberProfile);
        let oppData = opportunityData.recordDataForCa;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 25));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast shown when opportunity meets criteria and logged in user is business support', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        element.userId = '005W000000q8h1dIAA';
        getRecordAdapter.emit(userData.businessSupportProfile);
        element.recordId = '006W000000q8h1dIAA';
        let oppData = opportunityData.recordDataForCa;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 20));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast shown when opportunity meets criteria and logged in user is developer system administrator', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.devSysAdminProfile);
        let oppData = opportunityData.recordDataForCo;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 18));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast shown when opportunity meets criteria and logged in user is technial support', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForCa;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 23));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast shown when opportunity meets criteria, valid user and billing state is illinois and number of days less than 15', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForIl;
        oppData.fields.CreatedDate.value = new Date(new Date().setDate(new Date().getDate() - 19));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast not shown when valid user logged in, billing state is illinois and number of days greater than 15', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForIl;
        oppData.fields.CreatedDate.value = new Date(new Date().setDate(new Date().getDate() + 19));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast shown when valid user logged in and billing state is california and number of days less than 15', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForCa;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 16));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.consentGrantedRecord);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast not shown when valid user logged in, billing state is  california and number of days greater than 15', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForCa;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() + 14));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.consentRequestedRecord);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast not shown on other state and number of days greater than 45', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForOtherState;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() + 14));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast shown when valid user logged in, billing state is Colorado and number of days less than 15', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.agentProfile);
        let oppData = opportunityData.recordDataForCo;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 16));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast not shown when valid user logged in, billing state is Colorado and number of days greater than 15', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForCo;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 12));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast shown when only home phone is present', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForOnlyHomePhone;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 49));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.consentGrantedRecord);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast shown when only mobile phone is present', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        getRecordAdapter.emit(opportunityData.recordDataForOnlyMobilePhone);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelectorAll("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast shown when only opportunity phone is present', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        getRecordAdapter.emit(opportunityData.recordDataForOnlyOpportunityPhone);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelectorAll("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast shown when only phone is present', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        getRecordAdapter.emit(opportunityData.recordDataForOnlyPhone);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelectorAll("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast not shown when all phone numbers are empty', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        getRecordAdapter.emit(opportunityData.recordDataForAllNumbersEmpty);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast not shown when stage is Closed Won', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        getRecordAdapter.emit(opportunityData.recordDataForClosedWon);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast not shown for any profile not present in the list of allowed profiles', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.notAllowedProfile);
        getRecordAdapter.emit(opportunityData.recordDataForCa);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('validate displayed expired message when date captured is less than today', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForCo;
        let today = new Date();
        today.setDate(today.getDate() - 32);
        oppData.fields.DateCaptured__c.value = today;
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('validate displayed expiring message when consent is expiring in 1 day', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForCo;
        let today = new Date();
        today.setDate(today.getDate() - 30);
        oppData.fields.DateCaptured__c.value = today;
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
            let toastMessage = element.shadowRoot.querySelector("[data-id='toastMessage']");
            expect(toastMessage.textContent).toEqual('Marketing Consent Expiring in 1 day. Click to request SIGNED WRITTEN CONSENT');
        });
    });

    it('validate displayed expiring message  when consent is expiring in 6 days', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForCo;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 25));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
            let toastMessage = element.shadowRoot.querySelector("[data-id='toastMessage']");
            expect(toastMessage.textContent).toEqual('Marketing Consent Expiring in 6 days. Click to request SIGNED WRITTEN CONSENT');
        });
    });

    it('validate expiring message displayed when date captured is equal to today', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForCo;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 31));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
            let toastMessage = element.shadowRoot.querySelector("[data-id='toastMessage']");
            expect(toastMessage.textContent).toEqual('Marketing Consent Expiring Today. Click to request SIGNED WRITTEN CONSENT');
        });
    });


    it('validate when "SIGNED WRITTEN CONSENT" is clicked, the modal pop up opens', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        let oppData = opportunityData.recordDataForCo;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 18));
        getRecordAdapter.emit(oppData);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let singnedWrittenConsentModal = element.shadowRoot.querySelector("[data-id='singnedWrittenConsentModal']");
            singnedWrittenConsentModal.show = jest.fn();
            let popHyperlink = element.shadowRoot.querySelector("[data-id='popHyperLink']");
            popHyperlink.dispatchEvent(new CustomEvent('click'));
            return Promise.resolve().then(() => {
                expect(singnedWrittenConsentModal.show).toHaveBeenCalled();
                let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
                expect(toastModal).toBeNull();
            });
        });
    });

    it('validate modal dialog closed when cancel is clicked', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.techSupportProfile);
        getRecordAdapter.emit(opportunityData.recordDataForIl);
        retrieveSObjectsAdapter.emit(signedWrittenConsentData.swcEmptyList);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let singnedWrittenConsentModal = element.shadowRoot.querySelector("c-modal");
            singnedWrittenConsentModal.showModal = true;
            singnedWrittenConsentModal.hide = jest.fn();

            return Promise.resolve().then(() => {
                const cancelEvent = new CustomEvent('cancel');
                let signedWrittenConsentElement = element.shadowRoot.querySelector("c-signed-written-consent");
                signedWrittenConsentElement.dispatchEvent(cancelEvent);
                return Promise.resolve().then(() => {
                    expect(singnedWrittenConsentModal.hide).toHaveBeenCalled();
                });
            });
        });
    });

    function buildRequest(accountId) {
        return {
            sobjectName: 'SignedWrittenConsent__c',
            fieldNames: ['Id', 'Status__c', 'RequestStartDate__c'],
            filterCriteriaIn: [{
                enable: true,
                filterFieldName: 'Account__c',
                queryNullValues: false,
                filterValues: [accountId],
                filterType: 'LIST_OF_STRING'
            }],
            orderByCriteriaIn: [{
                sortedBy: 'CreatedDate',
                sortedDirection: 'DESC',
            }],
            queryLimit: 1
        };
    }
});

//getOpportunityData
{
    "recordDataForIl": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "IL"
            },
            "StageName": {
                "value": "In Progress"
            },
            "CreatedDate": {
                "value": "6-6-2020"
            },
            "DateCaptured__c": {
                "value": ""
            },
            "Phone__c": {
                "value": "9876543210"
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": "549887331"
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "0123456789"
                        },
                        "Phone": {
                            "value": "9876543210"
                        }
                    }
                }
            }
        }
    },
    "recordDataForCa": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "CA"
            },
            "StageName": {
                "value": "In Progress"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-06-2020"
            },
            "Phone__c": {
                "value": "9876543210"
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": "549887331"
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "0123456789"
                        },
                        "Phone": {
                            "value": "9876543210"
                        }
                    }
                }
            }
        }
    },
    "recordDataForCo": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "CO"
            },
            "StageName": {
                "value": "In Progress"
            },            
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "Phone__c": {
                "value": "9876543210"
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": "549887331"
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "0123456789"
                        },
                        "Phone": {
                            "value": "9876543210"
                        }
                    }
                }
            }
        }
    },
    "recordDataForOtherState": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "NY"
            },
            "StageName": {
                "value": "In Progress"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-06-2020"
            },
            "Phone__c": {
                "value": "9876543210"
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": "549887331"
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "0123456789"
                        },
                        "Phone": {
                            "value": "9876543210"
                        }
                    }
                }
            }
        }
    },
    "recordDataForDoNotCall": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": ""
            },
            "StageName": {
                "value": "In Progress"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "Phone__c": {
                "value": "9876543210"
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": ""
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": ""
                        },
                        "Phone": {
                            "value": "9876543210"
                        }
                    }
                }
            }
        }
    },
    "recordDataForAllNumbersEmpty": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": ""
            },
            "StageName": {
                "value": "In Progress"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "Phone__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": ""
                        },
                        "PersonDoNotCall": {
                            "value": false
                        },
                        "PersonMobilePhone": {
                            "value": ""
                        },
                        "Phone": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForOnlyHomePhone": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "MN"
            },
            "StageName": {
                "value": "In Progress"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "Phone__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": "9876543210"
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": ""
                        },
                        "Phone": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForOnlyMobilePhone": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": ""
            },
            "StageName": {
                "value": "In Progress"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "Phone__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": ""
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "549887331"
                        },
                        "Phone": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForOnlyPhone": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": ""
            },
            "StageName": {
                "value": "In Progress"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "Phone__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": ""
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": ""
                        },
                        "Phone": {
                            "value": "549887331"
                        }
                    }
                }
            }
        }
    },
    "recordDataForOnlyOpportunityPhone": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": ""
            },
            "StageName": {
                "value": "In Progress"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "Phone__c": {
                "value": "549887331"
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": ""
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": ""
                        },
                        "Phone": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForClosedWon": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": ""
            },
            "StageName": {
                "value": "Closed Won"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "Phone__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonHomePhone": {
                            "value": "549887331"
                        },
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "0123456789"
                        },
                        "Phone": {
                            "value": "9876543210"
                        }
                    }
                }
            }
        }
    }
}

//swcData
//
//{
    "emptyList": {
        "sobjects": [],
        "success": true
    },
    "consentGrantedStatus": {
        "sobjects": [
            {
                "Id": "a3L2F000000EPXZ",
                "Status__c": "Consent Granted",
                "RequestStartDate__c": "5-6-2020"
            }
        ],
        "success": true
    },
    "consentRejectedStatus": {
        "sobjects": [
            {
                "Id": "a3L2F000000EPXZ",
                "Status__c": "Consent Rejected",
                "RequestStartDate__c": "5-6-2020"
            }
        ],
        "success": true
    }
}

//user Data
{
    "agentProfile": {
        "fields": {
            "Profile": {
                "value": {
                    "fields": {
                        "Name": {
                            "value": "2.00 Agent"
                        }
                    }
                }
            },
            "ClickToDialEnabled__c": {
                "value": "true"
            }
        }
    },
    "agentTeamMemberProfile": {
        "fields": {
            "Profile": {
                "value": {
                    "fields": {
                        "Name": {
                            "value": "2.01 Agent Team Member"
                        }
                    }
                }
            },
            "ClickToDialEnabled__c": {
                "value": "true"
            }
        }
    },
    "devSysAdminProfile": {
        "fields": {
            "Profile": {
                "value": {
                    "fields": {
                        "Name": {
                            "value": "Developer System Administrator"
                        }
                    }
                }
            },
            "ClickToDialEnabled__c": {
                "value": "false"
            }
        }
    },
    "techSupportProfile": {
        "fields": {
            "Profile": {
                "value": {
                    "fields": {
                        "Name": {
                            "value": "1.07 Technical Support"
                        }
                    }
                }
            },
            "ClickToDialEnabled__c": {
                "value": "false"
            }
        }
    },
    "businessSupportProfile": {
        "fields": {
            "Profile": {
                "value": {
                    "fields": {
                        "Name": {
                            "value": "1.08 Business Support"
                        }
                    }
                }
            },
            "ClickToDialEnabled__c": {
                "value": "false"
            }
        }
    },
    "notAllowedProfile": {
        "fields": {
            "Profile": {
                "value": {
                    "fields": {
                        "Name": {
                            "value": "3.00 CCC Licensed"
                        }
                    }
                }
            },
            "ClickToDialEnabled__c": {
                "value": "false"
            }
        }
    }
}
*/
}