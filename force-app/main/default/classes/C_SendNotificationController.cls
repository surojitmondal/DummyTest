public class C_SendNotificationController {
    public class B {
    
	}
    public ID targetObjectId { get; set; }
    public ID recipientUserId { get; set; }
    
    public C_SendNotificationController(){
        
    }
    public void totalAmount() {
        
            //return getTotalAmount();
        }
    //private Integer getTotalAmount() {
        // Put your apex logic calculation here and return the amount or anything that you want.
    //}
    
    /*
    public with sharing class AP_CampMailerCostNotifications {
    
    
    public static EmailDataWrapper emailDataWrapper = new EmailDataWrapper();
    private static final String CLASS_NAME = 'AP_CampMailerCostNotifications';
    private static final String METHODNAME = 'processSendNotifications';    
    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();    
    
    /**
    * @method- Invoked by  CampaignMessageAfterInsert Trigger           
    * @description  This method will helps us to form the email body with required campaign message details,
    * 				fetch the users who have performed the operation and send the email notifications as required
    * @name  processSendNotifications
    * @param  byPassObjectTrigger - boolean to check bypass trigger
    * @param  campMessageList - Campaign Messages List
    
    public static void processOneOffSendNotifications(Boolean byPassObjectTrigger,List<CampaignMessage__c> campMessageList){
        try{
            if(isTriggerByPassed(byPassObjectTrigger)) {
                return;
            }
            campaignToCampaignMessageMap(campMessageList);
            if(emailDataWrapper.campToCampaignMessageMap.isEmpty()){
                return;
            }
            setCampaignAndCampaignMessages(emailDataWrapper.campToCampaignMessageMap.keySet());
            if(emailDataWrapper.campIdToCampMap.isEmpty()){                    
                return; 
            }
            getOneOffAgentEmailMap(emailDataWrapper.campaignToUserExternalIdMap.values());
            HLPR_CampMailerCostNotifications.sendEmailNotifications(emailDataWrapper, false);
            
        }
        catch(Exception CampSendNotificationException){
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME, LoggingLevel.ERROR);
        }
        
    }
    
    //Helper method to check if trigger bypassed
    private static Boolean isTriggerByPassed(Boolean byPassObjectTrigger) {        
        return CS001_ByPassTriggerAll__c.getInstance().Override_All__c || toggleContext.isActive(UTIL_Toggles.SENDNOTIFICATIONS) || byPassObjectTrigger;
        
    }    
    
    //Helper method to get campaign to campaignmessage map
    private static void campaignToCampaignMessageMap(List<CampaignMessage__c> campMessageList){        
        for(CampaignMessage__c campMessage : campMessageList){
            if(campMessage.JourneyID__c == null){
                emailDataWrapper.campToCampaignMessageMap.put(campMessage.campaign__c, campMessage);
                emailDataWrapper.campaignToUserExternalIdMap.put(campMessage.campaign__c,campMessage.AssociateID__c + '_' + campMessage.AssociateID__c);
            }
        }       
    }
    
    //Helper method to set campaigns to campaign messages map
    private static List<Campaign> setCampaignAndCampaignMessages(Set<Id> campaignIds){
        List<Campaign> campaignList = [Select id,Recordtype.name,Total_Number_Members__c,Name,LastModifiedby.Name,Lastmodifiedbyid,Initiated_By_Id__c,Lastmodifiedby.UserType__c,Journey_Start_Date__c,
                                       (Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c,Associateid__c
                                        from CampaignMessage__r where Status__c != 'Cancelled - stopped journey' ORDER BY Transmissiondate__c ASC) from campaign where Id IN:campaignIds WITH SECURITY_ENFORCED]; 
        
        for(Campaign camp : campaignList) {
            if(camp.Recordtype.name != 'Corporate Leads'){
                emailDataWrapper.campIdToCampMap.put(camp.Id,camp);    
				List<EmailObjectWrappper> wrappers = new List<EmailObjectWrappper>();
                for(CampaignMessage__c message : camp.CampaignMessage__r) {
                	wrappers.add(new EmailObjectWrappper(message));
                }
                emailDataWrapper.emailObjects.put(camp.Id, wrappers);                
            }
        }
        return campaignList;
    }
    
    //Helper method to get agent userexternalid to agent email map
    private static void getOneOffAgentEmailMap(List<String> userExternalIds){
        List<User> userList = [Select id,Email,Userexternalid__c from user where Userexternalid__c IN: userExternalIds WITH SECURITY_ENFORCED];
        for(User usr : userList){
            emailDataWrapper.userExtIdToUserEmailMap.put(usr.UserExternalID__c,usr.Email);          
        }      
    }
    
    /**
    * @method- Invoked by  CampaignJourneyTrackingAfterInsert Trigger           
    * @description  This method will helps us to form the email body with required journey step and campaign message details,
    * 				fetch the users who have performed the operation and send the email notifications as required
    * @name  processJourneySendNotifications
    * @param  byPassObjectTrigger - boolean to check bypass trigger
    * @param  campJrnyTrackingList - Campaign Journey Tracking List
    
    public static void processJourneySendNotifications(Boolean byPassObjectTrigger,List<Campaign_Journey_Tracking__c> campJrnyTrackingList){        
        try{
            if(isTriggerByPassed(byPassObjectTrigger)) {
                return;
            }            
            
            campaignIdToJourneyMap(campJrnyTrackingList);
            if(emailDataWrapper.campaignToJourneyMap.isEmpty()){
                return; 
            }
            setCampaignAndCampaignMessages(emailDataWrapper.campaignToJourneyMap.keySet());
            if(emailDataWrapper.campIdToCampMap.isEmpty()){                    
                return; 
            }
            getJourneyAndJourneySteps(emailDataWrapper.campaignToJourneyMap.values());
           	getAgentAndCcEmailMap(emailDataWrapper.campaignToAgentUserIdMap.values(),setCampaignAndCampaignMessages(emailDataWrapper.campaignToJourneyMap.keySet()));
            HLPR_CampMailerCostNotifications.sendEmailNotifications(emailDataWrapper,true);
            
        }        
        catch(Exception CampSendNotificationException){
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME, LoggingLevel.ERROR);
        }
    }
    
    //Helper method to get campaign to journey map
    private static void campaignIdToJourneyMap(List<Campaign_Journey_Tracking__c> campJrnyTrackingList){ 
        Map<Id,String> campaignToJourneyMap = new Map<Id,String>();
        Map<String,List<Journey_Step__c>> journeyExtIdToJrnyStepListMap = new Map<String,List<Journey_Step__c>>();
        for(Campaign_Journey_Tracking__c campJrnyTrackingRec : campJrnyTrackingList){
            if(campJrnyTrackingRec.ActionType__c == 'Journey Started'){
                campaignToJourneyMap.Put(campJrnyTrackingRec.Campaign__c,campJrnyTrackingRec.JourneyExternalID__c);
                emailDataWrapper.campaignToAgentUserIdMap.put(campJrnyTrackingRec.Campaign__c,campJrnyTrackingRec.Agent__c);
            }
        }
        
        List<Journey__c> jrnyAndJrnyStepList = [Select id,Journey_External_ID__c ,(Select id,DaysNum__c,Cost__c,ItemID__c,JourneyName__c, MailClassCode__c FROM Journey_Step__r WHERE ContactMethodName__c  = 'Mailing' ORDER BY JourneyStepID__c)
                                                FROM Journey__c WHERE Journey_External_ID__c IN:campaignToJourneyMap.values() WITH SECURITY_ENFORCED];
        for(Journey__c jrny : jrnyAndJrnyStepList){
           journeyExtIdToJrnyStepListMap.put(jrny.Journey_External_ID__c, jrny.Journey_Step__r); 
        }

        for(Id campaignId  : campaignToJourneyMap.keySet()) {
			List<EmailObjectWrappper> wapppers = new List<EmailObjectWrappper>();
            for(Journey_Step__c step : journeyExtIdToJrnyStepListMap.get(campaignToJourneyMap.get(campaignId))) {
            	wapppers.add(new EmailObjectWrappper(step));
            }
        	emailDataWrapper.campIdToJourneyStepMap.put(campaignId, wapppers);
        }
    }
    
    //Helper method to get journey and journeysteps
    private static void getJourneyAndJourneySteps(List<String> jrnyExternalIds){
        
        List<Journey__c> jrnyAndJrnyStepList = [Select id,Journey_External_ID__c ,(Select id,DaysNum__c,Cost__c,ItemID__c,JourneyName__c, MailClassCode__c FROM Journey_Step__r WHERE ContactMethodName__c  = 'Mailing' ORDER BY JourneyStepID__c)
                                                FROM Journey__c WHERE Journey_External_ID__c IN:jrnyExternalIds WITH SECURITY_ENFORCED];
        for(Journey__c jrny : jrnyAndJrnyStepList){
           emailDataWrapper.journeyExtIdToJrnyStepListMap.put(jrny.Journey_External_ID__c, jrny.Journey_Step__r); 
        }
        
    }
    
    //Helper method to get agent/atm email and initiated user name
    private static void getAgentAndCcEmailMap(List<Id> agentUserIds, List<Campaign> campaignList){
        for(Campaign camp : campaignList){
            if(camp.lastmodifiedby.UserType__c != 'Agent' && camp.lastmodifiedby.UserType__c != 'ATM'){
                emailDataWrapper.campaignToUserIdMap.put(camp.Id,camp.Initiated_By_Id__c);
            }
            else{
                emailDataWrapper.campaignToUserIdMap.put(camp.Id,camp.Lastmodifiedby.id);
            }
        }
        List<User> userList = [Select id,Email,Name from user where Id IN: agentUserIds OR Id IN:emailDataWrapper.campaignToUserIdMap.values() WITH SECURITY_ENFORCED];
        for(User usr : userList){
            emailDataWrapper.userIdToEmailMap.put(usr.Id,usr.Email);
            emailDataWrapper.userIdToNameMap.put(usr.Id,usr.Name);
        }
    }
    
	public class EmailObjectWrappper implements Comparable {
		public SObject record {get;set};
		public Date SortFieldValue { get; set;}
        // Constructor
        public EmailObjectWrappper(SObject op, Date sortFieldValue) {
            this.record = op;
			this.SortFieldValue = sortFieldValue;
        }
        
        // Compare opportunities based on the opportunity amount.
        global Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            EmailObjectWrappper compareToOppy = (EmailObjectWrappper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (SortFieldValue > compareToOppy.SortFieldValue) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (SortFieldValue < compareToOppy.SortFieldValue) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    public class EmailDataWrapper{
        public Map<Id,Campaign> campIdToCampMap{get;set;}
        public Map<Id,List<CampaignMessage__c>> campToCampaignMessageListMap{get;set;}
        //public Map<Id,String> campaignToJourneyMap{get;set;}
        //public Map<String,List<Journey_Step__c>> journeyExtIdToJrnyStepListMap{get;set;}
        public Map<Id,Id> campaignToUserIdMap{get;set;}
        public Map<Id,String> userIdToEmailMap{get;set;}
        public Map<Id,String> userIdToNameMap{get;set;}
        public Map<Id,Id> campaignToAgentUserIdMap{get;set;}
		public Map<Id,List<Journey_Step__c>> campIdToJourneyStepMap{get;set;}
        public Map<Id,CampaignMessage__c> campToCampaignMessageMap;
        public Map<Id,String> campaignToUserExternalIdMap{get;set;}
        public Map<String,String> userExtIdToUserEmailMap{get;set;}
		public Map<Id,User> campIdToUserMap{get;set;}
        EmailDataWrapper() {
            campIdToCampMap = new Map<Id,Campaign>();
            campToCampaignMessageListMap = new Map<Id,List<CampaignMessage__c>>();
            campaignToJourneyMap = new Map<Id,String>();
            journeyExtIdToJrnyStepListMap = new Map<String,List<Journey_Step__c>>();
            campaignToUserIdMap = new Map<Id,Id>();
            userIdToEmailMap = new Map<Id,String>();
            userIdToNameMap = new Map<Id,String>();
            campaignToAgentUserIdMap = new Map<Id,Id>();
            campToCampaignMessageMap = new Map<Id,CampaignMessage__c>();
            campaignToUserExternalIdMap = new Map<Id,String>();
            userExtIdToUserEmailMap = new Map<String,String>();
        }
    }
}
*************************
/****************************************************************************************

public with sharing class HLPR_CampMailerCostNotifications {
@TestVisible private static String emailHtmlBody;
private static List<Messaging.singleEmailMessage> emailMessages;    
    
    /**
    * @method- Invoked by  AP_CampMailerCostNotifications Class           
    * @description  This method will helps us to form the email body with required campaign message details, journeystep details
    
    public static void sendEmailNotifications(AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper, Boolean isJourneyNotification){
        singleEmailMessageList(emailDataWrapper,isJourneyNotification);
        Messaging.SendEmailResult[] results =  Messaging.sendEmail(emailMessages); 
    }
    
    //Helper method to form email message and add to messages list
    private static void singleEmailMessageList(AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper, Boolean isJourneyNotification){
        emailMessages = new List<Messaging.singleEmailMessage>();
        String[] toAddresses;
        String[] toCcAddresses;
        for(Id campaignId : emailDataWrapper.campIdToCampMap.keySet()){
            if(isJourneyNotification){
                toAddresses = new List<String>{emailDataWrapper.userIdToEmailMap.get(emailDataWrapper.campaignToAgentUserIdMap.get(campaignId))};
                    toCcAddresses = getCcAddresses(toAddresses,campaignId,emailDataWrapper);
            }
            else{
                toAddresses = new List<String>{emailDataWrapper.userExtIdToUserEmailMap.get(emailDataWrapper.campaignToUserExternalIdMap.get(campaignId))};
                    }
            emailHtmlBody = getEmailHtmlBody(campaignId,isJourneyNotification,emailDataWrapper);
            Messaging.singleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setToAddresses(toAddresses);
            if(toCcAddresses != null && !toCcAddresses.isEmpty() && isJourneyNotification){
                emailMessage.setCcAddresses(toCcAddresses);
            }
            emailMessage.setSubject(System.Label.CL_CAMP_MAILER_SUBJECT);
            emailMessage.setHtmlBody(emailHtmlBody);
            emailMessages.add(emailMessage);    
        }
    }
    
   //Helper method to get ccemail addresses
    private static List<String> getCcAddresses(List<String> toAddresses, Id campaignId,AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper){
        List<String> toCcAddresses = new List<String>{emailDataWrapper.userIdToEmailMap.get(emailDataWrapper.campaignToUserIdMap.get(campaignId))};
        String[] cCAddresses = new List<String>();    
        if(toCcAddresses[0] != toAddresses[0]){
            cCAddresses.add(toCcAddresses[0]); 
        }        
        return cCAddresses;
    }
    
  	//Helper method to form complete Email Body
    private static string getEmailHtmlBody(Id campaignId,Boolean isJourneyNotification,AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper){
        String htmlBody = '';
        htmlBody += getHtmlTableHeader(campaignId,emailDataWrapper);
        htmlBody += getHtmlTableBody(campaignId,isJourneyNotification,emailDataWrapper);        
        htmlBody += getCampaignUrlAndLegend(campaignId);
        return htmlBody;
    }    
    
    //Helper method to get Html table header
    private static string getHtmlTableHeader(Id campaignId,AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper){
        String htmlBody = '';
        htmlBody += '<font color="gray">';
        htmlBody += '<h3>'+'The following Direct Mail has been started on a Campaign by '+emailDataWrapper.userIdToNameMap.get(emailDataWrapper.campaignToUserIdMap.get(campaignId))+'</h3>';
        htmlBody += '<br />';
        htmlBody += 'Number of Campaign Members: '+ emailDataWrapper.campIdToCampMap.get(campaignId).Total_Number_Members__c;
        //open table..
        htmlBody += '<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray"> <tr style="background-color: #f2f2f2;text-align : center">';
        htmlBody += '<td colspan="6"><b>'+emailDataWrapper.campIdToCampMap.get(campaignId).Name+'</b></td> </tr>';
        htmlBody += '<tr style="background-color: #f2f2f2;"> <th align="center">ESTIMATED DATE</th> <th align="center">SOURCE</th> <th align="center">DELIVERY TYPE</th> <th align="center">ESTIMATED COST PER MAIL</th> <th align="center">LETTER NAME</th> <th align="center">STATUS</th>';            
        return htmlBody; 
    }
    
    //Helper method to get Html Table Body
    private static String getHtmlTableBody(Id campaignId, Boolean isJourneyNotification,AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper){
        String htmlBody = '';
        Double totalCost = 0.00;
		List<EmailObjectWrapper> emailObjects = getSortedRecords(
				emailDataWrapper.campToCampaignMessageListMap, 
				emailDataWrapper.journeyExtIdToJrnyStepListMap,
				emailDataWrapper.campIdToCampMap.get(campaignId));
        //iterate over list and output columns/data into table rows...
        List<CampaignMessage__c> campMessageList = emailDataWrapper.campToCampaignMessageListMap.get(campaignId);
        if(isJourneyNotification){
            for(EmailObjectWrappper wrapper : emailObjects) {
                if(wrapper.record.getSObjectType() == CampaignMessage__c.getSObjectType()) {
                    //getStarString(campaignMessage); 
                    Date estimatedDate = wrapper.Record.get('TransmissionDate__c');//campaignMessage.TransmissionDate__c;
                    totalCost = totalCost + (wrapper.Record.get('Cost__c') ==null?0.00:Double.valueOf(wrapper.Record.get('Cost__c')));
                    //htmlBody += getCampMessageHtmlTableCalculations(wrapper.Record,estimatedDate);  
                }
                else {
                    totalCost = totalCost + (wrapper.Record.get('Cost__c') ==null?0.00:Double.valueOf(wrapper.Record.get('Cost__c')));
                    htmlBody += getJourneyStepHtmlTableCalculations(jrnyStep,campaignId,emailDataWrapper); 
                }
            }

            for(CampaignMessage__c campaignMessage : campMessageList){
                //getStarString(campaignMessage);            
                Date estimatedDate = campaignMessage.TransmissionDate__c;
                totalCost = totalCost + (campaignMessage.Cost__c ==null?0.00:Double.valueOf(campaignMessage.Cost__c));
                //htmlBody += getCampMessageHtmlTableCalculations(campaignMessage,estimatedDate);  
            }
            List<Journey_Step__c> jrnyStepList = emailDataWrapper.journeyExtIdToJrnyStepListMap.get(emailDataWrapper.campaignToJourneyMap.get(campaignId));
            for(Journey_Step__c jrnyStep : jrnyStepList){
                totalCost = totalCost + (jrnyStep.Cost__c ==null?0.00:Double.valueOf(jrnyStep.Cost__c));
                htmlBody += getJourneyStepHtmlTableCalculations(jrnyStep,campaignId,emailDataWrapper);             
            }
        }
        else{
            for(CampaignMessage__c campaignMessage : campMessageList){
                Date estimatedDate = campaignMessage.TransmissionDate__c;
                totalCost = totalCost + (campaignMessage.Cost__c ==null?0.00:Double.valueOf(campaignMessage.Cost__c));
                htmlBody += getCampMessageHtmlTableCalculations(campaignMessage,estimatedDate,emailDataWrapper);  
            }
        }
        totalCost = totalCost*emailDataWrapper.campIdToCampMap.get(campaignId).Total_Number_Members__c;  
        
        htmlBody += +'<tr>'+'<td><b>TOTAL COST:</b></td>'+'<td></td>'+'<td></td>'+'<td>'+'$'+totalCost+'</td>'+'<td></td>'+'<td></td>'+'</table>';
        return htmlBody;
    }

    private List<EmailObjectWrapper> getSortedRecords(List<CampaignMessage__c> campMsgs, List<Journey_Step__c> journeySteps, Date journeyStartDate) {
    	List<EmailObjectWrapper> sortedObjects = new List<EmailObjectWrapper>();
        for(CampaignMessage__c message : campMsgs) {
        	sortedObjects.add(new EmailObjectWrapper(message, message.TransmissionDate__c));
        }

        for(Journey_Step__c step : journeySteps) {
			Integer daysNum = step.DaysNum__c.intvalue();
			DateTime dt = ((journeyStartDate != null) ? DateTime.newInstance(journeyStartDate.adddays(daysNum).year(), journeyStartDate.adddays(daysNum).month(),journeyStartDate.adddays(daysNum).day()).format('MM/dd/yy')
        	sortedObjects.add(new EmailObjectWrapper(step, dt));
        }
		
		return sortedObjects.sort();
    }
    
    //Helper method to perform journeystep Html table calculations
    private static String getJourneyStepHtmlTableCalculations(Journey_Step__c jrnyStep, Id campaignId,AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper){
        Date estimatedDate = emailDataWrapper.campIdToCampMap.get(campaignId).Journey_Start_Date__c;
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
    private static String getCampMessageHtmlTableCalculations(SObject object, Date estimatedDate,AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper){
        String starString = campaignMessage.Id.equals(emailDataWrapper.campToCampaignMessageMap.get(campaignMessage.Campaign__c).Id)?'<font color="red">*</font>':'';
        String htmlBody = '';
		String col1, col2, col3,col4,col5, col6;
        if(object.getSObjectType() == CampaingMessage__c.getSObjectType()) {
        	col1 = ((object.get('JourneyId__c') != null) ?(object.get('JourneyName__c') : 'Single Mailer');
			col2 = (((object.get('MailClassCode__c') == '1') ? '1st Class' : '3rd Class');
			col3 = (((object.get('cost__c') != null) ? '$'+object.get('cost__c') : 'Not Provided');
        }
        else {
        	col1 = object.get('JourneyName__c');
			col2 = (((object.get('MailClassCode__c') == '1') ? '1st Class' : '3rd Class');
			col3 = (((object.get('cost__c') != null) ? '$'+object.get('cost__c') : 'Not Provided');
        }

        htmlBody += '<tr>' +
            '<td>' + starString +((estimatedDate != null) ? DateTime.newInstance(estimatedDate.year(), estimatedDate.month(),estimatedDate.day()).format('MM/dd/yy') : 'Not Provided') + '</td>' +
            '<td>' + col1 + '</td>' +
            '<td>' + col2 + '</td>'+            
            '<td>' + col3 + '</td>' +
            '<td>' + (((object.get('Itemid__c') != null) ? object.get('Itemid__c') : 'Not Provided') + '</td>' +
            '<td>' + (((object.get('Status__c') != null) ? object.get('Status__c') : 'Not Provided') + '</td>'+
            '</tr>';
        
        return htmlBody;        
    }    
    
    //Helper method to get campaign url and legend
    private static String getCampaignUrlAndLegend(Id campaignId){
        String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + campaignId;
        String htmlBody = '';
        htmlBody += '<br />'+'<font color="red">*</font>' + ' New Mails'+'<p>'+'View Campaign at: '+recordUrl+'</p>'+System.Label.CL_CAMP_MAILER_NOTIFICATION_MSG+'</font>';
        return htmlBody; 
    }
    
}


**************************
Design:

Trigger After Insert --> CampaignJourneyTracking

CampaignJourneyTracking --> Campaign Relation(Lookup)

List<CampaignJourneyTracking> will insert will collect the list

form a campaignid list and journeyidlist camp

Map<CampaignId, UserId>

Send the Map to the helper

map.keyset
Campaign, CampaignMessage
SOQL on JourneySteps where campaignId
CampaignMessage
SendNotification

for each campaign will get messages based on the campaignto CampaignMessages Map and Journey to Journeysteps Map

Users --> setToAddresses and CCAddresses(Emails from users)

Trigger After Insert --> CampaignMessage

CampaignMessage --> Campaign(Master Detail)

List<CampaignMessage> will insert so we will collect the list and for the map of campaign to campaignmessages, will iterate over the campaign list and get the messages for each campaign and display it

Users --> setToAddresses and CCAddresses

********************************************
What would be the better way to pass the parameters to singleemailmessagemethod??
2 different Html or 2 different singleemailmessage??
end sendemail would be same??
*****************************
*/
    
}