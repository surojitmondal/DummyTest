public class newSendMailNotifications{
/*

public with sharing class AP_CampMailerCostNotifications { 
    
    private static final String CLASS_NAME = 'AP_CampMailerCostNotifications';
    private static final String METHODNAME_ONEOFF = 'processOneOffSendNotifications';
    private static final String METHODNAME_LEADNOTIFICATIONS = 'processOrderUploadLeadSendNotifications';
    private static final String METHODNAME_STARTJOURNEYNOTIFICATIONS = 'processStartJourneySendNotifications';
    public static final String NOTIFICATIONTYPE_LEADNOTIFICATIONS = 'OrderLeadNotifications';
    public static final String NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS = 'OneOffNotifications';
    public static final String NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS = 'StartJourneyNotifications';
    private static Map<Id,Id> campaignIdToInitatedOrLastModfdByIdMap = new Map<Id,Id>();
    private static Map<Id,Id> campaignIdToOwnerIdMap = new Map<Id,Id>();    
    public static EmailDataWrapper emailDataWrapper = new EmailDataWrapper();
    private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();    
    
    /**
    * @method- Invoked by  CampaignMessageAfterInsert Trigger           
    
    public static void processOneOffSendNotifications(Boolean byPassObjectTrigger,List<CampaignMessage__c> campMessageList){
        try{  
            Map<Id,String> campIdToUserExternalIdMap = campaignToCampaignMessageMap(campMessageList);
            if(!isTriggerByPassedOrToggleOn(byPassObjectTrigger) && !emailDataWrapper.campIdToCampaignMessageMap.isEmpty()){                
                getCampaignAndCampaignMessages(emailDataWrapper.campIdToCampaignMessageMap.keySet(),NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS);                    
                getAgentEmail(campIdToUserExternalIdMap);                    
                HLPR_CampMailerCostNotifications.sendEmailNotifications(emailDataWrapper, NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS);
            } 
        }
        catch(Exception CampSendNotificationException) {
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME_ONEOFF, LoggingLevel.ERROR);
        }        
    }
    
    /**
    * @method- Invoked by  CampaignAfterUpdate Trigger           
   
    public static void processOrderUploadLeadSendNotifications(Boolean byPassObjectTrigger, List<Campaign> updatedCampaignList, Map<Id,Campaign> oldCampaignMap){
        try{           
            Set<Id> updatedLeadCampaignIds = getUpdatedLeadCampaignIds(updatedCampaignList,oldCampaignMap);
            if(!isTriggerByPassedOrToggleOn(byPassObjectTrigger) && !updatedLeadCampaignIds.isEmpty()){                    
                getCampaignAndCampaignMessages(updatedLeadCampaignIds, NOTIFICATIONTYPE_LEADNOTIFICATIONS);
                getOwnerIdToSvcAgentExtIdMap();
                HLPR_CampMailerCostNotifications.sendEmailNotifications(emailDataWrapper, NOTIFICATIONTYPE_LEADNOTIFICATIONS);
            }
        }
        catch(Exception CampSendNotificationException) {
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME_LEADNOTIFICATIONS, LoggingLevel.ERROR);
        }        
    }    
    
    /**
    * @method- Invoked by  AP_Campaign_StartJourney Class           
    
    @future    
    public static void processStartJourneySendNotifications(id jrnyStartedCampaignId){
        try{
            if(!toggleContext.isActive(UTIL_Toggles.RESTRICTCAMPSENDNOTIFICATIONS)) {
                List<Campaign> campaignList = getCampaignAndCampaignMessages(new set<Id>{jrnyStartedCampaignId},NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS);
                getCampIdToOwnrIdAndLastModfdByIdMap(campaignList[0]);
                getOwnerIdToSvcAgentExtIdMap();
                campaignIdToJrnyStepListMap(campaignList[0]);
                HLPR_CampMailerCostNotifications.sendEmailNotifications(emailDataWrapper, NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS);
            }            
        }
        catch(Exception CampSendNotificationException){
            LoggingService.logHandledException(CampSendNotificationException, CLASS_NAME, METHODNAME_STARTJOURNEYNOTIFICATIONS, LoggingLevel.ERROR);
        }        
    }
    
    //Helper method to check if trigger bypassed and sendnotifications is not toggled
    private static Boolean isTriggerByPassedOrToggleOn(Boolean byPassObjectTrigger) {       
        return CS001_ByPassTriggerAll__c.getInstance().Override_All__c || toggleContext.isActive(UTIL_Toggles.RESTRICTCAMPSENDNOTIFICATIONS) || byPassObjectTrigger;        
    }
    
    //Helper method to get campaign to campaignmessage map
    private static Map<Id,String> campaignToCampaignMessageMap(List<CampaignMessage__c> campMessageList){
        Map<Id,String> campIdToUserExternalIdMap = new Map<Id,String>();        
        for(CampaignMessage__c campMessage : campMessageList){
            if(String.isBlank(campMessage.JourneyID__c)){
                emailDataWrapper.campIdToCampaignMessageMap.put(campMessage.campaign__c, campMessage);
                campIdToUserExternalIdMap.put(campMessage.campaign__c,campMessage.AssociateID__c + '_' + campMessage.AssociateID__c);
            }
        }
        return campIdToUserExternalIdMap;
    }
    
    //Helper method to get campaignid to campaign map and campaignid to campaignmessagelist map
    private static List<Campaign> getCampaignAndCampaignMessages(Set<Id> campaignIds, String notificationType){
        List<Campaign> campaignList;
        if(notificationType.equals(NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS)){
            campaignList = [Select id,Total_Number_Members__c,Name,LastModifiedById,OwnerId,Journey_ID__c,Journey_Start_Date__c,(Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c                                       
                            from CampaignMessage__r where Status__c != 'Cancelled - stopped journey' AND (Status__c = 'Sent' OR JourneyID__c = null) ORDER BY Transmissiondate__c) from Campaign where Id IN:campaignIds WITH SECURITY_ENFORCED];
        }                                                               
        else{
            campaignList = [Select id,Total_Number_Members__c,Name,LastModifiedById,OwnerId,Journey_ID__c,Journey_Start_Date__c,(Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c                                       
                            from CampaignMessage__r where Status__c != 'Cancelled - stopped journey' ORDER BY Transmissiondate__c) from Campaign where Id IN:campaignIds WITH SECURITY_ENFORCED];
        }
        
        for(Campaign camp : campaignList) {
            emailDataWrapper.campIdToCampMap.put(camp.Id,camp);    
            emailDataWrapper.campIdToCampaignMessageListMap.put(camp.Id, camp.CampaignMessage__r);
        }
        return campaignList;
    }
    
    //Helper method to get agent email
    private static void getAgentEmail(Map<Id,String> campIdToUserExternalIdMap){
        Map<String,String> userExtIdToEmailMap = new Map<String,String>();
        for(User usr : [Select Id,Email,Userexternalid__c from user where Userexternalid__c IN :campIdToUserExternalIdMap.values() WITH SECURITY_ENFORCED]){
            userExtIdToEmailMap.put(usr.UserExternalID__c,usr.Email);
        }
        getCampaignIdToAgentEmailMap(userExtIdToEmailMap,campIdToUserExternalIdMap);
    }
    
    //Helper method to get campaign id to agent email map
    private static void getCampaignIdToAgentEmailMap(Map<String,String> userExtIdToEmailMap,Map<Id,String> campIdToUserExternalIdMap){
        for(Id campaignId : campIdToUserExternalIdMap.keyset()){
            emailDataWrapper.campIdToAgentEmailMap.put(campaignId, userExtIdToEmailMap.get(campIdToUserExternalIdMap.get(campaignId)));           
        }
    }
    
    //Helper method to get updated lead campaign ids
    private static set<Id> getUpdatedLeadCampaignIds(List<Campaign> updatedCampaignList, Map<Id,Campaign> oldCampaignMap){
        Set<Id> updatedLeadCampaignIds = new set<Id>();
        Set<String> campaignTypeSet = new set<String>{'Lead', 'Lead Upload Individual','Lead Upload Organization'};
            for(Campaign updatedCampaign : updatedCampaignList){
                Campaign oldCampaign = oldCampaignMap.get(updatedCampaign.Id);
                if(oldCampaign.Status != null && updatedCampaign.Status != null && oldCampaign.Status.equals('Fulfillment Pending')
                   && updatedCampaign.Status.equals('Fulfillment Completed') && updatedCampaign.Journey_ID__c != null && campaignTypeSet.contains(updatedCampaign.Type)){
                       updatedLeadCampaignIds.add(updatedCampaign.Id);
                       campaignIdToOwnerIdMap.put(updatedCampaign.Id,updatedCampaign.ownerid);
                       campaignIdToInitatedOrLastModfdByIdMap.put(updatedCampaign.Id,updatedCampaign.Initiated_By_Id__c);
                   }           
            }       
        return updatedLeadCampaignIds;
    }
    
    //Helper method to get campaign ownerid to servicingagentexternalid map
    private static void getOwnerIdToSvcAgentExtIdMap(){
        if(!campaignIdToOwnerIdMap.isEmpty() && !campaignIdToInitatedOrLastModfdByIdMap.isEmpty()){
            Map<Id,String> ownerIdToSvcAgentExtIdMap = new Map<Id,String>();
            for(User usr : [Select Id,Servicing_Agent_External_ID__c from user where Id IN:campaignIdToOwnerIdMap.values() WITH SECURITY_ENFORCED]){
                ownerIdToSvcAgentExtIdMap.put(usr.Id, usr.Servicing_Agent_External_ID__c);
            }
            getCampaignIdToAgentEmailAndInitiatedOrLastModfdUserMap(ownerIdToSvcAgentExtIdMap);
        }
    }
    
    //Helper method to get campaign id to agent email, initiated or lastmodified user map
    private static void getCampaignIdToAgentEmailAndInitiatedOrLastModfdUserMap(Map<Id,String> ownerIdToSvcAgentExtIdMap){
        Map<String,String> userExtIdToEmailMap = new Map<String,String>();
        Map<Id,User> userIdToUserMap = new Map<Id,User>();
        for(User usr : [Select Id,Email,Userexternalid__c,Name from user where Userexternalid__c IN:ownerIdToSvcAgentExtIdMap.values() OR Id IN:campaignIdToInitatedOrLastModfdByIdMap.values() WITH SECURITY_ENFORCED]){
            userExtIdToEmailMap.put(usr.UserExternalID__c,usr.Email);
            userIdToUserMap.put(usr.Id,usr);
        }
        for(Id campaignId : campaignIdToInitatedOrLastModfdByIdMap.keySet()){
            emailDataWrapper.campIdToAgentEmailMap.put(campaignId, userExtIdToEmailMap.get(ownerIdToSvcAgentExtIdMap.get(campaignIdToOwnerIdMap.get(campaignId))));
            emailDataWrapper.campIdToInitiatedOrLstModfdUserMap.put(campaignId,userIdToUserMap.get(campaignIdToInitatedOrLastModfdByIdMap.get(campaignId)));
        }
    }
    
    //Helper method to get campaign id to owner id and lastmodifiedbyid map on start journey
    private static void getCampIdToOwnrIdAndLastModfdByIdMap(Campaign jrnyStartedCampaign){
        campaignIdToOwnerIdMap.put(jrnyStartedCampaign.Id,jrnyStartedCampaign.OwnerId);        
        campaignIdToInitatedOrLastModfdByIdMap.put(jrnyStartedCampaign.Id,jrnyStartedCampaign.LastModifiedById);                
    }
    
    //Helper method to get campaign id to journey steps list map
    private static void campaignIdToJrnyStepListMap(Campaign jrnyStartedCampaign){        
        List<Journey_Step__c> jrnyStepList = [Select id,Cost__c,DaysNum__c,MailClassCode__c,ItemID__c,JourneyName__c,JourneyId__c from Journey_Step__c where JourneyID__r.Journey_External_ID__c = :jrnyStartedCampaign.Journey_ID__c WITH SECURITY_ENFORCED];
        emailDataWrapper.campIdToJrnyStepListMap.Put(jrnyStartedCampaign.Id,jrnyStepList);
    }
    
    /**
 
    public with sharing class EmailDataWrapper {
        public Map<Id,Campaign> campIdToCampMap = new Map<Id,Campaign>();
        public Map<Id,String> campIdToAgentEmailMap = new Map<Id,String>();
        public Map<Id,User> campIdToInitiatedOrLstModfdUserMap = new Map<Id,User>();
        public Map<Id,List<CampaignMessage__c>> campIdToCampaignMessageListMap = new Map<Id,List<CampaignMessage__c>>();
        public Map<Id,CampaignMessage__c> campIdToCampaignMessageMap = new Map<Id,CampaignMessage__c>();
        public Map<Id,List<Journey_Step__c>> campIdToJrnyStepListMap = new Map<Id,List<Journey_Step__c>>();
    }    
}

*******HELPER*********88
public with sharing class HLPR_CampMailerCostNotifications {
    
    private static AP_CampMailerCostNotifications.EmailDataWrapper emailData;
    private static final String TDOPEN = '<td align="center">';
    private static final String TDCLOSE = '</td>';
    private static final String LEGENDSTARSTRING = '<font color="red">*</font>';
    private static final String HTMLTABLEFONTCOLOR = '<font color="gray">'; 
    private static final String EMAILHTMLTABLEHEADERBORDER = '<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray"> <tr style="background-color: #f2f2f2;text-align : center">';
    private static final String EMAILHTMLTABLEHEADER = '<tr style="background-color: #f2f2f2;"> <th align="center">ESTIMATED DATE</th> <th align="center">SOURCE</th> <th align="center">DELIVERY TYPE</th> <th align="center">ESTIMATED COST PER MAIL</th> <th align="center">LETTER NAME</th> <th align="center">STATUS</th> </tr>';
    private static final String DIRECTMAILSTARTEDMESSAGE = 'The following Direct Mail has been started on a Campaign';
    private static final String TROPEN = '<tr>';
    private static final String TRCLOSE = '</tr>';
    private static Decimal totalNumberMembers;
    
    /**
    * @method- Invoked by  AP_CampMailerCostNotifications Class           
    * @description  This method will helps us to form the email body with required campaign message details
   
    public static void sendEmailNotifications(AP_CampMailerCostNotifications.EmailDataWrapper emailDataWrapper, String notificationType){
        emailData = emailDataWrapper;
        List<Messaging.singleEmailMessage> emailMessages = singleEmailMessageList(notificationType);        
        if(!emailMessages.isEmpty()){
            Messaging.SendEmailResult[] results =  Messaging.sendEmail(emailMessages);
        }
    }
    
    //Helper method to form email message and add to messages list
    private static List<Messaging.singleEmailMessage> singleEmailMessageList(String notificationType){
        List<Messaging.singleEmailMessage> emailMessages = new List<Messaging.singleEmailMessage>();
        
        for(Id campaignId : emailData.campIdToCampMap.keySet()){
            if((!emailData.campIdToCampaignMessageListMap.get(campaignId).isEmpty() || notificationType.equals(AP_CampMailerCostNotifications.NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS)) && totalCampaignMemberCount(campaignId) > 0){
                Messaging.singleEmailMessage emailMessage = new Messaging.SingleEmailMessage();                
                emailMessage = setCcEmailAddresses(emailMessage,notificationType,campaignId);
                emailMessage.setToAddresses(new List<String>{emailData.campIdToAgentEmailMap.get(campaignId)});                   
                emailMessage.setSubject(System.Label.CL_CAMP_MAILER_SUBJECT);                
                emailMessage.setSenderDisplayName(System.Label.CL_CAMP_MAILER_SENDERNAME);
                emailMessage.setHtmlBody(getEmailHtmlBody(campaignId,notificationType));
                emailMessages.add(emailMessage);
            }
        }
        return emailMessages;
    }
    
    //Helper method get total number of members
    private static Decimal totalCampaignMemberCount(Id campaignId){
        totalNumberMembers = emailData.campIdToCampMap.get(campaignId).Total_Number_Members__c;
        return totalNumberMembers;
    }
    
    //Helper method to get email addresses for email message
    private static Messaging.singleEmailMessage setCcEmailAddresses(Messaging.singleEmailMessage emailMessage,String notificationType,Id campaignId){        
        if(notificationType.equals(AP_CampMailerCostNotifications.NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS)){                    
            return emailMessage;
        }
        String agentEmailAddress = emailData.campIdToAgentEmailMap.get(campaignId);
        String ccEmailAddress = emailData.campIdToInitiatedOrLstModfdUserMap.get(campaignId).Email;
        List<String> toCcEmailAddresses = (ccEmailAddress != agentEmailAddress) ? new List<String>{ccEmailAddress} : new List<String>();
        if(!toCcEmailAddresses.isEmpty()){
            emailMessage.setCcAddresses(toCcEmailAddresses);
        }
        return emailMessage ;
    }
    
    //Helper method to form complete Email Body
    private static string getEmailHtmlBody(Id campaignId,String notificationType){
        String htmlBody = '';
        htmlBody += getHtmlTableHeader(campaignId,notificationType);
        htmlBody += getHtmlTableBody(campaignId,notificationType);        
        htmlBody += getCampaignUrlAndLegend(campaignId);
        return htmlBody;
    }    
    
    //Helper method to get Html table header
    private static string getHtmlTableHeader(Id campaignId, String notificationType){
        String headingOpen = '<h3>';
        String headingClose = '</h3>';
        String htmlTableHeader = '';
        htmlTableHeader += HTMLTABLEFONTCOLOR;
        if(notificationType != AP_CampMailerCostNotifications.NOTIFICATIONTYPE_ONEOFFNOTIFICATIONS){
            htmlTableHeader += headingOpen+DIRECTMAILSTARTEDMESSAGE+' by '+emailData.campIdToInitiatedOrLstModfdUserMap.get(campaignId).Name+headingClose;
        }
        else{
            htmlTableHeader += headingOpen+DIRECTMAILSTARTEDMESSAGE+headingClose;
        }
        htmlTableHeader += '<br />' + 'Number of Campaign Members: '+ totalNumberMembers;
        htmlTableHeader += EMAILHTMLTABLEHEADERBORDER;
        htmlTableHeader += '<td colspan="6"><b>'+emailData.campIdToCampMap.get(campaignId).Name+'</b></td> </tr>';
        htmlTableHeader += EMAILHTMLTABLEHEADER;            
        return htmlTableHeader; 
    }
    
    //Helper method to check notification type and get Html Table Body
    private static String getHtmlTableBody(Id campaignId, String notificationType){
        String htmlTableBody = '';
        if(notificationType.equals(AP_CampMailerCostNotifications.NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS)){
            htmlTableBody = getHtmlTableBodyForStartJourneyNotifications(campaignId);
        }
        else{
            htmlTableBody = getHtmlTableBodyForOneOffOrLeadNotifications(campaignId,notificationType);
        }
        return htmlTableBody;
    }
    
    //Helper to get Html Table Body for start journey notifications
    private static String getHtmlTableBodyForStartJourneyNotifications(Id campaignId){
        String htmlTableBody = '';
        Double totalCost = 0.00;
        List<CampaignMessage__c> campMessageList = emailData.campIdToCampaignMessageListMap.get(campaignId);
        List<Journey_Step__c> jrnyStepList = emailData.campIdToJrnyStepListMap.get(campaignId);
        Date journeyStartDate = emailData.campIdToCampMap.get(campaignId).Journey_Start_Date__c;
        List<EmailObjectWrapper> campMessageAndJrnyStepRecs = getSortedCampMessagesAndJrnyStepRecs(campMessageList,jrnyStepList,journeyStartDate);
        for(Journey_Step__c jrnyStep : jrnyStepList){
            totalCost = totalCost + Double.valueOf(jrnyStep.Cost__c);
        }
        htmlTableBody += getCampMessageAndJrnyStepHtmlTableData(campMessageAndJrnyStepRecs);
        htmlTableBody += getTotalCost(totalCost,campaignId);
        return htmlTableBody;        
    }
    
    //Helper method to get Html Table Body for one off or lead notifications
    private static String getHtmlTableBodyForOneOffOrLeadNotifications(Id campaignId, String notificationType){
        String htmlTableBody = '';
        Double totalCost = 0.00;
        String starString;
        Boolean isLeadNotificatons = notificationType.equals(AP_CampMailerCostNotifications.NOTIFICATIONTYPE_LEADNOTIFICATIONS);
        List<CampaignMessage__c> campMessageList = emailData.campIdToCampaignMessageListMap.get(campaignId);        
        for(CampaignMessage__c campaignMessage : campMessageList){
            if((isLeadNotificatons && campaignMessage.JourneyID__c != null) || 
               (!isLeadNotificatons && campaignMessage.Id.equals(emailData.campIdToCampaignMessageMap.get(campaignMessage.Campaign__c).Id))){
                   totalCost = totalCost + Double.valueOf(campaignMessage.Cost__c);
                   starString = LEGENDSTARSTRING;
               }
            else{
               starString = ''; 
            }
            htmlTableBody += getCampMessageHtmlTableData(campaignMessage,starString);  
        }
        
        htmlTableBody += getTotalCost(totalCost,campaignId);
        return htmlTableBody;
    }
    
    //Helper method to get total cost row in html table
    private static String getTotalCost(Double totalCost, Id campaignId){
        String totalCostRow = '';
        totalCost = (totalCost*totalNumberMembers).setscale(2);      
        totalCostRow += +TROPEN+TDOPEN+'<b>TOTAL COST:</b>'+TDCLOSE+TDOPEN+TDCLOSE+TDOPEN+TDCLOSE+TDOPEN+'$'+totalCost+TDCLOSE+TDOPEN+TDCLOSE+TDOPEN+TDCLOSE+'</table>';
        return totalCostRow;
    }
    
    //Helper method to perform journey step and campaign message html table calculations
    private static String getCampMessageAndJrnyStepHtmlTableData(List<EmailObjectWrapper> campMessageAndJrnyStepRecs){
        String htmlTableData = '';
        for(EmailObjectWrapper campMessOrJrnyStep : campMessageAndJrnyStepRecs){
            String starString = campMessOrJrnyStep.campMessOrJrnyStepRecord.getSObjectType() != campaignMessage__c.getSObjectType()?'<font color="red">*</font>':''; 
            String estimatedDate = DateTime.newInstance(campMessOrJrnyStep.estimatedDate.year(), campMessOrJrnyStep.estimatedDate.month(),campMessOrJrnyStep.estimatedDate.day()).format('MM/dd/yy');
            htmlTableData += TROPEN +
                +TDOPEN + starString + estimatedDate + TDCLOSE +
                TDOPEN + (campMessOrJrnyStep.campMessOrJrnyStepRecord.get('JourneyId__c') != null ? campMessOrJrnyStep.campMessOrJrnyStepRecord.get('JourneyName__c') : 'Single Mailer') + TDCLOSE +
                TDOPEN + (campMessOrJrnyStep.campMessOrJrnyStepRecord.get('MailClassCode__c').equals('1') ? '1st Class' : '3rd Class') + TDCLOSE +            
                TDOPEN + '$'+campMessOrJrnyStep.campMessOrJrnyStepRecord.get('cost__c') + TDCLOSE +
                TDOPEN +  campMessOrJrnyStep.campMessOrJrnyStepRecord.get('Itemid__c') + TDCLOSE +
                TDOPEN + (campMessOrJrnyStep.campMessOrJrnyStepRecord.getSObjectType() == campaignMessage__c.getSObjectType() ? campMessOrJrnyStep.campMessOrJrnyStepRecord.get('Status__c') : 'Scheduled') + TDCLOSE +                 
                TRCLOSE;
        }
        return htmlTableData;
    }
    
    //Helper method to perform campaignmessage Html table calculations
    private static String getCampMessageHtmlTableData(CampaignMessage__c campaignMessage,String starString){
        String estimatedDate = DateTime.newInstance(campaignMessage.TransmissionDate__c.year(), campaignMessage.TransmissionDate__c.month(),campaignMessage.TransmissionDate__c.day()).format('MM/dd/yy');
        String htmlTableData = '';
        htmlTableData += TROPEN +            
            +TDOPEN + starString + estimatedDate + TDCLOSE +
            TDOPEN + ((campaignMessage.JourneyId__c != null) ? campaignMessage.JourneyName__c : 'Single Mailer') + TDCLOSE +
            TDOPEN + ((campaignMessage.MailClassCode__c.equals('1')) ? '1st Class' : '3rd Class') + TDCLOSE +            
            TDOPEN + '$'+campaignMessage.cost__c + TDCLOSE +
            TDOPEN +  campaignMessage.Itemid__c + TDCLOSE +
            TDOPEN +  campaignMessage.Status__c + TDCLOSE +
            TRCLOSE;        
        return htmlTableData;        
    } 
    
    //Helper method to get campaign url and legend
    private static String getCampaignUrlAndLegend(Id campaignId){
        String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + campaignId;
        String campaignLinkAndMessage = '';
        campaignLinkAndMessage += '<br />'+LEGENDSTARSTRING + ' New Mails'+'<p>'+'View Campaign '+'<a href="'+recordUrl+'">here</a>'+'</p>'+System.Label.CL_CAMP_MAILER_NOTIFICATION_MSG+'</font>';
        return campaignLinkAndMessage; 
    }
    
    //Helper method to get sorted records based on estimated date
    public static List<EmailObjectWrapper> getSortedCampMessagesAndJrnyStepRecs(List<CampaignMessage__c> campMessageList, List<Journey_Step__c> jrnyStepList, Date journeyStartDate) {
        List<EmailObjectWrapper> sortedcampMessageOrJrnyStepRecs = new List<EmailObjectWrapper>();        
        for(Journey_Step__c jrnystep : jrnyStepList) {
            Integer daysNum = jrnystep.DaysNum__c.intvalue();
            Date estimateDate = Date.newInstance(journeyStartDate.adddays(daysNum).year(), journeyStartDate.adddays(daysNum).month(),journeyStartDate.adddays(daysNum).day());
            sortedcampMessageOrJrnyStepRecs.add(new EmailObjectWrapper(jrnystep, estimateDate));
        }
        for(CampaignMessage__c campMessage : campMessageList) {
            sortedcampMessageOrJrnyStepRecs.add(new EmailObjectWrapper(campMessage, campMessage.TransmissionDate__c));
        }
        sortedcampMessageOrJrnyStepRecs.sort();
        return sortedcampMessageOrJrnyStepRecs;
    }
    
    /**
    * @description - wrapper class to implement comparable and sort campaign message and journey step records based on estimatedate
  
    public with sharing class EmailObjectWrapper implements Comparable {       
        public SObject campMessOrJrnyStepRecord;
        public Date estimatedDate;
        // Constructor
        public EmailObjectWrapper(SObject sObjectRecord, Date dateSortFieldValue) {
            this.campMessOrJrnyStepRecord = sObjectRecord;
            this.estimatedDate = dateSortFieldValue;
        }
        
        // Compare records based on date.
        public Integer compareTo(Object compareTo) {
            
            EmailObjectWrapper compareToObj = (EmailObjectWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (estimatedDate > compareToObj.estimatedDate) {
                returnValue = 1;
            } 
            else if (estimatedDate < compareToObj.estimatedDate) {
                returnValue = -1;
            }            
            return returnValue;       
        }
    }
    
}
    
    /**
   
    public with sharing class EmailObjectWrapper implements Comparable {       
        public SObject campMessOrJrnyStepRecord;
        public Date estimatedDate;
        // Constructor
        public EmailObjectWrapper(SObject sObjectRecord, Date dateSortFieldValue) {
            this.campMessOrJrnyStepRecord = sObjectRecord;
            this.estimatedDate = dateSortFieldValue;
        }
        
        // Compare records based on date.
        public Integer compareTo(Object compareTo) {
            
            EmailObjectWrapper compareToObj = (EmailObjectWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (estimatedDate > compareToObj.estimatedDate) {
                returnValue = 1;
            } 
            else if (estimatedDate < compareToObj.estimatedDate) {
                returnValue = -1;
            }            
            return returnValue;       
        }
    }
    
}
    *********TESTCLASS*******

@isTest(SeeAlldata=false)
public class AP_CampMailerCostNotifications_TEST {
    
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User adminUser;
    private static User sysAdminuser;    
    private static UserRole proxyStandardUserRole;
    private static UserRole atmStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static final String CAMPAIGNMESSAGE_STATUS_SCHEDULED  = 'Scheduled';
    private static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName();
    
    
    //setup method to set test data for Agent Office Creation of Agent, ATM, Proxy Users
    @TestSetup
    private static void setUp() {        
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        System.runAs(sysAdminuser) {            
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            atmStandardUserRole= new UserRole(name='ATMMRole', parentRoleId = agentStandardUserRole.id);                    
            insert atmStandardUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = atmStandardUserRole.id);
            insert proxyStandardUserRole;
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser('Proxy', 'TaskProxy','verifytaskproxy1@statefarm.com','123testP','123test');
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            atmUser = UTIL_UserProvisioning_TEST.buildAgentTeamUser('ATM', 'TaskATM', 'verifytaskAtm1@statefarm.com');
            atmUser.userRoleId= atmStandardUserRole.id;
            atmUser.Servicing_Agent_Associate_ID__c = '123test';
            Database.insert(atmUser);
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser('Agent','TaskAgent','verifytaskAgent1@statefarm.com','123test','123test_123test','123test');
            agentUser.userRoleId= agentStandardUserRole.id;
            agentUser.UserPermissionsMarketingUser = true;
            Database.insert(agentUser);
        }
    }   
    
    //testMethod to test oneoff send email notifications    
    private static testMethod void testOneOffSendEmailNotifications(){ 
        User queryAgent = [Select id,name from User where username = 'verifytaskAgent1@statefarm.com'];
        agentUser= queryAgent;
        System.runAs(agentUser) {
        Campaign testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');
        testLeadCampaign.Journey_ID__c = null;
        insert testLeadCampaign;    
        }
        Campaign testCampaign = [Select id,Recordtype.name,Total_Number_Members__c,Name,Lastmodifiedby.name,lastmodifiedby.UserType__c from campaign];
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testCampaign,proxyUser,5);
        campaignMessage__c campaignMessage = buildCampaignMessageRecord(testCampaign.id, System.today().adddays(10),'campMessage5');
        campaignMessage.journeyid__c = null;
        Test.startTest();
        insert campaignMessage;        
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals('verifytaskagent1@statefarm.com',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToAgentEmailMap.get(testCampaign.Id));
        System.assertEquals(1, invocations, 'Email has not been sent');
        Test.stopTest();
     }
    
    //testMethod to test order lead send email notifications    
    private static testMethod void testOrderLeadSendEmailNotifications(){
        User queryAgent = [Select id,name from User where username = 'verifytaskAgent1@statefarm.com'];
        agentUser= queryAgent;
        System.runAs(agentUser) {
            Campaign testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');        
            testLeadCampaign.Initiated_By_Id__c = agentUser.id;
            insert testLeadCampaign;
        }       
        Campaign testCampaign = [Select id,Recordtype.name,Total_Number_Members__c,Name,Lastmodifiedby.name,lastmodifiedby.UserType__c from campaign];
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testCampaign,proxyUser,5);
        List<CampaignMessage__c> campaignMessageList = buildCampaignMessagesForCampaign(testCampaign);
        insert campaignMessageList;
        String emailHtmlBody = getEmailHtmlBody(testCampaign,campaignMessageList);
        testCampaign.Status = 'Fulfillment Completed';
        Test.startTest();
        update testCampaign;
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(1, invocations, 'Email has not been sent');
        System.assertEquals(emailHtmlBody, HLPR_CampMailerCostNotifications.emailHtmlBody, 'Email body does not match');
        System.assertEquals('verifytaskagent1@statefarm.com',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToAgentEmailMap.get(testCampaign.Id));
        System.assertEquals('verifytaskagent1@statefarm.com',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToInitiatedUserMap.get(testCampaign.Id).Email);
        System.assertEquals('TaskAgent',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToInitiatedUserMap.get(testCampaign.Id).Name);        
        Test.stopTest();
    }
    
    //testMethod to test order lead send email notifications    
    private static testMethod void testOrderLeadWithOneOffSendEmail(){
        User queryAgent = [Select id,name from User where username = 'verifytaskAgent1@statefarm.com'];
        agentUser= queryAgent;
        System.runAs(agentUser) {
            Campaign testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');        
            testLeadCampaign.Initiated_By_Id__c = agentUser.id;
            insert testLeadCampaign;
        }       
        Campaign testCampaign = [Select id,Recordtype.name,Total_Number_Members__c,Name,Lastmodifiedby.name,lastmodifiedby.UserType__c from campaign];
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testCampaign,proxyUser,5);
        List<CampaignMessage__c> campaignMessageList = buildCampaignMessagesForCampaign(testCampaign);
        insert campaignMessageList;
        testCampaign.Status = 'Fulfillment Completed';
        update testCampaign;
        campaignMessage__c campaignMessage = buildCampaignMessageRecord(testCampaign.id, System.today().adddays(10),'campMessage6');
        campaignMessage.journeyid__c = null;
        Test.startTest();        
        insert campaignMessage;
        String emailHtmlBody = getEmailHtmlBodyForOrderLeadAndOneOff(testCampaign);
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(1, invocations, 'Email has not been sent');
        System.assertEquals(emailHtmlBody, HLPR_CampMailerCostNotifications.emailHtmlBody, 'Email body does not match');
        System.assertEquals('verifytaskagent1@statefarm.com',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToAgentEmailMap.get(testCampaign.Id));
        System.assertEquals('verifytaskagent1@statefarm.com',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToInitiatedUserMap.get(testCampaign.Id).Email);
        System.assertEquals('TaskAgent',AP_CampMailerCostNotifications.EmailDataWrapper.campIdToInitiatedUserMap.get(testCampaign.Id).Name);        
        Test.stopTest();
    }
    
    //testMethod to test send email exception
    private static testMethod void testOneOffSendEmailException(){
        Campaign testLeadCampaign = buildCampaignRecord('leadCampaignTest',campaignRecordTypeMap.get('Lead Campaign').RecordTypeId,'EXTCAMPAIGNID#1');
        testLeadCampaign.Journey_ID__c = null;
        insert testLeadCampaign;
        Campaign testCampaign = [Select id,Recordtype.name,Total_Number_Members__c,Name,External_Campaign_ID__c from campaign];
        user proxyUser = [Select Id from user where username = 'verifytaskproxy1@statefarm.com'];
        buildCampaignMembers(testCampaign,proxyUser,5);
        List<CampaignMessage__c> campaignMessageList = new List<CampaignMessage__c>();
        campaignMessageList.add(new CampaignMessage__c (Campaign__c = testCampaign.id , ContactMethodName__c = 'Mailing', JourneyID__c = null,CategoryName__c= 'Customer/Prospect Campaign', Status__c = CAMPAIGNMESSAGE_STATUS_SCHEDULED,
                                                        StepTypeCode__c = 1,TimingTypeCode__c = 1,CampaignId__c = testCampaign.External_Campaign_ID__c,TransmissionDate__c = System.today().adddays(10),Name = 'campMessage1',Itemid__c = 'PK43',cost__c = '0.34',MailClassCode__c = '1'));
        insert campaignMessageList;
        List<ExceptionLog__c> exLog = [SELECT Id,Exception_Message__c from ExceptionLog__c class__c where class__c = 'AP_CampMailerCostNotifications'];
        system.assertEquals(1,exLog.size(), 'Exception not found');
    }
    
    //method to create campaign for Agent
    private static void buildCampaignAsAgent()
    {
        
    }
    
    //method to create campaign members
    private static void buildCampaignMembers(Campaign campaign,User proxyUser, Integer num)
    { 
        List<Lead> testLeadList = createLeads(num,proxyUser);
        List<CampaignMember> testCampaignMemberList = new List<CampaignMember>();
        for(Lead testLead:testLeadList)
        {
            testCampaignMemberList.add(new CampaignMember(CampaignId = campaign.id,leadId = testLead.id,Status= 'Sent'));
        }
        insert testCampaignMemberList;
    }
    
    //method to create leads for campaign members
    private static List<Lead> createLeads(Integer num, User proxyUser){
        List<Lead> testLeadList = new List<Lead>();
        for(Integer i = 1;i <= num;i++)
        {
            testLeadList.add(new Lead(LastName = 'tstCmpMemval'+1, ownerId = proxyUser.Id));
        }
        insert testLeadList;
        return testLeadList;
    }
    
    //method to build campaign message
    private static CampaignMessage__c buildCampaignMessageRecord(String paramCmpId, Date paramTransmissionDate,String paramName){ 
        CampaignMessage__c  cmpMessage = new CampaignMessage__c (Campaign__c = paramCmpId , ContactMethodName__c = 'Mailing', JourneyID__c = '00555-13',CategoryName__c= 'Lead Camapigns', Status__c = CAMPAIGNMESSAGE_STATUS_SCHEDULED,
                                                                 StepTypeCode__c = 1,TimingTypeCode__c = 1,CampaignId__c = 'EXTCAMPAIGNID#3',TransmissionDate__c = paramTransmissionDate,Name = paramName,Associateid__c = '123test',
                                                                 Itemid__c = 'PK43',cost__c = '0.34',MailClassCode__c = '1',JourneyName__c = 'Test Journey Lead Campaign 2019');
        return cmpMessage;
    }
    
    //method to build campaign messages 
    private static List<CampaignMessage__c> buildCampaignMessagesForCampaign(Campaign currentCmp) {
        List<CampaignMessage__c> listofCampaignMessages = new List<CampaignMessage__c>();
        listofCampaignMessages.add(buildCampaignMessageRecord(currentCmp.id, System.today().adddays(10),'campMessage1'));
        listofCampaignMessages.add(buildCampaignMessageRecord(currentCmp.id, System.today().adddays(40),'campMessage2'));
        listofCampaignMessages.add(buildCampaignMessageRecord(currentCmp.id, System.today().adddays(75),'campMessage3'));
        listofCampaignMessages.add(buildCampaignMessageRecord(currentCmp.id, System.today().adddays(110),'campMessage4'));
        return listofCampaignMessages;
    }
    
    //method to build campaign
    private static Campaign buildCampaignRecord(String paramCampaignName,Id paramRecordTypeId, String paramExternalCampaignId) {
        Campaign campaigntoBuild = new Campaign(Name = paramCampaignName, Journey_ID__c = '00555-13' ,Journey_Name__c = 'Test Journey Lead Campaign 2019',External_Campaign_ID__c = paramExternalCampaignId,
                                                RecordTypeId = paramRecordTypeId,EndDate = System.today().adddays(60),StartDate =System.today(),Status = 'Fulfillment Pending');       
        return campaigntoBuild;
    }
    
    //method to build email body
    private static String getEmailHtmlBody(Campaign testCampaign,List<CampaignMessage__c>campMessageList){
        String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + testCampaign.Id;
        String tdOpen = '<td align="center">';
        String tdClose = '</td>';
        String htmlBody = '';
        htmlBody += '<font color="gray">';
        htmlBody += '<h3>The following Direct Mail has been started on a Campaign by TaskAgent</h3>';
        htmlBody += '<br />';
        htmlBody += 'Number of Campaign Members: '+ 5;
        htmlBody += '<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray"> <tr style="background-color: #f2f2f2;text-align : center">';
        htmlBody += '<td colspan="6"><b>'+'leadCampaignTest'+'</b></td> </tr>';
        htmlBody += '<tr style="background-color: #f2f2f2;"> <th align="center">ESTIMATED DATE</th> <th align="center">SOURCE</th> <th align="center">DELIVERY TYPE</th> <th align="center">ESTIMATED COST PER MAIL</th> <th align="center">LETTER NAME</th> <th align="center">STATUS</th> </tr>'; 
        for(CampaignMessage__c campaignMessage : campMessageList){
            Date transmissionDate = campaignMessage.TransmissionDate__c;
            htmlBody += '<tr>' +
                +tdOpen + '<font color="red">*</font>' + DateTime.newInstance(transmissionDate.year(), transmissionDate.month(),transmissionDate.day()).format('MM/dd/yy') + tdClose +
                tdOpen + campaignMessage.JourneyName__c + tdClose +
                tdOpen + '1st Class' + tdClose+            
                tdOpen +'$'+campaignMessage.Cost__c +tdClose +
                tdOpen + campaignMessage.ItemID__c+ tdClose +
                tdOpen + campaignMessage.Status__c + tdClose +
                '</tr>';
        }
        htmlBody += +'<tr>'+tdOpen+'<b>TOTAL COST:</b>'+tdClose+tdOpen+tdClose+tdOpen+tdClose+tdOpen+'$'+6.8+tdClose+tdOpen+tdClose+tdOpen+tdClose+'</table>';
        htmlBody += '<br />'+'<font color="red">*</font>' + ' New Mails'+'<p>'+'View Campaign '+'<a href="'+recordUrl+'">here</a>'+'</p>'+System.Label.CL_CAMP_MAILER_NOTIFICATION_MSG+'</font>';    
        return htmlBody;
    }
    
    //method to build email body
    private static String getEmailHtmlBodyForOrderLeadAndOneOff(Campaign testCampaign){
        String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + testCampaign.Id;
        //Query Campaign data and Campaign Messages  
        List<CampaignMessage__c> campMessageList = [Select id,TransmissionDate__c,Cost__c,JourneyName__c,Status__c,ItemID__c, campaign__r.LastMessageSentDate__c, campaign__r.Enddate
                                                                        from CampaignMessage__c where campaign__c =: testCampaign.Id];
            
        String tdOpen = '<td align="center">';
        String tdClose = '</td>';
        String htmlBody = '';
        system.debug('campMessageList' + campMessageList.size());
        htmlBody += '<font color="gray">';
        htmlBody += '<h3>The following Direct Mail has been started on a Campaign by TaskAgent</h3>';
        htmlBody += '<br />';
        htmlBody += 'Number of Campaign Members: '+ 5;
        htmlBody += '<table border="1" style="border: 1px solid gray;border-collapse: collapse;width: 100%;text-align: right;color:gray"> <tr style="background-color: #f2f2f2;text-align : center">';
        htmlBody += '<td colspan="6"><b>'+'leadCampaignTest'+'</b></td> </tr>';
        htmlBody += '<tr style="background-color: #f2f2f2;"> <th align="center">ESTIMATED DATE</th> <th align="center">SOURCE</th> <th align="center">DELIVERY TYPE</th> <th align="center">ESTIMATED COST PER MAIL</th> <th align="center">LETTER NAME</th> <th align="center">STATUS</th> </tr>'; 
        for(CampaignMessage__c campaignMessage : campMessageList){
            Date transmissionDate = campaignMessage.TransmissionDate__c;
            htmlBody += '<tr>' +
                +tdOpen + '<font color="red">*</font>' + DateTime.newInstance(transmissionDate.year(), transmissionDate.month(),transmissionDate.day()).format('MM/dd/yy') + tdClose +
                tdOpen + campaignMessage.JourneyName__c + tdClose +
                tdOpen + '1st Class' + tdClose+            
                tdOpen +'$'+campaignMessage.Cost__c +tdClose +
                tdOpen + campaignMessage.ItemID__c+ tdClose +
                tdOpen + campaignMessage.Status__c + tdClose +
                '</tr>';
        }
        htmlBody += +'<tr>'+tdOpen+'<b>TOTAL COST:</b>'+tdClose+tdOpen+tdClose+tdOpen+tdClose+tdOpen+'$'+8.5+tdClose+tdOpen+tdClose+tdOpen+tdClose+'</table>';
        htmlBody += '<br />'+'<font color="red">*</font>' + ' New Mails'+'<p>'+'View Campaign '+'<a href="'+recordUrl+'">here</a>'+'</p>'+System.Label.CL_CAMP_MAILER_NOTIFICATION_MSG+'</font>';    
        return htmlBody;
    }
}
        String selectQuery = 'Select id,Total_Number_Members__c,Name,LastModifiedById,OwnerId,Journey_ID__c,Journey_Start_Date__c,(Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c from CampaignMessage__r where Status__c != ('Cancelled - stopped journey')';
        String subQuery = notificationType.equals(NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS) ? ' AND JourneyID__c = null ' : '';
        String whereClause = 'ORDER BY Transmissiondate__c) from Campaign where Id IN:campaignIds WITH SECURITY_ENFORCED'
        campaignList = (List<Campaign>) Database.query(selectQuery + subQuery + whereClause);
        List<Campaign> campaignList;
        if(notificationType.equals(NOTIFICATIONTYPE_STARTJOURNEYNOTIFICATIONS)){
            campaignList = [Select id,Total_Number_Members__c,Name,LastModifiedById,OwnerId,Journey_ID__c,Journey_Start_Date__c,(Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c                                       
                            from CampaignMessage__r where Status__c != 'Cancelled - stopped journey' AND (Status__c = 'Sent' OR JourneyID__c = null) ORDER BY Transmissiondate__c) from Campaign where Id IN:campaignIds WITH SECURITY_ENFORCED];
        }                                                               
        else{
            campaignList = [Select id,Total_Number_Members__c,Name,LastModifiedById,OwnerId,Journey_ID__c,Journey_Start_Date__c,(Select Cost__c, Itemid__c,TransmissionDate__c,Status__c,Journeyid__c,Mailclasscode__c,JourneyName__c,Campaign__c                                       
                            from CampaignMessage__r where Status__c != 'Cancelled - stopped journey' ORDER BY Transmissiondate__c) from Campaign where Id IN:campaignIds WITH SECURITY_ENFORCED];
        }        
    
*/
}