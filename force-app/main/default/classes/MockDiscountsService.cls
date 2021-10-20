@isTest
public class MockDiscountsService implements StubProvider {
    
   Integer amount;
 
   public MockDiscountsService(Integer amount){
      this.amount = amount;
   }
 
   public Object handleMethodCall(Object stubbedObject,
               String stubbedMethodName,
                     System.Type returnType,
                           List<System.Type> listOfParamTypes,
                                 List<String> listOfParamNames,
                                       List<Object> listOfArgs){
        System.debug('Name of stubbed method: ' + stubbedMethodName);
        System.debug('Return type of stubbed method: ' + returnType.getName());
        
        // You can also use the parameter names and types to determine which method 
        // was called.
        for (integer i =0; i < listOfParamNames.size(); i++) {
            System.debug('parameter name: ' + listOfParamNames.get(i));
            System.debug('  parameter type: ' + listOfParamTypes.get(i).getName());
        }
        
        // This shows the actual parameter values passed into the stubbed method at runtime.
        System.debug('number of parameters passed into the mocked call: ' + 
            listOfArgs.size());
        System.debug('parameter(s) sent into the mocked call: ' + listOfArgs);
 
      if(stubbedMethodName == 'getDiscount'){
         Decimal discount = 0;
       
         if(amount >= 10 && amount < 20) discount = 10;
         if(amount >= 20 && amount < 50) discount = 20;
         if(amount >= 50) discount = 30;
 
         return discount;
          /**
        public with sharing class VFC_ApexController {
    public opportunity opp {get;set;}
    public Journey__c selectedJourney {get;set;}
    public Map<id,Journey__c> journeyMap {get;set;}
    public String selectedJourneyId {get;set;}
    public List<Journey_Step__c> journeyStepsList {get;set;}
    public Date journeyStartDate {get;set;}        
    public Double totalCost {get;set;}
    public List<String> pageMessages {get;set;}
    public boolean showJourneySelection {get;set;}
    public Boolean isLightning {get; set;}
    public Boolean isS1Request {get; set;}
    public boolean isStopJourney {get;set;}
    public String stopJourneyResponse {get;set;}
    public Map<String,String> stepToTypeMap {get;set;}
    public String pageTitle {get;set;}          
    private static final String CLASS_NAME = 'VFC_Start_Stop_Journey';
    private enum METHOD_NAMES {startStopOpportunityJourney,previewJourneySteps}
    private static final String BIZ_LINE_CODE_GENERAL = 'General';
    private static final String BIZ_LINE_CODE_SMALL_BIZ = 'Small Business';
    private static final String CATEGORY_NAME = 'Prospect Customers';
    private static final String OPP_PRODUCT_ARTISAN_SERVICE = 'Artisan and Service Contractor Policy';
    private static final String OPP_PRODUCT_BUSINESS_INSURANCE = 'Business Insurance';
    private static final String OPP_PRODUCT_COMMERCIAL_INLAND = 'Commercial Inland Marine Policy';
    private static final String OPP_PRODUCT_COMMERCIAL_LIABILITY = 'Commercial Liability Umbrella Policy';
    private static final String OPP_PRODUCT_RESIDUAL = 'Residual Workers Compensation';
    private static final String OPP_PRODUCT_WORKERS = 'Workers Compensation and Employers Liability Policy';
    private static final String OPP_LOB_FIRE = 'Fire';
    private static final String DEFAULT_OPTION = '-- Select Journey --';
    private static final String JNY_LOB_HOMEFIRE = 'Home - Fire';
    private static final String S1_THEME = 'Theme4t';
    private static final String LIGHTNING_DESKTOP_THEME = 'Theme4d';
    private static final String CONFIRM_YES = 'Yes';
    private static final String CONFIRM_NO = 'No';
    private static List<CM_USStateCodeMapping__mdt> metaDataStateCodeMapping;
    private static Map<String, String> stateCodeMap;
    
    //Page Action Method
    public VFC_ApexController(ApexPages.StandardController stdController) {
        opp = (Opportunity)stdController.getRecord();
        AP_ClickJackPrevention.setRequiredHeaders();
        journeyMap = new Map<id,Journey__c>();
        journeyStepsList = new List<Journey_Step__c>();
        pageMessages = new List<String>(); 
        showJourneySelection = false;
        stepToTypeMap = new Map<String,String>();
        pageTitle = system.label.CL_JOURNEY_OPP_START_STOP;
        isStopJourney = false;
        if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
            isLightning = true;
            isS1Request = true;
        }
        else if(LIGHTNING_DESKTOP_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
            isLightning = true;
            isS1Request = false;
        }
        else {
            isLightning = false;
            isS1Request = false;
        }
    }
    
    //Start Opportunity Journey
    public PageReference startStopOpportunityJourney(){
        try{
            //Only Agent, ATMs and support profiles should be able to start the journey
            if(!isValidProfile()) return null;			
			
            opp = [SELECT Id, Name, LOB__c, OppAccountStateCode__c, IsAccountHealthSourced__c, Product__c,X_Date__c,createddate,Journey_ID__c, stageName, assigned_to__c FROM Opportunity WHERE Id = :opp.id];
            if(isS1Request || HLPR_OppButtonController.isOppNewAndAssignedToAnotherUser(opp.StageName,opp.Assigned_To__c)) {
                pageMessages.add((isS1Request) ? System.Label.CL_JOURNEY_S1_ERROR : System.label.CL_OPP_ASSIGNED_TO_ERROR); 
                return null;
            }
			         
            pageTitle = opp.name;  
			isStopJourney = opp.Journey_ID__c != null;	
            if(opp.Journey_ID__c == null){	
				//Journeys are not currently available for Health Sourced Customers
                if(isAccountHealthSourced()) return null;
                //Check for Opp LOB Fire and valid set of products
                if(isValidOppProduct()){
                    //get journeys for Small Business and General business line 
                    getMapOfJourneys(new List<String>{BIZ_LINE_CODE_GENERAL,BIZ_LINE_CODE_SMALL_BIZ});
                }else if(!isValidOppProduct() && opp.LOB__c.equals(OPP_LOB_FIRE)) {
                    //get journeys for opportunity LOB + General line of business
                    //for Lob Fire - Check "Home - Fire"  
					getMapOfJourneys(new List<String>{JNY_LOB_HOMEFIRE,BIZ_LINE_CODE_GENERAL});
				}else {
					getMapOfJourneys(new List<String>{opp.LOB__c,BIZ_LINE_CODE_GENERAL});
				}  
				if(isJourneyMapEmpty()) return null;
				showJourneySelection = true;
			}			
        }catch(Exception exp){
            LoggingService.logHandledException(exp, CLASS_NAME, METHOD_NAMES.startStopOpportunityJourney.name(), System.LoggingLevel.ERROR);
            pageMessages.add(System.Label.CL_Exception_Message);
        }
        return null;
    }
    
    //Method to check if the logged in user has Agent, ATM or support profile
    private boolean isValidProfile() {
        String loggedInUserProfileName = [Select Name from Profile where Id=:userinfo.getProfileId()].Name;
        Set<String> validProfiles = new Set<String>{UTIL_Constants.AGENT_PROFILE_NAME,UTIL_Constants.ATM_PROFILE_NAME,
            UTIL_Constants.TECHNICAL_SUPPORT_PROFILE_NAME,UTIL_Constants.DEV_SYSTEM_ADMIN_PROFILE_NAME};
        boolean validProfileFlag = false;
        if(validProfiles.contains(loggedInUserProfileName)){
            validProfileFlag = true;
        }else{
            pageMessages.add(System.Label.CL_JOURNEY_INVALID_PROFILE);            
        }
        return validProfileFlag;
    }
    
    //Method to check if Account is Health Sourced
    private boolean isAccountHealthSourced() {
        boolean accHealthSourcedFlag = false;
        if(opp.IsAccountHealthSourced__c){
            accHealthSourcedFlag =true;
            pageMessages.add(System.Label.CL_JOURNEY_HEALTH_SOURCED);
        }
        return accHealthSourcedFlag;
    }
    
    //Method to check that Opportunity product is one of the products for opp with Fire LOB
    private boolean isValidOppProduct() {
        boolean prodValidFlag = false;
        Set<String> setOfValidProducts = new Set<String>{OPP_PRODUCT_ARTISAN_SERVICE,OPP_PRODUCT_BUSINESS_INSURANCE,OPP_PRODUCT_COMMERCIAL_INLAND,
            OPP_PRODUCT_COMMERCIAL_LIABILITY,OPP_PRODUCT_RESIDUAL,OPP_PRODUCT_WORKERS};            
        if(opp.product__c!=null && opp.LOB__c.contains(OPP_LOB_FIRE) && setOfValidProducts.contains(opp.product__c)){
            prodValidFlag = true;
        }
        return prodValidFlag;
    }
    
    //Method to get a Map of Journeys based on business line and state code
    private void getMapOfJourneys(List<String> businessLineList){
        retrieveStateCodeMapping();
        String businessLineCriteria = '';
        for(String sBL:businessLineList){
            if(String.isBlank(businessLineCriteria)){
                businessLineCriteria = '(BusinessLineCode__c Includes (\'' + String.escapeSingleQuotes(sBL)  + '\'))';
            }else{
                businessLineCriteria = businessLineCriteria+' or (BusinessLineCode__c Includes (\'' + String.escapeSingleQuotes(sBL)  + '\'))';
            }
        } 
        
        String numericStateCode = stateCodeMap.get(opp.OppAccountStateCode__c); 
        String queryStr = 'Select id, name, StateCode__c, JourneyName__c, EffectiveDate__c, (select id, name, JourneyName__c, JourneyStepID__c, StepTypeCode__c, '
            +'ContactMethodName__c, ItemEffectiveDate__c, Cost__c, DaysNum__c, Bundle_ID__c, MailClassCode__C, ItemID__c '
            +'from journey_step__r order by JourneyStepID__c asc) from journey__c where Categoryname__c=\''+CATEGORY_NAME 
            +'\' and EffectiveDate__c <=today and ExpirationDate__c>=today and StateCode__c=\''+numericStateCode
            +'\' and ('+businessLineCriteria+')';
        journeyMap = new Map<id,journey__c>((List<journey__c>)Database.query(queryStr));
    }
    
    //Method to check size of journey map
    private boolean isJourneyMapEmpty() {
        boolean journeyMapEmptyFlag = false;
        if(journeyMap.size()<=0){
            pageMessages.add(System.Label.CL_JOURNEY_NO_JOURNEYS);
            journeyMapEmptyFlag = true;                    
        }
        return journeyMapEmptyFlag;        
    }
    
    //Method to populate Journey names in the drop down
    public List<SelectOption> getJourneyOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',DEFAULT_OPTION));
        for(Journey__c j:journeyMap.values()){
            options.add(new SelectOption(j.id,j.JourneyName__c));
        }
        return options;           
    } 
    
    //Ajax method to generate the preview of Journey steps
    public void previewJourneySteps() {
        try{
            pageMessages.clear();
            if(String.isNotBlank(selectedJourneyId) && journeyMap.containsKey(selectedJourneyId)){
                selectedJourney = journeyMap.get(selectedJourneyId);
                journeyStepsList = selectedJourney.journey_step__r;
                
                //Calculate Journey Start date on Opportunity
                if(selectedJourney.JourneyName__c.containsIgnoreCase('xDate') && journeyStepsList.size()>0) {
                    journeyStartDate = new AP_Opportunity_StartJourney().getJourneyXcalcStartDate(opp, journeyStepsList[0].DaysNum__c.intvalue());
                }else { 
                    journeyStartDate = new AP_Opportunity_StartJourney().getCalculateOppStartDate();  
                }
                //calculate the totals & populate the Delivery Type Map
                totalCost = 0.00;
                Map<String,String> methodToStepMap = methodToStepTypeMap();
                for(journey_step__c js:journeyStepsList){
                    totalCost = totalCost + (js.Cost__c==null?0.00:Double.valueOf(js.Cost__c));
                    String deliveryType = '';
                    String methodClass = (js.ContactMethodName__c==null?'':js.ContactMethodName__c)+
                            (js.MailClassCode__c==null?'':js.MailClassCode__c); 
                    if(methodToStepMap.containsKey(methodClass)){
                        deliveryType = methodToStepMap.get(methodClass);
                    }
                    stepToTypeMap.put(js.Id, deliveryType);
                }
            }
        }catch(Exception exp){
            LoggingService.logHandledException(exp, CLASS_NAME, METHOD_NAMES.previewJourneySteps.name(), System.LoggingLevel.ERROR);
            pageMessages.add(System.Label.CL_Exception_Message);
        }
    }
    
    Method to call AP_Opportunity_StartJourney class to create the tasks and account messages
    public PageReference nextJourneyAction() {
        if(selectedJourney!=null && String.isNotBlank(selectedJourney.Id)){
            String oppIdJourneyId = opp.id+';'+selectedJourney.Id;
            List<boolean> exceptionList = AP_Opportunity_StartJourney.oppStartJourney(new List<String>{oppIdJourneyId});
            if(exceptionList.size()>0 && exceptionList[0]){
                pageMessages.add(System.Label.CL_JOURNEY_ERROR);    
                return null;
            }else{
                return new PageReference('/lightning/r/Opportunity/'+opp.id+'/view');
            } 
        }else{
            pageMessages.add(System.Label.CL_JOURNEY_SELECT); 
        }    
        return null;        
    }
    
    //Method to check if there are page messages
    public boolean hasMessages {
        get {
             return pageMessages.size()>0;
        }
    }
    
    //Method to get page message
    public String errorMessage {
        get {
            if (hasMessages) {
                return pageMessages[0];
            } 
            return null;
        }
    }
    
    //Method to return to original opportunity record
    public PageReference finishJourneyAction() {
        PageReference oppPage = new PageReference('/lightning/r/Opportunity/'+opp.id+'/view');
        oppPage.setRedirect(true);
        return oppPage;        
    }
    
    //Method to create a map with method+classcodes a key to get the delivery type   
    public Map<String,String> methodToStepTypeMap(){
        Map<String,String> mailCodeMap = new Map<String,String>();
            mailCodeMap.put('Mailing1','1st Class');
            mailCodeMap.put('Mailing3','3rd Class');
            mailCodeMap.put('MailingE','Email');
            mailCodeMap.put('Appointment','Task');
            mailCodeMap.put('Call','Task');
            mailCodeMap.put('Other','Task');
            return mailCodeMap;        
    } 
    
    //Method to get confirmation options for stop journey action
    public List<SelectOption> getConfirmationOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(CONFIRM_YES,CONFIRM_YES));
        options.add(new SelectOption(CONFIRM_NO,CONFIRM_NO));
        return options;
    }
    
    //Method to perform stop action based on user's response
    public PageReference stopJourneyAction() {
        PageReference retPage = null;
        //if response is Yes then stop the journey
        if(stopJourneyResponse!=null && stopJourneyResponse.equals(CONFIRM_YES)){
            List<Boolean> exceptionOccured = AP_Opportunity_StopJourney.oppStopJourney(new List<id>{opp.id});
            if(exceptionOccured.get(0)){
                pageMessages.add(System.label.CL_JOURNEY_EXCEPTION_MSG);
            }            
            retPage = new PageReference('/lightning/r/Opportunity/'+opp.id+'/view');
        }else if(stopJourneyResponse!=null && stopJourneyResponse.equals(CONFIRM_NO)){
            //if response is No then return to the Opportunity        
            retPage = new PageReference('/lightning/r/Opportunity/'+opp.id+'/view');
        }else{ 
            //show error message is none of the options selected
            pageMessages.add(System.label.CL_JOURNEY_CONFIRM);
            retPage = null;
        }
        return retPage;
    }
    
    //Helper method to retrieve metadata mapping for state and statecode
    private void retrieveStateCodeMapping () {
        if (metaDataStateCodeMapping == null) {
            metaDataStateCodeMapping = [Select DeveloperName, State__c, StateCode__c
                                        from CM_USStateCodeMapping__mdt where State__c != null Limit 51];
            stateCodeMap = new Map<String, String>();
            if(metaDataStateCodeMapping != null && !metaDataStateCodeMapping.isEmpty()){
                for (CM_USStateCodeMapping__mdt mappingRecord : metaDataStateCodeMapping){
                    stateCodeMap.put(mappingRecord.State__c, mappingRecord.StateCode__c);
                }
            } 
        } 
    }
}  
        */
      }
       
      return null;
   }
 
}