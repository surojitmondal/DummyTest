public class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(Map<Id, Case> applicableCaseMap){
		System.debug('*******Inside MaintenanceRequestHelper Class*******');
	    Map<Id, Integer> mapProduct = new Map<Id, Integer>(); 
   		List<Case> newCaseList = new List<Case>();
        
        List<Product2> productList = [select Id, Maintenance_Cycle__c from Product2];       							
		for (Product2 productRecord : productList) {
            if (productRecord != null) {
                if(productRecord.Maintenance_Cycle__c != null){
                    mapProduct.put(productRecord.Id, Integer.valueOf(productRecord.Maintenance_Cycle__c));
                }               
            }
        }

        for(Case caseRecord: applicableCaseMap.values()){
            Case newCase = new Case();
            newCase.Vehicle__c = caseRecord.Vehicle__c;
            newCase.Equipment__c = caseRecord.Equipment__c;
            newCase.Type = 'Routine Maintenance';
            newCase.Subject = String.isBlank(caseRecord.Subject) ? 'Routine Maintenance Request' : caseRecord.Subject;
            newCase.Date_Reported__c = Date.today();
            newCase.Status = 'New';
            newCase.Product__c = caseRecord.Product__c;
            newCase.AccountId = caseRecord.AccountId;
            newCase.ContactId = caseRecord.ContactId;
            newCase.AssetId = caseRecord.AssetId;
            newCase.Origin = caseRecord.Origin;
            newCase.Reason = caseRecord.Reason;
            newCase.Date_Due__c =  (mapProduct.get(caseRecord.Id) != null) ? (Date.today().addDays(Integer.valueOf(mapProduct.get(caseRecord.Id)))) : (Date.today());
            newCaseList.add(newCase);
        }
        if(newCaseList.size() > 0){
            insert newCaseList;
        }        
        
    }        
    
}