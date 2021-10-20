trigger AccountAddressTrigger on Account (before insert, before update) {
List<Account> acctList = new List<Account>();
    for(Account a: Trigger.New) {
        if(a.Match_Billing_Address__c == true && a.Texttest2__c != null){
            a.Texttest1__c = a.Texttest2__c;
        }
    }
    
}