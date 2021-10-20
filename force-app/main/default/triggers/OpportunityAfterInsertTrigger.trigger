trigger OpportunityAfterInsertTrigger on Opportunity (after insert) {
for (Opportunity opp : trigger.new){

List<opportunity> oppList = [Select id,name from opportunity where AccountId = :opp.Accountid];
system.debug('SIZE:'+ OppList.size());
system.debug(+oppList);


/*CampaignJourneyTracking Code sample
     * Map<Id, Id> campaignToUserMap = new Mapp<Id, Id>();
    * for(CampaignJourneyTracking journeyTracking : trigger.new) {
        campaignToUserMap.put(journeyTracking.CampaignId, journeyTracking.AgentId);
    }
    List<CampaignMessage_c> cms = [SELECT .... FROM CampaignMessage_c WHERE campaignId In : campaignToUserMap.keySet()];
    Map<Id,List<CampaignMessage_c>> cmMap = new Map<Id,List<CampaignMessage_c>>();
    for(CampaignMessage__c cm : cms) {
        if(!cmMap.containsKey(cm.CampaignId)) {
            cmMap.put(cm.CampaignId, new List<CampaignMessage__c>());
        }
        cmMap.get(cm.CampaignId).add(cm);
    }

    List<JouneryStep_c> jss = [SELECT .... FROM JouneryStepc WHERE Parent_r.CampaignId In : campaignToUserMap.keySet()];
    Map<Id,List<JouneryStep_c>> jsMap = new Map<Id,List<JouneryStep_c>>();
    for(JouneryStep__c js : jss) {
        if(!jsMap.containsKey(js.CampaignId)) {
            jsMap.put(js.Parent_r.CampaignId, new List<JouneryStep_c>());
        }
        jsMap.get(cm.CampaignId).add(cm);
    }
    sendEmailNotification(campaignToUserMap, cmMap, jsMap);
     * /

     public static void sendEmailNotification(Map<Id, Id> campaignToUserMap, Map<Id,CampaignMessage_c> campaignMessageList, Map<Id,JourneyStep_c steps) {  
        List<Messaging.singleEmailMessage> emailMessages = new List<Messaging.singleEmailMessage>();
        for(Id campaignId :campaignToUserMap.keySet()) {
            //List<CampaignMessage_c> campaignMessageList =[Select id,Name,Costc, Itemidc,TransmissionDatec,LetterNamec,Statusc,Journeyidc, AgentOnlineMessageURLc  from CampaignMessagec where Campaignc = '7012F0000007AqaQAE' AND Status_c != 'Cancelled - stopped journey'];
            String recordUrl = 'View Campaign at:' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + '7012F0000007AqaQAE';
            String[] toAddresses = new List<String>{'hemanth.k.lakkam.ekbq@statefarm.com'};            
                Messaging.singleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setToAddresses(toAddresses);
            emailMessage.setSubject('Campaign: Direct Mail Notification');        
            system.debug('after plain text');
            emailMessage.setHTMLBody(getTableEmailBodyCampMessage(campaignMessageList,campaignMessageList.get(campaignId), steps.get(campaignId)) + recordUrl);
            emailMessages.add(emailMessage);
        }
        system.debug('after HTML');
        Messaging.SendEmailResult [] result = Messaging.sendEmail(emailMessages);        
    }
    */
}
}