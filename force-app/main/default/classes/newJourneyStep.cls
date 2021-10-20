public class newJourneyStep{
/**
public with sharing class AP_JourneyStepProcessing {

    private static final String METADATA_MAPPINGTYPE_JNYSTEPTOACCMSG = 'JourneyStepToAccountMessage';
    private static final String CLASS_NAME = 'AP_JourneyProcessing';
    private static final String PREINSERT_METHODNAME = 'processJnyStepsPreInsert';
    private static final String POSTINSERT_METHODNAME = 'processJnyStepsPostInsert';
    public static Boolean INSERTTRIGGER_FIRST_RUN = true;
    
    /**Invoked by JourneyStep BeforeInsert Trigger
    *  This method will add JourneyStep records with related Journey Fields.
        
    public void processJnyStepsPreInsert (List <Journey_Step__c> JrnyStepList) {
        try {
            Set<Id> masterJrnyIdSet = new Set<Id>();
            Map<Id, Journey__c> masterJrnyIdToJourney = new Map<Id, Journey__c> ();
            for(Journey_Step__c jrnyStep : JrnyStepList) {
                masterJrnyIdSet.add(jrnyStep.JourneyID__c);
            }
        
            for (Journey__c masterJrny : [Select Id, JourneyName__c,StateCode__c , BusinessLineCode__c, CategoryName__c, JourneyFundingID__c
                                                from Journey__c where Id IN : masterJrnyIdSet] ) {
                masterJrnyIdToJourney.put(masterJrny.Id, masterJrny);
            }
        
            for (Journey_Step__c jrnyStepPreInsert : JrnyStepList) {
                jrnyStepPreInsert.JourneyName__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).JourneyName__c;
                jrnyStepPreInsert.StateCode__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).StateCode__c;
                jrnyStepPreInsert.BusinessLineCode__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).BusinessLineCode__c;
                jrnyStepPreInsert.CategoryName__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).CategoryName__c;
                jrnyStepPreInsert.Bundle_ID__c = masterJrnyIdToJourney.get(jrnyStepPreInsert.JourneyID__c).JourneyFundingID__c;
            }
        }
        catch (Exception jnyStepPreInsertExp) {
            LoggingService.logHandledException(jnyStepPreInsertExp, CLASS_NAME, PREINSERT_METHODNAME, LoggingLevel.ERROR);
        }
        
    }
    
    /**Invoked by JourneyStep AfterInsert Trigger
    *  This method will replicate current master JourneyStep into state JourneySteps based on State Journey records
   
    public void processJnyStepsPostInsert (List <Journey_Step__c> JrnyStepList) {
        try {
            Set<Id> masterJrnyIdSet = new Set<Id>();
            List<Journey_Step__c> jrnyStepListToInsert = New List<Journey_Step__c>();
            List<Journey__c> jrnyList = new List<Journey__c>();            
            //Map of MasterJourneyID and JourneyStep__c Object            
            Map<Id, List<Journey_Step__c>> mastJrnyIdJrnyStepMap = new Map<Id, List<Journey_Step__c>>();      
            //Map of JourneyId and MasterJourneyID
            Map<Id, Id> jrnyIdMasterJrnyIdMap = new Map<Id, Id>();
            
            // Iterate through JourneyStep List and collect thier JourneyId                    
            for(Journey_Step__c jrnyStep : JrnyStepList) {
                masterJrnyIdSet.add(jrnyStep.JourneyID__c);
                List<Journey_Step__c> stepsWithinTheMaster = mastJrnyIdJrnyStepMap.get(jrnyStep.JourneyID__c);
                if(stepsWithinTheMaster==null) {
                    stepsWithinTheMaster = new List<Journey_Step__c>();
                }
                stepsWithinTheMaster.add(jrnyStep);     
                mastJrnyIdJrnyStepMap.put(jrnyStep.JourneyID__c,stepsWithinTheMaster);              
            }
            // Based on above JourneyId, pull State Journey records that need JourneyStep replication   
            for (Journey__c stateJrnyRecord : [Select Id, MasterJourneyId__c, StateCode__c, Journey_External_ID__c 
                                                    from Journey__c where MasterJourneyId__c IN : masterJrnyIdSet]) {
                jrnyList.add(stateJrnyRecord);
                jrnyIdMasterJrnyIdMap.put(stateJrnyRecord.id, stateJrnyRecord.MasterJourneyId__c);
            }
            
            //Build Journey Step record for each State Journey record
            if (!jrnyList.isEmpty()) {
                for (Journey__c stateJrny : jrnyList) {                
                    Id masterJourneyId = jrnyIdMasterJrnyIdMap.get(stateJrny.id);
                    List<Journey_Step__c> listToBeCloned = mastJrnyIdJrnyStepMap.get(masterJourneyId);
                    for(Journey_Step__c theClonedJourneyStep: listToBeCloned) {
                        Journey_Step__c jnyStepToCreate = new Journey_Step__c ();
                        //Using the sObject clone method to copy JourneyStep   
                        jnyStepToCreate = theClonedJourneyStep.clone();
                        jnyStepToCreate.JourneyID__c = stateJrny.Id;
                        jnyStepToCreate.StateCode__c = stateJrny.StateCode__c;
                        //JourneyStep External Id
                        System.debug('Check1'+stateJrny.Journey_External_ID__c);
                                                System.debug('Check2'+theClonedJourneyStep.JourneyStepID__c);
                        if (stateJrny.Journey_External_ID__c != null && theClonedJourneyStep.JourneyStepID__c != null){
                            jnyStepToCreate.ExternalJourneyStepIdentifier__c = stateJrny.Journey_External_ID__c +'-'+ theClonedJourneyStep.JourneyStepID__c;
                            System.debug('##'+jnyStepToCreate.ExternalJourneyStepIdentifier__c);
                        }
                        jrnyStepListToInsert.add(jnyStepToCreate);
                    }   
                }            
                insert jrnyStepListToInsert;
            }
        }
        catch (Exception jnyStepPostInsertExp) {
            LoggingService.logHandledException(jnyStepPostInsertExp, CLASS_NAME, POSTINSERT_METHODNAME, LoggingLevel.ERROR); 
        }
    }
}
Test class-------------->


@IsTest(SeeAllData = false)
Private class AP_JourneyStepProcessing_TEST {
    private static User sysAdminUser;
    private static User corpMktingUser;
    private static final String SELECT_ID = 'select Id';      
    private static string querystringForLeadMessage='';
    private static string dynamicQuery='';
    private static string dynamicQuery1='';
    private static final String QUERY_DELIMETER = ',';
    private static list<CMOpportunityStartJourneyMapping__mdt> mappingForAccountMessagetoJourneyStep = [SELECT Id, MappingType__c, SourceField__c, TargetField__c
                                                                                                        FROM CMOpportunityStartJourneyMapping__mdt  WHERE MappingType__c = 'JourneyStepToAccountMessage' and SourceField__c != 'StateCode__c'];    
    //setup method
    public static void setup(){
        //create system Admin user and croporate marketing user to insert records
        Profile sysProfile = [Select Id from Profile WHERE name = 'System Administrator' LIMIT 1];
        sysAdminUser = buildtestUser('remCmpMemSysAd@statefarm.com', sysProfile);
        Database.insert(sysAdminUser);
        Profile corpMktingProfile = [Select Id from Profile WHERE name = '5.04 Corporate Marketing'];
        corpMktingUser = buildtestUser('corpMarketing@statefarm.com', corpMktingProfile);       
    }
    
    //method to build user with the given parameter value
    public static User buildtestUser(String t_lastName, Profile testProfile) {
        User testUser= new User(alias = 'test', email= 'testuser@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=t_lastName, languagelocalekey='en_US', 
                                localesidkey='en_US', timezonesidkey='America/Chicago', username= t_lastName+'@statefarm.com',
                                UserType__c='MarketingUser');
        return testUser;
    }
    //method to build journey record with the given parameter value
    private static Journey__c buildJourneyRecord(String Param_JnyName,String param_applicablestates, Boolean param_appliestoall, String param_businesslinecode, String param_categoryname, String param_Type) {
        Journey__c jny = new Journey__c(JourneyName__c=Param_JnyName, BusinessLineCode__c = param_businesslinecode,CategoryName__c = param_categoryname,
                                        JourneyDescription__c='Jny description',CustomDemographicsInd__c = true,EffectiveDate__c = System.today(),
                                        ExpirationDate__c = System.today()+60, ApplicableStates__c = param_applicablestates, AppliestoAllStates__c = param_appliestoall,Type__c = param_Type );
        return jny;
    }
    //method to build journey steps record with the given parameter value
    private static Journey_Step__c buildJourneyStepsRecord(String Param_JnyId, String param_Contactmethodname, String param_mailClassCode,String param_JourneyNumber,Decimal param_VendorCode,Decimal param_JourneyStepID) {
        Journey_Step__c jnyStep = new Journey_Step__c(JourneyID__c = Param_JnyId ,ContactMethodName__c = param_contactmethodname,Cost__c= '0.28', MailClassCode__c = param_mailClassCode,JourneyNumber__c = param_JourneyNumber,
                                                      VendorCode__c = param_VendorCode,CustomGreetingText__c='Hello, How are you',GiveawayOptionCode__c='b',GreetingCode__c='Hi',
                                                      LetterName__c ='New Letter',MediaTypeFilterText__c='This Text',PhotoOptionCode__c='A',PreferenceObjectID__c=123344,    SatelliteOfficeInd__c=false,Script__c='Description',StaffEmailID__c='Email',
                                                      StepTypeCode__c=22,TaskActionCode__c='B',TaskCategoryID__c=23433534,TaskHighPriorityInd__c=false,JourneyStepID__c=param_JourneyStepID);
        return jnyStep;
    }
    
    //method to insert single journey record with selected states and a journey step record
    private static testMethod void insertJourneyStepRecordwithSelectedStatesJourney(){
        setup();
        Test.startTest();
        System.runAs(sysAdminUser){
            Journey__c jrnyRecord = buildJourneyRecord('Journey1','CO;CT',false, 'Auto;General','Corporate assigned','Standard');                  
            insert jrnyRecord;
            Journey__c queryJrnyRecord = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                          JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                          EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null];            
            Journey_step__c jnyStep = buildJourneyStepsRecord(jrnyRecord.id,'Mailing','1','224489',queryJrnyRecord.VendorCode__c,1);
            insert jnyStep;
            List<Journey__c> queryJrnyList = [Select id,Name,JourneyName__c,JourneyFundingID__c,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                              JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,Journey_External_ID__c,
                                              EffectiveDate__c,ExpirationDate__c,TargetGroupCode__c,TimingTypeCode__c from Journey__c where   MasterJourneyId__c != null];
            if (mappingForAccountMessagetoJourneyStep != null && !mappingForAccountMessagetoJourneyStep.isEmpty()) {
                for(CMOpportunityStartJourneyMapping__mdt metamapping : mappingForAccountMessagetoJourneyStep) {                
                    querystringForLeadMessage = querystringForLeadMessage + QUERY_DELIMETER + metamapping.SourceField__c;
                }
            }
            dynamicQuery = SELECT_ID + querystringForLeadMessage +',ExternalJourneyStepIdentifier__c' +', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c = null' ;
            System.debug('This is the quesry:'+dynamicQuery);
            Journey_Step__c queryjrnyStepRecord = Database.query(dynamicQuery);    
            System.assertEquals('Journey1',queryjrnyStepRecord.JourneyName__c);
            System.assertEquals(queryjrnyStepRecord.Bundle_ID__c,queryJrnyRecord.JourneyFundingID__c);            
            System.assert(queryjrnyStepRecord.BusinessLineCode__c.contains('Auto') && queryjrnyStepRecord.BusinessLineCode__c.contains('General'));
            System.assertEquals('Corporate assigned',queryjrnyStepRecord.CategoryName__c);
            dynamicQuery1 = SELECT_ID + querystringForLeadMessage +',ExternalJourneyStepIdentifier__c' + ', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c != null' ;            
            List<Journey_Step__c> queryJnyStepList1 = Database.query(dynamicQuery1);            
            //System.assertEquals(4, queryJnyStepList1.size());
            for(Journey__c jnyRec : queryJrnyList){               
                for(Journey_Step__c jnyStepRec :queryJnyStepList1){
                    for(CMOpportunityStartJourneyMapping__mdt metadataMapping : mappingForAccountMessagetoJourneyStep){                                 
                        System.assertEquals(jnyStepRec.get(metadataMapping.SourceField__c), queryjrnyStepRecord.get(metadataMapping.SourceField__c));                       
                    }
                    System.assertEquals(jnyStepRec.Bundle_ID__c,queryJrnyRecord.JourneyFundingID__c);
                    String jnYStepExternalIdTocheck = null;
                    jnYStepExternalIdTocheck = jnyRec.Journey_External_ID__c +'-'+ queryjrnyStepRecord.JourneyStepID__c;
                    System.assertEquals(jnYStepExternalIdTocheck,jnyStepRec.ExternalJourneyStepIdentifier__c);
                }
            } 
        }
        Test.stopTest();
    }
    //method to insert single journey record with selected states and a journey step record Test
    private static testMethod void insertJourneyStepRecordwithSelectedStatesJourneyTest(){
        setup();
        Test.startTest();
        System.runAs(sysAdminUser){
            Journey__c jrnyRecord = buildJourneyRecord('Journey1','CO;CT;DE;DC',false, 'Auto;General','Corporate assigned','Standard');                  
            insert jrnyRecord;
            Journey__c queryJrnyRecord = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                          JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                          EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null];            
            Journey_step__c jnyStep = buildJourneyStepsRecord(jrnyRecord.id,'Mailing','1','224489',queryJrnyRecord.VendorCode__c,1);
            insert jnyStep;
            List<Journey_Step__c> queryJnyStep = [SELECT Bundle_ID__c, BusinessLineCode__c,CategoryName__c,ContactMethodName__c,Cost__c,CustomGreetingText__c,DaysNum__c,DesignationsInd__c,GiveawayOptionCode__c,
                                                  GreetingCode__c, GreetingOptionCode__c,InsertTimestamp__c,ItemEffectiveDate__c,ItemID__c,JourneyName__c, JourneyNumber__c,JourneyStepID__c,
                                                  LanguageCode__c, LanguageFilterCode__c,LetterName__c,MailCategoryCode__c,MailClassCode__c,MediaTypeFilterText__c,ObjectTypeID__c,PhotoOptionCode__c,PreferenceObjectID__c,
                                                  SatelliteOfficeInd__c,Script__c,SignatureOptionCode__c,StaffEmailID__c,StateCode__c,StepTypeCode__c,TaskActionCode__c,TaskCategoryID__c,
                                                  TaskHighPriorityInd__c,TPCreatedTimestamp__c,VendorCode__c,createdById FROM Journey_Step__c Where createdById =:sysAdminUser.id];
            System.debug('This is the createdById:'+queryJnyStep);
            System.debug('This is the Size'+queryJnyStep.size());
            //System.assertEquals(1,queryJnyStep.size());
            
        }
        Test.stopTest();
    }    
    //method to insert single journey record with Applies to all states and a journey step record
    private static testMethod void insertJourneyStepRecordwithAppliestoAllStatesJourney(){
        setup();
        Test.startTest();
        System.runAs(corpMktingUser){
            Journey__c jrnyRecord = buildJourneyRecord('Journey1','CO;CT;DE;DC',true, 'Auto;General','Corporate assigned','Standard');                  
            insert jrnyRecord;
            Journey__c queryJrnyRecord = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                          JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                          EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null];            
            Journey_step__c jnyStep = buildJourneyStepsRecord(jrnyRecord.id,'Mailing','1','224489',queryJrnyRecord.VendorCode__c,1);
            insert jnyStep;
            if (mappingForAccountMessagetoJourneyStep != null && !mappingForAccountMessagetoJourneyStep.isEmpty()) {
                for(CMOpportunityStartJourneyMapping__mdt metamapping : mappingForAccountMessagetoJourneyStep) {                
                    querystringForLeadMessage = querystringForLeadMessage + QUERY_DELIMETER + metamapping.SourceField__c;
                }
            }
            dynamicQuery = SELECT_ID + querystringForLeadMessage + ', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c = null' ;
            Journey_Step__c queryjrnyStepRecord =Database.query(dynamicQuery);
            System.assertEquals('Journey1',queryjrnyStepRecord.JourneyName__c);            
            System.assert(queryjrnyStepRecord.BusinessLineCode__c.contains('Auto') && queryjrnyStepRecord.BusinessLineCode__c.contains('General'));
            System.assertEquals('Corporate assigned',queryjrnyStepRecord.CategoryName__c);
            dynamicQuery1 = SELECT_ID + querystringForLeadMessage + ', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c != null' ;            
            List<Journey_Step__c> queryJnyStepList = Database.query(dynamicQuery1);
            System.debug('This is the jnyStepList:'+queryJnyStepList);            
            System.assertEquals(51, queryJnyStepList.size());
            for(Journey_Step__c jnyStepRec: queryJnyStepList){
                System.assertEquals(jnyStepRec.Bundle_ID__c,queryJrnyRecord.JourneyFundingID__c);              
            }
        }
        Test.stopTest();
    }    
    
    //method to insert list of journey steps
    private static testMethod void insertJourneyStepsListWithSelectedStates(){
        setup();
        Journey__c jrnyRecord = buildJourneyRecord('Journey1','CO;CT;DE;DC',false, 'Auto;General','Prospect customers','Standard');
        Test.startTest();
        System.runAs(corpMktingUser){            
            insert jrnyRecord;
            Journey__c queryJrnyRecord = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                          JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                          EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null];
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            jnystepsList.add(buildJourneyStepsRecord(jrnyRecord.id,'Mailing','1','224489',queryJrnyRecord.VendorCode__c,1));
            jnystepsList.add(buildJourneyStepsRecord(jrnyRecord.id,'Mailing','1','224489',queryJrnyRecord.VendorCode__c,2));
            jnystepsList.add(buildJourneyStepsRecord(jrnyRecord.id,'Mailing','1','224489',queryJrnyRecord.VendorCode__c,3));
            jnystepsList.add(buildJourneyStepsRecord(jrnyRecord.id,'Mailing','1','224489',queryJrnyRecord.VendorCode__c,4));            
            insert jnystepsList;
            if (mappingForAccountMessagetoJourneyStep != null && !mappingForAccountMessagetoJourneyStep.isEmpty()) {
                for(CMOpportunityStartJourneyMapping__mdt metamapping : mappingForAccountMessagetoJourneyStep) {                
                    querystringForLeadMessage = querystringForLeadMessage + QUERY_DELIMETER + metamapping.SourceField__c;
                }
            }
            dynamicQuery = SELECT_ID + querystringForLeadMessage + ', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c = null' ;
            List<Journey_Step__c> queryJnyStepList = Database.query(dynamicQuery);
            System.assertEquals(4, queryJnyStepList.size());
            dynamicQuery = SELECT_ID + querystringForLeadMessage + ', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c != null' ;
            List<Journey_Step__c> queryJnyStepList1 = Database.query(dynamicQuery);
            System.assertEquals(16, queryJnyStepList1.size());
            
        }
        Test.stopTest(); 
    }
    //method to insert list of journey steps with Applies to all states
    private static testMethod void insertJourneyStepsListWithAppliestoAllStates(){
        setup();
        Journey__c jrnyRecord = buildJourneyRecord('Journey1','CO;CT;DE;DC',true, 'Auto;General','Prospect customers','Standard');
        Test.startTest();
        System.runAs(corpMktingUser){            
            insert jrnyRecord;
            Journey__c queryJrnyRecord = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                          JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                          EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null];
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();
            jnystepsList.add(buildJourneyStepsRecord(jrnyRecord.id,'Mailing','1','224489',queryJrnyRecord.VendorCode__c,1));
            jnystepsList.add(buildJourneyStepsRecord(jrnyRecord.id,'Mailing','1','224489',queryJrnyRecord.VendorCode__c,2));           
            insert jnystepsList;
            if (mappingForAccountMessagetoJourneyStep != null && !mappingForAccountMessagetoJourneyStep.isEmpty()) {
                for(CMOpportunityStartJourneyMapping__mdt metamapping : mappingForAccountMessagetoJourneyStep) {                
                    querystringForLeadMessage = querystringForLeadMessage + QUERY_DELIMETER + metamapping.SourceField__c;
                }
            }
            dynamicQuery = SELECT_ID + querystringForLeadMessage + ', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c = null' ;
            List<Journey_Step__c> queryJnyStepList = Database.query(dynamicQuery);
            System.assertEquals(2, queryJnyStepList.size());
            dynamicQuery1 = SELECT_ID + querystringForLeadMessage + ', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c != null' ;            
            List<Journey_Step__c> queryJnyStepList1 = Database.query(dynamicQuery1);
            System.assertEquals(102, queryJnyStepList1.size());
        }
        Test.stopTest(); 
    }
    //method to insert journey list and journey step list
    private static testMethod void insertJourneyandJourneyStepsList(){
        setup();
        Test.startTest();
        System.runAs(corpMktingUser){
            List<Journey__c> journeyList=new List<Journey__c>();
            journeyList.add(buildJourneyRecord('Jny1','AZ;AL;MO;MN', false,'Auto;General','Corporate assigned','Standard'));
            journeyList.add(buildJourneyRecord('Jny2','', true,'Auto','Prospect customers','Standard'));
            journeyList.add(buildJourneyRecord('Jny3','KS;NY;IL', false,'Auto;Home - Fire','Prospect customers','Standard'));            
            insert journeyList;
            Journey__c queryJrnyRecord1 = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                           JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                           EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null AND JourneyName__c = 'Jny1'];
            Journey__c queryJrnyRecord2 = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                           JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                           EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null AND JourneyName__c = 'Jny2'];
            Journey__c queryJrnyRecord3 = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                           JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                           EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null AND JourneyName__c = 'Jny3'];
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();            
            jnystepsList.add(buildJourneyStepsRecord(journeyList[0].id,'Mailing','1','224489',queryJrnyRecord1.VendorCode__c,1));
            jnystepsList.add(buildJourneyStepsRecord(journeyList[0].id,'Mailing','1','224489',queryJrnyRecord1.VendorCode__c,2));
            jnystepsList.add(buildJourneyStepsRecord(journeyList[1].id,'Mailing','1','224489',queryJrnyRecord2.VendorCode__c,1));
            jnystepsList.add(buildJourneyStepsRecord(journeyList[2].id,'Mailing','1','224489',queryJrnyRecord3.VendorCode__c,1));            
            insert jnystepsList;
            if (mappingForAccountMessagetoJourneyStep != null && !mappingForAccountMessagetoJourneyStep.isEmpty()) {
                for(CMOpportunityStartJourneyMapping__mdt metamapping : mappingForAccountMessagetoJourneyStep) {                
                    querystringForLeadMessage = querystringForLeadMessage + QUERY_DELIMETER + metamapping.SourceField__c;
                }
            }
            dynamicQuery = SELECT_ID + querystringForLeadMessage + ', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c = null' ;
            List<Journey_Step__c> queryJnyStepList = Database.query(dynamicQuery);
            System.assertEquals(4,queryJnyStepList.size());
            dynamicQuery1 = SELECT_ID + querystringForLeadMessage + ', DaysNum__c' +', JourneyName__c' +', BusinessLineCode__c' +', CategoryName__c' +' From Journey_Step__c WHERE JourneyID__r.MasterJourneyId__c != null' ;            
            List<Journey_Step__c> queryJnyStepList1 = Database.query(dynamicQuery1);
            System.assertEquals(62,queryJnyStepList1.size());
        }
        Test.stopTest(); 
    }
    
    //method to insert journey list and journey step list Test
    private static testMethod void insertJourneyandJourneyStepsListTest(){
        setup();
        Test.startTest();
        System.runAs(corpMktingUser){
            List<Journey__c> journeyList=new List<Journey__c>();
            journeyList.add(buildJourneyRecord('Jny1','AZ;AL;MO', false,'Auto;General','Corporate assigned','Standard'));
            journeyList.add(buildJourneyRecord('Jny2','CT;CO;DC', false,'Auto','Prospect customers','Standard'));
            journeyList.add(buildJourneyRecord('Jny3','KS;NY;IL', false,'Auto;Home - Fire','Prospect customers','Standard'));            
            insert journeyList;
            Journey__c queryJrnyRecord1 = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                           JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                           EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null AND JourneyName__c = 'Jny1'];
            Journey__c queryJrnyRecord2 = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                           JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                           EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null AND JourneyName__c = 'Jny2'];
            Journey__c queryJrnyRecord3 = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                           JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                           EffectiveDate__c,ExpirationDate__c,AssociateId__c,JourneyFundingID__c from Journey__c WHERE MasterJourneyId__c = null AND JourneyName__c = 'Jny3'];
            List<Journey_Step__c> jnystepsList = new List<Journey_Step__c>();            
            jnystepsList.add(buildJourneyStepsRecord(journeyList[0].id,'Mailing','1','224489',queryJrnyRecord1.VendorCode__c,1));            
            jnystepsList.add(buildJourneyStepsRecord(journeyList[1].id,'Mailing','1','224489',queryJrnyRecord2.VendorCode__c,1));
            jnystepsList.add(buildJourneyStepsRecord(journeyList[2].id,'Mailing','1','224489',queryJrnyRecord3.VendorCode__c,1));            
            insert jnystepsList;           
            for(Journey__c objJourney :[Select id,Name from Journey__c where MasterJourneyId__c != null]){
                //System.assertEquals(3,[Select id,name from Journey_Step__c where JourneyID__c = :objJourney.Id].size());                              
            }
        }
        Test.stopTest(); 
    }
    
    //method to Bypass trigger
    private static testMethod void insertJourneyRecordAfterTriggerBypass(){
        setup();        
        CS001_ByPassTriggerAll__c PassTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c= true);
        insert PassTriggerAll;      
        Journey__c jrnyRecord = buildJourneyRecord('Journey1','CO;CT;DE;DC',false, 'General;Auto','Corporate assigned;Prospect customers','Xdate');         
        Test.startTest();
        System.runAs(corpMktingUser){            
            insert jrnyRecord;
            Journey__c queryJrnyRecord = [Select id,JourneyName__c,Name,StateCode__c,categoryName__c,BusinessLineCode__c,JourneyDescription__c,VendorCode__c,StateCodemap__c,
                                          JourneyNumber__c,CreatorRoleCode__c,CustomDemographicsInd__c,InsertTimestamp__c,
                                          EffectiveDate__c,ExpirationDate__c,AssociateId__c from Journey__c WHERE MasterJourneyId__c = null];            
            System.assertEquals(1,[Select id, Name from Journey__c WHERE MasterJourneyId__c = null].size());
            Journey_step__c jnyStep = buildJourneyStepsRecord(queryJrnyRecord.id,'Mailing','1','224489',0,1);
            insert jnyStep;            
            System.assertEquals(1,[SELECT Id,Name FROM Journey_Step__c].size());                        
        }
        Test.stopTest();        
    }
    
    //test method to check exceptions
    private static testMethod void insertJourneyStepWithException(){        
        List<Journey_step__c> jnyStepList = new List<Journey_Step__c>();        
        AP_JourneyStepProcessing jnyStepProcessing = new AP_JourneyStepProcessing();
        String message = '';
        try{        
            jnyStepProcessing.processJnyStepsPreInsert(null);
            jnyStepProcessing.processJnyStepsPostInsert(null);
        }
        catch(Exception e){
            message = e.getMessage();
            System.assert(!String.isBlank(message));
        }        
    }
}

    **/
}