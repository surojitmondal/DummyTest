@isTest
public class DataTableControllerTest {
    @isTest
    public static void whenMethodInvokedWithNoDataExpectEmptyDataToBeReturned() {
        String data = DataTableController.getLeadOptyConversionData(Date.today().addDays(-31), Date.today());
        System.assertEquals(0, ((List<DataTableController.userWrapper>)JSON.deserialize(data, List<DataTableController.userWrapper>.class)).size());
    }
    
    @isTest
    public static void whenMethodInvokedWithOneUserExpectOneRecordToBeReturned() {
        createAndConvertLead(new UserBuilder().createRecord(), 'First', 'Last', 'Test', Date.today());
        
        Test.startTest();
        String data = DataTableController.getLeadOptyConversionData(Date.today().addDays(-31), Date.today().addDays(1));
        Test.stopTest();
        List<DataTableController.userWrapper> parsedData = ((List<DataTableController.userWrapper>)JSON.deserialize(data, List<DataTableController.userWrapper>.class));
        System.assertEquals(1, parsedData.size());
    }
    
    @isTest
    public static void whenMethodInvokedWithTwoUsersExpectTwoRecordToBeReturned() {
        createAndConvertLead(new UserBuilder().withFirstName('First1').withLastName('Last1').withEmail('1@gmail.com').withUserName('1@gmail.com.devsandbox').createRecord(), 'First1', 'Last1', 'Test1', Date.today());
        createAndConvertLead(new UserBuilder().withFirstName('First2').withLastName('Last2').withEmail('2@gmail.com').withUserName('2@gmail.com.devsandbox').createRecord(), 'First2', 'Last2', 'Test2', Date.today());
        
        Test.startTest();
        String data = DataTableController.getLeadOptyConversionData(Date.today().addDays(-31), Date.today().addDays(1));
        Test.stopTest();
        List<DataTableController.userWrapper> parsedData = ((List<DataTableController.userWrapper>)JSON.deserialize(data, List<DataTableController.userWrapper>.class));
        System.assertEquals(2, parsedData.size());
    }
    
    @isTest
    public static void whenMethodInvokedWithTwoUsersOustideDateRangeExpectOneRecordToBeReturned() {
        createAndConvertLead(new UserBuilder().withFirstName('First1').withLastName('Last1').withEmail('1@gmail.com').withUserName('1@gmail.com.devsandbox').createRecord(), 'First1', 'Last1', 'Test1', Date.today().addDays(-32));
        createAndConvertLead(new UserBuilder().withFirstName('First2').withLastName('Last2').withEmail('2@gmail.com').withUserName('2@gmail.com.devsandbox').createRecord(), 'First2', 'Last2', 'Test2', Date.today());
        
        Test.startTest();
        String data = DataTableController.getLeadOptyConversionData(Date.today().addDays(-31), Date.today().addDays(1));
        Test.stopTest();
        List<DataTableController.userWrapper> parsedData = ((List<DataTableController.userWrapper>)JSON.deserialize(data, List<DataTableController.userWrapper>.class));
        System.assertEquals(1, parsedData.size());
    }
    
    private static void createAndConvertLead(User owner, String firstName, String lastName, String company, Date createdDate) {
        System.runAs(owner) {
            Lead lead = new Lead(FirstName = firstName, LastName = lastName, Company = company);
            insert lead;
        	Test.setCreatedDate(lead.Id, createdDate);  
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.id);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.convertLead(lc);
        }
    }
}