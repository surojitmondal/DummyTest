trigger MaintenanceRequest on Case (before update, after update) {
    // call MaintenanceRequestHelper.updateWorkOrders  
    Map<Id,Case> caseMap = new Map<Id,Case>();
    
    if(Trigger.isUpdate  && Trigger.isAfter){
        system.debug('Entrance');
        for(Case caseRecord : Trigger.new){
            if (caseRecord.IsClosed && (caseRecord.Type.equals('Repair') || caseRecord.Type.equals('Routine Maintenance'))){
                caseMap.put(caseRecord.Id, caseRecord);
            }
        }
        if(caseMap.size() > 0){
            system.debug('I am Here');
        	MaintenanceRequestHelper.updateWorkOrders(caseMap);    
        }        
    } 
}