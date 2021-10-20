public class UpdateOpportunitySwc{
/*
 {
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "type": "node",
            "request": "launch",
            "name": "Mocha Current File",
            "program": "${workspaceFolder}/node_modules/mocha/bin/_mocha",
            "args": [
                "--timeout",
                "999999",
                "--colors",
                "${file}"
            ],
            "console": "integratedTerminal",
            "internalConsoleOptions": "neverOpen"
        },
        {
            "name": "Debug Jest Tests",
            "type": "node",
            "request": "launch",
            "runtimeArgs": [
                "--inspect-brk",
                "${workspaceRoot}/node_modules/jest/bin/jest.js",
                "--runInBand"
            ],
            "console": "integratedTerminal",
            "internalConsoleOptions": "neverOpen",
            "port": 9229
        },
        {
            "type": "node",
            "request": "launch",
            "name": "Launch Program",
            "skipFiles": [
                "<node_internals>/**"
            ],
            "program": "${workspaceFolder}\\index.js"
        }
    ]
}
 //HTML
 <template>
      <c-modal data-id='quickOpportunityModal'>
        <div style='width:600px;' data-id="noIconDiv23423534">
          <c-l-w-c_-new-opportunity-workflow
          guided={guided}
          opp-org={role} 
          isdesktop={isDesktop}
          account-id={accountId} 
          campaign-id={recordId}
          oncancelclicked={handleNewOpportunityCancel}
          onresetclicked={handleNewOpportunityReset}
          oncloseclicked={handleNewOpportunitySave}
        >
        </c-l-w-c_-new-opportunity-workflow>
      </div>
    </c-modal>
</template>

//Js
 
 import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { registerListener, fireEvent } from 'c/eventRegistration';
import { events, buildEventName } from 'c/campaignConstants';
import 'c/checkBrowser';

export default class QuickOpportunityModal extends NavigationMixin(LightningElement) {
    @api recordId
    @track role = 'Agent/Team Member' 
    @track guided = false;
    @track isDesktop = true;
    @track accountId;
    @track campaignMemberId;
    @track campaignMemberName;

    connectedCallback() {
        registerListener(buildEventName(this.recordId,events.QUICK_OPPORTUNITY), this.initialize, this)
    }
    findModal() {
        return this.template.querySelector("c-modal[data-id='quickOpportunityModal']");
    }
    initialize(event) {
        this.accountId = event.detail.accountId;
        this.campaignMemberId = event.detail.campaignMemberId;
        this.campaignMemberName = event.detail.campaignMemberName;
        this.findModal().show();
    }
    handleNewOpportunityCancel() {
        this.findModal().hide();
    }
    async handleNewOpportunityReset() {
        await this.findModal().hide();
        this.findModal().show();
    }
    handleNewOpportunitySave(event) {
        this.findModal().hide();
        if (event.detail.result.length > 0) {
            for (let i = 0; i < event.detail.result.length; i++) {
                this.openNewRecordTab(event.detail.result[i].Id, 'Opportunity', 'view');
            }
            this.openNewRecordTab(event.detail.result[0].Id, 'Opportunity', 'view');
            if (event.detail.whichButton === 'saveAndOpenUrl') {
                this.openProductSelectionPage(event.detail.result[0].AccountId, event.detail.result[0].Id, event.detail.result[0].LOB__c)
            }
            let campaignMemberDetails = {
                detail: {
                    campaignMemberId: this.campaignMemberId,
                    campaignMemberName: this.campaignMemberName
                }
            }
            fireEvent(buildEventName(this.recordId, events.QUICK_OPPORTUNITY_CREATED_SUCCESS), campaignMemberDetails)
        }
    }
    openProductSelectionPage(accountId, opportunityId, lob) {
        let url = '/apex/VFP_ExternalLink?linkId=88&accountId=' + accountId + '&opportunityId=' + opportunityId + '&lob=' + lob + '&newStageName=Quoting';
        window.open(url);
    }
    openNewRecordTab(opportunityId, objectApiName, actionName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: opportunityId,
                objectApiName: objectApiName,
                actionName: actionName
            }
        });
    }
}
 
 
 //Jest Test
 it('hides quick opportunity modal when cancel button is clicked', () => {
        const element = createCustomElement();
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            fireEvent(buildEventName(RECORD_ID, events.QUICK_OPPORTUNITY), campaignMemberDetails);
        }).then(() => {

            const newOpportunityWorkflow = element.shadowRoot.querySelector('c-l-w-c_-new-opportunity-workflow');
            newOpportunityWorkflow.dispatchEvent(new CustomEvent('cancelclicked'));
        }).then(() => {
            const newOpportunityWorkflow = element.shadowRoot.querySelector('c-l-w-c_-new-opportunity-workflow');
            expect(newOpportunityWorkflow).toBeNull();
        });
    });

*/
}