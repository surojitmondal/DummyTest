public class AP_CampaignMessageAfterInsertTrigger {
/*
 public with sharing class AP_CampMailerCostNotifications {
    public class EmailDataWrapper {
        public Map<Id,Campaign> campIdToCampMap{get;set;}
        public Map<Id,List<CampaignMessage__c>> campIdToCampMessageMapp{get;set;}
        public Map<Id,List<Journey_Step__c>> campIdToJourneyStepMap{get;set;}
		public Map<Id,String[]> campIdToCCAddressMap{get;set}
		public Map<Id,User> campIdToUserMap{get;set;}
		
        EmailDataWrapper() {
        	campIdToCampMap = new Map<Id,Campaign>();
			campIdToCampMessageMapp = new Map<Id,List<CampaignMessage__c>>();
			campIdToJourneyStepMap = new Map<Id,List<Journey_Step__c>>();
			campIdToCCAddressMap = new Map<Id,String[]>();
			campIdToUserMap = new Map<Id,User>();
        }
    }
	
	public static EmailDataWrapper emailDataWrapper = new EmailDataWrapper();
    public static Map<Id,List<CampaignMessage__c>> campToCampaignMessageListMap = new Map<Id,List<CampaignMessage__c>>();
    public static Map<String,List<Journey_Step__c>> journeyExtIdToJrnyStepListMap = new Map<String,List<Journey_Step__c>>();
    public static Map<Id,String> campaignToUserExternalIdMap = new Map<Id,String>();
    public static Map<Id,Campaign> campIdToCampMap = new Map<Id,Campaign>();
    public static Map<String,String> userExtIdToUserEmailMap = new Map<String,String>();
    public static Map<Id,String> userIdToEmailMap = new Map<Id,String>();
    public static Map<Id,Id> campaignToUserIdMap = new Map<Id,Id>();
    public static Map<Id,String> userIdToNameMap = new Map<Id,String>();
    public static Map<Id,Id> campaignToAgentUserIdMap = new Map<Id,Id>();
    private static final String CLASS_NAME = 'AP_CampMailerCostNotifications';
    private static final String METHODNAME = 'processSendNotifications';    
    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    
    
    * @method- Invoked by  CampaignMessageAfterInsert Trigger           
    * @description  This method will helps us to form the email body with required campaign message details,
    *               fetch the users who have performed the operation and send the email notifications as required
    * @name  processSendNotifications
    * @param  byPassObjectTrigger - boolean to check bypass trigger
    * @param  campMessageList - Campaign Messages List
    
    public static void processOneOffSendNotifications(Boolean byPassObjectTrigger,List<CampaignMessage__c> campMessageList){
        try{
            if(isTriggerByPassed(byPassObjectTrigger)) {
            	return;
            }	
			
			EmailDataWrapper emailDataWrapper = new EmailDataWrapper();
            Map<Id,CampaignMessage__c> campToCampaignMessageMap = campaignToCampaignMessageMap(campMessageList);
            if(campToCampaignMessageMap.isEmpty()) {
            	return;
            }
            
            setCampaignAndCampaignMessages(campToCampaignMessageMap.keySet(), emailDataWrapper); 
            if(campIdToCampMap.isEmpty()) {
            	return;
            }

            setCCEmails(emailDataWrapper);
            HLPR_CampMailerCostNotifications.sendEmailNotifications(emailDataWrapper, false);
        }
        catch(Exception CampSendNotificationException){
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME, LoggingLevel.ERROR);
        }
        
    }
    
    
    * @method- Invoked by  CampaignJourneyTrackingAfterInsert Trigger           
    * @description  This method will helps us to form the email body with required journey step and campaign message details,
    *               fetch the users who have performed the operation and send the email notifications as required
    * @name  processJourneySendNotifications
    * @param  byPassObjectTrigger - boolean to check bypass trigger
    * @param  campJrnyTrackingList - Campaign Journey Tracking List
    
    public static void processJourneySendNotifications(Boolean byPassObjectTrigger,List<Campaign_Journey_Tracking__c> campJrnyTrackingList){        
        try{
            if(!isTriggerByPassed(byPassObjectTrigger)) {
                Map<Id,String> campaignToJourneyMap = campaignIdToJourneyMap(campJrnyTrackingList);
                if(!campaignToJourneyMap.isEmpty()){
                    setCampaignAndCampaignMessages(campaignToJourneyMap.keySet());
                }
                if(!campIdToCampMap.isEmpty()){                    
                    getJourneyAndJourneySteps(campaignToJourneyMap.values());
                    getCcEmailUserIds(setCampaignAndCampaignMessages(campaignToJourneyMap.keySet()));
                    HLPR_CampMailerCostNotifications.sendEmailNotifications(campaignToJourneyMap.keySet(),true);
                }
            }
        }        
        catch(Exception CampSendNotificationException){
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME, LoggingLevel.ERROR);
        }
    }
    
    //Helper method to get campaign to journey map
    private static Map<Id,String> campaignIdToJourneyMap(List<Campaign_Journey_Tracking__c> campJrnyTrackingList){
        Map<Id,String> campaignToJourneyMap = new Map<Id,String>();
        for(Campaign_Journey_Tracking__c campJrnyTrackingRec : campJrnyTrackingList){
            if(campJrnyTrackingRec.ActionType__c == 'Journey Started'){
                campaignToJourneyMap.Put(campJrnyTrackingRec.Campaign__c,campJrnyTrackingRec.JourneyExternalID__c);
                campaignToAgentUserIdMap.put(campJrnyTrackingRec.Campaign__c,campJrnyTrackingRec.Agent__c);
            }
        }

		return campaignToJourneyMap;
    }
    
    //Helper method to get cc email user ids
    private static void getCcEmailUserIds(List<Campaign> campaignList, EmailDataWrapper emailDataWrpper){
        for(Campaign camp : campaignList){
            if(camp.lastmodifiedby.UserType__c != 'Agent' && camp.lastmodifiedby.UserType__c != 'ATM'){
                campaignToUserIdMap.put(camp.Id,camp.Initiated_By_Id__c);
            }
            else{
                campaignToUserIdMap.put(camp.Id,camp.Lastmodifiedby.id);
            }
        }

        List<User> userList = [Select id,Email,Name from user where Id IN: campaignToAgentUserIdMap.values() OR Id IN:campaignToUserIdMap.values() WITH SECURITY_ENFORCED];
        for(User usr : userList){
            userIdToEmailMap.put(usr.Id,usr.Email);
            userIdToNameMap.put(usr.Id,usr.Name);
        }
    }
    
    //Helper method to get journey and journeysteps
    private static void getJourneyAndJourneySteps(List<String> jrnyExternalIds){
        
        List<Journey__c> jrnyAndJrnyStepList = [Select id,Journey_External_ID__c ,(Select id,DaysNum__c,Cost__c,ItemID__c,JourneyName__c, MailClassCode__c FROM Journey_Step__r WHERE ContactMethodName__c  = 'Mailing' ORDER BY JourneyStepID__c)
                                                FROM Journey__c WHERE Journey_External_ID__c IN:jrnyExternalIds WITH SECURITY_ENFORCED];
        for(Journey__c jrny : jrnyAndJrnyStepList){
           journeyExtIdToJrnyStepListMap.put(jrny.Journey_External_ID__c, jrny.Journey_Step__r); 
        }
        
    }
    
    //Helper method to check if trigger bypassed
    private static Boolean isTriggerByPassed(Boolean byPassObjectTrigger) {        
        return CS001_ByPassTriggerAll__c.getInstance().Override_All__c || toggleContext.isActive(UTIL_Toggles.SENDNOTIFICATIONS) || byPassObjectTrigger;
        
    }
    
    //Helper method to get campaign to campaignmessage map
    private static Map<Id, CampaignMessage__c> campaignToCampaignMessageMap(List<CampaignMessage__c> campMessageList){
        Map<Id, CampaignMessage__c> campToCampaignMessageMap = new Map<Id, CampaignMessage__c> ();
        for(CampaignMessage__c campMessage : campMessageList){
            if(campMessage.JourneyID__c == null){
                campToCampaignMessageMap.put(campMessage.campaign__c, campMessage);
                //campaignToUserExternalIdMap.put(campMessage.campaign__c,campMessage.AssociateID__c + '_' + campMessage.AssociateID__c);
            }
        } 
		return campToCampaignMessageMap;
    }
    
    //Helper method to get campaign messages to campaigns Map
    private static List<Campaign> setCampaignAndCampaignMessages(Set<Id> campaignIds,EmailDataWrapper emailDataWrapper) {
        List<Campaign> campaignList = [Select id,Recordtype.name,Total_Number_Members__c,Name,LastModifiedby.Name,Lastmodifiedbyid,Initiated_By_Id__c,Lastmodifiedby.UserType__c,Journey_Start_Date__c,
                                       (Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c,Associateid__c
                                        from CampaignMessage__r where Status__c != 'Cancelled - stopped journey' ORDER BY Transmissiondate__c ASC) from campaign where Id IN:campaignIds WITH SECURITY_ENFORCED]; 
        
        for(Campaign camp : campaignList) {
            if(camp.Recordtype.name != 'Corporate Leads'){
                //campIdToCampMap.put(camp.Id,camp);    
                //campToCampaignMessageListMap.put(camp.Id, camp.CampaignMessage__r); 
                emailDataWrapper.campIdToCampMap.put(camp.Id, camp);
                if(!emailDataWrapper.campIdToCampMessageMap.containsKey(camp.Id)) {
                	emailDataWrapper.campIdToCampMessageMap.put(campId, new List<CampaignMessage__c>());
                }
				emailDataWrapper.campIdToCampMessageMap.get(camp.Id).add(camp.CampaignMessage__r);
            }
        }
        //return campaignList;
    }
    
    //Helper method to get email map and send notifications
    private static void setCCEmails(EmailDataWrapper emailDataWrapper){
        if(emailDataWrapper.campIdToCampMessageMap.isEmpty()) {
        	return;
        }
		
		Map<Id, List<String>> campToExtIds = new Map<Id, List<String>>();
        for(CampaignMessage__c message : emailDataWrapper.campIdToCampMessageMap.values()) {
            if(!campToExtIds.containsKey(message.Campaign__c)) {
                campToExtIds.put(message.Campaign__c, new List<String>());
            }
        	campToExtIds.get(message.Campaign__c).add(message.campMessage.AssociateID__c + '_' + campMessage.AssociateID__c)
        }

        List<User> userList = [Select id,Email,Userexternalid__c from user where Userexternalid__c IN: campToExtIds.values() WITH SECURITY_ENFORCED];
		Map<String, User> userExtIdToEmailMap = new Mapp<String, User>();
        for(User usr : userList){
        	userExtIdToEmailMap.put(usr.UserExternalID__c,usr);          
        }

		for(Id campaignId : emailDataWrapper.campIdToCampMessageMap.keySet()) {
            if(!emailDataWrapper.campIdToCCAddressMap.containsKey(campaignId)) {
            	emailDataWrapper.campIdToCCAddressMap.put(campaignId, new List<String>());
            }
            for(CampaignMessage__c message : emailDataWrapper.campIdToCampMessageMap.get(campaignId)) {
				emailDataWrapper.campIdToCCAddressMap.get(campaignId).add(userExtIdToEmailMap.get(message.campMessage.AssociateID__c + '_' + campMessage.AssociateID__c));
            }
        }
    }
}
*******************
public with sharing class HLPR_CampMailerCostNotifications {
    private static String starString;
    @TestVisible private static String emailHtmlBody;
    private static List<Messaging.singleEmailMessage> emailMessages;    
    
    public static void sendEmailNotifications(EmailDataWrapper emailDataWrappper, Boolean journeyOrOneOffIndication){
		singleEmailMessageList(emailDataWrappper,journeyOrOneOffIndication);
        Messaging.SendEmailResult[] results =  Messaging.sendEmail(emailMessages); 
    }
    
    private static void singleEmailMessageList(EmailDataWrapper emailDataWrappper, Boolean journeyOrOneOffIndication){
        emailMessages = new List<Messaging.singleEmailMessage>();
        String[] toCcAddresses;
        for(Id campaignId : emailDataWrappper.campIdToCampMap.keySet()){
        	String[] toAddresses = emailDataWrappper.campIdToCCAddressMap.get(campaignId);
            if(journeyOrOneOffIndication){
                toCcAddresses = getCcAddresses(toAddresses,campaignId);
            }

            emailHtmlBody = getEmailHtmlBody(campaignId,emailDataWrappper, journeyOrOneOffIndication);
            Messaging.singleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setToAddresses(toAddresses);
            if(toCcAddresses != null && !toCcAddresses.isEmpty() && journeyOrOneOffIndication){
                emailMessage.setCcAddresses(toCcAddresses);
            }
            emailMessage.setSubject(System.Label.CL_CAMP_MAILER_SUBJECT);
            emailMessage.setHtmlBody(emailHtmlBody);
            emailMessages.add(emailMessage);    
        }
    }
    
   //Helper method to get ccaddresses
    private static List<String> getCcAddresses(List<String> toAddresses, Id campaignId){
        List<String> toCcAddresses = new List<String>{AP_CampMailerCostNotifications.userIdToEmailMap.get(AP_CampMailerCostNotifications.campaignToUserIdMap.get(campaignId))};
        String[] cCAddresses = new List<String>();    
        if(toCcAddresses[0] != toAddresses[0]){
            cCAddresses.add(toCcAddresses[0]); 
        }        
        return cCAddresses;
    }
    
    
    * @method - getEmailHtmlBody
    * @description - This method will be help us to form Email Body used for sending notifications
    * @param campaignId - Campaign Id
    * @return - String Html Body
    
    public static string getEmailHtmlBody(Id campaignId,EmailDataWrapper emailDataWrappper, Boolean journeyOrOneOffIndication){
        String htmlBody = '';
        htmlBody += getHtmlTableHeader(campaignId);
        htmlBody += getHtmlTableBody(campaignId,journeyOrOneOffIndication);        
        htmlBody += getCampaignUrlAndLegend(campaignId);
        return htmlBody;
    }    
    
    //Helper method to get Html table header
    private static string getHtmlTableHeader(Id campaignId, EmailDataWrapper emailDataWrappper){
        String htmlBody = '';
        htmlBody += '<font color="gray">';
        htmlBody += '<h3>'+'The following Direct Mail has been started on a Campaign by '+emailDataWrappper.campIdToUserMap.get(campaignId).Name+'</h3>';
        htmlBody += '<br />';
        htmlBody += 'Number of Campaign Members: '+ emailDataWrappper.campIdToCampMap.get(campaignId).Total_Number_Members__c;
        //open table..
        htmlBody += '<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray"> <tr style="background-color: #f2f2f2;text-align : center">';
        htmlBody += '<td colspan="6"><b>'+emailDataWrappper.campIdToCampMap.get(campaignId).Name+'</b></td> </tr>';
        htmlBody += '<tr style="background-color: #f2f2f2;"> <th align="center">ESTIMATED DATE</th> <th align="center">SOURCE</th> <th align="center">DELIVERY TYPE</th> <th align="center">ESTIMATED COST PER MAIL</th> <th align="center">LETTER NAME</th> <th align="center">STATUS</th>';            
        return htmlBody; 
    }
    
    //Helper method to get Html Table Body
    private static String getHtmlTableBody(Id campaignId, EmailDataWrapper emailDataWrappper, Boolean journeyOrOneOffIndication){
        String htmlBody = '';
        //htmlBody+='<tr>';
        Double totalCost = 0.00;
        //iterate over list and output columns/data into table rows...
        List<CampaignMessage__c> campMessageList = emailDataWrappper.campIdToCampMessageMapp.get(campaignId);        
        for(CampaignMessage__c campaignMessage : campMessageList){
            //getStarString(campaignMessage);            
            Date estimatedDate = campaignMessage.TransmissionDate__c;
            totalCost = totalCost + (campaignMessage.Cost__c ==null?0.00:Double.valueOf(campaignMessage.Cost__c));
            htmlBody += getCampMessageHtmlTableCalculations(campaignMessage,estimatedDate);  
        }
        if(journeyOrOneOffIndication){
            List<Journey_Step__c> jrnyStepList = emailDataWrappper.campIdToJourneyStepMap.get(campaignId);
            for(Journey_Step__c jrnyStep : jrnyStepList){
                totalCost = totalCost + (jrnyStep.Cost__c ==null?0.00:Double.valueOf(jrnyStep.Cost__c));
                htmlBody += getJourneyStepHtmlTableCalculations(jrnyStep,campaignId);             
            }
        }
        totalCost = totalCost*emailDataWrappper.campIdToCampMap.get(campaignId).Total_Number_Members__c;  
        
        htmlBody += +'<tr>'+'<td><b>TOTAL COST:</b></td>'+'<td></td>'+'<td></td>'+'<td>'+'$'+totalCost+'</td>'+'<td></td>'+'<td></td>'+'</table>';
        return htmlBody;
    }
    
    //Helper method to perform journeystep Html table calculations
    private static String getJourneyStepHtmlTableCalculations(Journey_Step__c jrnyStep, Id campaignId, EmailDataWrapper emailDataWrappper){
        Date estimatedDate = emailDataWrappper.campIdToCampMap.get(campaignId).Journey_Start_Date__c;
        Integer daysNum = jrnyStep.DaysNum__c.intvalue();
        String htmlBody = '';        
        htmlBody += '<tr>' +
            +'<td>' + '<font color="red">*</font>' + ((estimatedDate != null) ? DateTime.newInstance(estimatedDate.adddays(daysNum).year(), estimatedDate.adddays(daysNum).month(),estimatedDate.adddays(daysNum).day()).format('MM/dd/yy') : 'Not Provided') + '</td>' +
            '<td>' +jrnyStep.JourneyName__c  + '</td>' +
            '<td>' + ((jrnyStep.MailClassCode__c == '1') ? '1st Class' : '3rd Class') + '</td>'+            
            '<td>' + ((jrnyStep.cost__c != null) ? '$'+jrnyStep.cost__c : 'Not Provided') + '</td>' +
            '<td>' + ((jrnyStep.Itemid__c != null) ? jrnyStep.Itemid__c : 'Not Provided') + '</td>' +
            '<td>' + 'Scheduled' + '</td>'+
            '</tr>';
        return htmlBody;        
    }    
    
    //Helper method to perform campaignmessage Html table calculations
    private static String getCampMessageHtmlTableCalculations(CampaignMessage__c campaignMessage, Date estimatedDate){
        String htmlBody = '';
        htmlBody += '<tr>' +
            +'<td>' + ((estimatedDate != null) ? DateTime.newInstance(estimatedDate.year(), estimatedDate.month(),estimatedDate.day()).format('MM/dd/yy') : 'Not Provided') + '</td>' +
            '<td>' + ((campaignMessage.JourneyId__c != null) ? campaignMessage.JourneyName__c : 'Single Mailer') + '</td>' +
            '<td>' + ((campaignMessage.MailClassCode__c == '1') ? '1st Class' : '3rd Class') + '</td>'+            
            '<td>' + ((campaignMessage.cost__c != null) ? '$'+campaignMessage.cost__c : 'Not Provided') + '</td>' +
            '<td>' + ((campaignMessage.Itemid__c != null) ? campaignMessage.Itemid__c : 'Not Provided') + '</td>' +
            '<td>' + ((campaignMessage.Status__c != null) ? campaignMessage.Status__c : 'Not Provided') + '</td>'+
            '</tr>';
        
        return htmlBody;        
    }    
    
    //Helper method to get star string based on the conditions
    private static void getStarString(CampaignMessage__c campaignMessage){
        starString = campaignMessage.Id.equals(AP_CampMailerCostNotifications.campToCampaignMessageMap.get(campaignMessage.Campaign__c).Id)?'<font color="red">*</font>':'';
        
    }
    
    //Helper method to get campaign url and legend
    private static String getCampaignUrlAndLegend(Id campaignId){
        String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + campaignId;
        String htmlBody = '';
        htmlBody += '<br />'+'<font color="red">*</font>' + ' New Mails'+'<p>'+'View Campaign at: '+recordUrl+'</p>'+System.Label.CL_CAMP_MAILER_NOTIFICATION_MSG+'</font>';
        return htmlBody; 
    }
}
*/
}