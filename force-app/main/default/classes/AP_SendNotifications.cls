public class AP_SendNotifications {
    public static void sendEmailNotifications(){
        EmailTemplate emailTemplate = [Select id from EmailTemplate where name = 'SendNotificationTemplate'];
        //String bodyData = '';
        //String[] toAddresses = new List<String>{'lakkamhemanth@gmail.com'};
            
            String emailTitleBody = 'Hi this is a test email';
        
        Messaging.singleEmailMessage emailMessage = Messaging.renderStoredEmailTemplate(emailTemplate.Id, '0056A000001re89', '7016A000000In3CQAS');
            //new Messaging.SingleEmailMessage();
        
       // emailMessage.setTargetObjectId('0056A000001re89');
       // emailMessage.setWhatId('7016A000000In3CQAS');
        emailMessage.SaveAsActivity = false;
        //emailMessage.setToAddresses(toAddresses);
        emailMessage.setSubject('Hello');
       // emailMessage.setTemplateID(emailTemplate.Id);
        //emailMessage.setWhatId(campaignObj.Id);
        //emailMessage.setHTMLBody(emailTitleBody);
        //0052F000000vkyT
        //campaignId
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
        Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.singleEmailMessage[] {emailMessage});   
    }
}