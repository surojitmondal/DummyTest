public with sharing class AP_JourneyStepProcessing {

        private static final String METADATA_MAPPINGTYPE_JNYSTEPTOACCMSG = 'JourneyStepToAccountMessage';
        
    
    // Inner Class to return Journey Details required by JourneyStep Lightning Component
    public with sharing class JourneyStepWrapper {
        
        @AuraEnabled
        public String userAlias{get;set;}
        
        @AuraEnabled
        public String journeyNumber{get;set;}
        
        @AuraEnabled
         public Integer JourneyStepId{get;set;}
    }
    
    // Method invoked by JourneyStep Lightning Component to get Journey Details
    @AuraEnabled
    public static JourneyStepWrapper getJourneyStepDetails (Id masterJnyId) {
        JourneyStepWrapper wrapperClassObj = new JourneyStepWrapper();
        Journey__c jny = new Journey__c ();
        jny = [Select id, JourneyNumber__c, name from Journey__c where id =: masterJnyId];
        wrapperClassObj.journeyNumber = jny.JourneyNumber__c;
        wrapperClassObj.userAlias = getUserAlias();
        wrapperClassObj.JourneyStepId = getJourneyStepId(masterJnyId);
        
        return wrapperClassObj;
    }
    
    // Method to retrieve logged in user's Alias
    private static String getUserAlias (){
        User loggedInUser = [Select id, Alias from User where id =: Userinfo.getUserId() Limit 1 ];
        return loggedInUser.Alias;
        
    }
    
    // Method to retrieve next Journey Step Id based on Journey Id
    private static Integer getJourneyStepId (Id journeyId ) {
        List<Journey_Step__c> jnyStepList = new List<Journey_Step__c>();    
        Integer stepId = 1;
        jnyStepList = [Select id, JourneyStepID__c from Journey_Step__c where JourneyID__c =: journeyId AND JourneyStepID__c !=null ORDER BY JourneyStepID__c  DESC LIMIT 1];
        if (!jnyStepList.isEmpty()) {
            Decimal stepId1 =jnyStepList[0].JourneyStepID__c;
            Decimal jnyStepId = stepId1++;
            stepId = Integer.valueOf(jnyStepId);
            stepId ++;
        }            
        return stepId;
    }
    }