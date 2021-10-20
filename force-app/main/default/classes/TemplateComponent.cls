public class TemplateComponent{
/*
<messaging:emailTemplate subject="" recipientType="User" relatedToType="Campaign">
    <messaging:htmlEmailBody>
        <html>

        <body>
            <p>Hi {!recipient.Name}</p>
            <p>Some text</p>
            <c:VF_Component campaignId="{!relatedto.id}" recipientId="{!recipient.Id}"></c:VF_Component>

            <p>Some More text</p>

        </body>

        </html>
    </messaging:htmlEmailBody>
</messaging:emailTemplate>


<!--VF_Component-->
<apex:component controller="ApexController" access="global">
    <apex:attribute name="relatedToId" assignTo="{!targetObjectId}" type="String"/>
    <apex:attribute name="recipientId" assignTo="{!recipientUserId}" type="String"/>
    Total amount is {!totalAmount} 
</apex:component>



public class ApexController {
    public ID targetObjectId { get; set; }
    public ID recipientUserId { get; set; }
    
    
    public String totalAmount {
        get {
            return getTotalAmount();
        }
        private set;
    }
    
    public ApexController() {}    
    
    private Integer getTotalAmount() {
        // Put your apex logic calculation here and return the amount or anything that you want.
    }
    
}
*/


}