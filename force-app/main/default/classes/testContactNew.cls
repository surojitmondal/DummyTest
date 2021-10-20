@isTest
public class testContactNew {
public integer numAccts = 10;
    public static void createTestRecords(Integer numAccts, Integer numContactsPerAcct){
        List<Account> accts = new List<Account>();
        for(integer i = 0; i< numAccts; i++){
            Account a = new Account(name = 'TestAcc' + i);
            accts.add(a);
        }
        insert accts;
        System.debug(accts);
    }
    
    /*
     ({    
    closeCmpLaunchLink : function(component, event, helper) {
        alert('Entering innerMethod');
        var journeyId = component.get("v.recordId");
        var inputDaysNum = component.find("jnyStepDaysNum").get("v.value");
        var cmpTarget = component.find("jnyStepDaysNum");
        if(inputDaysNum ==''){
            component.set("v.errorMessage","Enter a value in this field");
			$A.util.addClass(cmpTarget,'slds-has-error');            
        }
        if(inputDaysNum > 0){
        var action = component.get("c.getJourneyStepDetails");
        action.setParams({masterJnyId:component.get("v.recordId")});            
        action.setCallback(this, function(response) {
        	var state = response.getState();        
            if(state == "SUCCESS") {
                var serverMethodResp = response.getReturnValue();
                this.closeJnyStepComp(component);
                this.launchLetterSelectLink(journeyId,inputDaysNum,serverMethodResp);                		
            }    
        });
        $A.enqueueAction(action);
        }
        else if(inputDaysNum !='' && inputDaysNum != null){
          component.set("v.errorMessage","Enter a value greater than zero in this field");
          $A.util.addClass(cmpTarget,'slds-has-error');  
        }
	},
    
    closeJnyStepComp : function(component) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({"title": "Launch Success!","message": "Letter selection was launched sucessfully!"});
        resultsToast.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    launchLetterSelectLink : function(p_JourneyId, p_daysNum, p_JourneyRecord) {
        var journeyStepId = 1;
        var baseUrl = '/apex/VFP_ExternalLink?LinkId=86';
     	var urlParamPart1 = '&agentAlias='+p_JourneyRecord.userAlias+'&journeyNumber='+p_JourneyRecord.journeyNumber+'&journeyStepId='+p_JourneyRecord.JourneyStepId;
        var urlParamPart2 = '&journeyId='+p_JourneyId+'&daysNum='+p_daysNum;
        var p2kinLetterSelUrl = baseUrl + urlParamPart1 + urlParamPart2;
       	window.open(p2kinLetterSelUrl);
    },    
    
})
     **/ 
}