@IsTest(SeeAllData = false)
Private class AP_JourneyStepProcessing_TEST {
    private static User sysAdminUser;    
    //setup method
    public static void setup(){
        //create system Admin user and croporate marketing user to insert records
        Profile sysProfile = [Select Id from Profile where name = 'System Administrator' LIMIT 1];
        sysAdminUser = buildtestUser('remCmpMemSysAd@statefarm.com', sysProfile);               
    }
    
    //method to build user with the given parameter value
    public static User buildtestUser(String t_lastName, Profile testProfile) {
        User testUser= new User(alias = 'test', email= 'testuser@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=t_lastName, languagelocalekey='en_US', 
                                localesidkey='en_US', timezonesidkey='America/Chicago', username= t_lastName+'@statefarm.com');
        return testUser;
    }
    //method to build journey record with the given parameter value
    private static Journey__c buildJourneyRecord(String Param_JnyName,String param_applicablestates, Boolean param_appliestoall, String param_businesslinecode, String param_categoryname) {
                                                     Journey__c jny = new Journey__c(JourneyName__c=Param_JnyName, BusinessLineCode__c = param_businesslinecode,CategoryName__c = param_categoryname,
                                                                                     JourneyDescription__c='Jny description',
                                                                                     ExpirationDate__c = System.today()+60, State__c = param_applicablestates, AppliestoAllStates__c = param_appliestoall);
                                                     return jny;
                                                 }
    //method to build journey steps record with the given parameter value
    /*private static Journey_Step__c buildJourneyStepsRecord(String Param_JnyId, integer param_jnyStepID, String param_jnynumber,integer param_daysnum, String param_Contactmethodname) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = Param_JnyId , JourneyStepID__c = param_jnyStepID, 
         JourneyNumber__c = param_jnynumber, DaysNum__c = param_daysnum, ContactMethodName__c = param_contactmethodname,
         Cost__c= '0.28');
        return jnyStep;
    }
    **/
    //method to insert single journey record with selected states
    private static testMethod void insertJourneyRecord(){
        setup();
        Test.startTest();
        System.runAs(sysAdminUser){
        Journey__c jrnyRecord = buildJourneyRecord('Journey1','CO;CT;DE;DC',false, 'Auto;General','Corporate');                  
            insert jrnyRecord;          
            Journey_step__c jnyStep = new Journey_step__c(JourneyID__c=jrnyRecord.id,JourneyName__c='Test22',JourneyStepId__c=22,DaysNum__c=5,JourneyNumber__c='23y29483459');            
            insert jnyStep;       
        AP_JourneyStepProcessing.getJourneyStepDetails(jrnyRecord.id);
        }
        Test.stopTest();
    }

}