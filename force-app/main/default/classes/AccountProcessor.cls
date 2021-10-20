public with sharing class AccountProcessor {
    
    @future
    public static void countContacts(List<Id> accountIds){
		Map<Account,Integer> acctIntMap = new Map<Account,Integer>();
        List<Account> acctListToUpdate = new List<Account>();
        Map<Account,List<contact>> acctToContactListMap = new Map<Account,List<Contact>>();
        List<Account> acctList = [Select id,name,number_of_contacts__c,(Select id,name from contacts) from account where id IN: accountIds];
        for(Account acct : acctList){
            acct.number_of_contacts__c = acct.contacts.size();
            acctListToUpdate.add(acct);
        }
        
        update acctListToUpdate;
    } 

}