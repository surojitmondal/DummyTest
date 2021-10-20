@isTest
private class DailyLeadProcessorTest {
	static testMethod void testDailyLeadProcessor() {
		String CRON_EXP = '0 0 1 * * ?';
		List<Lead> leadList = new List<Lead>();
	    for (Integer i = 0; i < 200; i++) {
			leadList.add(new Lead(LastName='Dreamforce'+i, Company='Test1 Inc.', Status='Open - Not Contacted'));
		}
		insert leadList;
		  
		Test.startTest();
		String jobId = System.schedule('DailyLeadProcessor', CRON_EXP, new DailyLeadProcessor()); 
	}
}