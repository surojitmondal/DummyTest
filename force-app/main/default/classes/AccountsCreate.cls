public class AccountsCreate {
    
    public Static List<Account> acctList(){
        List<account> accts = new List<Account>();
        Account a = new Account(Name = 'Kumer', BillingCountry = 'india');
        Account b = new Account(Name = 'Akhila', BillingCountry = 'Yedulla');
        accts.add(a);
        accts.add(b);
        insert accts;
        return accts;
        
    }

}