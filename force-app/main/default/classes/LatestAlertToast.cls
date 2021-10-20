public class LatestAlertToast{

/*

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
            billing-state={billingState} min-date={minDate} is-submit-action-disabled={isSubmitDisabled} onrefreshtab={handleRefresh} oncancel={handleClose}>
        </c-signed-written-consent>
    </c-modal>
</template>

//JS
import { LightningElement, wire, api, track } from 'lwc';
import "c/checkBrowser";
import { getRecord } from 'lightning/uiRecordApi';
import restrictSignedWrittenConsent from '@salesforce/apex/HLPR_SignedWrittenConsent.getSignedWrittenConsentToggleContext';
import USER_ID from '@salesforce/user/Id';
//import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
//import CLICK_TO_DIAL_ENABLED from '@salesforce/schema/User.ClickToDialEnabled__c';
import USER_TYPE from '@salesforce/schema/User.UserType__c';
import { refreshApex } from '@salesforce/apex';
import { formatDate } from 'c/journeyDateValidation';

//const ALLOWED_PROFILE_NAME_LIST = ['2.00 Agent', '2.01 Agent Team Member'];
//const SUPPORT_PROFILE_NAME_LIST = ['Developer System Administrator', '1.07 Technical Support', '1.08 Business Support'];
const ALLOWED_USER_TYPE_LIST = ['Agent','ATM','Corporate Support'];
const OPPORTUNITY_STAGE_LIST = ['Closed','Closed Won'];
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
    @track minDate;
    @track isSubmitDisabled;
    numberOfDaysToExpire;
    autoCloseTime = 8000;
    signedWrittenConsentStatus;
    opportunityDataResult;
    @ track restrictConsentRequest;
    
    //Using the wire adapter to get the opportunity data.
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [
            "Opportunity.AccountId",
            "Opportunity.Account.PersonDoNotCall",
            "Opportunity.BillingAddressType__c",
            "Opportunity.Account.PersonMobilePhone",
            "Opportunity.StageName",
            "Opportunity.CreatedDate",
            "Opportunity.DateCaptured__c",
            "Opportunity.Account.SignedWrittenConsentStatus__c",
            "Opportunity.SignedWrittenConsentRequestedDate__c",
            "Opportunity.SignedWrittenConsentGrantedDate__c"
        ]
    })
    wiredRecord(result) {
        this.opportunityDataResult = result;
        if (result.data && result.data.fields.BillingAddressType__c && result.data.fields.BillingAddressType__c.value) {
            //alert('OpportunityWire');
            //restrictSignedWrittenConsent()
            //if(result.data !== null && result.data !== undefined){
              //  alert(result.data.value);
                //this.restrictConsentRequest = result.data;                
            //}
            this.billingState = result.data.fields.BillingAddressType__c.value.toUpperCase();
            this.accountId = result.data.fields.AccountId.value;
            this.signedWrittenConsentStatus = result.data.fields.Account.value.fields.SignedWrittenConsentStatus__c.value;
            this.validateIfConsentRequired(result.data.fields.Account.value,result.data.fields,this.billingState);                        
            this.showToast();
        }
    }

    //wire
    @wire(restrictSignedWrittenConsent, {opportunityId: '$recordId'})
    wiredRestrictSignedWrittenConsent(result) {
        alert(result.data);
        this.restrictConsentRequest = result.data;
        this.showToast();
    }


    //Connected Call Back
    connectedCallback() {
    restrictSignedWrittenConsent()
    .then(data => {
        //alert(data);
        this.restrictConsentRequest = data;
        this.showToast();
    })
    }

    //Using the wire adapter to get the logged in user data.
    @wire(getRecord, { recordId: '$userId', fields: [USER_TYPE] })
    wiredUser({ data }) {
        if (data && data.fields.UserType__c) {
            //alert('UserWire');
            this.isValidUser = ALLOWED_USER_TYPE_LIST.includes(data.fields.UserType__c.value);
            this.isSubmitDisabled = data.fields.UserType__c.value === 'Corporate Support';
            this.showToast();
        }
    }

    validateIfConsentRequired(acctFields,opptyFields,billingState) {
        if (
            acctFields.fields.PersonDoNotCall.value &&
            acctFields.fields.PersonMobilePhone.value && billingState === 'TX' &&
            this.validateOpportunityRecordDate(
                opptyFields.CreatedDate.value,
                opptyFields.DateCaptured__c.value,
                opptyFields.SignedWrittenConsentRequestedDate__c.value,
                opptyFields.SignedWrittenConsentGrantedDate__c.value
            )
        ) {
            this.isConsentRequired = true;
        }
    }

    validateOpportunityRecordDate(opportunityCreatedDate, opportunityDateCaptured,swcRequestedDate,swcGrantedDate) {
        let warningMessageStart = "Marketing Consent Expiring ";
        let warningMessageEnd = "Click to request ";
        let opportunityDate = opportunityDateCaptured ? opportunityDateCaptured : opportunityCreatedDate;        
        let isShowToast = this.isConsentNecessary(opportunityDate,swcRequestedDate,swcGrantedDate);      
        if (this.numberOfDaysToExpire === 0) {
            this.warningMessage = warningMessageStart + "Today. " + warningMessageEnd;
        } else {
            this.warningMessage = this.numberOfDaysToExpire === 1 ? warningMessageStart + "in 1 day. " + warningMessageEnd : warningMessageStart + "in " + this.numberOfDaysToExpire + " days. " + warningMessageEnd;
        }
        return isShowToast;
    }

    isConsentNecessary(opportunityDate,swcRequestedDate,swcGrantedDate){
        let isConsentNotRunning = !(swcRequestedDate !== null && (swcGrantedDate === null || new Date(swcGrantedDate) > new Date(TODAYS_DATE)));
        let dateToCalculate = (swcGrantedDate !== null && new Date(swcGrantedDate) <= new Date(TODAYS_DATE)) ? swcGrantedDate : opportunityDate;        
        this.calculateDaysToExpire(new Date(dateToCalculate));        
        return isConsentNotRunning && this.numberOfDaysToExpire >= 0;       
    }
    
    calculateDaysToExpire(dateToCalculate){
        dateToCalculate = new Date(dateToCalculate.setDate(dateToCalculate.getDate() + 89));
        let calculatedDays = new Date(dateToCalculate) - new Date(TODAYS_DATE);            
        this.numberOfDaysToExpire = Math.ceil(calculatedDays / (1000 * 3600 * 24));
    }

    showSignedWrittenConsent() {
        this.closeToast();
        this.findModal().show();
    }

    showToast() {        
        if (this.isValidUser && this.isConsentRequired && this.signedWrittenConsentStatus !== "Requested" &&
        !OPPORTUNITY_STAGE_LIST.includes(this.opportunityDataResult.data.fields.StageName.value) && !this.restrictConsentRequest) {
            //alert(this.restrictConsentRequest);
            this.displayToast = true;
            this.minDate = formatDate(
            new Date(new Date().setDate(new Date().getDate() + this.numberOfDaysToExpire + 1))
        );
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
            this.closeToast();
        }, this.autoCloseTime);        
        }        
    }

    closeToast() {
        this.displayToast = false;
    }

    handleClose() {
      this.findModal().hide();
    }

    handleRefresh() {
        refreshApex(this.opportunityDataResult);
    }

    findModal() {
      return this.template.querySelector('[data-id="singnedWrittenConsentModal"]');
  }
}

//Jest
import { createElement } from 'lwc';
import signedWrittenConsentAlertToast from 'c/signedWrittenConsentAlertToast';
import { getRecord } from 'lightning/uiRecordApi';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { refreshApex } from '@salesforce/apex';
const opportunityData = require('./data/opportunityData.json');
const userData = require('./data/userData.json');

// Register as Apex wire adapter. Some tests verify that provisioned values trigger desired behavior.
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

describe('c-signed-written-consent-alert-toast', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        refreshApex.mockReset();
        jest.clearAllMocks();
    });

    it('test opportunity record is invoked with the right parameters', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        const GET_RECORD_PARAMS = {
            fields: [
                'Opportunity.AccountId',
                'Opportunity.Account.PersonDoNotCall',
                'Opportunity.BillingAddressType__c',
                'Opportunity.Account.PersonMobilePhone',
                'Opportunity.StageName',
                'Opportunity.CreatedDate',
                'Opportunity.DateCaptured__c',
                'Opportunity.Account.SignedWrittenConsentStatus__c',
                'Opportunity.SignedWrittenConsentRequestedDate__c',
                'Opportunity.SignedWrittenConsentGrantedDate__c'],
            recordId: '0062F000007O4bqQAC'
        };
        getRecordAdapter.emit(opportunityData.recordDataForTxState);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            element.recordId = '0062F000007O4bqQAC';
            return Promise.resolve().then(() => {
                expect(getRecordAdapter.getLastConfig()).toEqual(GET_RECORD_PARAMS);
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
                    "fieldApiName": "UserType__c",
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

    it('test toast shown when opportunity meets criteria and logged in user is Agent', () => {
        jest.useFakeTimers();
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.agentProfile);
        document.body.appendChild(element);
        let oppData = opportunityData.recordDataForTxState;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 75));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        jest.runAllTimers();
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelectorAll("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
            expect(setTimeout).toHaveBeenCalledTimes(1);
        });
    });

    it('test toast shown when opportunity meets criteria and logged in user is ATM', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.agentTeamMemberProfile);
        let oppData = opportunityData.recordDataForTxState;
        oppData.fields.SignedWrittenConsentGrantedDate__c.value = new Date(new Date().setDate(new Date().getDate() - 85));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
            let swcPopUp = element.shadowRoot.querySelector("[data-id='signedWrittenConsent']");
            expect(swcPopUp.isSubmitActionDisabled).toBe(false);
        });
    });

    it('test toast not shown when opportunity meets criteria and logged in user is CCC', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.notAllowedProfile);
        let oppData = opportunityData.recordDataForTxState;
        oppData.fields.SignedWrittenConsentGrantedDate__c.value = new Date(new Date().setDate(new Date().getDate() - 25));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            let swcPopUp = element.shadowRoot.querySelector("[data-id='signedWrittenConsent']");
            expect(swcPopUp.isSubmitActionDisabled).toBe(false);
            //expect(element.isSubmitDisabled).toBe(true);
            expect(toastModal).toBeNull();
        });
    });

    it('test toast not shown when Account is not donotcall', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        element.userId = '005W000000q8h1dIAA';
        getRecordAdapter.emit(userData.businessSupportProfile);
        element.recordId = '006W000000q8h1dIAA';
        let oppData = opportunityData.recordDataForDoNotCall;
        oppData.fields.SignedWrittenConsentGrantedDate__c.value = "";
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 70));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
            let swcPopUp = element.shadowRoot.querySelector("[data-id='signedWrittenConsent']");
            expect(swcPopUp.isSubmitActionDisabled).toBe(true);
        });
    });
    it('test toast shown when opportunity meets criteria and logged in user is business support', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        element.userId = '005W000000q8h1dIAA';
        getRecordAdapter.emit(userData.businessSupportProfile);
        element.recordId = '006W000000q8h1dIAA';
        let oppData = opportunityData.recordDataForTxState;
        oppData.fields.SignedWrittenConsentGrantedDate__c.value = "";
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 70));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });
    it('test toast not shown when opportunity meets criteria and logged in user is developer system administrator but consent already requested once', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForRequested;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 18));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast not shown when opportunity does not meet the criteria', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForSWCDate;
        oppData.fields.SignedWrittenConsentGrantedDate__c.value = new Date(new Date().setDate(new Date().getDate() + 15));
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 23));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast shown when opportunity swc date meet the criteria', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForSWCDate;
        oppData.fields.SignedWrittenConsentRequestedDate__c.value = null;
        oppData.fields.SignedWrittenConsentGrantedDate__c.value = new Date();
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 23));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
        });
    });

    it('test toast not shown on other state', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForOtherState;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 85));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast not shown when mobile phone empty', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForEmptyMobilePhone;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 20));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast not shown when Person do not call is false', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForPersonDoNotCall;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 15));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast not shown when stage is Closed Won', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForClosedWonStage;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 15));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('test toast not shown when stage is Closed', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForClosedStage;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 15));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).toBeNull();
        });
    });

    it('validate displayed expiring message when consent is expiring Today', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForTxState;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 90));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
            let toastMessage = element.shadowRoot.querySelector("[data-id='toastMessage']");
            expect(toastMessage.textContent).toEqual('Marketing Consent Expiring Today. Click to request SIGNED WRITTEN CONSENT');
        });
    });

    it('validate displayed expiring message  when consent is expiring in 5 days', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForTxState;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 85));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
            let toastMessage = element.shadowRoot.querySelector("[data-id='toastMessage']");
            expect(toastMessage.textContent).toEqual('Marketing Consent Expiring in 5 days. Click to request SIGNED WRITTEN CONSENT');
        });
    });

    it('validate displayed expiring message when consent is expiring in 1 Day', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForTxState;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 89));
        getRecordAdapter.emit(oppData);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let toastModal = element.shadowRoot.querySelector("[data-id='toastModal']");
            expect(toastModal).not.toBeNull();
            let toastMessage = element.shadowRoot.querySelector("[data-id='toastMessage']");
            expect(toastMessage.textContent).toEqual('Marketing Consent Expiring in 1 day. Click to request SIGNED WRITTEN CONSENT');
        });
    });


    it('validate when "SIGNED WRITTEN CONSENT" is clicked, the modal pop up opens', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element

        getRecordAdapter.emit(userData.businessSupportProfile);
        let oppData = opportunityData.recordDataForTxState;
        oppData.fields.DateCaptured__c.value = new Date(new Date().setDate(new Date().getDate() - 18));
        getRecordAdapter.emit(oppData);
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
        getRecordAdapter.emit(userData.businessSupportProfile);
        getRecordAdapter.emit(opportunityData.recordDataForTxState);
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

    it('validate modal dialog refreshed when refresh tab event is raised', () => {
        const element = createElement('c-signed-written-consent-alert-toast', { is: signedWrittenConsentAlertToast }); //Create an element
        getRecordAdapter.emit(userData.businessSupportProfile);
        getRecordAdapter.emit(opportunityData.recordDataForTxState);
        document.body.appendChild(element);
        return Promise.resolve().then(() => {
            let singnedWrittenConsentModal = element.shadowRoot.querySelector("c-modal");
            singnedWrittenConsentModal.show();

            return Promise.resolve().then().then(() => {
                const refreshEvent = new CustomEvent('refreshtab');
                let signedWrittenConsentElement = element.shadowRoot.querySelector("c-signed-written-consent");
                signedWrittenConsentElement.dispatchEvent(refreshEvent);
                return Promise.resolve().then(() => {
                    expect(refreshApex).toHaveBeenCalled();
                });
            });
        });
    });
});

//userData.json
{
    "agentProfile": {
        "fields": {
            "UserType__c": {
                "value": "Agent"
            }
        }
    },
    "agentTeamMemberProfile": {
        "fields": {
            "UserType__c": {
                "value": "ATM"
            }
        }
    },
    "businessSupportProfile": {
        "fields": {
            "UserType__c": {
                "value": "Corporate Support"
            }
        }
    },
    "notAllowedProfile": {
        "fields": {
            "UserType__c": {
                "value": "CCC"
            }
        }
    }
}

//opportunityData.json
{
    "recordDataForSWCDate": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "TX"
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
            "SignedWrittenConsentRequestedDate__c": {
                "value": "5-06-2020"
            },
            "SignedWrittenConsentGrantedDate__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "6123456789"
                        },
                        "SignedWrittenConsentStatus__c": {
                            "value": ""
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
            "SignedWrittenConsentRequestedDate__c": {
                "value": ""
            },
            "SignedWrittenConsentGrantedDate__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "6123456789"
                        },
                        "SignedWrittenConsentStatus__c": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForTxState": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "TX"
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
            "SignedWrittenConsentRequestedDate__c": {
                "value": ""
            },
            "SignedWrittenConsentGrantedDate__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "6123456789"
                        },
                        "SignedWrittenConsentStatus__c": {
                            "value": ""
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
                "value": "TX"
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
            "SignedWrittenConsentRequestedDate__c": {
                "value": ""
            },
            "SignedWrittenConsentGrantedDate__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonDoNotCall": {
                            "value": false
                        },
                        "PersonMobilePhone": {
                            "value": "6123456789"
                        },
                        "SignedWrittenConsentStatus__c": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForEmptyMobilePhone": {
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
            "SignedWrittenConsentRequestedDate__c": {
                "value": "5-06-2020"
            },
            "SignedWrittenConsentGrantedDate__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": ""
                        },
                        "SignedWrittenConsentStatus__c": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForPersonDoNotCall": {
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
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "SignedWrittenConsentRequestedDate__c": {
                "value": "5-06-2020"
            },
            "SignedWrittenConsentGrantedDate__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonDoNotCall": {
                            "value": false
                        },
                        "PersonMobilePhone": {
                            "value": "6123456789"
                        },
                        "SignedWrittenConsentStatus__c": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForClosedWonStage": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "TX"
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
            "SignedWrittenConsentRequestedDate__c": {
                "value": ""
            },
            "SignedWrittenConsentGrantedDate__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "6123456789"
                        },
                        "SignedWrittenConsentStatus__c": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForClosedStage": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "TX"
            },
            "StageName": {
                "value": "Closed"
            },
            "CreatedDate": {
                "value": ""
            },
            "DateCaptured__c": {
                "value": "5-6-2020"
            },
            "SignedWrittenConsentRequestedDate__c": {
                "value": ""
            },
            "SignedWrittenConsentGrantedDate__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "6123456789"
                        },
                        "SignedWrittenConsentStatus__c": {
                            "value": ""
                        }
                    }
                }
            }
        }
    },
    "recordDataForRequested": {
        "apiName": "Opportunity",
        "fields": {
            "AccountId": {
                "value": "0012F00000EIbhJQAT"
            },
            "BillingAddressType__c": {
                "value": "TX"
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
            "SignedWrittenConsentRequestedDate__c": {
                "value": "5-6-2020"
            },
            "SignedWrittenConsentGrantedDate__c": {
                "value": ""
            },
            "Account": {
                "value": {
                    "fields": {
                        "PersonDoNotCall": {
                            "value": true
                        },
                        "PersonMobilePhone": {
                            "value": "6123456789"
                        },
                        "SignedWrittenConsentStatus__c": {
                            "value": "Requested"
                        }
                    }
      //Updated JS
import { LightningElement, wire, api, track } from 'lwc';
import "c/checkBrowser";
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { formatDate } from 'c/journeyDateValidation';
import retrieveAgentRelation from '@salesforce/apex/HLPR_SignedWrittenConsent.signedWrittenConsentToast';
const ALLOWED_USER_TYPE_LIST = ['Agent','ATM'];
const OPPORTUNITY_STAGE_LIST = ['Closed','Closed Won'];
const TODAYS_DATE = new Date();

export default class SignedWrittenConsentAlertToast extends LightningElement {
    @api recordId;
    @track displayToast;    
    @track warningMessage;
    @track billingState;
    @track accountId;
    @track minDate;
    @track isSupportUser;
    isAgentAtmUser;
    usrTyp;
    isConsentRequired;
    numberOfDaysToExpire;
    autoCloseTime = 8000;
    signedWrittenConsentStatus;
    opportunityDataResult;
    isSwcToggleOff;
    isProspectRelation;
    

    
    //Using the wire adapter to get the opportunity data.
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [
            "Opportunity.AccountId",
            "Opportunity.Account.PersonDoNotCall",
            "Opportunity.Account.PersonMobilePhone",
            "Opportunity.Account.PersonHomePhone",
            "Opportunity.Account.PersonEmail",
            "Opportunity.Account.SignedWrittenConsentStatus__c",
            "Opportunity.BillingAddressType__c",
            "Opportunity.StageName",
            "Opportunity.CreatedDate",
            "Opportunity.DateCaptured__c",
            "Opportunity.SignedWrittenConsentRequestedDate__c",
            "Opportunity.SignedWrittenConsentGrantedDate__c"
        ]
    })
    wiredRecord(result) {
        this.opportunityDataResult = result;
        if (result.data && result.data.fields.BillingAddressType__c && result.data.fields.BillingAddressType__c.value) {
            this.billingState = result.data.fields.BillingAddressType__c.value.toUpperCase();
            this.accountId = result.data.fields.AccountId.value;
            this.signedWrittenConsentStatus = result.data.fields.Account.value.fields.SignedWrittenConsentStatus__c.value;
            this.validateIfConsentRequired(result.data.fields.Account.value,result.data.fields,this.billingState);
            this.getAgentRelation(this.accountId);
            this.showToast();
        }
    }

    validateIfConsentRequired(acctFields,opptyFields,billingState) {
        if (
            acctFields.fields.PersonDoNotCall.value &&
            (acctFields.fields.PersonMobilePhone.value || acctFields.fields.PersonHomePhone.value) && 
            acctFields.fields.PersonEmail.value
            && billingState === 'TX' &&
            this.validateOpportunityRecordDate(
                opptyFields.CreatedDate.value,
                opptyFields.DateCaptured__c.value,
                opptyFields.SignedWrittenConsentRequestedDate__c.value,
                opptyFields.SignedWrittenConsentGrantedDate__c.value
            )
        ) {
            this.isConsentRequired = true;
        }
    }

    validateOpportunityRecordDate(opportunityCreatedDate, opportunityDateCaptured,swcRequestedDate,swcGrantedDate) {
        let warningMessageStart = "Marketing Consent Expiring ";
        let warningMessageEnd = "Click to request ";
        let opportunityDate = opportunityDateCaptured ? opportunityDateCaptured : opportunityCreatedDate;        
        let isShowToast = this.isConsentNecessary(opportunityDate,swcRequestedDate,swcGrantedDate);      
        if (this.numberOfDaysToExpire === 0) {
            this.warningMessage = warningMessageStart + "Today. " + warningMessageEnd;
        } else {
            this.warningMessage = this.numberOfDaysToExpire === 1 ? warningMessageStart + "in 1 day. " + warningMessageEnd : warningMessageStart + "in " + this.numberOfDaysToExpire + " days. " + warningMessageEnd;
        }
        return isShowToast;
    }

    isConsentNecessary(opportunityDate,swcRequestedDate,swcGrantedDate){
        let isConsentNotRunning = !(swcRequestedDate !== null && (swcGrantedDate === null || new Date(swcGrantedDate) > new Date(TODAYS_DATE)));
        let dateToCalculate = (swcGrantedDate !== null && new Date(swcGrantedDate) <= new Date(TODAYS_DATE)) ? swcGrantedDate : opportunityDate;        
        this.calculateDaysToExpire(new Date(dateToCalculate));        
        return isConsentNotRunning && this.numberOfDaysToExpire >= 0;       
    }
    
    calculateDaysToExpire(dateToCalculate){
        dateToCalculate = new Date(dateToCalculate.setDate(dateToCalculate.getDate() + 89));
        let calculatedDays = new Date(dateToCalculate) - new Date(TODAYS_DATE);            
        this.numberOfDaysToExpire = Math.ceil(calculatedDays / (1000 * 3600 * 24));
    }

    getAgentRelation(accountId){
        retrieveAgentRelation({accountId:accountId})
        .then(data => {
            this.isProspectRelation = data.isProspect;
            this.isSwcToggleOff = data.isToggleOff;
            this.usrTyp = data.userType;

            this.isAgentAtmUser = ALLOWED_USER_TYPE_LIST.includes(this.usrTyp);
            this.isSupportUser = this.usrTyp === 'Corporate Support';
            this.showToast();
        })
        
    }

    showSignedWrittenConsent() {
        this.closeToast();
        this.findModal().show();
    }

    showToast() {        
        if ((this.isSupportUser || (this.isAgentAtmUser && this.isProspectRelation))  && this.isConsentRequired && this.signedWrittenConsentStatus !== "Requested" &&
        !OPPORTUNITY_STAGE_LIST.includes(this.opportunityDataResult.data.fields.StageName.value) && this.isSwcToggleOff) {
            this.displayToast = true;
            this.minDate = formatDate(
            new Date(new Date().setDate(new Date().getDate() + this.numberOfDaysToExpire + 1))
        );
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
            this.closeToast();
        }, this.autoCloseTime);        
        }        
    }

    closeToast() {
        this.displayToast = false;
    }

    handleClose() {
      this.findModal().hide();
    }

    handleRefresh() {
        refreshApex(this.opportunityDataResult);
    }

    findModal() {
      return this.template.querySelector('[data-id="singnedWrittenConsentModal"]');
  }
}

//APEX
public with sharing class HLPR_SignedWrittenConsent {
    
    private static final String CLASS_NAME = 'HLPR_SignedWrittenConsent';
    private static final String METHOD_NAME = 'processConsentOnOpportunityCreate';
    private static final String TASK_STATUS_CANCELLED  = 'Cancelled';
    
    
    //wrapper class to store the campaignmember query response.    
    public with sharing class SignedWrittenConsentResponse {
        @AuraEnabled
        public String userType = '';
        @AuraEnabled
        public Boolean isProspect = false;
        @AuraEnabled
        public Boolean isToggleOff = false;
        
    }
    /**
    * @method- Invoked by  OpportunityAfterInsert Trigger           
     
    public static void processConsentOnOpportunityCreate(List<Opportunity> opportunityList) {
        try{
            if(!isSignedWrittenConsentToggleOn()) {
                Map<Id,Opportunity> accountIdToOpportunityMap = getAccountIdToOpportunityMap(opportunityList);
                getAccountOpportunityListAndProcessNextSteps(accountIdToOpportunityMap);
            }
        }
        catch(Exception opptyAfterInsertException){
            LoggingService.logHandledException(opptyAfterInsertException, CLASS_NAME, METHOD_NAME, LoggingLevel.ERROR);
        }
    }
    
    //Helper method to get account id to opportunity map
    private static Map<Id,Opportunity> getAccountIdToOpportunityMap(List<Opportunity> opportunityList){           
        Map<Id,Opportunity> accountIdToOpportunityMap = new Map<Id,Opportunity>();
        for(Opportunity opptyRecord : opportunityList){      
            accountIdToOpportunityMap.put(opptyRecord.AccountId,opptyRecord);
        }
        return accountIdToOpportunityMap;
    }
    
    //Helper method to get accounts and opportunites list to process
    private static void getAccountOpportunityListAndProcessNextSteps(Map<Id,Opportunity> accountIdToOpportunityMap){
        List<Account> accountToUpdateList = new List<Account>();
        List<Opportunity> opportunityToUpdateList = new List<Opportunity>();
        List<Opportunity> opportunityToProcessList = new List<Opportunity>();
        Set<String> opportunityStageSet = new Set<String>{'Closed', 'Closed Won'};
        for(Account acctRecord : [Select Id,SignedWrittenConsentGrantedDate__c,SignedWrittenConsentRequestedDate__c,
                                  SignedWrittenConsentStatus__c, (Select id,DateCaptured__c from Opportunities where StageName Not IN: opportunityStageSet) from Account 
                                  where Id IN :accountIdToOpportunityMap.keySet() AND persondonotcall = true AND BillingState = 'TX']){
            opportunityToUpdateList.addAll(acctRecord.Opportunities);
            opportunityToProcessList.add(accountIdToOpportunityMap.get(acctRecord.Id));
            accountToUpdateList.add(acctRecord);                      
         }
        updateDateCapturedInOpportunities(opportunityToUpdateList);
        updateSWCValuesInAccounts(accountToUpdateList);
        createSignedWrittenConsent(opportunityToProcessList);
        cancelSwcTasks(accountToUpdateList);     
    }
    
    //Helper method to update date captured field value in opportunities except closed and closed won opportunities
    private static void updateDateCapturedInOpportunities(List<Opportunity> opportunityToUpdateList){
        for(Opportunity opptyRecord : opportunityToUpdateList){
            opptyRecord.DateCaptured__c = System.today();
        }    
        if(!opportunityToUpdateList.IsEmpty() && Schema.sObjectType.Opportunity.isUpdateable()){
            Database.update(opportunityToUpdateList,false);
        }
    }
    
    //Helper method to update swc date field values in account
    private static void updateSWCValuesInAccounts(List<Account> accountToUpdateList){
        for(Account acct : accountToUpdateList){
            acct.SignedWrittenConsentGrantedDate__c = null;
            acct.SignedWrittenConsentRequestedDate__c = null;
            acct.SignedWrittenConsentStatus__c = null;
            acct.Edit_In_VFP__c = true;              
        }
        if(!accountToUpdateList.IsEmpty() &&Schema.sObjectType.Account.isUpdateable()){
            update accountToUpdateList;
        }
    }
    
    //Helper method to create signed written consent records
    private static void createSignedWrittenConsent(List<Opportunity> opportunityToProcessList){
        List<SignedWrittenConsent__c> signedWrittenConsentList = new List<SignedWrittenConsent__c>();
        for(Opportunity opptyRecord : opportunityToProcessList){
            SignedWrittenConsent__c signedWrittenConsentRecord = new SignedWrittenConsent__c();
            signedWrittenConsentRecord.InitiatedFromId__c = opptyRecord.Id;
            signedWrittenConsentRecord.Account__c = opptyRecord.AccountId;
            signedWrittenConsentRecord.Status__c = 'Opportunity Created';
            signedWrittenConsentList.add(signedWrittenConsentRecord);
        }
        if(!signedWrittenConsentList.IsEmpty() && Schema.sObjectType.SignedWrittenConsent__c.isCreateable()){
            insert signedWrittenConsentList;
        }
    }
    
    //Helper method to query swc tasks
    private static void cancelSwcTasks(List<Account> accountList){
        List<Task> taskToCancelList = new List<Task>();
        for(Task taskToCancel : [Select Id from Task where AccountId IN:accountList AND Isclosed = false
                                 AND Subject = 'Signed Written Consent Granted']){
            taskToCancel.Status = TASK_STATUS_CANCELLED;
            taskToCancelList.add(taskToCancel);                         
        }        
        updateTasks(taskToCancelList);        
    }
    
    //Helper method to cancel tasks
    private static void updateTasks(List<Task> taskList)
    {
        if(!taskList.isEmpty())
        {
            update taskList;
        }
    }
    
    /**
    * @method- Invoked by SignedWrittenConsentBeforeUpdate Trigger and used in Opportunity  Create Swc flow
    * @description  This helps us to verify signed written consent toggle.
   
    public static Boolean isSignedWrittenConsentToggleOn(){
        Boolean isToggleOn = false;
        List<Toggle__c> toggleList = [Select Status__c from Toggle__c where FeatureName__c = 'SignedWrittenConsent' WITH SECURITY_ENFORCED LIMIT 1];
        if(!toggleList.isEmpty()){
            isToggleOn = toggleList[0].Status__c;
        }
        return isToggleOn;
    }
    
    
    public static Boolean isProspectAccount(Id accountId){
        List<AgentRole__c> agentRoleList = [Select Id,RelationshipNature__c from AgentRole__c where Customer__c = :accountId AND Agent__r.UserExternalID__c = :getLoggedInUserInfo().Servicing_Agent_External_ID__c];
		return agentRoleList != null && !agentRoleList.isEmpty() && agentRoleList[0].RelationshipNature__c != 'Customer';
    }
    
    private static User getLoggedInUserInfo(){
        return [Select id,Servicing_Agent_External_ID__c,UserType__c from user where id = :UserInfo.getUserId()];
    }
    
    @AuraEnabled(cacheable = true)
    public static SignedWrittenConsentResponse signedWrittenConsentToast(Id accountId){
        SignedWrittenConsentResponse signedWrittenConsentResponse = new SignedWrittenConsentResponse();
        User loggedInUserDetails = getLoggedInUserInfo();
        signedWrittenConsentResponse.userType = loggedInUserDetails.UserType__c;
        signedWrittenConsentResponse.isToggleOff = !isSignedWrittenConsentToggleOn();
        signedWrittenConsentResponse.isProspect = isProspectAccount(accountId);
        
        return signedWrittenConsentResponse;
    }
}

*/
}