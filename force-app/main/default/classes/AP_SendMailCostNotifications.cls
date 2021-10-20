public with sharing class AP_SendMailCostNotifications {
    /*
    //public Map<String,Journey__c> journeyMap;
    private static Map<Id,List<CampaignMessage__c>> campaignToCampaignMessageMap = new Map<Id,List<CampaignMessage__c>>();
    private static Map<String,List<Journey_Step__c>> journeyExtIdToJourneyStepMap = new Map<String,List<Journey_Step__c>>();
    private static Map<String,String> associateIdToEmailMap = new Map<String,String>();
    public static void processNotifications(List<CampaignMessage__c>campMessageList, Boolean isJourney){
        List<Id>campaignIds = new List<Id>();
        List<String>journeyExternalIds = new List<Id>();
        List<String>servicingAgentAssociateId = new list<String>();
        String agentUserExternalId;
        for(CampaignMessage__c campMessage : campMessageList){
            agentUserExternalId = campMessage.AssociateID__c + '_' + campMessage.AssociateID__c;
            campaignIds.add(campMessage.Campaign__c);
            journeyExternalIds.add(campMessage.External_Journey_Id__c);
            servicingAgentAssociateId.add(agentUserExternalId);
            
        }
        getMessagesAndSteps(campaignIds,journeyExternalIds,servicingAgentAssociateId);
        sendEmailNotifications2(campMessageList);
    }
    
    private static void sendEmailNotifications2(List<CampaignMessage__c> campMessagesList){
        
        List<Messaging.singleEmailMessage> emailMessages = new List<Messaging.singleEmailMessage>();
        for(CampaignMessage__c campMessage : campMessagesList){
            String recordUrl = 'View Campaign at:' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + campMessage.Campaign__c;
            String[] toAddresses = new List<String>{'hemanth.k.lakkam.ekbq@statefarm.com'};
                Messaging.singleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setToAddresses(toAddresses);
            emailMessage.setSubject('Campaign: Direct Mail Notification');
            emailMessage.setHtmlBody(getTableEmailBody(campMessage,recordUrl));
            emailMessages.add(emailMessage);    
        }
        
        Messaging.SendEmailResult [] result = Messaging.sendEmail(emailMessages);   
    }
    
    
    private static void getMessagesAndSteps(List<Id>campaignIds,List<String>journeyExternalIds,List<String>servicingAgentAssociateIds){
        List<CampaignMessage__c> campMessageList = [Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c  from CampaignMessage__c where Campaign__c IN:campaignIds AND Status__c != 'Cancelled - stopped journey']; 
        
        for(CampaignMessage__c campMessage : campMessageList) {
            if(!campaignToCampaignMessageMap.containsKey(campMessage.Campaign__c)) {
                campaignToCampaignMessageMap.put(campMessage.Campaign__c, new List<CampaignMessage__c>());
            }
            campaignToCampaignMessageMap.get(campMessage.Campaign__c).add(campMessage);
        }
        
        List<Journey_Step__c> jrnyStepList = [Select JourneyName__c,ContactMethodName__c,Cost__c,DaysNum__c,MailClassCode__C,ItemID__c 
                                              from journey_step__c where JourneyId__r.Journey_External_Id__c IN:journeyExternalIds order by JourneyStepID__c asc];
        for(Journey_Step__c jrnyStep :jrnyStepList ){
            if(!journeyExtIdToJourneyStepMap.containsKey(jrnyStep.JourneyId__r.Journey_External_Id__c)) {
                journeyExtIdToJourneyStepMap.put(jrnyStep.JourneyId__r.Journey_External_Id__c, new List<Journey_Step__c>());
            }
            journeyExtIdToJourneyStepMap.get(jrnyStep.JourneyId__r.Journey_External_Id__c).add(jrnyStep);
        }
        List<User> userList = [Select Email from user where Userexternalid__c IN: servicingAgentAssociateIds];
        for(User usr : userList){
            if(!associateIdToEmailMap.containsKey(usr.Email)){
                //associateIdToEmailMap.put();
            }
        }
        
    }    
    
    //Campaign Message HTML Body
    private static string getTableEmailBody(CampaignMessage__c campMessage, String recordUrl){
        if(campMessage.JourneyID__c != null){
            System.debug('Form HTML Template with CampaignMessages and JourneySteps');
        }
        
        else{
            system.debug('Form HTML Template with CampaignMessages');
        }
        String htmlBody = '';
        htmlBody += '<font color="gray">';
        htmlBody += '<h3>The following Direct Mail has been started on a Campaign by '+ 'Allison Waage, FJKF, 90-1583' + '</h3>';
        htmlBody += '<br />';
        htmlBody += 'Number of Campaign Members: '+ 344;
        //open table..
        htmlBody += '<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray">';
        htmlBody += '<tr style="background-color: #f2f2f2;text-align : center">';
        htmlBody += '<td colspan="6"><b>2019 LEAD CAMPAIGN</b></td>';
        htmlBody += '</tr>';
        htmlBody += '<tr style="background-color: #f2f2f2;">'+
            '<th align="center">ESTIMATED DATE</th>'+
            '<th align="center">SOURCE</th>'+
            '<th align="center">DELIVERY TYPE</th>'+
            '<th align="center">ESTIMATED COST PER MAIL</th>'+
            '<th align="center">LETTER NAME</th>'+
            '<th align="center">STATUS</th>'+
            '</tr>';
        Double totalCost = 0.00;
        //iterate over list and output columns/data into table rows...
        if(campaignToCampaignMessageMap != null && campaignToCampaignMessageMap.containsKey(campMessage.Campaign__c)) {
            List<CampaignMessage__c> campMessageList = campaignToCampaignMessageMap.get(campMessage.Campaign__c);
            for(CampaignMessage__c campaignMessage : campMessageList){
                DateTime transmissionDate = campaignMessage.TransmissionDate__c;
                totalCost = totalCost + (campaignMessage.Cost__c ==null?0.00:Double.valueOf(campaignMessage.Cost__c));
                htmlBody += '<tr>' +
                    '<td style = required>' + ((transmissionDate == null) ? 'Not Provided' : DateTime.newInstance(transmissionDate.year(), transmissionDate.month(),transmissionDate.day()).format('MM/dd/yy')) + '</td>' +
                    '<td>' + ((campaignMessage.JourneyId__c == null) ? 'Single Mailer' : campaignMessage.JourneyName__c) + '</td>' +
                    '<td>' + ((campaignMessage.MailClassCode__c == '1') ? '1st Class' : '3rd Class') + '</td>' +
                    '<td>' + ((campaignMessage.cost__c == null) ? 'Not Provided' : campaignMessage.cost__c) + '</td>' +
                    '<td>' + ((campaignMessage.Itemid__c == null) ? 'Not Provided' : campaignMessage.Itemid__c) + '</td>' +
                    '<td>' + ((campaignMessage.Status__c == null) ? 'Not Provided' : campaignMessage.Status__c) + '</td>' +
                    '</tr>';
            }
        }

        if(journeyExtIdToJourneyStepMap != null && journeyExtIdToJourneyStepMap.containsKey(campMessage.JourneyId__c)) {
            List<Journey_Step__c> journayStepsList = journeyExtIdToJourneyStepMap.get(campMessage.JourneyId__c);
            for(Journey_Step__c journeyStep : journayStepsList){
                DateTime transmissionDate = journeyStep.TransmissionDate__c;
                totalCost = totalCost + (journeyStep.Cost__c ==null?0.00:Double.valueOf(journeyStep.Cost__c));
                htmlBody += '<tr>' +
                    '<td style = required>' + ((transmissionDate == null) ? 'Not Provided' : DateTime.newInstance(transmissionDate.year(), transmissionDate.month(),transmissionDate.day()).format('MM/dd/yy')) + '</td>' +
                    '<td>' + ((journeyStep.JourneyId__c == null) ? 'Single Mailer' : journeyStep.JourneyName__c) + '</td>' +
                    '<td>' + ((journeyStep.MailClassCode__c == '1') ? '1st Class' : '3rd Class') + '</td>' +
                    '<td>' + ((journeyStep.cost__c == null) ? 'Not Provided' : journeyStep.cost__c) + '</td>' +
                    '<td>' + ((journeyStep.ItemId__c == null) ? 'Not Provided' : journeyStep.ItemId__c) + '</td>' +
                    '<td>' + ((journeyStep.Status__c == null) ? 'Not Provided' : journeyStep.Status__c) + '</td>' +
                    '</tr>';
            }
        }

        totalCost = totalCost*344;
        htmlBody += '<tr>'+
            '<td><b>TOTAL COST</b></td>'+            
            '<td></td>'+
            '<td></td>'+
            '<td>'+totalCost+'</td>'+
            '<td></td>'+
            '<td></td>';
        
        //close table...
        htmlBody += '</table>';
        htmlBody += '<br />';
        htmlBody += '<p>'+recordUrl+'</p>';
        htmlBody += '<h4><b>NOTE:</b>No all Journeys and Direct Mail have subsidy. The total cost displays the highest possible cost for the '+
            'mailers and does not include your marketing tier subsiidy for journeys that are applicable. For more '+
            'resources review the Agent Marketing Plan on ABS</h4>';
        htmlBody += '</font>';
        return htmlBody;
    }
    
    //Journey HTML Body
    private static string getTableEmailBodyJourney(Campaign camp){
        String recordUrl = 'View Campaign at: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + camp.id;
        List<Journey_Step__c> jrnyStepList = [Select id,name,JourneyName__c,JourneyStepID__c,StepTypeCode__c, 
                                              ContactMethodName__c, ItemEffectiveDate__c,Cost__c,DaysNum__c,Bundle_ID__c,MailClassCode__C,ItemID__c 
                                              from journey_step__c where id = 'a0P2F000001GSlDUAW' order by JourneyStepID__c asc];
        String htmlBody = '';
        htmlBody += '<font color="gray">';
        htmlBody += '<h3>The following Direct Mail has been started on a Campaign by Allison Waage, FJKF, 90-1583</h3>';
        htmlBody += '<br />';
        htmlBody += 'Number of Campaign Members: '+ 344;
        //open table..
        htmlBody += '<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray">';
        htmlBody += '<tr style="background-color: #f2f2f2;text-align : center">';
        htmlBody += '<td colspan="6"><b>2019 LEAD CAMPAIGN</b></td>';
        htmlBody += '</tr>';
        htmlBody += '<tr style="background-color: #f2f2f2;">'+
            '<th align="center">ESTIMATED DATE</th>'+
            '<th align="center">SOURCE</th>'+
            '<th align="center">DELIVERY TYPE</th>'+
            '<th align="center">ESTIMATED COST PER MAIL</th>'+
            '<th align="center">LETTER NAME</th>'+
            '<th align="center">STATUS</th>'+
            '</tr>';
        Double totalCost = 298.00;
        Integer steps = 1;
        //iterate over list and output columns/data into table rows...
        for(Journey_Step__c jrnyStep : jrnyStepList){
            Date dt = camp.Journey_Start_Date__c.addDays(jrnyStep.DaysNum__c.intvalue());
            String mailClass = jrnyStep.MailClassCode__c;
            htmlBody += '<tr>' +
                '<td>' + ((dt == null) ? 'Not Provided' : DateTime.newInstance(dt.year(), dt.month(),dt.day()).format('MM/dd/yy')) + '</td>' +
                '<td>' + ((jrnyStep.JourneyName__c == null) ? 'Not Provided' : jrnyStep.JourneyName__c)  +'</td>' +
                '<td>' + ((mailClass == '1') ? '1st Class' : '3rd Class') + '</td>' +
                '<td>' + ((jrnyStep.cost__c == null) ? 'Not Provided' : jrnyStep.cost__c) + '</td>' +
                '<td>' + ((jrnyStep.Itemid__c == null) ? 'Not Provided' : jrnyStep.Itemid__c) + '</td>' +
                '<td>Scheduled</td>' +
                '</tr>';
        }
        
        htmlBody += '<tr>'+
            '<td>TOTAL COST:</td>'+
            '<td></td>'+
            '<td></td>'+
            '<td></td>'+
            '<td>'+totalCost+'</td>'+
            '<td></td>';
        
        //close table...
        htmlBody += '</table>';
        htmlBody += '<br />';
        htmlBody += '<p>'+recordUrl+'</p>';
        htmlBody += '<h4><b>NOTE:</b>No all Journeys and Direct Mail have subsidy. The total cost displays the highest possible cost for the '+
            'mailers and does not include your marketing tier subsiidy for journeys that are applicable. For more '+
            'resources review the Agent Marketing Plan on ABS</h4>';
        htmlBody += '</font>';
        return htmlBody;
    }
    
    
   
    private static List<String> buildSetToAddresses(String userExternalId){
        List<String> setToAddresses = new List<String>();
        User agentUser = [Select Email from user where UserExternalID__c = :userExternalId];
        setToAddresses.add(agentUser.Email);
        return setToAddresses;
    }
    
    private static String defineSource(CampaignMessage__c campMessage){
        String sourceDef;     
        if (campMessage.JourneyID__c != null){
            sourceDef = campMessage.JourneyName__c;
        }
        else {
            sourceDef = 'One Off';
        }                
        return sourceDef;
    }
    //Step Type
    private static String mailClassCodeToDeliveryType(String contactMethodName){
        String stepType = null;     
        if(contactMethodName == 'Mailing1'){
            stepType = '1st Class';
        }
        else{
            stepType = '3rd Class';
        }
        
        return stepType;
    }
    
//Updated Latest one

public with sharing class AP_SendCampMailCostNotifications {
    
    private static Map<Id,List<CampaignMessage__c>> campToCampaignMessageListMap = new Map<Id,List<CampaignMessage__c>>();
    private static Map<Id,CampaignMessage__c> campToCampaignMessageMap;
    private static Map<Id,String> campaignToUserExternalIdMap = new Map<Id,String>();
    private static Map<String,String> associateIdToUserMap = new Map<String,String>();   
    private static final String CLASS_NAME = 'AP_SendCampMailCostNotifications';
    private static final String METHODNAME = 'processSendNotifications';
    
    
    //main method
    public static void processSendNotifications(List<CampaignMessage__c>campMessageList){
        try{
            campToCampaignMessageMap = campaignToCampaignMessageMap(campMessageList);
            if(!campToCampaignMessageMap.isEmpty()){
                getCampaignMessages(campToCampaignMessageMap.keySet());
                getCampaignToUserExternalIdMap(campToCampaignMessageMap.keySet());
                sendEmailNotifications(campToCampaignMessageMap.keySet());
            }
        }
        catch(Exception CampSendNotificationException){
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME, LoggingLevel.ERROR);  
        }
        
    }
    
    //Campaign to userexternalid map
    private static void getCampaignToUserExternalIdMap(Set<Id>campaignIds){
        List<String>agentUserExternalIds = new list<String>();        
        for(Id campaignId : campaignIds){
            CampaignMessage__c campMessage = campToCampaignMessageMap.get(campaignId);
            String agentUserExternalId = campMessage.AssociateID__c + '_' + campMessage.AssociateID__c;
            agentUserExternalIds.add(agentUserExternalId);
            campaignToUserExternalIdMap.put(campaignId,agentUserExternalId);
        }
        getAgentEmailMap(agentUserExternalIds);
    }
    
    
    
    //campaign to campaignmessage map
    private static Map<Id,CampaignMessage__c> campaignToCampaignMessageMap(List<CampaignMessage__c> campMessageList){
        campToCampaignMessageMap = new map <Id, CampaignMessage__c> ();
        for(CampaignMessage__c campMessage : campMessageList){
            if(campMessage.Campaign__r.Recordtype.Id == Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Corporate Leads').getRecordTypeId()){
                break;
            }
            else{
                campToCampaignMessageMap.put(campMessage.campaign__c, campMessage);
            }
        }
        
        return campToCampaignMessageMap;
    }   
    
    
    
    private static void sendEmailNotifications(Set<Id> campaignIds){
        
        List<Messaging.singleEmailMessage> emailMessages = new List<Messaging.singleEmailMessage>();
        for(Id campaignId : campaignIds){
            String recordUrl = 'View Campaign at:' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + campaignId;
            String[] toAddresses = new List<String>{associateIdToUserMap.get(campaignToUserExternalIdMap.get(campaignId))};
            Messaging.singleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setToAddresses(toAddresses);
            emailMessage.setSubject('Campaign: Direct Mail Notification');
            emailMessage.setHtmlBody(getEmailHtmlBody(campaignId,recordUrl));
            emailMessages.add(emailMessage);    
        }
        
        Messaging.SendEmailResult [] result = Messaging.sendEmail(emailMessages);
        //check based on the result
    }
    
    
    private static void getCampaignMessages(Set<Id>campaignIds){
        List<CampaignMessage__c> campMessageList = [Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c,Associateid__c  from CampaignMessage__c where Campaign__c IN:campaignIds AND Status__c != 'Cancelled - stopped journey' ORDER BY Transmissiondate__c ASC]; 
        
        for(CampaignMessage__c campMessage : campMessageList) {
            if(!campToCampaignMessageListMap.containsKey(campMessage.Campaign__c)) {
                campToCampaignMessageListMap.put(campMessage.Campaign__c, new List<CampaignMessage__c>());
            }
            campToCampaignMessageListMap.get(campMessage.Campaign__c).add(campMessage);
        }        
    }
    
    //get agent email
    private static void getAgentEmailMap(List<String>servicingAgentAssociateIds){
        List<User> userList = [Select Email,Userexternalid__c from user where Userexternalid__c IN: servicingAgentAssociateIds];
        for(User usr : userList){
            associateIdToUserMap.put(usr.UserExternalID__c,usr.Email);
        }
    }
    
    //Campaign Message HTML Body
    private static string getEmailHtmlBody(Id campaignId, String recordUrl){
        //if(campMessage.JourneyID__c != null){
        //System.debug('Form HTML Template with CampaignMessages and JourneySteps');
        //}
        //else{
        //system.debug('Form HTML Template with CampaignMessages');
        //}

        String htmlBody = '';
        htmlBody += '<font color="gray">';
        htmlBody += '<h3>The following Direct Mail has been started on a Campaign by '+ 'Allison Waage, FJKF, 90-1583' + '</h3>';
        htmlBody += '<br />';
        htmlBody += 'Number of Campaign Members: '+ campToCampaignMessageMap.get(campaignId).Campaign__r.Total_Number_Members__c;
        //open table..
        htmlBody += '<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray">';
        htmlBody += '<tr style="background-color: #f2f2f2;text-align : center">';
        htmlBody += '<td colspan="6"><b>'+campToCampaignMessageMap.get(campaignId).Campaign__r.Name+'</b></td>';
        htmlBody += '</tr>';
        htmlBody += '<tr style="background-color: #f2f2f2;">'+
            '<th align="center">ESTIMATED DATE</th>'+
            '<th align="center">SOURCE</th>'+
            '<th align="center">DELIVERY TYPE</th>'+
            '<th align="center">ESTIMATED COST PER MAIL</th>'+
            '<th align="center">LETTER NAME</th>'+
            '<th align="center">STATUS</th>'+
            '</tr>';
        Double totalCost = 0.00;
		Boolean markAllStars = campToCampaignMessageMap.get(campaignId).JourneyId__c != null;
        //iterate over list and output columns/data into table rows...
        List<CampaignMessage__c> campMessageList = campToCampaignMessageListMap.get(campaignId);
        for(CampaignMessage__c campaignMessage : campMessageList){
            DateTime transmissionDate = campaignMessage.TransmissionDate__c;
            totalCost = totalCost + (campaignMessage.Cost__c ==null?0.00:Double.valueOf(campaignMessage.Cost__c));
			String starString = (markAllStars || campaignMessage.Id == campToCampaignMessageMap.get(campaignId).Id)?'<font color="red">*</font>':'';
            htmlBody += '<tr>' +
                '<td>' + starString + ((transmissionDate == null) ? 'Not Provided' : DateTime.newInstance(transmissionDate.year(), transmissionDate.month(),transmissionDate.day()).format('MM/dd/yy')) + '</td>' +
                '<td>' + ((campaignMessage.JourneyId__c == null) ? 'Single Mailer' : campaignMessage.JourneyName__c) + '</td>' +
                '<td>' + ((campaignMessage.MailClassCode__c == '1') ? '1st Class' : '3rd Class') + '</td>' +
                '<td>' + ((campaignMessage.cost__c == null) ? 'Not Provided' : campaignMessage.cost__c) + '</td>' +
                '<td>' + ((campaignMessage.Itemid__c == null) ? 'Not Provided' : campaignMessage.Itemid__c) + '</td>' +
                '<td>' + ((campaignMessage.Status__c == null) ? 'Not Provided' : campaignMessage.Status__c) + '</td>' +
                '</tr>';
        }
        totalCost = totalCost*campToCampaignMessageMap.get(campaignId).Campaign__r.Total_Number_Members__c;
        htmlBody += '<tr>'+
            '<td><b>TOTAL COST:</b></td>'+            
            '<td></td>'+
            '<td></td>'+
            '<td>'+totalCost+'</td>'+
            '<td></td>'+
            '<td></td>';
        
        //close table...
        htmlBody += '</table>';
        htmlBody += '<br />';
        htmlBody += '<p>'+recordUrl+'</p>';
        htmlBody += '<h4><b>NOTE:</b>No all Journeys and Direct Mail have subsidy. The total cost displays the highest possible cost for the '+
            'mailers and does not include your marketing tier subsiidy for journeys that are applicable. For more '+
            'resources review the Agent Marketing Plan on ABS</h4>';
        htmlBody += '</font>';
        return htmlBody;
    }
}
    ***/
}