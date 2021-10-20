@isTest
private class LeadProcessorTest {
    
    @testSetUp    
    private static void setUp(){
        List<Lead> leadsList = new List<Lead>();
        for(integer i=0;i<200;i++){
            leadsList.add(new Lead(LastName = 'LastName'+i,Company ='Lead'+i,LeadSource = 'Other'));            
        }
        insert leadsList;
    }
    
    private static testMethod void testBatch(){
        Test.startTest();
        LeadProcessor leadBatch = new LeadProcessor();
        Id batchId = Database.executeBatch(leadBatch);
        Test.stopTest();
        system.assertEquals(200, [select count() from lead where LeadSource = 'Dreamforce']);
    }

}