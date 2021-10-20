@isTest
private class MaintenanceRequestTest{
    @testSetup
    static void setup(){
        //Equipment SETUP
        List<Product2> equipmentList = new List<Product2>();
        
        Product2 eqip = new Product2(Name = 'Test Equipment', 
                                     Maintenance_Cycle__c = 10,
                                     Cost__c = 100,
                                     Current_Inventory__c = 10,
                                     Lifespan_Months__c = 10,
                                     Replacement_Part__c = true,
                                     Warehouse_SKU__c = 'abc');
        equipmentList.add(eqip);
        insert equipmentList;
    }
    
    
    private static testMethod void testMaintenanceRequest(){
        List<Case> caseInsertList = new List<Case>();
        
        List<Case> caseUpdateList = new List<Case>();
        
        Id equipId = [SELECT Id FROM Product2 LIMIT 1].get(0).Id;
        
        for(Integer i = 1; i <= 300; i++){
            Case caseRecord = new Case(Type = 'Routine Maintenance', Status = 'New', Origin = 'Phone',Description = 'Description' + i);
            caseRecord.Equipment__c = equipId;
            
            caseInsertList.add(caseRecord);
        }
        
        Test.startTest();
            insert caseInsertList;
            
            System.assertEquals(300, caseInsertList.size());
            
            for(Case caseUpdateRecord : caseInsertList){
                caseUpdateRecord.Status = 'Closed';
                caseUpdateList.add(caseUpdateRecord);
            }
            
            update caseUpdateList;
            
            System.assertEquals(300, caseUpdateList.size());
        Test.stopTest();
    }
    
 private static testMethod void testNotMaintenanceRequest(){
        List<Case> caseInsertList = new List<Case>();
        
        List<Case> caseUpdateList = new List<Case>();
        
        Id equipId = [SELECT Id FROM Product2 LIMIT 1].get(0).Id;
        
        for(Integer i = 1; i <= 300; i++){
            Case caseRecord = new Case(Type = 'Routine', Status = 'New', Origin = 'Phone',Description = 'Description' + i);
            caseRecord.Equipment__c = equipId;
            
            caseInsertList.add(caseRecord);
        }
        
        Test.startTest();
            insert caseInsertList;
            
            System.assertEquals(300, caseInsertList.size());
            
            for(Case caseUpdateRecord : caseInsertList){
                caseUpdateRecord.Status = 'Closed';
                caseUpdateList.add(caseUpdateRecord);
            }
            
            update caseUpdateList;
            
            System.assertEquals(300, caseUpdateList.size());
        Test.stopTest();
    }
    
    
    
}