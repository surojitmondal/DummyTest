global class DailyLeadProcessor implements Schedulable {

    global void execute(SchedulableContext ctx) {
        List<Lead> leadList = [Select Id, LeadSource from Lead where LeadSource = null];
        
        if(!leadList.isEmpty()) {
			for(Lead leadRecord: leadList) {
				leadRecord.LeadSource = 'Dreamforce';
			}
			update leadList;
		}
    }
}