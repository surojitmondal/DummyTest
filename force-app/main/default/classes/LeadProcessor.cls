global class LeadProcessor implements 
Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID,LeadSource FROM Lead'
        );
    }
    global void execute(Database.BatchableContext bc, List<Lead> scope){
        // process each batch of records
        List<Lead> leadList = new List<Lead>();
        for (Lead leadRec : scope) {
            leadRec.LeadSource = 'Dreamforce';
            leadList.add(leadRec);
        }
        update leadList;
    }
    
    global void finish(Database.BatchableContext bc){
        System.debug(' records processed.');
    }    
}