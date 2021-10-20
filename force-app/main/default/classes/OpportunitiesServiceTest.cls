@isTest
public class OpportunitiesServiceTest {
 
 
   private static testMethod void discountShouldBeZero(){
       System.assertEquals(0, createOpportunity(0).Discount__c);
   } 
   
   private static testMethod void discountShouldBeTen(){
       System.assertEquals(10, createOpportunity(15).Discount__c);
   }
 
   private static testMethod void discountShouldBeTwenty(){
       System.assertEquals(20, createOpportunity(25).Discount__c);
   }
 
   
   private static testMethod void discountShouldBeFifty(){
       System.assertEquals(30, createOpportunity(50).Discount__c);
   }
 
   private static Opportunity createOpportunity(Integer amount){
      Account a = new Account(Name = 'Test');
      insert a;
         
      DiscountsService mockDS = (DiscountsService) Test.createStub(DiscountsService.class, new MockDiscountsService(amount));
         
      Opportunity o = new OpportunitiesService(mockDS).createOpportunity(a.Id);
      return o;
   }
     
}