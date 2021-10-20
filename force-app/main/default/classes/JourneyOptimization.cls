public class JourneyOptimization{
/****************************************************************************************


public with sharing class AP_JourneyEditAndDeleteTrigger {
    
    private static final String CLASS_NAME = 'AP_JourneyEditAndDeleteTrigger';
    private static final String DELETE_METHOD_NAME = 'processJourneysDelete';
    private static final String UPDATE_METHOD_NAME = 'processEditJourney';
    private static Boolean isDeleteTriggerFirstRun = true;
    private static Boolean isUpdateTriggerFirstRun = true;
    public static final String JOURNEY_EDITDELETE_ERRORMESSAGE = System.Label.CL_JOURNEY_EDITDELETE_ERRORMSG;
    private static List<Id> masterJourneyIdList;
    private static Map<Id, List<Journey__c>> masterJourneyToChildJourneyListMap;
    private static Map<Id, List<Journey_Step__c>> masterJourneyToMasterJourneyStepListMap;
    private static Map<Id, List<Journey_Step__c>> masterJourneyToChildJourneyStepListMap;
    private static List<Journey_Step__c> jnyStepList;
    
    
    * @method - processJourneysDelete
    * @description - This method will be invoked by JourneyBeforeDelete Trigger
    *                If there are any child records in the list it will revert the whole transaction, else it will delete all the 
    *                child journeys associated with the master journey record
    * @param journeyList - List of Journey__c records passed by deleted Trigger operation
    
    public static void processJourneysDelete(List<Journey__c> journeyList){
        if (isDeleteTriggerFirstRun){
            try{ 
                Boolean stateJourneyFound = evaluateMasterAndChildJourney(journeyList);             
                if (stateJourneyFound) {
                    errorOnStateJourney(journeyList);
                } else {
                    deleteChildJourneysForMaster(); 
                }
            }
            catch (Exception jnyBeforeDeleteException){
                LoggingService.logHandledException(jnyBeforeDeleteException, CLASS_NAME, DELETE_METHOD_NAME, LoggingLevel.ERROR);
            }
        }
    }

    
    * @method - processEditJourney
    * @description - This method will be invoked by JourneyBeforeUpdate Trigger
    *                If there are any child records in the list it will revert the whole transaction, else it will update all the 
    *                child journeys associated with the master journey record
    * @param journeyList - List of Journey__c records passed by Before Update Trigger operation
    * @param oldJourneyMap - Map of Id to the old version of the journey record
    
    public static void processEditedJourneys(List<Journey__c> journeyList,Map<Id,Journey__c> oldJourneyMap){
        if (isUpdateTriggerFirstRun){
            try{ 
                Boolean stateJourneyFound = evaluateMasterAndChildJourney(journeyList);             
                if (stateJourneyFound) {
                    errorOnStateJourney(journeyList);
                } else {
                    queryStateJourneysForEditOperation(journeyList,oldJourneyMap); 
                }
            }
            catch (Exception jnyBeforeUpdateException){
                LoggingService.logHandledException(jnyBeforeUpdateException, CLASS_NAME, UPDATE_METHOD_NAME, LoggingLevel.ERROR);
            }
        }
    }
    
    //Helper method to evaluate master or child journey
    private static Boolean evaluateMasterAndChildJourney(List<Journey__c> journeyList) {
        masterJourneyIdList = new List<Id>();
        Boolean stateJourneyFound = false;
        for(Journey__c jny : journeyList) {
            if(String.isNotBlank(jny.MasterJourneyId__c)){
                stateJourneyFound = true;
                break;
            } else {
                masterJourneyIdList.add(jny.id);
            }       
        }
        return stateJourneyFound;   
    }
    
    //Helper method to process master journeys and error out child journeys found
    private static void errorOnStateJourney(List<Journey__c> journeyList){
        for(Journey__c jny : journeyList){
            jny.addError(JOURNEY_EDITDELETE_ERRORMESSAGE);
        }
    }
    
    //Helper method to query state journeys and process edit 
    private static void queryStateJourneysForEditOperation (List<Journey__c> masterJourneyList,Map<Id,Journey__c> oldJourneyMap) {
        populateUpdatedTargetGroupCode(masterJourneyList,oldJourneyMap);
        List<Journey__c> queriedStateJourneysList = getStateJourneyList();
        populateMasterJourneyToStateJourneysMap(queriedStateJourneysList);
        applyEditedMasterJrnyToStateJrny(masterJourneyList);
        populateJourneyToJourneyStepsMap();
        //updateJourneyStepsList(masterJourneyList);
        
    }
    
    //Helper method to update TargetGroupCode__c if applicable 
    private static void populateUpdatedTargetGroupCode(List<Journey__c> journeyList,Map<Id,Journey__c> oldJourneyMap){        
        for(Journey__c updatedMasterjny : journeyList){
            Journey__c oldJourney = oldJourneyMap.get(updatedMasterjny.Id);
            if(oldJourney.CategoryName__c != updatedMasterjny.CategoryName__c){
                updatedMasterjny.TargetGroupCode__c = AP_JourneyProcessing.getTargetGroupCode(updatedMasterjny);
            }
        }
    }
    
    //Helper method to query state journey based on passed master journey Id's list
    private static List<Journey__c> getStateJourneyList () {
        return [Select id, MasterJourneyId__c, JourneyName__c from Journey__c where masterJourneyId__c IN:masterJourneyIdList];
    }
    
    //Helper method to form a map of master journey tied with a list of state journey's
    private static void populateMasterJourneyToStateJourneysMap (List<Journey__c> stateJourneyList) {
        masterJourneyToChildJourneyListMap = new Map<Id, List<Journey__c>>();
        List<Journey__c> stateJourneyListForMap;
        for (Journey__c stateJourney : stateJourneyList) {
            stateJourneyListForMap = masterJourneyToChildJourneyListMap.get(stateJourney.masterJourneyId__c);
            if(stateJourneyListForMap == null){               
                stateJourneyListForMap = new List<Journey__c> ();                
            }
            stateJourneyListForMap.add(stateJourney);            
            masterJourneyToChildJourneyListMap.put(stateJourney.masterJourneyId__c, stateJourneyListForMap);
        }
    }

    //Helper method to form a map of master journey tied with a list of state journey's
    private static void populateMasterJourneyToStateJourneysMap_Aneesh (List<Journey__c> stateJourneyList) {
        masterJourneyToChildJourneyListMap = new Map<Id, List<Journey__c>>();
        List<Journey__c> stateJourneyListForMap;
        for (Journey__c stateJourney : stateJourneyList) {
            if(!masterJourneyToChildJourneyListMap.containsKey(stateJourney.masterJourneyId__c)) {
                masterJourneyToChildJourneyListMap.put(stateJourney.masterJourneyId__c, new List<Journey__c> ());
            }

            masterJourneyToChildJourneyListMap.get(stateJourney.masterJourneyId__c).add(stateJourney);
        }
    }
    
    //Helper method to apply masterjourney updates to child journey
    private static void applyEditedMasterJrnyToStateJrny(List<Journey__c> masterJourneyListToBeCopied){
        List<Journey__c> childJourneyListToBeUpdated = new List<Journey__c>();
        for (Journey__c masterEditedJourney : masterJourneyListToBeCopied){
            for (Journey__c stateJourney : masterJourneyToChildJourneyListMap.get(masterEditedJourney.id)){
                
                stateJourney.JourneyName__c = masterEditedJourney.JourneyName__c;
                stateJourney.JourneyDescription__c = masterEditedJourney.JourneyDescription__c;
                stateJourney.EffectiveDate__c = masterEditedJourney.EffectiveDate__c;
                stateJourney.ExpirationDate__c = masterEditedJourney.ExpirationDate__c;  
                stateJourney.BusinessLineCode__c = masterEditedJourney.BusinessLineCode__c;
                stateJourney.CategoryName__c = masterEditedJourney.CategoryName__c;
                stateJourney.TargetGroupCode__c = masterEditedJourney.TargetGroupCode__c;
                childJourneyListToBeUpdated.add(stateJourney);
            }
        }
        updateChildJourneyList(childJourneyListToBeUpdated);
    }
    
    //Helper method to update journey list
    private static void updateChildJourneyList(List<Journey__c> childJourneyListToBeUpdated) {
        if(!childJourneyListToBeUpdated.isEmpty() && Schema.sObjectType.Journey__c.isUpdateable()){ 
            isUpdateTriggerFirstRun = false;           
            update childJourneyListToBeUpdated;
        }
    }
    
    //Helper method to delete child journeys related to master journey
    private static void deleteChildJourneysForMaster(){
        if(!masterJourneyIdList.isEmpty()){
            List<Journey__c> childJnyListToBeDeleted = [Select Id from Journey__c where MasterJourneyId__c IN:masterJourneyIdList WITH SECURITY_ENFORCED];
            if(!childJnyListToBeDeleted.isEmpty() && Schema.sObjectType.Journey__c.isDeletable()){                
                isDeleteTriggerFirstRun = false;                
                delete childJnyListToBeDeleted;
            }
        }
    }
    
    //Helper method to map list of journey steps with associated edited master journey
    private static void populateJourneyToJourneyStepsMap(){
        jnyStepList = [Select id,JourneyId__c,JourneyId__r.Masterjourneyid__c from journey_Step__c where journeyid__c IN:masterJourneyIdList OR journeyid__r.masterjourneyid__c IN:masterJourneyIdList];      
        populateJourneyToMasterJourneyStepsMap(jnyStepList);
        //populateJourneyToChildJourneyStepsMap(jnyStepList);
    }
    
    //Helper method to map list of master journey steps with associated edited master journey
    private static void populateJourneyToMasterJourneyStepsMap(List<Journey_Step__c> jnyStepList){
        masterJourneyToMasterJourneyStepListMap = new Map<Id, List<Journey_Step__c>>();
        List<Journey_Step__c> masterJourneyStepListForMap;
        for (Journey_Step__c masterJourneyStep : jnyStepList) {
            masterJourneyStepListForMap = masterJourneyToMasterJourneyStepListMap.get(masterJourneyStep.JourneyId__c);
            
            if(masterJourneyStepListForMap == null){               
                masterJourneyStepListForMap = new List<Journey_Step__c> ();
            }               
            masterJourneyStepListForMap.add(masterJourneyStep);            
            masterJourneyToMasterJourneyStepListMap.put(masterJourneyStep.JourneyId__c, masterJourneyStepListForMap);   
        }
    }
    
    //Helper method to map list of child journey steps with associated edited master journey
    private static void populateJourneyToChildJourneyStepsMap(List<Journey_Step__c> jnyStepList){
        masterJourneyToChildJourneyStepListMap = new Map<Id, List<Journey_Step__c>>();
        List<Journey_Step__c> childJourneyStepListForMap;
        for (Journey_Step__c childJourneyStep : jnyStepList) {
            childJourneyStepListForMap = masterJourneyToChildJourneyStepListMap.get(childJourneyStep.JourneyId__r.Masterjourneyid__c);
            if(childJourneyStepListForMap == null){               
                childJourneyStepListForMap = new List<Journey_Step__c> ();
            }
            childJourneyStepListForMap.add(childJourneyStep);           
            masterJourneyToChildJourneyStepListMap.put(childJourneyStep.JourneyId__r.Masterjourneyid__c, childJourneyStepListForMap);
        }
    }
    
    //Helper method to update journeysteps
    private static void updateJourneyStepsList(List<Journey__c> masterJourneyList){
        List<Journey_Step__c> jrnyStepListToBeUpdated = new List<Journey_Step__c>();
        for(Journey__c masterEditedJourney : masterJourneyList){
            List<Journey_Step__c> jrnyStepList = new List<Journey_Step__c>();
            jrnyStepList.addAll(masterJourneyToMasterJourneyStepListMap.get(masterEditedJourney.id));
            jrnyStepList.addAll(masterJourneyToChildJourneyStepListMap.get(masterEditedJourney.id));
            for (Journey_Step__c masterJrnyStep : jrnyStepList){
                masterJrnyStep.JourneyName__c = masterEditedJourney.JourneyName__c;
                masterJrnyStep.BusinessLineCode__c = masterEditedJourney.BusinessLineCode__c;
                masterJrnyStep.CategoryName__c = masterEditedJourney.CategoryName__c;
                jrnyStepListToBeUpdated.add(masterJrnyStep);
            }
        }
        updateJourneySteps(jrnyStepListToBeUpdated);
    }

    //method to update journey steps
    private static void updateJourneySteps(List<Journey_Step__c> jrnyStepListToBeUpdated){
        if(!jrnyStepListToBeUpdated.isEmpty() && Schema.sObjectType.Journey_Step__c.isUpdateable()){
            Database.update(jrnyStepListToBeUpdated, false);
        }
    }

}

//Helper method to map list of journeysteps with associated journey
    private static void populateJourneytoJourneyStepMap(){
        List<Journey__c> journeyAndStepsList = [Select id,MasterJourneyId__c,JourneyName__c,BusinessLineCode__c,CategoryName__c, (Select id from Journey_Step__r) from Journey__c where Id IN: masterJourneyIdList OR MasterJourneyId__c IN: masterJourneyIdList];      
        
        populateJourneyToMasterJourneyStepsMap(journeyAndStepsList);
        populateJourneyToChildJourneyStepsMap(journeyAndStepsList);
        
        //updateJourneyStepsList(journeyAndStepsList);        
    }
    
    //Updated but not working
    //Helper method to map list of master journey steps with associated edited master journey
    private static void populateJourneyToMasterJourneyStepsMap(List<Journey__c> journeyAndStepsList){
        masterJourneyToMasterJourneyStepListMap = new Map<Id, List<Journey_Step__c>> ();
        
        for (Journey__c jrny : journeyAndStepsList){
        	List<Journey_Step__c> masterJourneyStepList = new List<Journey_Step__c>();            
            masterJourneyStepList.addAll(jrny.Journey_Step__r);
            masterJourneyToMasterJourneyStepListMap.put(jrny.id,masterJourneyStepList);
        }
    }
    
    //Helper method to map list of child journey steps with associated edited master journey
    private static void populateJourneyToChildJourneyStepsMap(List<Journey__c> journeyAndStepsList){
        masterJourneyToChildJourneyStepListMap = new Map<Id, List<Journey_Step__c>> ();
        List<Journey_Step__c> childJourneyStepList = new List<Journey_Step__c>();
        for (Journey__c jrny : journeyAndStepsList){
            
            childJourneyStepList.addAll(jrny.Journey_Step__r);
            masterjourneyToChildJourneyStepListMap.put(jrny.masterjourneyid__c, childJourneyStepList);
        }
    }
    
   //Helper method to update journeysteps
    private static void updateJourneyStepsList(List<Journey__c> masterJourneyList){
        Map<Id, Journey_Step__c> jrnyStepListToBeUpdated = new Map<Id,Journey_Step__c>();
        for(Journey__c masterEditedJourney : masterJourneyList){     
        	List<Journey_Step__c> jrnyStepList = new List<Journey_Step__c>();       
            jrnyStepList.addAll(masterJourneyToMasterJourneyStepListMap.get(masterEditedJourney.id));
            jrnyStepList.addAll(masterJourneyToChildJourneyStepListMap.get(masterEditedJourney.id));
            for (Journey_Step__c masterJrnyStep : jrnyStepList){
                masterJrnyStep.JourneyName__c = masterEditedJourney.JourneyName__c;
                masterJrnyStep.BusinessLineCode__c = masterEditedJourney.BusinessLineCode__c;
                masterJrnyStep.CategoryName__c = masterEditedJourney.CategoryName__c;
                jrnyStepListToBeUpdated.put(masterJrnyStep.Id, masterJrnyStep);
            }
        }
        updateJourneySteps(jrnyStepListToBeUpdated.values());
    }

    
   //Helper method to update journeysteps
    private static void updateJourneyStepsList_Aneesh(List<Journey__c> masterJourneyList){
        List<Journey_Step__c> jrnyStepListToBeUpdated = new List<Journey_Step__c>();
        for(Journey__c masterEditedJourney : masterJourneyList){            
            jrnyStepListToBeUpdated.addAll(masterJourneyToMasterJourneyStepListMap.get(masterEditedJourney.id));
            jrnyStepListToBeUpdated.addAll(masterJourneyToChildJourneyStepListMap.get(masterEditedJourney.id));
            for (Journey_Step__c masterJrnyStep : jrnyStepListToBeUpdated){
                masterJrnyStep.JourneyName__c = masterEditedJourney.JourneyName__c;
                masterJrnyStep.BusinessLineCode__c = masterEditedJourney.BusinessLineCode__c;
                masterJrnyStep.CategoryName__c = masterEditedJourney.CategoryName__c;
            }
        }
        updateJourneySteps(jrnyStepListToBeUpdated);
    }

*/


}