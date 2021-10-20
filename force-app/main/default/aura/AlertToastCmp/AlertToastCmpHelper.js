/*({
    showAlertToast : function(component) {
        const recId = component.get("v.recordId");
        if (recId && recId.length > 0) {
            const action = component.get("c.showAlertToast");
            action.setParams({
                recId : recId
            });
            action.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    var objName = component.get("v.sobjecttype");
                    if (response.getReturnValue()) {
                        component.find('alertToast').showToast({
                            "title": "This "+objName+" has an alert!",
                            "message": "Review "+objName+" Notes before proceeding.",
                            "variant": "warning",
                        });
                    }
                }
            });            
            $A.enqueueAction(action);
        }
    }
})*/

({
    showAlertToast : function(component,event,helper) {
        var oppId = component.get("v.recordId");
        var signedWrittenConsentURL = "/lightning/cmp/c%3ASignedWrittenConsentModal?c__recordId="+oppId;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: 'Consent is about to expire - If you would like to request consent',
            //messageTemplate: 'Record {0} created! See it {1}!',
            messageTemplate: 'Consent is about to expire! - If you would like to request consent {1}!',
            messageTemplateData: ['Salesforce', {
                url: signedWrittenConsentURL,
                label: 'click here',
            }
                                 ],
            'type': 'warning'
        });
        //toastEvent.fire();
    }
})