public class VFP_Page{
/*<apex:page standardController="Account" extensions="VFC_PoliciesBillingClaimsTabController" action="{!init}" standardStylesheets="false" docType="html-5.0" showQuickActionVfHeader="false" showHeader="false" sidebar="false" applyHtmlTag="false">
    <div class="slds" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <meta charset="utf-8" />
        <meta http-equiv="x-ua-compatible" content="ie=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <!-- Error section for policy create task -->
        <div id="policyTaskErrorDialog" style="display:none;text-align:center;">
            <div aria-hidden="false" role="dialog" class="slds-modal slds-modal_prompt slds-fade-in-open">
                <div class="slds-modal__container slds-modal_prompt">
                    <div id="policyTaskErrorBody" style="position:relative;z-index:2;border: 2px solid #00396b;">
                        <div class="slds-modal__content slds-p-around_medium" style="background-color:#efefef;padding-bottom:0.1rem;">
                              <div style="font-weight:bold; font-size: 14px;"><p>{!$Label.CL_POLICY_CREATE_TASK_ERROR}</p></div>
                        </div>
                        <div class="slds-modal__footer slds-theme_default" style="background-color:#efefef;">
                            <button id="policyTaskErrorBtn" onclick="hidePopup('policyTaskErrorDialog');return false;" class="slds-button slds-button_brand">{!$Label.CL_OK_BUTTON}</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="slds-backdrop slds-backdrop_open" style="background-color:#3a699259;"></div>
        </div>

        <apex:outputPanel rendered="{!NOT(summaryViewAccess.StateFarm_Products__c || summaryViewAccess.Billing_Summary__c || summaryViewAccess.Claim_Summary__c || summaryViewAccess.ABS_Activities_Summary__c || summaryViewAccess.ProductsServicedByMe__c || summaryViewAccess.ProductsWithOthers__c)}" id="noTabMsg" layout="block" style="margin-top:1px;margin-left:5px;">
            <p><strong>{!$Label.CL_FEATURE_DOWN}</strong></p>
        </apex:outputPanel>

        <apex:form >
            <apex:actionFunction name="callPolicies" action="{!fetchPolicies}" reRender="policies1" status="statusId"/>
            <apex:actionFunction name="callBillings" action="{!fetchBillings}" reRender="billings1" status="statusId"/>
            <apex:actionFunction name="callClaims" action="{!fetchClaims}" reRender="claims1" status="statusId"/>
            <apex:actionFunction name="callActivities" action="{!fetchActivities}" reRender="activities1" status="statusId"/>
            <apex:actionFunction name="callRemark" action="{!fetchRemark}" reRender="remarks1" status="statusId" >
                <apex:param id="actID" name="actID" value=""/>                 
            </apex:actionFunction>
            <apex:actionFunction name="callComplete" action="{!completeActivity}" reRender="activities1" status="statusId" oncomplete="clearCompleteMessage();">
                <apex:param id="actvID" name="actvID" value=""/>                 
            </apex:actionFunction>
            <apex:actionFunction name="callClearCompleteMSG" action="{!clearCompleteMessage}" reRender="hiddenSpace" status="statusId"/>
            <apex:actionFunction name="clearLists" action="{!clearLists}" reRender="ProductsSubTab" />
            <!-- Case creation Action Function -->
            <apex:actionFunction name="caseCreationForPolicyTransaction" action="{!caseCreationForPolicyTransaction}" status="statusId" rerender="launchCaseAfterCreation">
                <apex:param id="selectedPolicyActionValue" name="selectedPolicyActionValue" value="" assignTo="{!selectedPolicyActionValue}"/>
                <apex:param id="selectedPolicyLOB" name="selectedPolicyLOB" value="" assignTo="{!selectedPolicyLOB}"/>
                <apex:param id="selectedPolicyNumber" name="selectedPolicyNumber" value="" assignTo="{!selectedPolicyNumber}"/>
                <apex:param id="selectedPolicyAgentAssocID" name="selectedPolicyAgentAssocID" value="" assignTo="{!this.selectedPolicyAgentAssocID}" />
                <apex:param id="selectedPolicyClientID" name="selectedPolicyClientID" value="" assignTo="{!this.selectedPolicyClientID}" />
            </apex:actionFunction>

            <!-- Create Task Action Function -->
            <apex:actionFunction name="taskCreationForPolicyTransaction" action="{!taskCreationForPolicyTransaction}" status="statusId" rerender="afterTaskSaveActionId">
                <apex:param name="selectedPolicyLOB" value="" assignTo="{!this.selectedPolicyLOB}"/>
                <apex:param name="selectedPolicyAgentAssocID" value="" assignTo="{!this.selectedPolicyAgentAssocID}" />
                <apex:param name="selectedPolicyClientID" value="" assignTo="{!this.selectedPolicyClientID}" />
                <apex:param name="selectedPolicyNumber" value="" assignTo="{!this.selectedPolicyNumber}" />
                <apex:param name="selectedPolicyDescription" value="" assignTo="{!this.selectedPolicyDescription}" />
            </apex:actionFunction>

            <!---Spinner---->
            <apex:actionStatus id="statusId" onstop="resizeOverlay();">
                <apex:facet name="start">
                    <div class="waitingHolder" style="height: 100%;opacity:0.65;width: 100%; position: fixed; z-index: 9999;">
                        <div class="slds-spinner_container">
                            <div class="slds-spinner_brand slds-spinner slds-spinner_medium" aria-hidden="false" role="alert">
                                <span class="slds-assistive-text">{!$Label.CL_Loading}</span>
                                <div class="slds-spinner__dot-a"></div>
                                <div class="slds-spinner__dot-b"></div>
                            </div>
                        </div>
                    </div>
                </apex:facet>
            </apex:actionStatus>
            
            <div class="slds">
                <div id="remarks" class="slds-hide">
                    <apex:outputPanel id="remarks1">
                        <div id="remarksOverlay" onclick="hideRemark();" ></div>
                        <!-- Activity Remarks-->
                        <div id="remarksBody">
                            <a id="xRemarksTheSpot" onclick="hideRemark();">X</a>
                            <h3>Remarks:</h3>
                            <p>{!remarksErrorMessage}</p>
                            <div id="remarksText">
                                <apex:repeat value="{!remarksList}" var="remark">
                                    <p>{!remark.remark}<br/></p>
                                </apex:repeat>
                            </div>
                        </div>
                    </apex:outputPanel>
                </div>
                <div id="saveQuoteErrorDialog" style="display:none;text-align:center;" layout="block">
                    <div aria-hidden="false" role="dialog" class="slds-modal slds-modal--prompt slds-fade-in-open">
                        <div class="slds-modal__container slds-modal--prompt">
                            <div id="CompBody">
                                <div class="slds-modal__content slds-p-around--medium">
                                    <div style="font-weight:bold; font-size: 14px"><p>{!$Label.CL_WorkersComp}</p></div>
                                </div>
                                <div class="slds-modal__footer slds-theme--default">
                                    <button id="saveQuoteErrorBtn" onclick="hidePopup('saveQuoteErrorDialog');return false;" class="slds-button slds-button--brand">OK</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="slds-backdrop slds-backdrop--open"></div>
                </div>
                <!-----TABS----->
                <div class="slds-tabs_default">
                    <div id="slds-tabs" >
                        <ul class="slds-tabs_default__nav" role="tablist">
                            <li id="ProductsTab" class="slds-show slds-tabs_default__item slds-text-heading_small slds-active" title="Click here to view Products" role="presentation">
                                <a class="slds-tabs_default__link" href="" role="tab" tabindex="0" aria-selected="true" aria-controls="tab-default-1" id="tab-default-1__item" onclick="selectTab(this,'policies');">
                                    Products
                                </a>
                            </li>
                            <li id="BillingTab" class="slds-show slds-tabs_default__item slds-text-heading_small" title="Click here to view Billing" role="presentation">
                                <a class="slds-tabs_default__link" href="" role="tab" tabindex="-1" aria-selected="false" aria-controls="tab-default-2" id="tab-default-2__item" onclick="selectTab(this,'billings');">
                                    Billing
                                </a>
                            </li>
                            <li id="ClaimsTab" class="slds-show slds-tabs_default__item slds-text-heading_small" title="Click here to view Claims" role="presentation">
                                <a class="slds-tabs_default__link" href="" role="tab" tabindex="-1" aria-selected="false" aria-controls="tab-default-3" id="tab-default-3__item" onclick="selectTab(this,'claims');">
                                    Claims
                                </a>
                            </li>
                            <li id="ABSActivitiesTab" class="slds-show slds-tabs_default__item slds-text-heading_small" title="Click here to view ABS Activities" role="presentation">
                                <a class="slds-tabs_default__link" href="" role="tab" tabindex="-1" aria-selected="false" aria-controls="tab-default-4" id="tab-default-4__item" onclick="selectTab(this,'activities');">
                                    ABS Activities
                                </a>
                            </li>
                        </ul>
                        <input id="dropdown" TYPE="button" style="display:none;" onclick="toggleMobileTabs()"  /> 
                        <!-- ABS URL To Activity Summary -->
                        <apex:outputPanel id="absURLPanel">
                            <a id="absURL" onClick = "redirectToGateway('{!JSENCODE(requiredGatewayParameters)}');" class="slds-hide" style="position:relative;zindex:-1;">Go to ABS Customer Activity Management</a> 
                        </apex:outputPanel>
                        <apex:outputPanel id="refreshPanel">                          
                            <input id="refresh" TYPE="button" class="slds-hide" Value="Refresh" onclick="goToRefresh()"  /> 
                        </apex:outputPanel>
                    </div>
                    <div id="tab-default-1" class="slds-tabs_default__content slds-show" role="tabpanel" aria-labelledby="tab-default-1__item">
                        <div class="slds-tabs_scoped">
                            <div id="slds-subtabs" >
                                <ul class="slds-tabs_scoped__nav" role="tablist" >
                                    <li class="slds-tabs_scoped__item slds-active" title="State Farm Products" role="presentation" id="SFProductsTab">
                                        <a class="slds-tabs_scoped__link" onclick="selectSubTab(this,'statefarm');" href="" role="tab" tabindex="0" aria-selected="true" aria-controls="tab-scoped-1" id="tab-scoped-1__item">
                                            State Farm Products
                                        </a>
                                        </li> 
                                    <li class="slds-tabs_scoped__item" id = "ProductsServicedByMeTab" title="Products Serviced By Me" role="presentation">
                                        <a class="slds-tabs_scoped__link" onclick="selectSubTab(this,'servicedByMe');" href="" role="tab" tabindex="-1" aria-selected="false" aria-controls="tab-scoped-2" id="tab-scoped-2__item">
                                            Products Serviced By Me
                                        </a>
                                    </li>
                                    <li class="slds-tabs_scoped__item" id = "ProductWithOthersTab" title="Products With Others - Competitors" role="presentation">
                                        <a class="slds-tabs_scoped__link" onclick="selectSubTab(this,'withOthers');" href="" role="tab" tabindex="-1" aria-selected="false" aria-controls="tab-scoped-3" id="tab-scoped-3__item">
                                            Products With Others - Competitors
                                        </a>
                                    </li>    
                                </ul>
                            </div>
                            <div id="tab-scoped-1" class="slds-tabs_scoped__content slds-show" role="tabpanel" aria-labelledby="tab-scoped-1__item">
                                <apex:outputPanel id="policies1">
                                    <p class ="slds-text-body_regular slds-truncate" style="margin-top:5px">
                                        {!displayMessage}
                                    </p>
                                    <apex:outputPanel rendered="{!displayMessage ==''}">
                                        <table class="slds-table slds-table_bordered slds-table_cell-buffer slds-no-row-hover slds-scrollable slds-max-medium-table_stacked-horizontal">
                                            <thead>
                                                <tr class="slds-text-title">
                                                    <th scope="col">
                                                        <div title="Status">Status</div>
                                                    </th>
                                                    <th scope="col">
                                                        <div class="slds-cell-wrap" title="Line of Business">LOB</div>
                                                    </th>
                                                    <th scope="col">
                                                        <div title="Product Description">Product Description</div>
                                                    </th>
                                                    <th scope="col">
                                                        <div title="Policy Number">Policy Number</div>
                                                    </th>
                                                    <th scope="col">
                                                        <div class="slds-cell-wrap" title="Renewal Date">Renewal Date</div>
                                                    </th>
                                                    <th scope="col">
                                                        <div class="slds-cell-wrap" title="Termination Date">Termination Date</div>
                                                    </th>
                                                    <th scope="col">
                                                        <div title="Agent Name">Agent Name</div>
                                                    </th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                
                                                <apex:repeat value="{!policiesList}" var="policies" >
                                                    <tr>
                                                        <td scope="row" data-label="Status">
                                                            <div title="Status">
                                                                {!policies.status}
                                                            </div>
                                                        </td>
                                                        <td class="slds-cell-wrap" data-label="LOB">
                                                            <div title="Line of Business">
                                                                {!policies.lineOfBusiness}
                                                            </div>
                                                        </td>
                                                        <td data-label="Product Description">
                                                            <div title="Product Description">
                                                                {!policies.productDescription}
                                                            </div>
                                                        </td>
                                                        <td data-label="Policy Number">
                                                            <div  class="{!IF(isMobileContext==false,'slds-m-right_xx-large slds-size_1-of-2 ','none')}" style="display:inline-block;" title="Policy Number" >
                                                                <div style="display:inline-block;float:left">&nbsp;
                                                                    <apex:outputLink rendered="{!policies.isPolicyLinkDisplayed}"  target="_blank" onClick="launchPolicyBillingView('{!JSENCODE(policies.policyDetailsURLValue)}'); return false;" > {!policies.policyNumber} </apex:outputLink>                                                          
                                                                    <apex:outputText rendered="{!NOT(policies.isPolicyLinkDisplayed)}" > {!policies.policyNumber} </apex:outputText>
                                                                </div>
                                                                <div style="margin-left:1px;">
                                                                    <apex:selectList id="selectLstValue" size="1" rendered="{!NOT(isMobileContext) && policies.showPolicyDropDown}" multiselect="false" 
                                                                                     style="margin-left:10%; width:23px; height:17px;left:60%;position:absolute;"
                                                                                     onchange="performPolicyTransactions(this.value,'{!policies.status}','{!policies.policyActionsURLValue}','{!policies.lineOfBusiness}','{!policies.policyNumber}','{!policies.agentAssociateID}','{!isCCCLicensedUser}', '{!policies.clientID}', this.id, '{!policies.productDescription}')" >
                                                                        <apex:selectOptions value="{!policies.actionDropDownValues}" />
                                                                    </apex:selectList>
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td class="slds-cell-wrap" data-label="Renewal Date">
                                                            <div title="Renewal Date">
                                                                {!policies.nextRenewalDate}
                                                            </div>
                                                        </td>
                                                        <td class="slds-cell-wrap" data-label="Termination Date">
                                                            <div title="Termination Date">
                                                                {!policies.terminationDate}
                                                            </div>
                                                        </td>
                                                        <td data-label="Agent Name">
                                                            <div title="Agent Name">
                                                                <apex:outputLink rendered="{!IF(((policies.agentAssociateID = '8888' || policies.agentAssociateID = '9099') && (isAgentuser)) || (isMobileContext) || (policies.agentAssociateID = null),false,true)}" 
                                                                                 onClick="openAgentDetails('{!JSENCODE(policies.agentAssociateID)}','{!JSENCODE(policies.stateCodeValue)}','{!JSENCODE(policies.agentCodeValue)}', '{!IF(policies.sfoAgent, 'true', 'false')}','{!OR(isCCCLicensedUser, isCCCUnLicensedUser)}'); return false;" >
                                                                    {!policies.agentName}
                                                                </apex:outputLink> 
                                                                <apex:outputText rendered="{!(isMobileContext) || ((policies.agentAssociateID = '8888' || policies.agentAssociateID = '9099') && (isAgentuser)) || (policies.agentAssociateID = null) }" > {!policies.agentName} </apex:outputText> 
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </apex:repeat>
                                            </tbody>
                                        </table>
                                    </apex:outputPanel>
                                </apex:outputPanel>
                            </div>
                            <div id="tab-scoped-2" class="slds-tabs_scoped__content slds-hide" role="tabpanel" aria-labelledby="tab-scoped-2__item">
                                <c:C_ProductsServicedByMe customerIDInContext="{!accIdInContext}" customerGroupIdInContext="" displayMoreRecords="true" ProductsServicedByMeAccess="{!summaryViewAccess.ProductsServicedByMe__c}" createNewPSBM="{!summaryViewAccess.Create_New_PSBM__c}"/>
                            </div>
                            <div id="tab-scoped-3" class="slds-tabs_scoped__content slds-hide" role="tabpanel" aria-labelledby="tab-scoped-3__item">
                                <c:C_ProductsWithOthersCompetitors accIdInContext="{!accIdInContext}" accClntIdInContext="{!accClntIdInContext}" accMapByClntId="{!accMapByClntId}" customerGroupId="" ProductsWithOthers="{!summaryViewAccess.ProductsWithOthers__c}" createNewPWOC="{!summaryViewAccess.Create_New_PWOC__c}"/>
                            </div>
                        </div>
                    </div>
                    
                    <!----Billings Tab---->
                    <div id="tab-default-2" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="tab-default-2__item">
                        <apex:outputPanel id="billings1">
                            <p class ="slds-text-body_regular slds-truncate">
                                {!displayMessage}
                            </p>
                            
                            <apex:outputPanel rendered="{!displayMessage ==''}">
                                <table class="slds-table slds-table_bordered slds-table_cell-buffer slds-no-row-hover slds-scrollable slds-max-medium-table_stacked-horizontal">
                                    <thead>
                                        <tr class="slds-text-title">
                                            <th scope="col">
                                                <div title="Status">Status</div>
                                            </th>
                                            <th scope="col">
                                                <div title="Account Type">Account Type</div>
                                            </th>
                                            <th scope="col">
                                                <div title="Account Number">Account Number</div>
                                            </th>
                                            <th scope="col">
                                                <div title="Due Date">Due Date</div>
                                            </th>
                                            <th scope="col">
                                                <div title="Amount Due">Amount Due</div>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <apex:repeat value="{!billingsList}" var="billings">
                                            <tr>
                                                <td data-label="Status">
                                                    <div title="Status">
                                                        {!billings.status}
                                                    </div>
                                                </td>
                                                <td scope="row" data-label="Account Type">
                                                    <div title="Account Type">
                                                        {!billings.accountType}
                                                    </div>
                                                </td>
                                                <td data-label="Account Number">
                                                    <apex:outputLink rendered="{!(isABSViewed)}"  target="_blank" onClick="launchPolicyBillingView('{!JSENCODE(billings.billingDetailsURLValue)}'); return false;" >
                                                        {!billings.sfppAccountNumber}</apex:outputLink>
                                                    <apex:outputText rendered="{!NOT(isABSViewed)}" > {!billings.sfppAccountNumber} </apex:outputText> 
                                                </td>
                                                <td data-label="Due Date">
                                                    <div title="Due Date">
                                                        {!billings.dueDate}
                                                    </div>
                                                </td>
                                                <td data-label="Amount Due">
                                                    <div title="Amount Due">
                                                        {!billings.amountDue}
                                                    </div>
                                                </td>
                                            </tr>
                                        </apex:repeat>
                                    </tbody>
                                </table>
                            </apex:outputPanel>
                            
                            <apex:outputPanel rendered="{!summaryViewAccess.Create_New_SFPP__c}">
                                <apex:commandButton rendered="{!NOT(isMobileContext)}" value="New SFPP" title="New SFPP" styleClass="slds-button slds-button_stateful slds-button_neutral closeButton" style="margin-top:10px;font-weight:bold;"
                                                    onClick="launchNewSFPP('{!accIdInContext}', '{!selectedAgentContextAssociateID}','{!isCCCLicensedUser}'); return false;" />
                            </apex:outputPanel>
                        </apex:outputPanel>
                    </div>
                    
                    <!----Claims Tab---->
                    <div id="tab-default-3" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="tab-default-3__item">
                        <apex:outputPanel id="claims1">
                            <apex:outputPanel id="uploadPanel" rendered="{!(isABSViewed)}">
                                <apex:commandButton Value="Report Glass Claim" styleClass="standardButtons"
                                                    onclick="window.open('/apex/VFP_ExternalLink?LinkId=72','_blank','resizable=yes,top=300,left=100,bottom=100,width=1300,height=600,scrollbars=yes'); return false;"/>                                         
                            </apex:outputPanel>
                            <p class ="slds-text-body_regular slds-truncate">
                                {!displayMessage}
                            </p>
                            <apex:outputPanel rendered="{!displayMessage ==''}">
                                <table class="slds-table slds-table_bordered slds-table_cell-buffer slds-no-row-hover slds-scrollable slds-max-medium-table_stacked-horizontal">
                                    <thead>
                                        <tr class="slds-text-title">
                                            <th scope="col">
                                                <div title="Status">Status</div>
                                            </th>
                                            <th scope="col">
                                                <div title="Product Description">Product Description</div>
                                            </th>
                                            <th scope="col">
                                                <div title="Claim Number">Claim Number</div>
                                            </th>
                                            <th scope="col">
                                                <div title="Date of Loss">Date of Loss</div>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <apex:repeat value="{!claimsList}" var="claims">
                                            <tr>
                                                <td data-label="Status">
                                                    <div title="Status">
                                                        {!claims.claimStatus}
                                                    </div>
                                                </td>
                                                <td scope="row" data-label="Product Description">
                                                    <div title="Product Description">
                                                        {!claims.policyDescription}
                                                    </div>
                                                </td>
                                                <td data-label="Claim Number">
                                                    <div title="Claim Number">
                                                        <apex:outputLink rendered="{!AND( NOT(isMobileContext), (claims.toggle), (claims.isClaimDetailsRestricted), (isABSViewed))}" target="_blank" onClick="openClaimDetail('{!JSENCODE(claims.lOB)}','{!JSENCODE(claims.claimID)}', '{!JSENCODE(claims.claimNumber)}','{!JSENCODE(claims.clientID)}','{!IF(claims.displayWorkersComp, 'Workers', 'notWorkersComp')}'); return false;">
                                                            {!claims.claimNumber}
                                                        </apex:outputLink>
                                                        <apex:outputLink rendered="{!AND( NOT(isMobileContext), (claims.toggle), (claims.isClaimDetailsRestricted), NOT(isABSViewed))}" target="_blank" onClick="openClaimDetail('{!JSENCODE(claims.lOB)}','{!JSENCODE(claims.claimID)}', '{!JSENCODE(claims.claimNumber)}','{!JSENCODE(claims.clientID)}','{!IF(claims.displayWorkersComp, 'Workers', 'notWorkersComp')}'); return false;">
                                                            {!claims.claimNumber}
                                                        </apex:outputLink>
                                                        <apex:outputText rendered="{!OR(isMobileContext, NOT(claims.toggle), NOT(claims.isClaimDetailsRestricted)) }"> {!claims.claimNumber} </apex:outputText> 
                                                        
                                                        <apex:selectList rendered="{!NOT(OR(isMobileContext,isCCCLicensedUser, isCCCUnLicensedUser))}" size="1" title="Additional Details" style="margin-left: 10px; width:24px; height:17px; left:70px" onchange="launchAdditionalDetails(this.value, '{!claims.claimABSURLValue}')">
                                                            <apex:selectOptions value="{!additionalDetails}" />
                                                        </apex:selectList>
                                                    </div>
                                                </td>
                                                <td data-label="Date of Loss">
                                                    <div title="Date of Loss">
                                                        {!claims.dateOfLoss}
                                                    </div>
                                                </td>
                                            </tr>
                                        </apex:repeat>
                                    </tbody>
                                </table>
                            </apex:outputPanel>
                        </apex:outputPanel>
                    </div>
                    <!----Activities Tab---->
                    <div id="tab-default-4" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="tab-default-4__item">
                        <apex:outputPanel id="activities1" rendered="{!summaryViewAccess.ABS_Activities_Summary__c}">
                            <p id="fixedErrorBlock" class="{!activityErrorType} slds-text-body_regular slds-truncate" onclick="hideCompleteMessage();">
                                {!activityErrorMessage}
                            </p>
                            <p class ="slds-text-body_regular slds-truncate">
                                {!displayMessage}
                            </p>
                            <apex:outputPanel rendered="{!displayMessage ==''}">
                                <table class="slds-table slds-table_bordered slds-table_cell-buffer slds-no-row-hover slds-scrollable slds-max-medium-table_stacked-horizontal">
                                    <thead>
                                        <tr class="slds-text-title">
                                            <th scope="col">
                                                <div id="actsum_actions" title="Actions"></div>
                                            </th>
                                            <th scope="col">
                                                <div id="actsum_status" title="Status">Status</div>
                                            </th>
                                            <th scope="col">
                                                <div id="actsum_customer" title="Customer">Customer</div>
                                            </th>
                                            <th scope="col">
                                                <div id="actsum_description" title="Description">Description</div>
                                            </th>
                                            <th scope="col">
                                                <div id="actsum_lob" title="LOB">LOB</div>
                                            </th>
                                            <th scope="col">
                                                <div id="actsum_category" title="Category">Category</div>
                                            </th> 
                                            <th scope="col">
                                                <div id="actsum_duedate" title="Due Date">Due Date</div>
                                            </th>
                                            <th scope="col">
                                                <div id="actsum_modifieddate" title="Modified Date">Modified Date</div>
                                            </th>                                           
                                            
                                            <th scope="col">
                                                <div id="actsum_agentname" title="Agent Name">Agent Name</div>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <apex:repeat value="{!activitiesList}" var="activity">
                                            <tr> 
                                                <td scope="row" data-label="Actions" >                                                
                                                    <apex:outputPanel rendered="{!activity.displayCompleteButton}">
                                                        <input type="button" name="complete" value="Complete" onclick="completeActivity('{!JSENCODE(HTMLENCODE(activity.activityID))}');" style="cursor:pointer;" />
                                                    </apex:outputPanel>
                                                </td>
                                                <td scope="row" data-label="Status">
                                                    <div title="Status">
                                                        {!activity.status}
                                                    </div>
                                                </td> 
                                                <td scope="row" data-label="Customer">
                                                    <div title="Customer">
                                                        {!activity.customer}
                                                    </div>
                                                </td>
                                                <td scope="row" data-label="Description">
                                                    <div title="Show Remarks"  onclick="showRemark('{!JSENCODE(HTMLENCODE(activity.activityID))}');" style="cursor:pointer;">
                                                        <a>{!activity.description}</a>
                                                    </div>
                                                </td>
                                                
                                                <td scope="row" data-label="LOB">
                                                    <div title="LOB">
                                                        {!activity.lob}
                                                    </div>
                                                </td>
                                                <td scope="row" data-label="Category">
                                                    <div title="Category">
                                                        {!activity.category}
                                                    </div>
                                                </td>
                                                <td scope="row" data-label="Due Date">
                                                    <div title="Due Date">
                                                        {!activity.dueDate}
                                                    </div>
                                                </td>
                                                <td scope="row" data-label="Modified Date">
                                                    <div title="Modified Date">
                                                        {!activity.modifiedDate}
                                                    </div>
                                                </td>
                                                <td scope="row" data-label="Agent Name">
                                                    <div title="Agent Name">
                                                        {!activity.agentName}
                                                    </div>
                                                </td>
                                            </tr>
                                        </apex:repeat>
                                    </tbody>
                                </table>
                            </apex:outputPanel>
                        </apex:outputPanel>
                    </div>
                </div>
            </div>
            
            <apex:outputPanel id="launchCaseAfterCreation">
                <script>
                if('{!caseRecordId}' != null && '{!caseRecordId}' != ''){
                    var openSubtab = function openSubtab(result){                           
                        var primaryTabId = result.id;
                        sforce.console.openSubtab(primaryTabId , '/'+'{!caseRecordId}', true);                            
                    }
                    sforce.console.getEnclosingPrimaryTabId(openSubtab);                    
                } 
                </script>
            </apex:outputPanel>

            <!-- Output panel to execute after task creation for policy -->
            <apex:outputPanel id="afterTaskSaveActionId">
                <apex:outputPanel rendered="{!afterTaskSaveFlag}">
                    <script>
                        var taskSaveResultFlag = {!IF(taskErrorFlag, "true", "false")};
                        if(taskSaveResultFlag) {
                            j$("#policyTaskErrorDialog").show();
                        } else {
                            redirectToTaskEditPage("{!JSENCODE(taskRecordId)}", "{!JSENCODE(taskRecordAccountId)}");
                        }
                    </script>
               </apex:outputPanel>
            </apex:outputPanel>            
            <script type="text/javascript">
                var j$ = jQuery.noConflict();
                window.onresize = function(event) {
                    var elem = document.getElementById("dropdown");
                    var theCSSprop = window.getComputedStyle(elem,null).getPropertyValue("display");
                    if(theCSSprop == 'none') {
                        summaryViewTabsToggle(true);
                    } 
                           }
                
                function summaryViewTabsToggle(isShowElement){
                    if({!OR(summaryViewAccess.StateFarm_Products__c, summaryViewAccess.ProductsServicedByMe__c,summaryViewAccess.ProductsWithOthers__c)}) {
                        toggleTab(isShowElement, 'ProductsTab');
                    }
                    if({!IF(summaryViewAccess.Billing_Summary__c, "true", "false")}) {
                        toggleTab(isShowElement, 'BillingTab');
                    }
                    if({!IF(summaryViewAccess.Claim_Summary__c, "true", "false")}) {
                        toggleTab(isShowElement, 'ClaimsTab');
                    }
                    if({!IF(summaryViewAccess.ABS_Activities_Summary__c, "true", "false")}) {
                        toggleTab(isShowElement, 'ABSActivitiesTab');
                    }
                    if({!IF(summaryViewAccess.StateFarm_Products__c, "true", "false")}) {
                        toggleTab(isShowElement, 'SFProductsTab');
                    }
                    if({!IF(summaryViewAccess.ProductsServicedByMe__c, "true", "false")}) {
                        toggleTab(isShowElement, 'ProductsServicedByMeTab');
                    }
                    if({!IF(summaryViewAccess.ProductsWithOthers__c, "true", "false")}) {
                        toggleTab(isShowElement, 'ProductWithOthersTab');
                    }
                }
            
                function toggleTab(isShowElement, elementId){
                    if(isShowElement){
                        showElement("li[id="+elementId+"]");
                    }else{
                         j$('li[id='+elementId+']').toggleClass('slds-hide slds-show');
                    }
                }
                
                function resizeOverlay() {
                    var remarkYOffset = window.pageYOffset + j$("div[id='slds-tabs']").height() + 30;
                    j$("div[id='remarksBody']").css("top",remarkYOffset);
                    var remarkBottom = j$("div[id='remarksBody']").outerHeight()+ remarkYOffset;
                    var dynaHeight = j$("div[id='remarks']").closest("div.slds").height();
                    if(dynaHeight < remarkBottom){
                        dynaHeight = remarkBottom + 75;
                    }
                    j$("div[id='remarks']").children("span").children("div[id=remarksOverlay]").css("height",dynaHeight);
                }
                
                function hideRemark(){
                    hideElement("div[id='remarks'].slds-show");
                }
                
                function showRemark(activityID){
                    hideCompleteMessage();
                    var remarkYOffset = window.pageYOffset + j$("div[id='slds-tabs']").height() + 30;
                    j$("div[id='remarksBody']").css("top",remarkYOffset);
                    showElement("div[id='remarks'].slds-hide");
                    callRemark(activityID);
                }
                
                function completeActivity(activityID){
                    callComplete(activityID);
                }
                
                function hideCompleteMessage(){
                    j$("div.slds-tabs_default__content.slds-show.lowerTable").removeClass("lowerTable");
                    j$("p[id='fixedErrorBlock']").text("");
                    j$("p[id='fixedErrorBlock'].absActivity-Success").removeClass("absActivity-Success");
                    j$("p[id='fixedErrorBlock'].absActivity-Error").removeClass("absActivity-Error");
                }
                
                function clearCompleteMessage(){
                    j$("div.slds-tabs_default__content.slds-show").addClass("lowerTable");
                    callClearCompleteMSG();
                }
                
                function redirectToGateway(parameter){              
                    var gateway = '../apex/VFP_ExternalLink'+parameter;            
                    window.open(gateway);                
                }
                
                function goToRefresh(){
                    hideRemark();           
                    callActivities();
                    if({!IF(isMobileContext, "true", "false")}){
                        hideElement("li.slds-tabs_default__item:not(.slds-active)");
                    }
                }
                
                function toggleMobileTabs() {
                    summaryViewTabsToggle(false);
                    showElement("li.slds-tabs_default__item.slds-active");
                }
                
                j$(document).ready(function() {
                    toggleTabsByCSLocation();
                    if({!AND(summaryViewAccess.AutoLoadProductsOnAccountPage__c, summaryViewAccess.StateFarm_Products__c)}) {
                        callPolicies();
                    }
                });
    
                function toggleTabsByCSLocation() {
                    if({!AND(NOT(summaryViewAccess.StateFarm_Products__c),NOT(summaryViewAccess.ProductsServicedByMe__c),NOT(summaryViewAccess.ProductsWithOthers__c))}) {
                        hideElement("li[id='ProductsTab']");
                        j$("li[id='ProductsTab']").removeClass('slds-active');
                        hideElement("[id$=policies1]");
                        hideElement("div[id='tab-default-1']");
                        if({!IF(summaryViewAccess.Billing_Summary__c, "true", "false")}) {
                            j$("li[id='BillingTab']").addClass('slds-active');
                        } else if({!IF(summaryViewAccess.Claim_Summary__c, "true", "false")}) {
                            j$("li[id='ClaimsTab']").addClass('slds-active');
                        } else {
                            j$("li[id='ABSActivitiesTab']").addClass('slds-active');
                        }
                    }else {
                        if({!NOT(summaryViewAccess.StateFarm_Products__c)}) {
                            hideElement("li[id='SFProductsTab']");
                        }
                        if({!NOT(summaryViewAccess.ProductsServicedByMe__c)}){
                            hideElement("li[id='ProductsServicedByMeTab']");
                        }
                        if({!NOT(summaryViewAccess.ProductsWithOthers__c)}){
                            hideElement("li[id='ProductWithOthersTab']");
                        }
                    }
                    if({!NOT(summaryViewAccess.Billing_Summary__c)}) {
                        hideElement("li[id='BillingTab']");
                    }
                    if({!NOT(summaryViewAccess.Claim_Summary__c)}) {
                        hideElement("li[id='ClaimsTab']");
                    }
                    if({!NOT(summaryViewAccess.ABS_Activities_Summary__c)}) {
                        hideElement("li[id='ABSActivitiesTab']");
                    } 
                    }
    
                function performPolicyTransactions(selectedPolicyActionValue,status,urlToLaunch,selectedPolicyLOB,
                                                   selectedPolicyNumber,selectedPolicyAgentAssocID,isCCCLicensedUser,
                                                   selectedPolicyClientID, selectedPolicyDropDownDOMId, selectedPolicyDescription){
                    if(selectedPolicyActionValue != "select" && '{!JSENCODE($Label.CL_POLICY_CREATE_TASK)}' != selectedPolicyActionValue ) {
                        launchNechoAndCreateCase(urlToLaunch,selectedPolicyActionValue,selectedPolicyLOB,selectedPolicyNumber,selectedPolicyAgentAssocID, selectedPolicyClientID,isCCCLicensedUser,status);
                    } else if(selectedPolicyActionValue != "select" && '{!JSENCODE($Label.CL_POLICY_CREATE_TASK)}' == selectedPolicyActionValue) {
                        taskCreationForPolicyTransaction(selectedPolicyLOB, selectedPolicyAgentAssocID, selectedPolicyClientID, selectedPolicyNumber, selectedPolicyDescription);
                        document.getElementById(selectedPolicyDropDownDOMId).value = "select";
                    }
                }
    
                function launchNechoAndCreateCase(urlToLaunch,selectedPolicyActionValue,selectedPolicyLOB,selectedPolicyNumber,selectedPolicyAgentAssocID, selectedPolicyClientID,isCCCLicensedUser,status){
                     if((selectedPolicyAgentAssocID != null && selectedPolicyAgentAssocID != '') || status != 'Inactive' ){
                        window.open(urlToLaunch,"_blank","resizable=yes,top=300,left=100,bottom=100,width=1300,height=600,scrollbars=yes");
                        if(isCCCLicensedUser== 'true'){
                            caseCreationForPolicyTransaction(selectedPolicyActionValue,selectedPolicyLOB,selectedPolicyNumber,selectedPolicyAgentAssocID, selectedPolicyClientID);
                        }
                    } else {
                        window.alert('{!JSENCODE($Label.CL_POLICY_NECHOLAUNCH_ERROR)}');
                    }
                }
    
                function redirectToTaskEditPage(paramTaskId, paramAccountId) {
                    var redirectTaskEditURL = "00T/e?id=" + paramTaskId + "&saveURL=/"+paramAccountId;
                    if(paramTaskId != null && paramTaskId != '') {
                        var openSubtab = function openSubtab(result) {
                            var primaryTabId = result.id;
                            sforce.console.refreshPrimaryTabById(primaryTabId, true);
                            sforce.console.openSubtab(primaryTabId, redirectTaskEditURL, true);
                        }
                        sforce.console.getEnclosingPrimaryTabId(openSubtab);
                    }
                }
    
                function launchPolicyBillingView(param){
                    window.open(param,"_blank","resizable=yes,top=200,left=300,width=400,height=400,scrollbars=yes");
                }
                
                function launchNewSFPP(accountId, cccAssociate,isCCCLicensedUser){
                    if(isCCCLicensedUser=='true') {
                        window.open('/apex/VFP_ExternalLink?LinkId=31&accountId='+accountId+'&agentAssocId='+cccAssociate,"_blank","resizable=yes,top=300,left=100,bottom=100,width=1300,height=600,scrollbars=yes");
                    } else {
                        window.open('/apex/VFP_ExternalLink?LinkId=30&accountId='+accountId,"_blank","resizable=yes,top=300,left=100,bottom=100,width=1300,height=600,scrollbars=yes");
                    }
                }
                
            function openClaimDetail(lob, clmId, tabName, clientID,displayWorkersComp,accountID) {
                if(displayWorkersComp == 'notWorkersComp') {
                    if(clmId != null && clmId != '') {
                        var primaryTabId;                     
                        var openSubtab = function openSubtab(result){                           
                            primaryTabId = result.id;
                            sforce.console.focusSubtabByNameAndPrimaryTabId(tabName, primaryTabId, openSubtabForDetail);
                        };
                        var openSubtabForDetail = function openSubtabForDetail(result1){
                            if(!result1.success){
                                if(lob == 'A'){
                                    sforce.console.openSubtab(primaryTabId , '/apex/VFP_ClaimDetailAuto?param1='+clmId+'&param2='+clientID+'&param3='+accountID, true,'Claim #:'+tabName, null, null, tabName);                            
                                } else {
                                    sforce.console.openSubtab(primaryTabId , '/apex/VFP_ClaimDetailFire?param1='+clmId+'&param2='+clientID+'&param3='+accountID, true,'Claim #:'+tabName, null, null, tabName);                            
                                }
                            }
                        };
                        sforce.console.getEnclosingPrimaryTabId(openSubtab);                    
                    }
                }else {
                    j$("#saveQuoteErrorDialog").show();
                }
            }
    
                function launchAdditionalDetails(elm, param){ 
                    if(elm !="select" ){
                        window.open(param,"_blank","resizable=yes,top=300,left=100,bottom=100,width=1300,height=600,scrollbars=yes");                      
                    }
                }
    
                function openAgentDetails(agentAssocId, stateCode, agentCode, isSFOAgent,isCCCuser){
                    if((isCCCuser=='true') && (agentAssocId == '8888' || agentAssocId =='9099')) {
                        window.open('/apex/VFP_ExternalLink?LinkId=63&agentAssocId='+agentAssocId,"_blank","resizable=yes,top=300,left=100,bottom=100,width=1300,height=600,scrollbars=yes");            
                    } else if(isSFOAgent === 'true'){
                        window.open('/apex/VFP_ExternalLink?LinkId=26&primaryStateCode='+stateCode+'&primaryAgentCode='+agentCode,"_blank","resizable=yes,top=300,left=100,bottom=100,width=1300,height=600,scrollbars=yes");
                    } else {
                        window.open('/apex/VFP_ExternalLink?LinkId=27&agentAssocId='+agentAssocId,"_blank","resizable=yes,top=300,left=100,bottom=100,width=1300,height=600,scrollbars=yes");
                    }
                }
    
                function hidePopup(popUpId) {
                    j$("#"+popUpId).hide();
                }          
                
                function selectTab(elmnt, tabParam){ 
                    hideRemark();
                    hideCompleteMessage();
                    
                    hideElement("a[id='absURL'].slds-show");
                    
                    // slds-active
                    j$(elmnt).parent("li").siblings(".slds-active").removeClass("slds-active");
                    j$(elmnt).parent("li").addClass("slds-active");
                    
                    // tabindex
                    j$(elmnt).parent("li").siblings().children("a").attr("tabindex", -1);
                    j$(elmnt).attr("tabindex", 0);
                    
                    // aria-selected
                    j$(elmnt).parent("li").siblings().children("a").attr("aria-selected", false);
                    j$(elmnt).attr("aria-selected", true);
                    
                    // hiding previouly selected tab (slds-show/slds-hide)
                    j$(elmnt).closest(".slds-tabs_default").children("div[role='tabpanel'].slds-show").addClass("slds-hide");
                    j$(elmnt).closest(".slds-tabs_default").children("div[role='tabpanel'].slds-show").removeClass("slds-show");
                    // displaying newly selected tab (slds-show/slds-hide)
                    j$(elmnt).closest(".slds-tabs_default").children("div[aria-labelledby='"+elmnt.id+"']").addClass("slds-show");
                    j$(elmnt).closest(".slds-tabs_default").children("div[aria-labelledby='"+elmnt.id+"']").removeClass("slds-hide");
                    
                    if(tabParam == 'policies') {
                        hideAbsUrlAndRefresh();
                        if({!IF(isMobileContext, "false", "true")}){
                        selectSubTab(j$("a[id='tab-scoped-1__item']")[0], 'statefarm');
                        }
                    } else if(tabParam == 'billings') {
                        hideAbsUrlAndRefresh();
                        callBillings();
                    } else if(tabParam == 'claims') {
                        hideAbsUrlAndRefresh();
                        callClaims();
                    } else if(tabParam == 'activities') {
                        if({!IF(isABSViewed, "true", "false")}){
                            showElement("a[id='absURL'].slds-hide");
                        }
                        showElement("input[id='refresh'].slds-hide");
                        callActivities();
                    }
                    var elem = document.getElementById("dropdown");
                    var theCSSprop = window.getComputedStyle(elem,null).getPropertyValue("display");
                    if({!IF(isMobileContext, "true", "false")}|| theCSSprop == 'block'){
                        hideElement("li.slds-tabs_default__item:not(.slds-active)");
                        clearLists();
                        showElement("li.slds-tabs_scoped__item:not(.slds-active)");
                        if({!NOT(summaryViewAccess.ProductsServicedByMe__c)}){
                            hideElement("li[id='ProductsServicedByMeTab']");
                        }
                        if({!NOT(summaryViewAccess.ProductsWithOthers__c)}){
                            hideElement("li[id='ProductWithOthersTab']");
                        }
                    }
                }
                
                function selectSubTab(elmnt, tabParam) {
                    hideRemark();
                    hideCompleteMessage();
                    
                    hideElement("a[id='absURL'].slds-show");
                    
                    // slds-active
                    j$(elmnt).parent("li").siblings(".slds-active").removeClass("slds-active");
                    j$(elmnt).parent("li").addClass("slds-active");
                    
                    // tabindex
                    j$(elmnt).parent("li").siblings().children("a").attr("tabindex", -1);
                    j$(elmnt).attr("tabindex", 0);
                    
                    // aria-selected
                    j$(elmnt).parent("li").siblings().children("a").attr("aria-selected", false);
                    j$(elmnt).attr("aria-selected", true);
                    
                    // hiding previouly selected tab (slds-show/slds-hide)
                    j$(elmnt).closest(".slds-tabs_scoped").children("div[role='tabpanel'].slds-show").addClass("slds-hide");
                    j$(elmnt).closest(".slds-tabs_scoped").children("div[role='tabpanel'].slds-show").removeClass("slds-show");
                    // displaying newly selected tab (slds-show/slds-hide)
                    j$(elmnt).closest(".slds-tabs_scoped").children("div[aria-labelledby='"+elmnt.id+"']").addClass("slds-show");
                    j$(elmnt).closest(".slds-tabs_scoped").children("div[aria-labelledby='"+elmnt.id+"']").removeClass("slds-hide");
                    
                    if({!IF(summaryViewAccess.StateFarm_Products__c, "true", "false")} && tabParam == 'statefarm') {
                        hideAbsUrlAndRefresh();
                        callPolicies();
                    } else if(tabParam == 'servicedByMe') {
                        clearLists();
                        hideAbsUrlAndRefresh();
                        callProductsServicedByMe();
                    } else if(tabParam == 'withOthers') {
                        clearLists();
                        hideAbsUrlAndRefresh();
                        callProductsWithOthersCompetitors();
                    }
                    var elem = document.getElementById("dropdown");
                    var theCSSprop = window.getComputedStyle(elem,null).getPropertyValue("display");
                    if({!IF(isMobileContext, "true", "false")}|| theCSSprop == 'block'){
                        hideElement("li.slds-tabs_default__item:not(.slds-active)");
                        hideElement("li.slds-tabs_scoped__item:not(.slds-active)");
                    } 
                }
                
                if({!IF(isMobileContext, "true", "false")}){
                    //showElement("input[id='dropdown'].slds-hide");
                    j$("input[id='refresh']").val("");
                }
    
                
                function hideAbsUrlAndRefresh() {
                     hideElement("a[id='absURL'].slds-show");
                     hideElement("input[id='refresh'].slds-show");
                }
                
                function showElement(element) {
                    j$(element).addClass("slds-show");
                    j$(element).removeClass("slds-hide");
                }
                
                function hideElement(element) {
                    j$(element).addClass("slds-hide");
                    j$(element).removeClass("slds-show");
                }
                
                var a = navigator.userAgent;
                if((a.indexOf('Salesforce') != -1) && (a.indexOf('iPhone') != -1 || a.indexOf('iPad') != -1) && (a.indexOf('Safari') == -1)) {
                    var s = document.createElement('style');
                    s.innerHTML = "html,html body{overflow:scroll;-webkit-overflow-scrolling:touch;zindex:0;}body{position:absolute;left:0;right:0;top:0;bottom:0;}";
                    document.getElementsByTagName('head')[0].appendChild(s);
                    window.onkeydown = function() {
                        window.focus();
                    };
                };
            </script>
        </apex:form>
    </div>
    <apex:includeScript value="{!$Resource.jQuery}" />
    <apex:stylesheet value="{!URLFOR($Resource.LightningDesignSystem, 'assets/styles/salesforce-lightning-design-system.css')}" />
    <apex:includeScript value="/support/console/38.0/integration.js"/>
    <apex:stylesheet value="{!$Resource.SummaryViewCSS}" />    
</apex:page>

**/

}