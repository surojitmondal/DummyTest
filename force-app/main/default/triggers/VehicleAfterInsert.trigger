trigger VehicleAfterInsert on Vehicle__c (After Insert) {

System.debug('BOOLEAN IS:'+VehicleAfterInsert_Handler.isFirstRun);
VehicleAfterInsert_Handler.testBoolean(Trigger.New);
}