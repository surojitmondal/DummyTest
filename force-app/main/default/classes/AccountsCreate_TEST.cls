@isTest
public class AccountsCreate_TEST {
    
    static testMethod void acctCreateTest(){
        List<Account> acctList = new List<Account>();
        Account a = new Account(Name = 'Hemanth', BillingCountry = 'india');
        Account b = new Account(Name = 'Akhila', BillingCountry = 'Yedulla');
        acctList.add(a);
        acctList.add(b);
        insert acctList;
        //System.assert(Account != null);
        AccountsCreate.acctList();
    }

}