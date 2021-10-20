trigger JourneyAfterInsert on Journey__c (before insert,after Insert) {

        JourneyTriggerHandler.processJourneyStates(trigger.new);
    if(trigger.isInsert && trigger.isBefore){
        JourneyTriggerHandler.populateJourneyNonUiFields(trigger.new);
    }
}