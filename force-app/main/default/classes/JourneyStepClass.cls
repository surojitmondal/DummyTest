public class JourneyStepClass {
	
    @AuraEnabled
    public Static String callAPI(Journey_Step__c JSrecord){
    	system.debug('JSrecord===='+JSrecord);
        return 'Sucess';
    }
}