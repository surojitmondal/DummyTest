Public class CModal{
/*
https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_create_record
https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.data_salesforce_write
//HTML
<template>
        <template if:true={showModal}>
            <section
                role="dialog"
                tabindex="-1"
                aria-labelledby="modal-heading-01"
                aria-modal="true"
                aria-describedby="modal-content-id-1"
                class="slds-modal slds-fade-in-open" style="outline: none;"
            >
                <div class="slds-modal__container" style={modalWidth}>
                    <header class="slds-modal__header">
                        <lightning-button-icon
                            class="slds-modal__close"
                            title="Close"
                            icon-name="utility:close"
                            icon-class="slds-button_icon-inverse"
                            onclick={handleDialogClose}
                        ></lightning-button-icon>
    
                        <template if:true={hasHeaderString}>
                            <h2
                                class="slds-text-heading_medium slds-hyphenate header-string"
                            >
                                {header}
                            </h2>
                        </template>
                        <template if:false={hasHeaderString}>
                            <h2
                                class="slds-text-heading_medium slds-hyphenate header-slot"
                            >
                                <slot name="header"></slot>
                            </h2>
                        </template>
    
                        <p class="slds-m-top_x-small modal-hidden">
                            <slot
                                name="tagline"
                                onslotchange={handleSlotTaglineChange}
                            ></slot>
                        </p>
                    </header>
                    <div
                        class="slds-modal__content slds-p-around_medium"
                        id="modal-content-id-1"
                    >
                        <slot></slot>
                    </div>
    
                    <footer class="slds-modal__footer modal-hidden">
                        <slot
                            name="footer"
                            onslotchange={handleSlotFooterChange}
                        ></slot>
                    </footer>
                </div>
            </section>
            <template if:false = {backdropModal}>
                <div class="slds-backdrop slds-backdrop_open"></div>
            </template>            
        </template>
    </template>
//Javascript
import { LightningElement, api, track } from 'lwc';
import 'c/checkBrowser';

const CSS_CLASS = 'modal-hidden';

export default class Modal extends LightningElement {
    @api
    showModal = false;
    widthStyle="";
    @api backdropModal = false;

    set header(value) {
        this.hasHeaderString = value !== '';
        this._headerPrivate = value;
    }
    @api
    get header() {
        return this._headerPrivate;
    }
    
    set modalWidth(value){
        this.widthStyle = "max-width:" + value + "%; width:"+value + "%;";
    }
    @api 
    get modalWidth(){
        return this.widthStyle;
    }
    @track hasHeaderString = false;
    _headerPrivate;

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    handleDialogClose() {
        //Let parent know that dialog is closed (mainly by that cross button) so it can set proper variables if needed
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        this.hide();
    }

    handleSlotTaglineChange() {
        const taglineEl = this.template.querySelector('p');
        taglineEl.classList.remove(CSS_CLASS);
    }

    handleSlotFooterChange() {
        const footerEl = this.template.querySelector('footer');
        footerEl.classList.remove(CSS_CLASS);
    }
}

//CSS
.modal-hidden {
    display: none;
}
.slds-modal__container {
    margin: 0 auto;
    width: min-content;
    max-width: 40rem;
    min-width: 20rem;
}
.slds-modal__content{
    overflow: initial !important;
}

//Example LWC using CModal
template>
    <div data-id="startStopModal">
        <lightning-spinner if:true={loading} size="medium" variant="brand" alternative-text="Loading" style = "top:50%;bottom:50%"></lightning-spinner>
        <template if:false={loading}>
            <c-modal data-id="stopJourneyModal" header={header} modal-width={modalWidth} show-modal={displayModal}
                    backdrop-modal={backdropModal} onclosedialog = {handleCancel}>
                    <template if:true={journeyDataResult}>
                    <!--Start/Stop Journey ERROR MSG Section start-->               
                    <template if:true={errorMessage}>
                        <div data-id = "errorPanel" class="slds-notify__content slds-grid slds-wrap" style="display:inline-block;">
                            <div class="slds-size_2-of-2">
                                <div class="slds-box_x-small slds-text-align_left slds-theme_error">
                                    {errorMessage}
                                </div>
                            </div>
                        </div><br/>
                    </template>
                    <!--Start/Stop Journey ERROR MSG Section End-->
                    <template if:true={journeyId}>
                        <div data-id="stopJourneyContent">
                            <p>Are you sure you want to stop the Journey?</p>
                            <lightning-button-group>
                                <lightning-button data-id="stopJourneyButtonYes" disabled={startStopJourneyDisabled} variant="brand" label="Yes" onclick={handleStopJourney}></lightning-button>
                                <lightning-button data-id="stopJourneyButtonNo" label="No" onclick={handleCancel}></lightning-button>
                            </lightning-button-group>
                        </div>
                    </template>
                    <template if:true={displayStartJourney}>
                        <c-campaign-journey
                        data-id="startJourneyContent"
                        record-id={recordId}
                        record-type-name={recordTypeName}
                        total-members={totalMembers}
                        is-custom-demographics={isCustomDemographics}
                        is-submit-action-disabled={startStopJourneyDisabled}
                        onrefreshtab={handleRefresh}>
                        </c-campaign-journey>
                    </template>
                </template>
                </c-modal>
        </template>
    </div>
</template>

//JS
import { LightningElement, api, track } from 'lwc';
import retrieveSObjects from '@salesforce/apex/SObjectRetrieveController.retrieveSObjectsNotCacheable';
import 'c/checkBrowser';
import stopJourneyFromlWC from '@salesforce/apex/AP_StopJourney.stopJourneyFromlWC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { fireEvent } from 'c/eventRegistration';
import { buildEventName,events } from 'c/campaignConstants';

const JOUNREY_STOPPED_SUCCESS = 'Campaign Journey Stopped Successfully';
const JOURNEY_STOPPED_ERROR = "An unexpected error has occurred. Please contact your normal support channel for assistance.";
const DISABLE_STARTSTOP_JOURNEY_PROFILES = ['1.07 Technical Support', '1.08 Business Support'];
const SUPPORT_USERS_DISABLED_MESSAGE = "Start/Stop Journey Action is disabled for support users at this time.";
const CUSTOM_DEMOGRAPHICS_MESSAGE = "Journeys aren’t allowed on Campaigns with Custom Demographics.";
const DISABLE_STARTSTOP_STATUSES = ['Fulfillment Pending', 'Fulfillment Failed'];
const DISABLE_INVALID_STATUS_MESSAGE = "Journeys aren’t allowed on Campaigns with Status Fulfillment Pending/Failed or No Campaign Members.";

export default class JourneyStartStop extends LightningElement {
    @api recordId;
    @api objectApiName;
    header = "Start Journey";
    modalWidth;
    displayModal = false;
    backdropModal = false;
    @api sourceQuickAction = false;
    @api loggedInUserProfileName;
    @api startStopJourneyDisabled = false;
    @api isRendered = false;

    @api totalMembers;
    @api isCustomDemographics = false;
    @api recordTypeName;
    @api campaignStatus;
    @track loading = true;
    @track journeyId;
    @track errorMessage;
    journeyRequest;
    journeyDataResult;
    displayStartJourney;

    renderedCallback() {
        if (!this.isRendered) {
            if(this.sourceQuickAction) {
                this.backdropModal = true;
            }
            this.journeyRequest = buildRequest({ recordId: this.recordId, objectApiName: this.objectApiName});
            this.retrieveSObjects();
        }
        this.isRendered = true;
    }

    retrieveSObjects(){
        retrieveSObjects({request:this.journeyRequest})
        .then(result => {
            this.journeyDataResult = result;
            if (result.sobjects.length>0) {
                this.campaignStatus = result.sobjects[0].Status;
                this.isCustomDemographics = result.sobjects[0].Is_Custom_Demographics__c;
                this.journeyId = result.sobjects[0].Journey_ID__c;
                this.totalMembers = result.sobjects[0].Total_Number_Members__c;
                this.recordTypeName = result.sobjects[0].RecordType.DeveloperName;
                this.handleInitialJourneyValidations();
                this.disableStartStopJourney();
                this.loading = false;
            } else  {
                this.displayModal = true;
                this.loading = false;
                this.errorMessage = JOURNEY_STOPPED_ERROR;
                }
            })
    }

    handleInitialJourneyValidations() {
        if(this.totalMembers ===0 || DISABLE_STARTSTOP_STATUSES.includes(this.campaignStatus)) {
            this.showToastEvent("", DISABLE_INVALID_STATUS_MESSAGE, "error");
            this.handleCancel();
        } else if(this.isCustomDemographics) {
            this.showToastEvent("", CUSTOM_DEMOGRAPHICS_MESSAGE, "error");
            this.handleCancel();
        } else {
            this.displayModal = true;
            if(this.journeyId) {
                this.header = "Stop Journey";
                this.modalWidth = this.sourceQuickAction? "75":"30";
            } else {
                this.modalWidth = this.sourceQuickAction? "130":"53";
                this.displayStartJourney = true;
            }
        }
    }

    handleStopJourney() {
        this.loading = true;
        stopJourneyFromlWC({ campaignId: this.recordId})
        .then(result => {
            this.loading = false;
            if (result) {
                this.showToastEvent("", JOUNREY_STOPPED_SUCCESS, "success");
                this.handleCancel();
                this.handleRefresh();
            } else {
                this.showToastEvent("", JOURNEY_STOPPED_ERROR, "error");
                this.handleCancel();
            }
        });
    }

    handleCancel() {
        this.dispatchEvent(buildCancelEvent());
    }

    handleRefresh() {
        if(!this.sourceQuickAction) {
            fireEvent(buildEventName(this.recordId, events.CAMPAIGN_PATH_REFRESH));
        }
        refreshApex(this.journeyDataResult);
        this.dispatchEvent(new CustomEvent('refreshtab'));
    }

    disableStartStopJourney() {
        if (DISABLE_STARTSTOP_JOURNEY_PROFILES.includes(this.loggedInUserProfileName)) {
            this.startStopJourneyDisabled = true;
            this.errorMessage = SUPPORT_USERS_DISABLED_MESSAGE;
        }
    }

    showToastEvent(title,message,variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}

function buildRequest(data) {
    return {
        sobjectName: data.objectApiName,
        fieldNames: ['Journey_ID__c', 'RecordType.DeveloperName', 'Total_Number_Members__c', 'Is_Custom_Demographics__c', 'Status'],
        filterCriteriaIn: [
            {
                enable: true,
                filterType: 'LIST_OF_STRING',
                filterFieldName: 'ID',
                queryNullValues: false,
                filterValues: [data.recordId]
            }
        ],
        queryLimit: 1
    };
}

function buildCancelEvent() {
    return new CustomEvent('cancel');
}

*/


}