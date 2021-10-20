@isTest
public class myPriceBook_Test {
    static testMethod void testPriceBook(){
        Book__c b = new Book__c(Name = 'glimpses of the world history', Price__c = 100);
        Test.startTest();
        insert b;
        Test.stopTest();
        b = [SELECT Id,Name,Price__c from Book__C where id= :b.id];
        System.assertEquals(90, b.price__c);
    }
}