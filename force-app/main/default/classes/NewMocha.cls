public class NewMocha {
    /*
        ({    
    processButtonClick : function(component, event) {
        var errorMessage = 'Something went wrong';
        var clickedButtonLabel = event.getSource().get("v.label");
        if(this.canUserPerformOperation(component)){
            var action = component.get("c.getLaunchButtonData");
            var params = { oppOrAccId: component.get("v.recordId"),
                          sObjectType: component.get("v.sObjectName"),
                          servicingAgentExternalId: component.get("v.loggedInUserServicingAgentExternalId")};     
            action.setParams({'jsonString' :JSON.stringify(params) });        
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    var buttonDataResp = response.getReturnValue();
                    var clickedButtonId = event.getSource().getLocalId();
                    if(buttonDataResp.agentAlias != null && buttonDataResp.agentId != null) {
                        this.redirectButtonClick(clickedButtonId, buttonDataResp);
                    }
                    else{
                        this.popUpToast(clickedButtonLabel, errorMessage));
                    }
                }
                else {
                this.popUpToast(clickedButtonLabel, $A.get("$Label.c.CL_UNKNOWN_CLIENT_ERROR"));
                }
            });
            $A.enqueueAction(action);
        }
        else {
            this.popUpToast(clickedButtonLabel, $A.get("$Label.c.CL_JOURNEY_INVALID_PROFILE"));                    
        }
    },
    
    // helper method to check valid profile
    canUserPerformOperation : function(component) {
        var isValidProfile = true;
        var profileName = component.get("v.loggedInUserProfileName");
         if($A.get("$Label.c.CL_Agent_Profile") !== profileName
           && $A.get("$Label.c.CL_ATM_Profile") !== profileName) {
            isValidProfile = false;
         }
        return isValidProfile;       
    },
    
    // helper method to redirect link
    redirectButtonClick : function(clickedButton, buttonDataResp) {
        switch(clickedButton) {
            case 'sendEmailBtn' :
                this.launchSendEmail(buttonDataResp);
                break;
            case 'sendMailBtn':
                this.launchSendMail(buttonDataResp);
                break;
            default:
                this.launchDirectMail(buttonDataResp);                
        }    
    },
    
    //helper method to launch send mail functionality
    launchSendMail : function (buttonDataResp) {
        window.open('/apex/VFP_ExternalLink?LinkId=7' + '&accountId=' + buttonDataResp.sfAccountId + '&agentAlias=' + buttonDataResp.agentAlias);
    },    
    
    //helper method to launch send email functionality
    launchSendEmail :function(buttonDataResp) {
        window.open('/apex/VFP_ExternalLink?LinkId=8' + '&accountId=' + buttonDataResp.sfAccountId + '&agentAlias=' + buttonDataResp.agentAlias);
    },
    
    //helper method to launch direct mail functionality
    launchDirectMail : function (buttonDataResp) {
        window.open('/apex/VFP_ExternalLink?LinkId=82' + '&clientID=' + buttonDataResp.clientIdentifier +'&agentID=' + buttonDataResp.agentId);  
    },
    
    //helper method to launch Toast
    popUpToast : function(toastTitle,toastMessage) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title': toastTitle,
            'message': toastMessage,
            'type': 'error',
        });
        toastEvent.fire();        
    }    
})

    **/

}