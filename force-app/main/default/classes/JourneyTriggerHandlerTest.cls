@isTest(seeAllData=false)
public class JourneyTriggerHandlerTest {

    private static user sysAdminUser;
    
    public static void setup(){
        profile sysProfile = [Select id from profile where Name = 'System Administrator' Limit 1];
        sysAdminUser = buildTestUser('lakkamhemanth@ics.com', sysProfile);
    }
    
    public static User buildTestUser(String t_LastName, Profile testProfile){
        User testUser = new User(alias = 'test', email='testemail@ics.com',profileid = testProfile.id,
                                 userName= t_LastName+'@ics.com',
                                 LastName = t_LastName, TimeZoneSidKey ='Europe/London' , LocaleSidKey ='en_US' , EmailEncodingKey ='UTF-8' , LanguageLocaleKey ='en_US' );
        return testUser;        
    }
//method to create journey with the give param
/*
    private static void createJourneyRec
(List<Journey__c>journeys){
        if(journeys!= null && !journeys.isEmpty()){
            insert journeys;
        }
    }
*/
//method to create journey rec    
 private static journey__c buildJourneyRec(String Param_jnyName, integer param_vendorcode, 
                                           String param_jnyNumber, String param_creatorRoleCode, String param_applicablestates,
                                           Boolean param_appliestoallstates,String param_categname, String param_lineofbuss){
                                               Journey__c jny = new Journey__c(JourneyName__c = Param_jnyName,  BusinessLineCode__c=param_lineofbuss,CategoryName__c =param_categname,
                                                                               JourneyDescription__c = 'jny description '+param_applicablestates,VendorCode__c = param_vendorcode,JourneyNumber__c = param_jnyNumber,
                                                                               CreatorRoleCode__c = param_creatorRoleCode,Effective_Date__c = date.today(), ExpirationDate__c  = date.today(),
                                                                               State__c = param_applicablestates, AppliestoAllStates__c = param_appliestoallstates);
                                               return jny;
                                           }
    
    //method to insert single record
    private static testMethod void insertJourneyRecord(){        
        setup();
        Journey__c jnyRecord = buildJourneyRec('journey1',2,'test1','c','CO;CT;DE;DC;IL',false,'testcateg;Prospect customers','Auto;Fire');
        Test.startTest();
        System.runAs(sysAdminUser){
            insert jnyRecord;
            List<Journey__c> jnyList = [Select id,Name,StateCode__c,StateCodeMap__c from Journey__c];
            System.assertEquals(JnyRecord.CategoryName__c, 'testcateg;Prospect customers');
            //System.assertEquals(5, jnyList.size());
            for(Journey__c jrnyRec :jnyList){
                if(jrnyRec.StateCode__c.equals('13')){
                    System.assert(jrnyRec.StateCodeMap__c.equals('IL'));
                }
            }
        }
        Test.stopTest();
    }
    //method to insert jnyrecord with aplies to all states a true
    //if we check the applies to all states checkbo it will select all states after insert and it will insert 51 records    
    private static testMethod void insertJnyRecordWithAppliestoAllStates(){        
        setup();
        Journey__c jnyRecord = buildJourneyRec('journey1',2,'test1','c','',true,'testcateg;Prospect customers','Auto;Fire');
        Test.startTest();
        System.runAs(sysAdminUser){
            insert jnyRecord;
            //assertion to check if 51 records are inserted or not
            System.assertEquals(51, [Select id,JourneyName__c from journey__c].size());
            List<journey__c> journeyList = [Select id,Statecodemap__c,StateCode__c,name from Journey__c];
            for(Journey__c jny: journeyList){
                // after looping checking if one record is having these states and state codes or not
                // not sure if we can assert with in for loop 'Please comment/update'
            //System.assert(jny.StatecodeMap__c.contains('AZ'));
            //System.assert(jny.StateCode__c.contains('13'));                
            }
            
        }
        Test.stopTest();
    }
  //method insert journey list 
    private static testMethod void insertJourneyRecordList(){        
        setup();
         Test.startTest();
        Set<String> StateSet=new Set<String>{'NY','CT','CA','MN','KS','KY','IL','DE','NJ','NC','AZ','AL'};
        List<Journey__c> jnyList = new List<Journey__c>();
         jnyList.add(buildJourneyRec('journey1',2,'test1','c','NY;CT;CA;MN',false,'testcateg;Prospect customers','Auto;Fire'));
         jnyList.add(buildJourneyRec('journey2',2,'test1','c','KS;KY;IL;DE',false,'testcateg;Prospect customers','Auto;Fire'));
         jnyList.add(buildJourneyRec('journey3',2,'test1','c','NJ;NC;AZ;AL',false,'testcateg;Prospect customers','Auto;Fire'));
        // to cover before insert catch balock 
         //JourneyTriggerHandler.JNYVENDORCODE =1234573;
         insert jnyList;
         system.debug('jnyList===='+jnyList);   
        System.runAs(sysAdminUser){
                           
            for(Journey__c jny: [Select id,State__c,StateCode__c from Journey__C ]){ 
                system.debug('jny.State__c---'+jny.State__c);
                if(!jny.State__c.contains(';'))
                    System.assert(StateSet.contains(jny.State__c));                 
            }
        }
        Test.stopTest();
    }  
}