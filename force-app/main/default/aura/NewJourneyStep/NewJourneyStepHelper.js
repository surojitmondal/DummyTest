({
    checkDaysNum : function(component) {
        var intDaysNum = component.find("jnyStepDaysNum").get("v.value");
        var cmpTarget = component.find('jnyStepDaysNum');
        if(intDaysNum ==''){
            component.set("v.strMsg","Enter days num");
            $A.util.addClass(cmpTarget, 'slds-has-error');           
            //alert('Enter days num');
        }       	
        if(intDaysNum > 0){
            component.set("v.strMsg","");
            $A.util.removeClass(cmpTarget, 'slds-has-error');   
            this.openRecord(component);
        }  
        else if(intDaysNum !='' && intDaysNum !=null){
            component.set("v.strMsg","Enter only Positive value");
            $A.util.addClass(cmpTarget, 'slds-has-error');
            //alert('Enter only Positive value');
        }
    },
	openRecord : function(component) {
		var journeyId = component.get("v.recordId");
        var finalurl = 'www.google.com'       
        var action = component.get("c.callAPI");
        action.setParams({ 
            "JSrecordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                alert(response.getReturnValue());
                window.open(finalurl);
                //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                //dismissActionpanel.fire();
            }
            else if(state ==="INCOMPLETE"){
                
            }
                else if(state === "ERROR"){
                    var errors = response.getError();
                    if(errors){
                        if(errors[0] && errors[0].message){
                            console.log("Error message: "+
                                        errors[0].message);
                        }                            
                    } else{
                        console.log("unkown error");
                    }
                    
                }
        });
        $A.enqueueAction(action);
	}
    
})