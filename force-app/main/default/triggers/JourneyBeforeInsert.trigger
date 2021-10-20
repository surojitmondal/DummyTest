trigger JourneyBeforeInsert on Journey__c (before insert) {
JourneyTriggerHandler.populateJourneyNonUiFields(trigger.new);
}