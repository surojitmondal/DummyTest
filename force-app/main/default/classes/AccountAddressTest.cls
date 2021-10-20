@isTest(seeAllData =false)
public class AccountAddressTest {

    Static testMethod void createAccount(){
      Account a = new Account(Name='Hemanth');
        insert a;
    }
    Static testMethod void createAccount2(){
        Account b = new Account(Name='Kumer',Match_Billing_Address__c = true,Texttest2__c = 'Heemkumerredddy'
                               );
        insert b;
        System.assertEquals(b.Texttest1__c, 'Heemkumerredddy');
    }
}