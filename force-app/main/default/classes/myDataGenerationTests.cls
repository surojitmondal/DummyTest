@isTest

public class myDataGenerationTests {
@TestSetup
static void loadTestDataFromStaticResource(){
List<sobject> accounts = Test.loadData(Account.sObjecttype, 'Mock_Data');
}
@isTest static void testLoadAccountsFromStaticResource() {
    List<Account> accts = [SELECT ID FROM Account];
    system.assert(accts.size() == 15, 'expected 3 accounts');
    system.assertEquals(15,accts.size());
  }
}