public class CustomerOperationClass {
static final Double regularCustomerDiscount = 0.1;
static double finalPrice = 0;
    
    public static Double provideDiscount(Integer price){
        //calculate Discount
        finalPrice = price - price * regularCustomerDiscount;
        return finalPrice;
    }
}