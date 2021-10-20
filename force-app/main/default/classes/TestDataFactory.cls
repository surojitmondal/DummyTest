public with sharing class TestDataFactory {
public static CollaborationGroup ConstructCollaborationGroup(){
        CollaborationGroup ChatterGroup = new CollaborationGroup( Name = 'TEST'+ Constants.INVENTORY_ANNOUNCEMENTS,  
                                                                   CollaborationType = 'Public',//CanHaveGuests = true,
                                                                   IsArchived = false,
                                                                   IsAutoArchiveDisabled = true
                                                                 );

        return ChatterGroup;
    }
public static List<Product2> ConstructProducts(Integer cnt){
        List<Product2> prodsToInst = new List<product2>(); 
        Schema.DescribeFieldResult fieldResult =Product2.Family.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(integer i=0;i< cnt;i++)
        {
                product2 p = new product2();
                 p.Name = 'Product Curry-'+ i ;
                 p.IsActive = true;
                 p.Initial_Inventory__c =10;
                 if(i>=4)
                 p.Family = constants.PRODUCT_FAMILY[0].getValue();
                 else if(i<4)
                 p.Family = constants.PRODUCT_FAMILY[i].getValue();
                
                prodsToInst.add(p);
        }
        return prodsToInst;  
    }
public static List<pricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        Id pricebookId = constants.STANDARD_PRICEBOOK_ID;//Test.getStandardPricebookId();
          List<pricebookEntry> PBEntryToInst = new List<pricebookEntry>(); 
        for( integer i=0 ;i < prods.size();i++){
          pricebookEntry pbe = new pricebookEntry ( Product2Id = prods[i].Id , PriceBook2Id = pricebookId,IsActive = true , UnitPrice = 10);
          PBEntryToInst.add(pbe);
        }
         return PBEntryToInst;                                         
}
public static List<Account> ConstructAccounts(Integer cnt){
       List<Account> AccListToInst = new List<Account>();
        for(integer i=0;i< cnt;i++) {
         Account acc = new Account ( Name = 'TestAcco' + i);
          AccListToInst.add(acc);
        }
        return AccListToInst;
    }
public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        List<Contact> ConListToInst = new List<Contact>();
       for(integer i=0;i< cnt;i++) {
             Contact con = new Contact ( LastName = 'TestCont' + i , AccountId = accts[i].Id);
             ConListToInst.add(con);
        }
        return ConListToInst;
}
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
//public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        List<Order> OrdListToInst = new List<Order>();
        //Id PricebookId = [SELECT Id From Pricebook2 WHERE IsStandard = true].Id
        Id pricebookId = constants.STANDARD_PRICEBOOK_ID;//Test.getStandardPricebookId();
		for(integer i=0;i< cnt;i++) {
             Order o = new Order ( EffectiveDate = Date.Today() , AccountId = accts[i].Id, Status = 'Draft',Pricebook2Id = pricebookId);
             OrdListToInst.add(o);
        }
        return OrdListToInst;
    }
   
public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        List<OrderItem> OrderItemListToInst = new List<OrderItem>();
        
       for(integer i=0;i< cnt;i++) {
            OrderItem oi = new OrderItem (Quantity = Constants.DEFAULT_ROWS, UnitPrice = 10,
                                          orderId = ords[i].Id, pricebookentryId = pbes[i].Id);
           OrderItemListToInst.add(oi);                               
        }  
          
        return OrderItemListToInst;
    }
public static void InsertTestData(Integer cnt){
        CollaborationGroup cg = ConstructCollaborationGroup();
        insert cg;
        List<Account> accountList = ConstructAccounts(cnt);
        insert accountList;
        List<Contact> contactList = ConstructContacts(cnt, accountList);
        insert contactList ;
        List<Product2> prodList = ConstructProducts(cnt);
        insert prodList ;
        List<PriceBookEntry> pbeEntry = ConstructPricebookEntries(prodList);
        insert pbeEntry ;
        List<Order> orderList = ConstructOrders(cnt, accountList);
        insert orderList ;
        List<OrderItem> itemList = ConstructOrderItems(cnt, pbeEntry , orderList);
        insert itemList ;

    }
    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){
       
         System.assertEquals(originalProduct.Quantity_Ordered__c + qtyOrdered , updatedProduct.Quantity_Ordered__c,'QuantityOrdered mismatch after update' );
       
       }

}