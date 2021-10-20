public class VFP_class{
/*
public with sharing class VFC_PoliciesBillingClaimsTabController {

    private enum METHOD_NAMES {fetchPolicies, fetchBillings, fetchClaims, taskCreationForPolicyTransaction}
    public CS_FeatureToggle__c skipFeature {get; set;}
    public Boolean isCCCuser{get;set;}
    public Boolean sfppToggle{get; private set;}
    public String accIdInContext {get; set;}
    public Boolean showMoreRecords {get; set;}
    public Boolean hasMoreRecords {get; set;}
    public String accClntIdInContext {get; set;}
    public Map<String, Account> accMapByClntId {get; set;}
    public String groupId {get; set;}
    public String displayMessage{get;set;}
    public boolean isMobileContext{get;private set;}
    public String remarksErrorMessage{get;set;}
    public Boolean isABSViewed{get;set;}   
    public String requiredGatewayParameters{get;set;}
    public String activityErrorType{get;set;}    
    public String activityErrorMessage{get;set;}
    public Boolean isAgentuser {get; set;}
    public Boolean isCCCLicensedUser {get; private set;}
    public Boolean isCCCUnLicensedUser {get; private set;}
    public Boolean isPolicyActionEnabled;
    public Boolean lifeToggle{get; private set;}
    public Boolean phoenixToggle{get; private set;}
    public Boolean ascToggle{get; private set;}
    public String loggedInProfile;
    private String loggedInAssociateId;
    public String loggedInServiceAssocId;
    private String loggedInAlias;
    public String selectedAgentContextAssociateID{get; set;}
    
    public List<PolicyWrapper> policiesList{get;private set;}
    public List<BillingWrapper> billingsList{get;private set;}
    public List<ClaimWrapper> claimsList{get;set;}
    public List<ActivityWrapper> activitiesList{get;set;}
    public List<RemarkWrapper> remarksList{get;set;}
    
    @TestVisible public List<Policies__x> mockedTempPoliciesList = new List<Policies__x>();
    @TestVisible public List<Billings__x> mockedTempBillingList = new List<Billings__x>();
    @TestVisible public List<Claims__x> mockedTempClaimList = new List<Claims__x>();
    @TestVisible public List<Activities__x> mockedTempActivityList = new List<Activities__x>();
    @TestVisible public List<Remarks__x> mockedTempRemarkList = new List<Remarks__x>();
    @TestVisible public List<Updates__x> mockedUpdateList = new List<Updates__x>();
    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    
    private List<Remarks__x> oDataRemarksList{get;set;}
    private List<Updates__x> oDataUpdatesList{get;set;}
    
    // constants for all tabs
    private static final String S1_THEME = 'Theme4t';
    private static final String EMPTY_STRING = '';
    private static final String CLASS_NAME = 'VFP_PoliciesBillingClaimsTab_Controller';
    private static final String ACCOUNT_CLIENT_IDENTIFIER = 'ClientIdentifier__c';
    private static final String ACCOUNT_NAME = 'Name';
    private static final String CUSTOMER_ID_PARAM = 'customerId';
    
    //constants for Policies
    private static final String AUTO = 'A';
    private static final String FIRE = 'F';
    private static final String MUTUAL = 'M';
    private static final String HEALTH = 'H';
    private static final String BANK = 'B';
    private static final String LIFE = 'L';
    private static final String MASK = 'x';
    private static final String DOLLAR = '$';
    private static final String HOMEOWNERS ='HOMEOWNERS';
    private Static final String REGEX_ALPHA_NUMERIC = '[^a-zA-Z0-9]';
    private static final String REGEX_SFO_CODE = '[0-9]{2}-[0-9]{4} SFO ';
    private static final String POLICIES = 'Policies/Accounts';
    private static final String SELECT_VALUE = '--Select--';
    private static final String ADD_DRIVER = 'Add Driver';
    private static final String REPLACE_VEHCILE = 'Replace Vehicle';
    private static final String AUTO_POLICY_CHANGE = 'Auto Policy Change';
    private static final String FIRE_POLICY_CHANGE = 'Fire Policy Change';
    private static final String TOOF_REINSTATEMENT = 'TOOF/Reinstatement';
    private static final String POLICY = 'policy';
    private static final String POLICY_TRANSACTION = 'new pt';
    private static final String TABLE_OF_CONTENTS = 'main toc';
    private static final String Y_CHAR = 'Y';
    private static final integer LINK_NUMBER_FOR_WEB_NECHO_POLICY=9;
    private static final integer LINK_NUMBER_FOR_AUTO_FIRE_POLICY=13;
    private static final integer LINK_NUMBER_FOR_LIFE_POLICY=68;
    private static final integer LINK_NUMBER_FOR_PHOENIX_POLICY_VIEW=87;
    private static final integer LINK_NUMBER_FOR_MUTUALFUND_POLICY=112;
    private static List<CS_PolicyLOB_Mapping__c> mappingForLOB = [SELECT Name,Value__c FROM CS_PolicyLOB_Mapping__c Where Value__c != null Limit 25];
    private static List<CM_CaseReasonMappingOnPolicy__mdt> caseReasonMapping = [SELECT Source_Field__c,Target_Field__c FROM CM_CaseReasonMappingOnPolicy__mdt WHERE Source_Field__c != null Limit 25];
    public String stateCode{get;set;}
    public String agentCode{get;set;}
    public Boolean isSFOAgent {get; set;}
    public String oobIndicator{get; set;}
    
    //Case contants
    public final String CASE_STATUS ='New';
    public final String CASE_PRIORITY = 'Low';
    public final String CASE_SUBJECT = ' - Policy Change - ';
    public final String CASE_TYPE = 'Policy Change';
    public final String CASE_ORIGINATOR = 'CCC Sales';
    public String selectedPolicyActionValue{get;set;}
    public String selectedPolicyLOB{get;set;}
    public String selectedPolicyNumber{get;set;}
    public String selectedPolicyDescription{get;set;}
    public String selectedPolicyAgentAssocID{get;set;}
    public String selectedPolicyClientID{get;set;}
    public id caseRecordId{get;private set;}
    
    //constants for Billing
    private static final String BILLING = 'Billing';
    private static final integer LINK_NUMBER_FOR_BILLING=14;
    
    //constants for Claims
    private static final String CLAIMS = 'Claims';
    private static final String FIRE_DETAILS = 'ClaimDetailsFire__x';
    private static final String AUTO_DETAILS = 'ClaimDetailsAuto__x';
    private static final integer LINK_NUMBER_FOR_ADDITIONAL_CLAIMS=23;
    private static final String ADDITIONAL_DETAILS = 'Additional Details';
    private static final String WORKERS_Text = 'Workers';
    //constant for Task Creation
    private static final String CREATE_TASK_OPTION = 'Create Task';
    private static final String STATEFARM_FLEET = '8888';
    private static final String STATEFARM_RISK = '9099';
    private static final String TASK_ORIGINATOR_AGENT_OFFICE = 'Agent Office';
    private static final String TASK_ORIGINATOR_OTHER = 'Other';
    private static final String TASK_RECORD_TYPE_NAME = 'Task';
    private static final String TASK_TYPE = 'Service';
    private static final String TASK_APP_CODE = 'SFDC Task Quick Action';
    private static final String SELECTED_POLICY_AGENT_ASSOCIATE_ID_PARAM_NAME = 'selectedPolicyAgentAssocID';
    private static final String INACTIVE_STRING='inactive';
    private static final Integer POLICY_NUMBER_SIZE_LIMIT = 20;
    private static final Integer POLICY_DESCRIPTION_SIZE_LIMIT = 100;

    private Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(TASK_RECORD_TYPE_NAME).getRecordTypeId();    
    public Boolean afterTaskSaveFlag {get; set;}
    public Boolean taskErrorFlag {get; set;}
    public String taskRecordId {get; set;}
    public String taskRecordAccountId {get; set;}
    @TestVisible private UTIL_CustomerSummaryViewManager customerSummaryView = new UTIL_CustomerSummaryViewManager();
    public CS_CustomerSummaryView__c summaryViewAccess{get;private set;}

    public VFC_PoliciesBillingClaimsTabController(Apexpages.StandardController stdController){
        AP_ClickJackPrevention.setRequiredHeaders();    
        displayMessage = EMPTY_STRING;
        activityErrorType = EMPTY_STRING;
        activityErrorMessage = EMPTY_STRING;
        
        if(!Test.isRunningTest()) {
            stdController.addFields(new String[] {ACCOUNT_CLIENT_IDENTIFIER, ACCOUNT_NAME});
        }
        Account accountInfo = (Account) stdController.getRecord();
        accMapByClntId = new Map<String, Account>();
        accIdInContext = accountInfo.Id;
        summaryViewAccess = customerSummaryView.getCustomerSummaryViewAccessDetails();
        if(String.isNotEmpty(accountInfo.ClientIdentifier__c)){
            accMapByClntId.put(accountInfo.ClientIdentifier__c, accountInfo);
            accClntIdInContext = accountInfo.ClientIdentifier__c;
        }
        showMoreRecords = true;
        hasMoreRecords = false;
    }
    
    public VFC_PoliciesBillingClaimsTabController(){
        AP_ClickJackPrevention.setRequiredHeaders();    
        displayMessage = EMPTY_STRING;
        activityErrorType = EMPTY_STRING;
        activityErrorMessage = EMPTY_STRING;
        accMapByClntId = new Map<String, Account>();
        accClntIdInContext = EMPTY_STRING;
        summaryViewAccess  = customerSummaryView.getCustomerSummaryViewAccessDetails();
        hasMoreRecords = false;
        init();
    }
        
    private void buildInitialValuesForGroup(){
        if(String.isNotEmpty(groupId)){
            List<CustomerGroupMember__c> custGrpMember = [SELECT Id, customer__r.Id, customer__r.Name, customer__r.clientIdentifier__c FROM CustomerGroupMember__c where Group__c = :groupId LIMIT 100];
            if(!custGrpMember.isEmpty()){
                for(CustomerGroupMember__c grpMember: custGrpMember){
                    accMapByClntId.put(grpMember.customer__r.clientIdentifier__c, new Account(Id=grpMember.customer__r.Id, Name=grpMember.customer__r.Name));
                    If(accIdInContext != null && accIdInContext.subString(0,15).equalsIgnoreCase(String.valueOf(grpMember.customer__r.Id).subString(0,15))){
                        accClntIdInContext = grpMember.customer__r.clientidentifier__c;
                    }
                }
            }
            gotoGate();
        }
    }
    
    public void init() {
        User currentUser = [Select Associate_ID__c, Servicing_Agent_Associate_ID__c, Profile.Name, Alias from User Where Id = :UserInfo.getUserId()];
        loggedInProfile = currentUser.Profile.Name;
        loggedInAssociateId = currentUser.Associate_ID__c;
        loggedInAlias = currentUser.Alias;
        loggedInServiceAssocId = currentUser.Servicing_Agent_Associate_ID__c;
        isCCCLicensedUser = Label.CL_CCCLicensedProfile.equals(loggedInProfile);
        isPolicyActionEnabled = summaryViewAccess.Policy_Transactions__c;
        isCCCUnLicensedUser = Label.CL_CCCUnlicensedProfile.equals(loggedInProfile);
        isAgentuser = Label.CL_Agent_Profile.equals(loggedInProfile) || Label.CL_ATM_Profile.equals(loggedInProfile);
        sfppToggle = summaryViewAccess.Create_New_SFPP__c;
        lifeToggle= summaryViewAccess.Life_Policy_View__c; 
        phoenixToggle= summaryViewAccess.Phoenix_Policy_View__c; 
        ascToggle= summaryViewAccess.Life_Asc_Policy_View__c;
        if(isCCCLicensedUser && String.isNotEmpty(String.ValueOf(accIdInContext))) {
            List<AgentContext__c> agentContextDetails = [SELECT Id, Agent__r.Associate_ID__c, Customer__r.ClientIdentifier__c, 
                                                         CCCRepresentative__r.Alias, AgentContextIdentifier__c FROM AgentContext__c
                                                         where Customer__c = :accIdInContext and CCCRepresentative__c = :UserInfo.getUserId()];
            if(agentContextDetails !=null && !agentContextDetails.isEmpty()){
                selectedAgentContextAssociateID = agentContextDetails[0].Agent__r.Associate_ID__c;
            }
        }
        
        if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
            isMobileContext = true;
        } else {
            isMobileContext = false;
        }
        
        if('3.00 CCC Licensed'.equalsIgnoreCase(loggedInProfile) || '2.02 Sales Leader'.equalsIgnoreCase(loggedInProfile) || '3.01 CCC Unlicensed'.equalsIgnoreCase(loggedInProfile) || isMobileContext || String.isBlank(loggedInAssociateId)) {
            isABSViewed = false;
        } else {
            isABSViewed = true;
        }
        gotoGate();
    }
    
    
    //method to query policies from external object based on selected account and mask the policy number if needed
    public void fetchPolicies(){
        if(accMapByClntId.isEmpty()){
            buildInitialValuesForGroup();
        }
        hasMoreRecords = false;
        String policyQuery = 'Select AgentName__c, AgentAssociateID__c, LineOfBusiness__c, NextRenewalDate__c, PolicyNumber__c, ClientID__c, ProductDescription__c, TerminationDate__c, Status__c, AgreementIndexId__c'
                                        + ' From Policies__x Where ClientID__c in :clntIdList';               
        if(summaryViewAccess != null && summaryViewAccess.StateFarm_Products__c) {
            clearLists();
            List<Policies__x> oDataPoliciesList = new List<Policies__x>();
            policiesList = new List<PolicyWrapper>();
            try{
                Set<String> clntIdList = accMapByClntId.keySet();
                if(clntIdList.isEmpty()){
                    throw new InvalidInputException('Client Id Not found');
                }
                
                //Getting List of Policies based on logges in user
                oDataPoliciesList = customerSummaryView.getPoliciesBasedOnUser(clntIdList);//Database.query(policyQuery));
                
                
                if(!oDataPoliciesList.isEmpty()){
                    displayMessage = EMPTY_STRING;
                    Map<String, PolicyWrapper> mapPolicyData = new Map<String, PolicyWrapper>();
                        for(Policies__x selectPolicy : oDataPoliciesList){
                        if(String.isNotEmpty(selectPolicy.PolicyNumber__c)){
                            PolicyWrapper policyWrap = new PolicyWrapper();
                            if(mapPolicyData.get(selectPolicy.PolicyNumber__c)!=null){
                                policyWrap = mapPolicyData.get(selectPolicy.PolicyNumber__c);
                                if(String.isNotEmpty(accClntIdInContext) && selectPolicy.ClientID__c.equalsIgnoreCase(accClntIdInContext)){
                                    policyWrap.clientID = selectPolicy.ClientID__c;
                                    policyWrap.accName = accMapByClntId.get(selectPolicy.ClientID__c).Name + UTIL_CreateCustomerConstants.Comma + policyWrap.accName;
                                    policyWrap = buildPolicyUrls(policyWrap, selectPolicy);
                                }
                                else {
                                    policyWrap.accName += UTIL_CreateCustomerConstants.Comma + accMapByClntId.get(selectPolicy.ClientID__c).Name;
                                }
                            }
                            else{
                            policyWrap.policyActionsURLValue=null;
                            policyWrap.status = selectPolicy.status__c;
                            policyWrap.showPolicyDropDown = false;
                            policyWrap = buildPolicyUrls(policyWrap, selectPolicy);
                            policyWrap.lineOfBusiness = getTransformedLOBValue(selectPolicy.lineOfBusiness__c);
                            policyWrap.isOutOfBookCheckForLife = isOutOfBookCheck(selectPolicy);
                            policyWrap.agreementIndexId=selectPolicy.agreementIndexId__c;
                            policyWrap.productDescription = selectPolicy.productDescription__c;
                            policyWrap.agentName = getAgentName(selectPolicy.agentName__c);
                            policyWrap.sfoAgent = isSFOAgent;
                            policyWrap.stateCodeValue = stateCode;
                            policyWrap.agentCodeValue = agentCode;
                            policyWrap.agentAssociateID = selectPolicy.AgentAssociateID__c;
                            policyWrap.nextRenewalDate = selectPolicy.nextRenewalDate__c;
                            policyWrap.terminationDate = selectPolicy.terminationDate__c;  
                            policyWrap.clientID = selectPolicy.ClientID__c;
                            policyWrap.accName = accMapByClntId.get(selectPolicy.ClientID__c).Name;  
                            policyWrap.isPolicyLinkDisplayed = decidePolicyLinkDisplay(selectPolicy);
                            
                            if(MUTUAL.equals(selectPolicy.lineOfBusiness__c) || HEALTH.equals(selectPolicy.lineOfBusiness__c) || BANK.equals(selectPolicy.lineOfBusiness__c)){
                                if(selectPolicy.PolicyNumber__c!=null){
                                    String filteredString = String.valueof(selectPolicy.PolicyNumber__c).replaceAll(REGEX_ALPHA_NUMERIC,'');
                                    if(filteredString.length() >=4){
                                        String maskedPolicyNumber = '';
                                        String subString1 = filteredString.substring(0,filteredString.length()-4);
                                        String subString2 = filteredString.substring(filteredString.length()-4,filteredString.length());
                                        for(integer index=0;index<subString1.length();index++){
                                            maskedPolicyNumber  += MASK;
                                        }
                                        maskedPolicyNumber += subString2;
                                        policyWrap.policyNumber =maskedPolicyNumber;
                                    } 
                                    else{
                                        policyWrap.policyNumber =filteredString;
                                    }     
                                } 
                            }
                            else{
                                policyWrap.policyNumber = selectPolicy.PolicyNumber__c;
                            }

                            List<SelectOption> policyDropDownOptions = getActionDropdownValues(selectPolicy.lineOfBusiness__c, checkToAddTaskOptionInPolicy(selectPolicy.AgentAssociateID__c, policyWrap.policyNumber));
                                if(policyDropDownOptions.size() > 1 && String.isEmpty(groupId)) {
                                policyWrap.actionDropDownValues = policyDropDownOptions; //setting Actions Values based on LOB for Policy Tab
                                policyWrap.showPolicyDropDown = true;
                            }
                        }
                            mapPolicyData.put(selectPolicy.PolicyNumber__c, policyWrap);
                        }
                    }
                    if(!showMoreRecords && mapPolicyData.size() > 5){
                        hasMoreRecords = true;
                        List<PolicyWrapper> policyWrapList = mapPolicyData.values();
                        for(Integer i=0; i<5; i++){
                            policiesList.add(policyWrapList.get(i));
                        }
                    }
                    else{
                        policiesList.addAll(mapPolicyData.values());
                }
                }
                if(policiesList.isEmpty()){
                    displayMessage = Label.CL_NO_RECORDS;
                }
            }
            catch(Exception dataSourceExp){
                displayMessage = Label.CL_TRY_LATER;
                LoggingService.logHandledException(dataSourceExp, CLASS_NAME, METHOD_NAMES.fetchPolicies.name(), System.LoggingLevel.ERROR);
            }
        }
        else{
            displayMessage = Label.CL_FEATURE_DOWN;
        }
    }
    
    private Boolean decidePolicyLinkDisplay(Policies__x selectPolicy){
        Boolean isLinkDisplayed = false;
        if(isABSViewed && decideBasedOnLOBForLink(selectPolicy)){
            isLinkDisplayed = true;
        }
        else if(MUTUAL.equals(selectPolicy.lineOfBusiness__c)){
            isLinkDisplayed = decideMutualPolicylink(selectPolicy); 
        }
        return isLinkDisplayed;
    }
    
    private Boolean decideBasedOnLOBForLink(Policies__x selectPolicy) {
        if(AUTO.equals(selectPolicy.lineOfBusiness__c) || FIRE.equals(selectPolicy.lineOfBusiness__c) || HEALTH.equals(selectPolicy.lineOfBusiness__c)){
                return true;
        }
        else if(LIFE.equals(selectPolicy.lineOfBusiness__c)){
                return decideLifePolicylink(selectPolicy);
        }
        return false;
    }
    
    private Boolean decideLifePolicylink(Policies__x selectPolicy) {
        return ((selectPolicy.PolicyNumber__c.left(2)=='LF' || selectPolicy.PolicyNumber__c.left(2)=='AS') && lifeToggle)
                    || ((selectPolicy.PolicyNumber__c.left(2)=='SL'|| selectPolicy.PolicyNumber__c.left(2)=='SA') && ascToggle)
                    || (selectPolicy.productDescription__c.left(3)=='PNX' && phoenixToggle);
    }
    
    private Boolean decideMutualPolicylink(Policies__x selectPolicy){
        return Label.CL_Profile_502.equalsIgnoreCase(loggedInProfile) 
                    || Label.CL_Profile_503.equalsIgnoreCase(loggedInProfile) 
                    || ((Label.CL_Agent_Profile.equalsIgnoreCase(loggedInProfile) || Label.CL_ATM_Profile.equalsIgnoreCase(loggedInProfile)) && loggedInServiceAssocId.equalsIgnoreCase(selectPolicy.AgentAssociateID__c));
    }
    
        
    private PolicyWrapper buildPolicyUrls(PolicyWrapper wrapPolicy, Policies__x policyInfo){
        oobIndicator = isOutOfBookPolicy(policyInfo.AgentAssociateID__c);
        wrapPolicy.policyDetailsURLValue=getURLParametersForDetails(policyInfo,oobIndicator);
        if(policyInfo.lineOfBusiness__c.equalsIgnoreCase(AUTO) || policyInfo.lineOfBusiness__c.equalsIgnoreCase(FIRE)){
            wrapPolicy.policyActionsURLValue=buildingURLforWebNecho(policyInfo); //building Web Necho Policy URL from Salesforce
        }
        return wrapPolicy;
    }
    
    //Method to check if the policy agent is sfo
    private String getAgentName(String agentNameFromService){
        isSFOAgent = false;
        stateCode = EMPTY_STRING;
        agentCode = EMPTY_STRING;
        if(!String.isEmpty(agentNameFromService)){
            Pattern myPattern = Pattern.compile(REGEX_SFO_CODE);
            Matcher myMatcher = myPattern.matcher(agentNameFromService);
            if(myMatcher.find()) {
                String foundString = myMatcher.group();
                stateCode = foundString.substring(0,2);
                agentCode = foundString.substring(3,7);
                String parsedName = foundString.substring(0,7);
                agentNameFromService = String.valueof(agentNameFromService).replaceAll(parsedName,'');
                isSFOAgent = true;
            }
        }
        return agentNameFromService;
    }
    
    //Method to check if the policy is out of book for logged in agent
    private String isOutOfBookPolicy(String servicingAssociateId){
        oobIndicator = 'TRUE';
        if(!String.isEmpty(servicingAssociateId) && !String.isEmpty(loggedInServiceAssocId)){
            if(servicingAssociateId.equalsIgnoreCase(loggedInServiceAssocId)){
                oobIndicator = 'FALSE';
            }
        }
        return oobIndicator; 
    }

    //Method to check if Life Policy needs a Hyperlink based on servicing Agent for Policy   
    private Boolean isOutOfBookCheck(Policies__x policyInfo){
        Boolean isOutOfBookCheckForLife = true;
        if(policyInfo.LineOfBusiness__c.equalsIgnoreCase(LIFE)){
            isOutOfBookCheckForLife =false;
            if(!String.isEmpty(policyInfo.AgentAssociateID__c) && policyInfo.AgentAssociateID__c.equalsIgnoreCase(loggedInServiceAssocId)){
                isOutOfBookCheckForLife =true;
            }
        }
        return isOutOfBookCheckForLife;
    }
    
    //Building URL for Web Necho Policies
    private string buildingURLforWebNecho(Policies__x policyInfo){
        string urlToLaunchWebNecho=null;
        if(policyInfo.LineOfBusiness__c.equalsIgnoreCase(AUTO)){
            urlToLaunchWebNecho= getURLParametersForWebNechoPolicy(policyInfo,POLICY_TRANSACTION);//launching policy transaction page
        }else if(policyInfo.LineOfBusiness__c.equalsIgnoreCase(Fire)){
            urlToLaunchWebNecho= getURLParametersForWebNechoPolicy(policyInfo,TABLE_OF_CONTENTS);//launching table fo contents page
        }
        return urlToLaunchWebNecho;
    }
    
    
    /**
    * @method getURLParametersForWebNechoPolicy: Building an URL to launch WEB NECHO Screen from Actions Dropdown
    * @param Policies__x object policyInfo,string nechoAppName
    * @return string to launch Web Necho Screens
    
    private string getURLParametersForWebNechoPolicy(Policies__x policyInfo,string nechoAppName){
        Id accIdForPolicy = accMapByClntId.get(policyInfo.ClientID__c).Id;
        return 
            LinkConstants.EXTERNAL_LINK_PAGE+LINK_NUMBER_FOR_WEB_NECHO_POLICY+LinkConstants.AMPERSAND_SYMBOL+
            LinkConstants.INPUT_PARAM_ACCOUNT_ID+LinkConstants.EQUALS_SYMBOL+accIdForPolicy+LinkConstants.AMPERSAND_SYMBOL+
            LinkConstants.INPUT_PARAM_AGREEMENT_ID+LinkConstants.EQUALS_SYMBOL+policyInfo.AgreementIndexId__c+LinkConstants.AMPERSAND_SYMBOL+
            LinkConstants.INPUT_PARAM_CLIENT_LINK_DISABLED+LinkConstants.EQUALS_SYMBOL+Y_CHAR+LinkConstants.AMPERSAND_SYMBOL+
            LinkConstants.INPUT_PARAM_NECHO_APP_NAME+LinkConstants.EQUALS_SYMBOL+nechoAppName+LinkConstants.AMPERSAND_SYMBOL+
            LinkConstants.INPUT_PARAM_KEY+LinkConstants.EQUALS_SYMBOL+policyInfo.PolicyNumber__c+LinkConstants.AMPERSAND_SYMBOL+
            LinkConstants.INPUT_PARAM_LOB+LinkConstants.EQUALS_SYMBOL+policyInfo.LineOfBusiness__c+LinkConstants.AMPERSAND_SYMBOL+
            LinkConstants.INPUT_PARAM_POLICY_SERVICING_AGENT_ASSOC_ID+LinkConstants.EQUALS_SYMBOL+policyInfo.AgentAssociateID__c;
    }
    
    /**
    * @method getURLParametersForDetails: Building an URL to launch policy Screen from Policy Number Details
    * @param String policyInfo
    * @return string to launch policy screen
    
    private string getURLParametersForDetails(Policies__x policyInfo, String oobIndicator){
        Id accIdForPolicy = accMapByClntId.get(policyInfo.ClientID__c).Id;
        if(policyInfo.LineOfBusiness__c.equalsIgnoreCase(FIRE) && !policyInfo.ProductDescription__c.contains(HOMEOWNERS) || policyInfo.LineOfBusiness__c.equalsIgnoreCase(HEALTH) || (policyInfo.LineOfBusiness__c.equalsIgnoreCase(LIFE) && isASCPolicyType(policyInfo.PolicyNumber__c))){
            return getURLParametersForWebNechoPolicy(policyInfo,POLICY);
        }else if(policyInfo.LineOfBusiness__c.equalsIgnoreCase(AUTO) || policyInfo.LineOfBusiness__c.equalsIgnoreCase(FIRE)) {
            return LinkConstants.EXTERNAL_LINK_PAGE+LINK_NUMBER_FOR_AUTO_FIRE_POLICY+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_ACCOUNT_ID+LinkConstants.EQUALS_SYMBOL+accIdForPolicy+
                LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_AGREEMENT_ID+LinkConstants.EQUALS_SYMBOL+policyInfo.AgreementIndexId__c+LinkConstants.AMPERSAND_SYMBOL+
                LinkConstants.INPUT_PARAM_POLICY_NUMBER+LinkConstants.EQUALS_SYMBOL+policyInfo.PolicyNumber__c+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_LOB+
                LinkConstants.EQUALS_SYMBOL+policyInfo.LineOfBusiness__c+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_PROD_DESC+LinkConstants.EQUALS_SYMBOL+EncodingUtil.urlEncode(policyInfo.ProductDescription__c, LinkConstants.ENCODING_UTF_8)+
                LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_POLICY_SERVICING_AGENT_ASSOC_ID+LinkConstants.EQUALS_SYMBOL+policyInfo.AgentAssociateID__c+LinkConstants.AMPERSAND_SYMBOL+
                LinkConstants.INPUT_PARAM_OOB_INDICATOR+LinkConstants.EQUALS_SYMBOL+oobIndicator;
        }else if(policyInfo.LineOfBusiness__c.equalsIgnoreCase(MUTUAL))  {
            return LinkConstants.EXTERNAL_LINK_PAGE+LINK_NUMBER_FOR_MUTUALFUND_POLICY+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_AGREEMENT_ID+LinkConstants.EQUALS_SYMBOL+policyInfo.AgreementIndexId__c+LinkConstants.AMPERSAND_SYMBOL+
                LinkConstants.INPUT_PARAM_POLICY_NUMBER+LinkConstants.EQUALS_SYMBOL+policyInfo.PolicyNumber__c+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_LOB+
                LinkConstants.EQUALS_SYMBOL+policyInfo.LineOfBusiness__c;        
        }else if(policyInfo.LineOfBusiness__c.equalsIgnoreCase(LIFE) && isPMRPolicyType(policyInfo.PolicyNumber__c)){
            return LinkConstants.EXTERNAL_LINK_PAGE+LINK_NUMBER_FOR_LIFE_POLICY+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_ACCOUNT_ID+LinkConstants.EQUALS_SYMBOL+accIdForPolicy+
                LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_AGREEMENT_ID+LinkConstants.EQUALS_SYMBOL+policyInfo.AgreementIndexId__c+LinkConstants.AMPERSAND_SYMBOL+
                LinkConstants.INPUT_PARAM_POLICY_NUMBER+LinkConstants.EQUALS_SYMBOL+policyInfo.PolicyNumber__c+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_LOB+
                LinkConstants.EQUALS_SYMBOL+policyInfo.LineOfBusiness__c+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_POLICY_SERVICING_AGENT_ASSOC_ID+LinkConstants.EQUALS_SYMBOL+policyInfo.AgentAssociateID__c;
        }else if(policyInfo.LineOfBusiness__c.equalsIgnoreCase(LIFE) && policyInfo.ProductDescription__c.LEFT(3).equalsIgnoreCase('PNX')){                        
            return  
                LinkConstants.EXTERNAL_LINK_PAGE+LINK_NUMBER_FOR_PHOENIX_POLICY_VIEW+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_ACCOUNT_ID+LinkConstants.EQUALS_SYMBOL+accIdForPolicy+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_POLICY_NUMBER+LinkConstants.EQUALS_SYMBOL+policyInfo.PolicyNumber__c+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_POLICY_SERVICING_AGENT_ASSOC_ID+LinkConstants.EQUALS_SYMBOL+policyInfo.AgentAssociateID__c;            
            
        }
        return null;
    }
    
      public boolean isPMRPolicyType(String policyNumber){
        if(policyNumber.LEFT(2).equalsIgnoreCase('LF') || policyNumber.LEFT(2).equalsIgnoreCase('AS')){
            return true;      
        }
          return false;
       }
       
      public boolean isASCPolicyType(String policyNumber){
          if(policyNumber.LEFT(2).equalsIgnoreCase('SL') || policyNumber.LEFT(2).equalsIgnoreCase('SA')){
              return true;
          }
          return false;
       }

    /**
    * @method getActionValues: For displaying actions values based on LOB
    * @param String LOB
    * @return List<SelectOption>
    
    public List<SelectOption> getActionDropdownValues(string LOB, Boolean isAddTaskOptionAllowed){
        List<SelectOption> actionDropdownValues = new List<SelectOption>();
        actionDropdownValues.add(new SelectOption('select',SELECT_VALUE));

        if(isPolicyActionEnabled) {
            if(LOB.equalsIgnoreCase(AUTO)){
                actionDropdownValues.add(new SelectOption(ADD_DRIVER,ADD_DRIVER));
                actionDropdownValues.add(new SelectOption(REPLACE_VEHCILE,REPLACE_VEHCILE));
                actionDropdownValues.add(new SelectOption(AUTO_POLICY_CHANGE,AUTO_POLICY_CHANGE));
                actionDropdownValues.add(new SelectOption(TOOF_REINSTATEMENT,TOOF_REINSTATEMENT));
            } else if(LOB.equalsIgnoreCase(FIRE)){
                actionDropdownValues.add(new SelectOption(FIRE_POLICY_CHANGE,FIRE_POLICY_CHANGE));
                actionDropdownValues.add(new SelectOption(TOOF_REINSTATEMENT,TOOF_REINSTATEMENT));
            }
        }

        // drop down check for Create Task and adding the Create Task option as a last value in the drop down list.
        if(isAddTaskOptionAllowed) {
            actionDropdownValues.add(new SelectOption(CREATE_TASK_OPTION, CREATE_TASK_OPTION));
        }
        return actionDropdownValues;
    }

    //method to create task for the selected policy from the Create Task dropdown.
    public void taskCreationForPolicyTransaction() {
        afterTaskSaveFlag = true;
        taskErrorFlag = false;
        taskRecordId = '';
        taskRecordAccountId='';
        String selectedPolicyAgentAssocIDAfterParamValidation = '';
        try {
            selectedPolicyAgentAssocIDAfterParamValidation = UTIL_PageParameterHelper.retrieveCurrentPageParameter(SELECTED_POLICY_AGENT_ASSOCIATE_ID_PARAM_NAME, ParameterType.ASSOCIATE_ID);
            Task tskToBeInserted = buildTaskForPolicy(selectedPolicyAgentAssocIDAfterParamValidation, selectedPolicyNumber, selectedPolicyDescription);
            insert tskToBeInserted;
            taskRecordId = tskToBeInserted.id;
            taskRecordAccountId = tskToBeInserted.WhatId;
        } catch(Exception createPolicyTaskException) {
            taskErrorFlag = true;
            LoggingService.logHandledException(createPolicyTaskException, CLASS_NAME, METHOD_NAMES.taskCreationForPolicyTransaction.name(), LoggingLevel.ERROR);
        }
    }

    //method to get task record for selected policy for task creation.
    private Task buildTaskForPolicy(String selectedPolicyAgentAssocID, String selectedPolicyNumber, String selectedPolicyDescription) {
        Task taskRecord = new Task();
        taskRecord.Task_Type__c = TASK_TYPE;
        taskRecord.AppCode__c = TASK_APP_CODE;
        taskRecord.RecordTypeId = taskRecordTypeId;
        taskRecord.WhatId = accMapByClntId.get(selectedPolicyClientID).Id;
        taskRecord.Source__c = buildTaskOriginator();
        taskRecord.OwnerId = UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(selectedPolicyAgentAssocID).id;
        taskRecord.LineofBusiness__c = selectedPolicyLOB;
        if(String.isNotBlank(selectedPolicyNumber)) {
            taskRecord.PolicyNumber__c = selectedPolicyNumber.left(POLICY_NUMBER_SIZE_LIMIT);
        }
        if(String.isNotBlank(selectedPolicyDescription)) {
            taskRecord.ProductDescription__c = selectedPolicyDescription.left(POLICY_DESCRIPTION_SIZE_LIMIT);
        }
        return taskRecord;
    }

    //method to get Task Originator for policy task creation.
    private string buildTaskOriginator() {
        String taskOriginator = '';
        if(isAgentuser) {
            taskOriginator = TASK_ORIGINATOR_AGENT_OFFICE;
        } else if(Label.CL_TechSupport_Profile.equals(loggedInProfile)) {
            taskOriginator = TASK_ORIGINATOR_OTHER;
        }
        return taskOriginator;
    }

    /**
    * @method caseCreationForPolicyTransaction: For creating case on policy workflow change
    * @param none
    * @return void
    
    public void caseCreationForPolicyTransaction(){
        try{
            Account accData=[select id,PersonContactId from account where id=:accMapByClntId.get(selectedPolicyClientID).Id]; //Check Logic
            case caseCreationForCCCAction=new case();
            caseCreationForCCCAction.AccountId=accData.Id;
            caseCreationForCCCAction.ContactId=accData.PersonContactId;
            caseCreationForCCCAction.OwnerId =getCaseOwnerId();
            caseCreationForCCCAction.Priority=CASE_PRIORITY;
            caseCreationForCCCAction.Status=CASE_STATUS;
            caseCreationForCCCAction.Subject=selectedPolicyLOB+ CASE_SUBJECT+selectedPolicyNumber;
            caseCreationForCCCAction.Type=CASE_TYPE;
            caseCreationForCCCAction.Case_Originator__c=CASE_ORIGINATOR;
            caseCreationForCCCAction.Reason=getTransformedToCaseReason(selectedPolicyActionValue);
            caseCreationForCCCAction.LOB__c = selectedPolicyLOB;
            //case creation using utility DAO
            UTIL_CaseDAO.insertCase(caseCreationForCCCAction);
            caseRecordId=caseCreationForCCCAction.id;
            
            List<Case> cases = new List<Case>();
            cases.add(caseCreationForCCCAction);
            UTIL_InteractionProcessor.createInteractionEventsForSelectPolicyTransaction(cases,selectedPolicyActionValue);
        }catch(Exception exp){
            String errorMessage=exp.getMessage();
            exp.setMessage('Policy:'+selectedPolicyNumber+' '+errorMessage); 
            LoggingService.logHandledException(exp,CLASS_NAME, 'caseCreationForPolicyTransaction', LoggingLevel.ERROR); 
        }
    }
    //Mapping CaseReason in cases created due to policy tansaction with CaseReason Value
    private static String getTransformedToCaseReason(String selectedPolicyActionValue){
        Map<String, String> transfromCaseMap = new Map<String, String>();
        for(CM_CaseReasonMappingOnPolicy__mdt casReasonValue: caseReasonMapping){
            transfromCaseMap.put(casReasonValue.Source_Field__c, casReasonValue.Target_Field__c);
        }
        if(transfromCaseMap.containsKey(selectedPolicyActionValue)){
            selectedPolicyActionValue = transfromCaseMap.get(selectedPolicyActionValue);
        }
        return selectedPolicyActionValue;
    }    
    
    /**
    * @method getCaseOwnerId: For getting Agent's Proxy to assign it to Agent's offcie if not assigning to QUEUE
    * @param String Agent Assoc Id 
    * @return Id
    
    private id getCaseOwnerId(){
        id OwnerId =null;
        try{
            OwnerId=UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(selectedPolicyAgentAssocID).id;
        }catch(ProxyUserNotFoundException exp){
            Group caseQueue = [SELECT Id, developerName, Type FROM Group WHERE developerName = 'Case_Owner_Queue' AND Type = 'Queue' LIMIT 1];    
            OwnerId = caseQueue.Id; 
        }
        return OwnerId;        
    }
    
    //For Mapping oData LOB values to appropriate Claim
    private static String getTransformedLOBValue(String oDataValue){
        Map<String, String> transformationMap = new Map<String, String>();
        for(CS_PolicyLOB_Mapping__c lobValues : mappingForLOB){
            transformationMap.put(lobValues.Name, lobValues.Value__c);
        }
        if(transformationMap.containsKey(oDataValue)){
            oDataValue = transformationMap.get(oDataValue);
        }
        return oDataValue;
    }
    
    //method to query billing from external object based on selected account
    public void fetchBillings(){
        if(accMapByClntId.isEmpty()){
            buildInitialValuesForGroup();
        }
        hasMoreRecords = false;
        String billingQuery = 'Select AccountType__c, SfppAccountNumber__c, Status__c, DueDate__c, AmountDue__c, ClientID__c'
                                        +' From Billings__x where ClientID__c in :clntIdList';        
        if(summaryViewAccess != null && summaryViewAccess.Billing_Summary__c) {
            clearLists();
            List<Billings__x> oDataBillingsList = new List<Billings__x>();
            billingsList = new List<BillingWrapper>();
            try{
                Set<String> clntIdList = accMapByClntId.keySet();
                if(clntIdList.isEmpty()){
                    throw new InvalidInputException('Client Id Not found');
                }
                if(Test.isRunningTest()) {
                    oDataBillingsList =  mockedTempBillingList;
                }
                else{
                    oDataBillingsList = Database.query(billingQuery);
                }
                if(!oDataBillingsList.isEmpty()){
                    displayMessage = EMPTY_STRING;
                    Map<String, BillingWrapper> mapBillingData = new Map<String, BillingWrapper>();
                        for(Billings__x selectBilling : oDataBillingsList){
                        if(String.isNotEmpty(selectBilling.SfppAccountNumber__c)){
                            BillingWrapper billingWrap = new BillingWrapper();
                            if(mapBillingData.get(selectBilling.SfppAccountNumber__c)!=null){
                                billingWrap = mapBillingData.get(selectBilling.SfppAccountNumber__c);
                                if(String.isNotEmpty(accClntIdInContext) && selectBilling.ClientID__c.equalsIgnoreCase(accClntIdInContext)){
                                    billingWrap.clientID = selectBilling.ClientID__c;
                                    billingWrap.accName =accMapByClntId.get(selectBilling.ClientID__c).Name +  UTIL_CreateCustomerConstants.COMMA + billingWrap.accName;
                                    billingWrap.billingDetailsURLValue=getURLParametersForBillingDetails(selectBilling.SfppAccountNumber__c, selectBilling.ClientID__c);
                                }
                                else {
                                    billingWrap.accName += UTIL_CreateCustomerConstants.COMMA + accMapByClntId.get(selectBilling.ClientID__c).Name;
                                }
                            }
                            else {
                            billingWrap.billingDetailsURLValue=getURLParametersForBillingDetails(selectBilling.SfppAccountNumber__c, selectBilling.ClientID__c);
                            billingWrap.accountType = selectBilling.AccountType__c;
                            billingWrap.sfppAccountNumber = selectBilling.SfppAccountNumber__c;
                            billingWrap.status = selectBilling.Status__c;
                            billingWrap.dueDate = selectBilling.DueDate__c;
                            billingWrap.clientID = selectBilling.ClientID__c;
                            billingWrap.accName = accMapByClntId.get(selectBilling.ClientID__c).Name;
                            if(!String.isEmpty(selectBilling.AmountDue__c)){
                                billingWrap.amountDue = DOLLAR+selectBilling.AmountDue__c;
                            }
                        }    
                            mapBillingData.put(selectBilling.SfppAccountNumber__c, billingWrap);
                    }
                }
                    if(!showMoreRecords && mapBillingData.size() >5){
                        hasMoreRecords = true;
                        List<BillingWrapper> billingWrapList = mapBillingData.values();
                        for(Integer i=0; i<5; i++){
                            billingsList.add(billingWrapList.get(i));
                        }
                    }
                    else {
                        billingsList.addAll(mapBillingData.values());
                    }
                }
                if(billingsList.isEmpty()){
                    displayMessage = Label.CL_NO_RECORDS;
                }
            }
            catch(Exception dataSourceExp){
                displayMessage = Label.CL_TRY_LATER;
                LoggingService.logHandledException(dataSourceExp, CLASS_NAME, METHOD_NAMES.fetchBillings.name(), System.LoggingLevel.ERROR);
            }
        }
        else{
            displayMessage = Label.CL_FEATURE_DOWN;
        }
    }
    
    private string getURLParametersForBillingDetails(string sfppAccountNumber, String clientId){
        Id accId = accMapByClntId.get(clientId).Id;
        return LinkConstants.EXTERNAL_LINK_PAGE+LINK_NUMBER_FOR_BILLING+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_ACCOUNT_ID+LinkConstants.EQUALS_SYMBOL+accId+
            LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_ACCOUNT_NUMBER+LinkConstants.EQUALS_SYMBOL+sfppAccountNumber;
        
    }
    
    //method to query claims from external object based on selected account
    public void fetchClaims(){
        if(accMapByClntId.isEmpty()){
            buildInitialValuesForGroup();
        }
        hasMoreRecords = false;
        String claimsQuery = 'Select ClaimNumber__c, ClaimStatus__c, DateOfLoss__c, PolicyDescription__c, ClaimID__c, LineOfBusiness__c, ClientID__c'
                                       +' From Claims__x Where ClientID__c in :clntIdList';        
        if(summaryViewAccess != null && summaryViewAccess.Claim_Summary__c) {
            clearLists();
            List<Claims__x> oDataClaimsList = new List<Claims__x>();
            claimsList = new List<ClaimWrapper>();
            try{
                Set<String> clntIdList = accMapByClntId.keySet();
                if(clntIdList.isEmpty()){
                    throw new InvalidInputException('Client Id Not found');
                }
                if(Test.isRunningTest()) {
                    oDataClaimsList = mockedTempClaimList;
                }
                else{
                    oDataClaimsList = Database.query(claimsQuery);
                }
                if(!oDataClaimsList.isEmpty()){
                    displayMessage = EMPTY_STRING;
                    Map<String, ClaimWrapper> mapClaimData = new Map<String, ClaimWrapper>();
                        for(Claims__x selectClaim : oDataClaimsList){
                        if(String.isNotEmpty(selectClaim.ClaimNumber__c)){
                            ClaimWrapper claimWrap = new ClaimWrapper();
                            if(mapClaimData.get(selectClaim.ClaimID__c)!=null){
                                claimWrap = mapClaimData.get(selectClaim.ClaimID__c);
                                if(String.isNotEmpty(accClntIdInContext) && selectClaim.ClientID__c.equalsIgnoreCase(accClntIdInContext)){
                                    claimWrap.clientID = selectClaim.ClientID__c;
                                    claimWrap.accName = accMapByClntId.get(selectClaim.ClientID__c).Name + UTIL_CreateCustomerConstants.COMMA + claimWrap.accName;
                                    claimWrap.claimABSURLValue=getURLParametersForABS(selectClaim.ClientID__c);
                                }
                                else {
                                    claimWrap.accName += UTIL_CreateCustomerConstants.COMMA + accMapByClntId.get(selectClaim.ClientID__c).Name;
                                }
                            } else {
                            claimWrap.claimNumber = selectClaim.ClaimNumber__c;
                            claimWrap.claimStatus = selectClaim.ClaimStatus__c;
                            claimWrap.dateOfLoss = selectClaim.DateOfLoss__c;
                            claimWrap.policyDescription = selectClaim.PolicyDescription__c;
                                 if(selectClaim.PolicyDescription__c.containsignoreCase(WORKERS_Text)){
                                claimWrap.displayWorkersComp = true;
                            }
                            claimWrap.claimID = selectClaim.ClaimID__c;
                            claimWrap.lOB = selectClaim.LineOfBusiness__c;
                            claimWrap.addDetails=getAdditionalDetails();
                            claimWrap.claimABSURLValue=getURLParametersForABS(selectClaim.ClientID__c);
                            claimWrap.clientID = selectClaim.ClientID__c;
                            claimWrap.accName = accMapByClntId.get(selectClaim.ClientID__c).Name;
                            claimWrap.isClaimDetailsRestricted = summaryViewAccess.Claims_Detail__c;
                            claimWrap.toggle = toggleContext.isNotActive(UTIL_Toggles.CLAIMDETAILS);
                        }
                            mapClaimData.put(selectClaim.ClaimID__c, claimWrap);
                    }
                }
                    if(!showMoreRecords && mapClaimData.size()>5){
                        hasMoreRecords = true;
                        List<ClaimWrapper> claimWrapList = mapClaimData.values();
                        for(Integer i=0; i<5; i++){
                            claimsList.add(claimWrapList.get(i));
                        }
                    }
                    else {
                        claimsList.addAll(mapClaimData.values());
                    }
                }
                if(claimsList.isEmpty()){
                    displayMessage = Label.CL_NO_RECORDS;
                }
            }
            catch(Exception dataSourceExp){
                displayMessage = Label.CL_TRY_LATER;
                LoggingService.logHandledException(dataSourceExp, CLASS_NAME, METHOD_NAMES.fetchClaims.name(), System.LoggingLevel.ERROR);
            }
        }
        else{
            displayMessage = Label.CL_FEATURE_DOWN;
        }
    }
    
    //For displaying additional detail values for claim
    public List<SelectOption> getAdditionalDetails(){
        List<SelectOption> addDetails = new List<SelectOption>();
        addDetails.add(new SelectOption('select',SELECT_VALUE));
        addDetails.add(new SelectOption('Additional Details',ADDITIONAL_DETAILS)); 
        return addDetails;
    }
    
    //Building an URL to launch ABS OCS to view claim details
    public string getURLParametersForABS(String clientID){
        Id accId = accMapByClntId.get(clientId).Id;
        return LinkConstants.EXTERNAL_LINK_PAGE+LINK_NUMBER_FOR_ADDITIONAL_CLAIMS+LinkConstants.AMPERSAND_SYMBOL+LinkConstants.INPUT_PARAM_ACCOUNT_ID+LinkConstants.EQUALS_SYMBOL+accId; //Check Logic
    }
    
    public void fetchActivities() {  
        if(accMapByClntId.isEmpty()){
            buildInitialValuesForGroup();
        }
        hasMoreRecords = false;
        String activitiesQuery = 'Select User__r.Name, Category__c, AgentName__c, ClientID__c, Customer__c, Description__c, DueDate__c, LineOfBusiness__c, ModifiedDate__c, Status__c, AssociateID__c, ActivityID__c' 
                                       +' From Activities__x Where Activities__x.ClientID__c in : clntIdList And Activities__x.UserID__c =: userID';
        if(loggedInUserCanSeeAgentOnlyActivities()){
            //Only show ServicingAgentOwned ABS Activities *Works!*
            activitiesQuery += ' And Activities__x.AssociateID__c =: owningAgentAssocID';
        }
        if(summaryViewAccess != null && summaryViewAccess.ABS_Activities_Summary__c) {
        try{
            Set<String> clntIdList = accMapByClntId.keySet();
            if(clntIdList.isEmpty()){
                throw new InvalidInputException('Client Id Not found');
            }
            clearLists();
            List<Activities__x> oDataActivitiesList = new List<Activities__x>();
            activitiesList = new List<ActivityWrapper>();
            String userID = loggedInAlias;
            String owningAgentAssocID = loggedInServiceAssocId;
            
            if(Test.isRunningTest()) {
                oDataActivitiesList = mockedTempActivityList;
            }
            else {
                    oDataActivitiesList = Database.query(activitiesQuery);
            }
            if(accMapByClntId.keySet() != null) {
                if(!oDataActivitiesList.isEmpty()) {
                    displayMessage = EMPTY_STRING;
                        for(Activities__x selectActivity : oDataActivitiesList) {                
                        if(String.isNotEmpty(selectActivity.ActivityID__c)){
                            if(!showMoreRecords && activitiesList.size() == 5){
                                hasMoreRecords = true;
                                break;
                            }                
                            ActivityWrapper activityWrap = new ActivityWrapper();
                            activityWrap.dueDate =formatDate(selectActivity.DueDate__c);
                            activityWrap.modifiedDate = formatTimestamp(selectActivity.ModifiedDate__c); 
                            activityWrap.status = selectActivity.Status__c;
                            activityWrap.customer = selectActivity.Customer__c;
                            activityWrap.description = selectActivity.Description__c;
                            activityWrap.lob = selectActivity.LineOfBusiness__c;
                            activityWrap.category = selectActivity.Category__c;          
                            activityWrap.agentName =  selectActivity.User__r.Name;
                            activityWrap.activityID =  selectActivity.ActivityID__c;
                            activityWrap.associateID =  selectActivity.AssociateID__c;
                            activityWrap.clientID = selectActivity.ClientID__c;
                            activityWrap.displayCompleteButton = whoCanCompleteActivity(selectActivity.AssociateID__c, selectActivity.Status__c);
                            activitiesList.add(activityWrap);                                   
                        }
                    }
                }
            }
            if(activitiesList.isEmpty()){
                displayMessage = Label.CL_NO_RECORDS;
            }         
        }
        catch(Exception dataSourceExp) {
            displayMessage = Label.CL_TRY_LATER;
            LoggingService.logHandledException(dataSourceExp, CLASS_NAME, 'fetchActivities', System.LoggingLevel.ERROR);
        }              
    }   
        else {
            displayMessage = Label.CL_FEATURE_DOWN;
        }              
    }   
    
    public void fetchRemark(){
        clearCompleteMessage();
        remarksList = new List<RemarkWrapper>();  
        String userID = loggedInAlias;
        
        try {
            if(Test.isRunningTest()) {
                oDataRemarksList = mockedTempRemarkList;
            } else {
                oDataRemarksList = [SELECT Remark__c,ActivityID__c FROM Remarks__x WHERE ActivityID__c =:Apexpages.currentPage().getParameters().get('actID') AND UserID__c =: userID]; 
            }  
            if(!oDataRemarksList.isEmpty()) {
                remarksErrorMessage = EMPTY_STRING;
                Boolean isValidResponseActivity = true;
                if(oDataRemarksList.size()==1 && 
                   (String.isEmpty(oDataRemarksList[0].Remark__c) || oDataRemarksList[0].Remark__c.equalsIgnoreCase('null'))) {
                       remarksErrorMessage = Label.CL_TRY_LATER;
                       isValidResponseActivity = false;
                   }
                if(isValidResponseActivity) {
                    for(Remarks__x selectRemark : oDataRemarksList) {
                        List<String> lines = selectRemark.Remark__c.split('\\n');
                        for (String line : lines) {
                            RemarkWrapper remarkWrap = new RemarkWrapper();
                            remarkWrap.remark = line;
                            remarkWrap.activityid = selectRemark.ActivityID__c;
                            remarksList.add(remarkWrap);   
                        }
                    }
                }
            } else {
                remarksErrorMessage = Label.CL_NO_RECORDS;                
            }
        } catch(Exception dataSourceExp) {
            remarksErrorMessage = Label.CL_TRY_LATER;
            LoggingService.logHandledException(dataSourceExp, CLASS_NAME, 'fetchRemark', System.LoggingLevel.ERROR);
        }
    }
    
    public void completeActivity(){                
        String activityId = Apexpages.currentPage().getParameters().get('actvID');
        String userID = loggedInAlias;
        String modifierAssocID = loggedInAssociateId;
        
        try {
            if(Test.isRunningTest()) {
                oDataUpdatesList = mockedUpdateList;
            } else {
                oDataUpdatesList = [SELECT UpdateResponse__c,ActivityID__c, UserID__c, ModifierAssocID__c FROM Updates__x WHERE ActivityID__c =:activityId AND UserID__c =: userID AND ModifierAssocID__c =: modifierAssocID]; //a
            }
            
            if(!oDataUpdatesList.isEmpty()){
                for(Updates__x selectUpdate : oDataUpdatesList){
                    activityErrorMessage = selectUpdate.UpdateResponse__c;
                    activityErrorType = 'absActivity-Success';
                }
            } else {
                activityErrorMessage = Label.CL_NO_RECORDS;
                activityErrorType  = 'absActivity-Error';
            }   
        } catch(Exception dataSourceExp){
            activityErrorMessage = Label.CL_TRY_LATER;
            activityErrorType  =  'absActivity-Error';
            LoggingService.logHandledException(dataSourceExp, CLASS_NAME, 'completeActivity', System.LoggingLevel.ERROR);
        }
        //Update the list of Activities
        //fetchActivities();
    }
    
    public void clearCompleteMessage(){
        activityErrorType =EMPTY_STRING;
        activityErrorMessage = EMPTY_STRING;
    }

    public with sharing class PolicyWrapper{
        public String status{get;set;}
        public String lineOfBusiness{get;set;}
        public String productDescription{get;set;}
        public String policyNumber{get;set;}
        public String clientID{get; set;}
        public String accName{get; set;}
        public String agentName{get;set;}
        public String agentAssociateID{get;set;}
        public String nextRenewalDate{get;set;}
        public String terminationDate{get;set;}
        public String agreementIndexId{get;private set;}
        public List<selectoption> actionDropDownValues{get;private set;}
        public string policyActionsURLValue{get;private set;}
        public string policyDetailsURLValue{get;private set;}
        public Boolean sfoAgent{get;set;}
        public String stateCodeValue{get;set;}
        public String agentCodeValue{get;set;}
        public Boolean showPolicyDropDown {get;set;}
        public Boolean isOutOfBookCheckForLife{get;set;}
        public Boolean isPolicyLinkDisplayed {get; set;}
    }

    public with sharing class BillingWrapper{
        public String accountType{get;set;}
        public String sfppAccountNumber{get;set;}
        public String status{get;set;}
        public String dueDate{get;set;}
        public String amountDue{get;set;}
        public String clientID{get; set;}
        public String accName{get; set;}
        public string billingDetailsURLValue{get;private set;}
    }
    
    public with sharing class ClaimWrapper{
        public String claimNumber{get;set;}
        public String claimStatus{get;set;}
        public String dateOfLoss{get;set;}
        public String policyDescription{get;set;}
        public String claimID{get;set;}
        public String lOB{get;set;}
        public List<selectoption> addDetails{get;private set;}
        public String claimABSURLValue{get;private set;} 
        public String clientID{get;set;}
        public String accName{get; set;}
        public Boolean toggle{get;set;}
        public Boolean isClaimDetailsRestricted{get;set;}
        public Boolean displayWorkersComp{get;set;}
    }
    
    public with sharing class ActivityWrapper {
        public String dueDate{get;set;}
        public String modifiedDate{get;set;}
        public String status{get;set;}
        public String customer{get;set;}
        public String description{get;set;}
        public String clientID{get; set;}
        public String lob{get;set;}
        public String category{get;set;}
        public String agentName{get;set;}
        public String activityID{get;set;}
        public String associateID{get;set;}
        public Boolean displayCompleteButton{get;set;}        
    }
    
    public with sharing class RemarkWrapper {
        public String activityid{get;set;}
        public String remark{get;set;}
    }
    
    public string formatDate(String dateToFormat) {
        if(String.isNotBlank(dateToFormat)) { 
            try {
                Date dateObject = Date.valueOf(dateToFormat);            
                if(dateObject.year() > 1900) {       
                    Datetime dateTimeObject = Datetime.newInstance(dateObject.year(), dateObject.month(),dateObject.day());
                    return dateTimeObject.formatGmt('MM/dd/yyyy');
                } else {
                    return '';
                }
            } catch(Exception dataSourceExp) {
                return '';
            }
        } else {
            return ''; 
        }
    }
    public string formatTimestamp(String timeStampToFormat) {
        if(String.isNotBlank(timeStampToFormat)) {
            try {
                Datetime dateTimeObject = Datetime.valueOfGmt(timeStampToFormat);
                return dateTimeObject.formatGmt('MM/dd/yyyy');
            } catch(Exception dataSourceExp) {
                return '';
            }
        } else {
            return ''; 
        }     
    }
        
    public void gotoGate() {       
        String userAlias =   ''; 
        String associateID = '';
        String clientId =    '';
        
        if(Test.isRunningTest()) {
            userAlias =   '0000'; 
            associateID = '00000000000';
            clientId =    'abcdefg';
        } else {
            userAlias = loggedInAlias; 
            associateID = loggedInServiceAssocId;
            clientId =    accClntIdInContext;
        }
        
        Integer linkId   =  22;       
        requiredGatewayParameters = '?LinkId='+linkId+'&agentAssocId=' + associateID + '&clientId=' + clientId + '&userId=' + userAlias;    
        //Used to determine if the URL built in SFDC is incorrect or if there is an error inside of URL Gateway or the ABS application.
    }    
    
    public Boolean whoCanCompleteActivity(String associateId, String status){
        Boolean isProfileAllowed = false;  
        
        if( '2.00 Agent'.equalsIgnoreCase(loggedInProfile))  {          
            if(associateId.equalsIgnoreCase(loggedInServiceAssocId)){
                isProfileAllowed = true;
            }
        } else if('2.01 Agent Team Member'.equalsIgnoreCase(loggedInProfile)) {          
            if(associateId.equalsIgnoreCase(loggedInServiceAssocId)){
                isProfileAllowed = true;
            }
        }
        
        if(isProfileAllowed && !'C'.equalsIgnoreCase(status)){        
            return true;            
        } 
        return false;          
        
    }
    
    public Boolean loggedInUserCanSeeAgentOnlyActivities(){
        return ( '2.00 Agent'.equalsIgnoreCase(loggedInProfile) || '2.01 Agent Team Member'.equalsIgnoreCase(loggedInProfile));

    }

    //Method to determine if "Create Task" drop down option should display or not in policy tab
    private Boolean checkToAddTaskOptionInPolicy(String paramSelectedPolicyAgentAssociateId, String paramSelectedPolicyNumber) {
        Boolean isCreateTaskOptionAllowed = false;

        //checking for the agent is STATEFARM Risk or STATEFARM Fleet
        if(String.isNotBlank(paramSelectedPolicyAgentAssociateId) && String.isNotBlank(paramSelectedPolicyNumber)) {
            if(!(STATEFARM_FLEET.equals(paramSelectedPolicyAgentAssociateId) || STATEFARM_RISK.equals(paramSelectedPolicyAgentAssociateId))) {
                if(isAgentuser) {
                    if(String.isNotBlank(loggedInServiceAssocId) && loggedInServiceAssocId.equalsIgnoreCase(paramSelectedPolicyAgentAssociateId)) {
                        isCreateTaskOptionAllowed = true;
                    }
                } else if(Label.CL_TechSupport_Profile.equals(loggedInProfile)) {
                    isCreateTaskOptionAllowed = true;
                }
            }
        }
        return isCreateTaskOptionAllowed;
    }
    
    public void clearLists() {
        policiesList = null;
        billingsList = null;
        claimsList = null;
        activitiesList = null;
    }
}

**/

}