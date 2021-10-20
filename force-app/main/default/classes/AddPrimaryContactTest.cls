@IsTest
public class AddPrimaryContactTest {
    
    @IsTest
    public static void testAddPrimaryContact() {
        List<account> accList = new List<account>();
        for (Integer i=0; i<50;i++) {
            account a = new account(name=string.valueOf(i),billingstate='NY');
            system.debug('account a = '+a);
            accList.add(a);
        }
        for (Integer i=0; i<50;i++) {
            account a = new account(name=string.valueOf(50+i),billingstate='CA');
            system.debug('account a = '+a);
            accList.add(a);
        }      
        insert accList;
        Test.startTest();
        contact con = new contact(lastname='alex');
        AddPrimaryContact apc = new AddPrimaryContact(con,'CA');
        system.debug('apc = '+apc);
        System.enqueueJob(apc);
        Test.stopTest();
        List<contact> contactList = new List<contact>([select id from contact]);
        Integer size = contactList.size();
        system.assertEquals(50, size);
    }

}