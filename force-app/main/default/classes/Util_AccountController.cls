public class Util_AccountController {

    public static List<Account> getAccounts(Id accId){
        List<Account> acctList = new List<Account>();
        acctList = [SELECT Id,name,	AccountNumber,Active__c,Client_Identifier__c,CleanStatus from Account where Id =:accId];
        return acctList;
    }
}