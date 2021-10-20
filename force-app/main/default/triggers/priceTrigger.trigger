trigger priceTrigger on Book__c (before insert) {
Book__c[] books = trigger.new;
myPriceBook.applyDiscountBooks(books);

}