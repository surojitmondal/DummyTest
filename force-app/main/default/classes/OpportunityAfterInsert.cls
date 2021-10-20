public class OpportunityAfterInsert{

/*
public with sharing class HLPR_SignedWrittenConsent {
    
    private static final String CLASS_NAME = 'HLPR_SignedWrittenConsent';
    private static final String METHOD_NAME = 'processConsentOnOpportunityCreate';
    
    /**
    * @method- Invoked by  OpportunityAfterInsert Trigger             
    public static void processConsentOnOpportunityCreate(List<Opportunity> opportunityList) {
        try{
            if(!verifySignedWrittenConsentToggle()) {
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
                                  where Id IN :accountIdToOpportunityMap.keySet() AND persondonotcall = true]){
            opportunityToUpdateList.addAll(acctRecord.Opportunities);
            opportunityToProcessList.add(accountIdToOpportunityMap.get(acctRecord.Id));
            accountToUpdateList.add(acctRecord);
         }
        updateDateCapturedInOpportunities(opportunityToUpdateList);
        updateSWCValuesInAccounts(accountToUpdateList);
        createSignedWrittenConsent(opportunityToProcessList);
    }
    
    //Helper method to update date captured field value in opportunities except closed and closed won opportunities
    private static void updateDateCapturedInOpportunities(List<Opportunity> opportunityToUpdateList){
        for(Opportunity opptyRecord : opportunityToUpdateList){             
            opptyRecord.DateCaptured__c = System.today();
        }    
        if(!opportunityToUpdateList.IsEmpty() && Schema.sObjectType.Opportunity.isUpdateable()){
            update opportunityToUpdateList;
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
    
    //Method to verify signed written consent toggle from signed written consent alert toast component    
    @AuraEnabled
    public static Boolean getSignedWrittenConsentToggleContext() {
        return verifySignedWrittenConsentToggle();
    }
    
    //Helper method to verify signed written consent toggle
    private static Boolean verifySignedWrittenConsentToggle(){
        UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
        return toggleContext.isActive(UTIL_Toggles.RESTRICTSIGNEDWRITTENCONSENT);
    }
    
}
*/

}