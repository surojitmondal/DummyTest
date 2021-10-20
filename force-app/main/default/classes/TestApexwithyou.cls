public class TestApexwithyou {
    
    Private static integer daysNumber = 22;
    
    private static Account getAccountRecord(Id accountIddd){
        Account acc = [Select id,name,Billingcity from Account where Id =:accountIddd];
        return acc;
    }
    private static Campaign getCampaignRecord(){
        return [Select id,name from campaign Limit 1];
    }
}