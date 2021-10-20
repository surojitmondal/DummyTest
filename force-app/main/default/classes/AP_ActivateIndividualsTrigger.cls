//Apex helper class for ActivationBeforeInsert, update and Delete
public without sharing class AP_ActivateIndividualsTrigger {
    private final String RECORD_TYPE_NAME = 'Individual';
    private final String USER_ACTIVATION = 'User';
    private final String USER_TYPE = 'Agent';
    
//This method is used to insert and update Activation and Deactivation Date into user object
    public void populateActivationDeactivationDatetoUser(List<Activation__c> newActivationList){
        if(newActivationList != null && !newActivationList.isEmpty()){
            Set<id> setActivationUser = new Set<id>();
            for(Activation__c activationRecord :newActivationList){
                setActivationUser.add(activationRecord.Activation_User__c);
            }
        }        
    }

//method to check validations before inserting
    private void populateActivateDate(List<Activation__c> newActivationList, Set<id> setActivationUser){
        
        
    }    
}