public class myPriceBook {
    public static void 	applyDiscountBooks(Book__C[] books){
        for(Book__c b :books){
            b.price__c *= 0.9;
        }
    }

}