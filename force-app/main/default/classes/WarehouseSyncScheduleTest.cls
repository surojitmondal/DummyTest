@isTest
public class WarehouseSyncScheduleTest{
    
    private static testMethod void testWarehouseSyncSchd(){
        String sch = '0 0 0 * * ? 2020';
        Test.startTest();
            // Set mock callout class
            Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
            String jobId = System.schedule('ScheduledWarehouseTest', sch, new WarehouseSyncSchedule());
            
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            
            System.assertEquals(sch, ct.CronExpression);
        Test.stopTest();
    }
}