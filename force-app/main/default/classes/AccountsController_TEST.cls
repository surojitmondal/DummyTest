@IsTest(SeeAllData = false)
public class AccountsController_TEST {
    private static User sysAdminUser;    
    //setup method
    public static void setup(){
        //create system Admin user and croporate marketing user to insert records
        Profile sysProfile = [Select Id from Profile where name = 'System Administrator' LIMIT 1];
        sysAdminUser = buildtestUser('remCmpMemSysAd@statefarm.com', sysProfile);               
    }
    //method to build user with the given parameter value
    public static User buildtestUser(String t_lastName, Profile testProfile) {
        User testUser= new User(alias = 'test', email= 'testuser@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=t_lastName, languagelocalekey='en_US', 
                                localesidkey='en_US', timezonesidkey='America/Chicago', username= t_lastName+'@statefarm.com');
        return testUser;
    }
    private static testMethod void insertAccountRecord(){
        setup();
        Test.startTest();
        System.runAs(sysAdminUser){
            Account acctRecord = new Account(name = 'Kumer reddi',industry = 'sf farm', Phone = '203-821-1243');                  
            insert acctRecord;
            AccountsController.getAccounts();
        }
        Test.stopTest();
    }
    
}