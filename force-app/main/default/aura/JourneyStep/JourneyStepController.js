({
    doInit : function(component, event, helper) {   
        alert('journey id'+component.get("v.recordId"));
        component.set("v.statusVal","choose one"); 
    },
    saveJS : function(component, event, helper) {
        var newJS = component.get("v.JSrec");
        
        var action = component.get("c.callAPI");
            action.setParams({ 
                "JSrecord": newJS
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state == "SUCCESS") {
                    alert(a.getReturnValue());
                }   
            });
            $A.enqueueAction(action);
    },
	mailing : function(component, event, helper) {
        alert(Journey__c.id);
        window.open("https://www.google.com");		
	},
    
    call : function(component, event, helper) {
        
    },

    email : function(component, event, helper) {
        
    },
	statusChange : function(component, event, helper) {
        //alert check for picklist selected value
        alert('status-'+component.find("JouStatus").get("v.value"));
        //assign picklist value to 'statusVal' attribute in component
        component.set("v.statusVal", component.find("JouStatus").get("v.value"));
    },
    cancelDailog : function(component, event, helper) {
        alert("This will cancel the function");
        var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Journey__c"
            });
            homeEvt.fire();
    }   
})