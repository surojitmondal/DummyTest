@RestResource(urlMapping='/Accounts/*/contacts')
global with sharing class AccountManager {
@HttpGet
    global static Account getAccount() {
        RestRequest request = RestContext.request;
        // grab the AccountId from the end of the URL
        String accountId = request.requestURI.substringBetween('Accounts/','/contacts');
        Account result =  [SELECT Id,Name,(Select id,name from Contacts)
                        FROM Account
                        WHERE Id = :accountId];
        return result;	
    }
}