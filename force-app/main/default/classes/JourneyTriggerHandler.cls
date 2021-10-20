public class JourneyTriggerHandler {
    
    private static List<String> statePickListValues;
    private static List<stateCode__mdt> metaDataStateCodeMapping;
    private static Map<String,String> stateCodeMap;    
    @TestVisible private static final integer JNYVENDORCODE = 0; 
    public static void processJourneyStates(List<Journey__c> jnyList){
        List<Journey__c> jnyListToInsert = new List<Journey__c>();
        List<Journey__c> jnyInnerList = new List<Journey__c>();
        retrieveStatePickListValues();
        retrieveStateCodeMapping();
        
        //iterate all Journey
        for(Journey__c masterJny : jnyList){
            if(String.isBlank(masterJny.StateCode__c) && (!String.isBlank(masterJny.State__c) || masterJny.AppliestoAllStates__c)){
                if(masterJny.AppliestoAllStates__c){
                    //build journey record for all states
                    jnyInnerList = buildJourneyforStates(masterJny ,statePickListValues);
                }
                else{
                    // build journey for user selected states
                    List<String> stateCodeList = new List<String>();
                    stateCodeList = masterJny.State__c.split(';');
                    jnyInnerList = buildJourneyforStates(masterJny ,stateCodeList);
                }
                jnyListToInsert.addAll(jnyInnerList);  
            }
            system.debug('jnyInnerList==='+jnyInnerList);
            
        }
        system.debug('jnyListToInsert==='+jnyListToInsert);
        if( !jnyListToInsert.isEmpty()){
            insert jnyListToInsert;            
            
        }
    }
    
    //Helper method to populate nonui fields in before insert
    public static void populateJourneyNonUiFields(List<JOurney__c>jnyList){
        try{
            User loggedinUser = [SELECT Alias from user where id = :userinfo.getUserId()LIMIT 1];
            for(Journey__C jny :jnyList ){
                if(String.isBlank(jny.Associate_ID__c)){
                    jny.Associate_ID__c  = loggedinUser.Alias;
                    jny.VendorCode__c = JNYVENDORCODE;
                    jny.InsertTimestamp__c = System.now();
                }
            }
        }
        catch(Exception e){
            e.getMessage();
        }
    }
    
    private static void retrieveStatePickListValues(){
        if(statePickListValues == null){
            Schema.DescribeFieldResult fieldResult = Journey__c.State__c.getDescribe();
            statePickListValues = new List<String>();
            List<Schema.PicklistEntry> ple = fieldResult.getPickListValues();
            for(Schema.PicklistEntry pickListVal :ple){
                statePickListValues.add(pickListVal.getLabel());            
            }
        }
    }
    
    private static List<Journey__c> buildJourneyforStates(Journey__c masterJourney, List<String> applicableStateCodeList){
        List<Journey__c> stateJourneyList = new List<Journey__c>();
        if(applicableStateCodeList != null && !applicableStateCodeList.isEmpty()){
            for(String stateCode: applicableStateCodeList){
                Journey__c stateJnyRecord = New Journey__c();
                
                //building journey record for each state in the passed list
               /* if(test.isRunningTest() && stateCode =='TX'){
                    stateJnyRecord.Associate_ID__c = 'aaaaaaaaaaaawsrrrrddddddddddddddddddddddddddddddddddddddddddddddvvgffdd';
                }
				*/
                
                stateJnyRecord.Associate_ID__c = masterJourney.Associate_ID__c;
                stateJnyRecord.CategoryName__c = masterJourney.CategoryName__c;
                stateJnyRecord.CreatorRoleCode__c = masterJourney.CreatorRoleCode__c;
                stateJnyRecord.Effective_Date__c = masterJourney.Effective_Date__c;
                stateJnyRecord.ExpirationDate__c = masterJourney.ExpirationDate__c;
                stateJnyRecord.JourneyFundingID__c = masterJourney.JourneyFundingID__c;
                stateJnyRecord.JourneyDescription__c = masterJourney.JourneyDescription__c;
                stateJnyRecord.Status__c = masterJourney.Status__c;
                stateJnyRecord.StepsNumber__c = masterJourney.StepsNumber__c;
                stateJnyRecord.TargetGroupCode__c = masterJourney.TargetGroupCode__c;   
                stateJourneyList.add(stateJnyRecord);
            }            
        }
        return stateJourneyList; 
    }
    private static void retrieveStateCodeMapping(){
        if(metaDataStateCodeMapping == null){
            metaDataStateCodeMapping = [Select DeveloperName, MasterLabel,
                                        StateCodeMap__c,
                                        Statecodevalue__c
                                        FROM stateCode__mdt];
            stateCodeMap = new Map<String,String>();
            if(metaDataStateCodeMapping != null && !metaDataStateCodeMapping.isEmpty()){
                for(stateCode__mdt mappingStateCode :metaDataStateCodeMapping){
                    stateCodeMap.put(mappingStateCode.Statecodevalue__c,mappingStateCode.StateCodeMap__c);                
                }
            }
        }
    }
    
    /* public Static void createJournyRecords(List<Journey__c> newJourneyList){
List<Journey__c> journyList=new List<Journey__c>();
Map<String,String> stateCodeMap =new Map<String,String>();
For(stateCode__mdt stateCode: [Select MasterLabel,
StateCodeMap__c,
Statecodevalue__c
FROM stateCode__mdt]){
stateCodeMap.put(stateCode.Statecodevalue__c,stateCode.StateCodeMap__c);
}
for(Journey__c objJourny: newJourneyList){
List<String> statePickList =new List<String>();
if(!String.isEmpty(objJourny.State__c)){
if(objJourny.State__c.Contains(';')){
statePickList =objJourny.State__c.split(';');                 
}
}           
if(!statePickList.isEmpty()){
for(String state: statePickList){
Journey__c clonedJourny = objJourny.clone();
clonedJourny.State__c =state;
clonedJourny.StateCode__c=stateCodeMap.get(state);
clonedJourny.Parent_Journey__c =objJourny.id;
journyList.add(clonedJourny);
}
}
else{
objJourny.StateCode__c=stateCodeMap.get(objJourny.State__c);
}
}
if(!journyList.isEmpty()){
insert journyList;
}
}
**/
}