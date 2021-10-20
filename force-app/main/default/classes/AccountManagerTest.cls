@IsTest
private class AccountManagerTest {
    private static testMethod void testGetAccountById(){
        Id recordId = createTestRecord();
         // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://icshemanntth224-dev-ed.my.salesforce.com/services/apexrest/Accounts/'+ recordId +'/contacts';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Account thisAccount = AccountManager.getAccount();
        // Verify results
        System.assert(thisAccount != null);
        System.assertEquals('Test record', thisAccount.Name);
    }
    
    private static Id createTestRecord(){
        //Create Account Record
        Account accountTest = new Account(Name='Test record',BillingState='Illinois');
        insert accountTest;
        List<Contact> contactsList = new List<Contact>();
        contactsList.add(new Contact(LastName = 'Kumer',Department = 'Fire',accountId = accountTest.Id));
        contactsList.add(new Contact(LastName = 'rao',Department = 'Auto',accountId = accountTest.Id));
		insert contactsList;      
        return accountTest.Id;
    }
    
}