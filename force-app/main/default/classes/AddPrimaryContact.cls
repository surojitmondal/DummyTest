public class AddPrimaryContact implements Queueable
{
    private Contact c;
    private String state;
    public  AddPrimaryContact(Contact c, String state)
    {
        this.c = c;
        this.state = state;
    }
    public void execute(QueueableContext context) 
    {
         List<Account> accountList = [SELECT ID, Name ,(Select id,FirstName,LastName from contacts ) FROM ACCOUNT WHERE BillingState = :state LIMIT 200];
         List<Contact> contactList = new List<Contact>();
         for (Account acc:accountList)
         {
                 Contact cont = c.clone(false,false,false,false);
                 cont.AccountId =  acc.id;
                 contactList.add( cont );
         }
         
         if(contactList.size() >0 )
         {
             insert contactList;
         }
             
    }

}