public class TestMocha {
/**
 ##Helper##
 ({    
    processButtonClick : function(component, event) {
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
                    this.redirectButtonClick(clickedButtonId, buttonDataResp);
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

##Mocha for Helper##

"use strict";
const assert = require('assert');
const sinon = require('sinon');
const helper = require('../../../../main/default/aura/AccMessageButtons/AccMessageButtonsHelper');

describe('AccMessageButtonsHelper', function () {

    describe('processButtonClick', function () {

        let action, actionSetParamsSpy, response, component, componentGetStub, componentSetSpy, globalEnqueueActionSpy, globalUtilIsEmptyStub, globalGetStub, source, sourceGetStub, sourceGetLocalIdStub, event, helperRedirectButtonClickSpy, buttonDataResp;

        before(() => {
            global.window = {
                open: function(url) {}
            };
            
            action = {
                setParams : function(map) {},
                setCallback: function (helper, callback) {
                    helper.callback = callback;
                } 
            };
            actionSetParamsSpy = sinon.spy(action, 'setParams');

            response = {
                getState : function () {},
                getReturnValue : function () {}
            };

            component = {
                get : function() {},
                set: function(property, value) {}
            };
            componentGetStub = sinon.stub(component, 'get');

            componentGetStub.withArgs("c.getLaunchButtonData").returns(action);
            componentGetStub.withArgs("v.recordId").returns("1234Id");
            componentGetStub.withArgs("v.sObjectName").returns("Account");
            componentGetStub.withArgs("v.loggedInUserServicingAgentExternalId").returns("AssociateId_AssociateId");            
            componentSetSpy = sinon.spy(component, 'set');

            global.$A = {
                enqueueAction: function(action) {
                    helper.callback(response);
                },
                util: {
                    isEmpty: function(collection) {}
                },
                get: sinon.stub()
            };

            globalEnqueueActionSpy = sinon.spy($A, "enqueueAction");
            
            source = {
                get : function() {
                },
                getLocalId : function() {
                }
            };
            sourceGetStub = sinon.stub(source, "get" );
            sourceGetStub.returns('Send Mail');
            sourceGetLocalIdStub = sinon.stub(source, "getLocalId" );;
            sourceGetLocalIdStub.returns('sendMailBtn');

            event = {
                getSource : function() {
                    return source;
                }
            };
            
            helperRedirectButtonClickSpy = sinon.spy(helper, "redirectButtonClick");            
            buttonDataResp = {
                sfAccountId : '12345AccId',
                agentAlias : 'ekbq'
            };
        });

        after(() => {
            global.$A = null;
        });


        it('calls the server, gets empty data and displays toast - Valid profile', function () {
            debugger;
            //do setup
            buttonDataResp.agentAlias = null;
            buttonDataResp.agentId = null;

            let responseGetStateStub = sinon.stub(response, "getState");
            responseGetStateStub.returns('SUCCESS');
            let responseGetReturnValueStub = sinon.stub(response, "getReturnValue");
            responseGetReturnValueStub.returns(buttonDataResp);
            componentGetStub.withArgs("v.loggedInUserProfileName").returns("Agent");
            global.$A.get.withArgs('$Label.c.CL_Agent_Profile').returns('Agent');
            global.$A.get.withArgs('$Label.c.CL_ATM_Profile').returns('Agent');
            global.$A.get.withArgs('$Label.c.CL_Addl_Info').returns('Error');

            let toastTitle = 'Send Mail';

            let toastEvent = {
                setParams: function () { },
                fire: function () { }
            };

            global.$A.get.withArgs('e.force:showToast').returns(toastEvent);

            let toastParams = {
                'title': toastTitle,
                'message': 'Error',
                'type': 'error'
            };

            let helperToastSetParamSpy = sinon.spy(toastEvent, 'setParams');
            let helperToastFireSpy = sinon.spy(toastEvent, 'fire');

            // Make call to method under test
            helper.processButtonClick(component, event);

            // do asserts
            responseGetStateStub.restore();
            responseGetReturnValueStub.restore();
            sinon.assert.calledWith(helperToastSetParamSpy, toastParams);
            sinon.assert.calledOnce(helperToastFireSpy);
        });

        it('calls the server, gets data and redirect method for url launch - Valid profile', function () {
            debugger;
            //do setup
            buttonDataResp.isValidProfile = true;
            buttonDataResp.agentAlias = 'Valid Allias';
            buttonDataResp.agentId = 'Valid AgentId';

            let responseGetStateStub = sinon.stub(response, "getState");
            responseGetStateStub.returns('SUCCESS');
            let responseGetReturnValueStub = sinon.stub(response, "getReturnValue");
            responseGetReturnValueStub.returns(buttonDataResp);
            componentGetStub.withArgs("v.loggedInUserProfileName").returns("Agent");
            global.$A.get.withArgs('$Label.c.CL_Agent_Profile').returns('Agent');
            global.$A.get.withArgs('$Label.c.CL_ATM_Profile').returns('Agent');

            // Make call to method under test
            helper.processButtonClick(component, event);

            //do asserts
            sinon.assert.calledWith(componentGetStub, "c.getLaunchButtonData");
            var params = { oppOrAccId: "1234Id", sObjectType: "Account", servicingAgentExternalId: "AssociateId_AssociateId" };
            sinon.assert.calledWith(actionSetParamsSpy, { 'jsonString': JSON.stringify(params) });
            sinon.assert.called(responseGetStateStub);
            sinon.assert.called(responseGetReturnValueStub);
            sinon.assert.calledWith(helperRedirectButtonClickSpy, "sendMailBtn", buttonDataResp);

            responseGetStateStub.restore();
            responseGetReturnValueStub.restore();
        });

        it('calls the server, gets data and redirect method for popup launch - Invalid profile', function () {

            // do setup            
            let responseGetStateStub = sinon.stub(response, "getState");
            responseGetStateStub.returns('SUCCESS');
            let responseGetReturnValueStub = sinon.stub(response, "getReturnValue");
            responseGetReturnValueStub.returns(buttonDataResp);
            componentGetStub.withArgs("v.loggedInUserProfileName").returns("Agent");
            global.$A.get.withArgs('$Label.c.CL_Agent_Profile').returns('Non Agent');
            global.$A.get.withArgs('$Label.c.CL_ATM_Profile').returns('Non Agent');
            let helperPopUpToastStub = sinon.stub(helper, "popUpToast");

            // Make call to method under test
            helper.processButtonClick(component, event);

            //do asserts
            sinon.assert.calledWith(helperPopUpToastStub, 'Send Mail');

            responseGetStateStub.restore();
            responseGetReturnValueStub.restore();
            helperPopUpToastStub.restore();
        });

        it('calls server and return Error', function () {

            // do setup    
            let responseGetStateStub = sinon.stub(response, "getState");
            responseGetStateStub.returns('ERROR');
            let responseGetReturnValueSpy = sinon.spy(response, "getReturnValue");
            componentGetStub.withArgs("v.loggedInUserProfileName").returns("Agent");
            global.$A.get.withArgs('$Label.c.CL_Agent_Profile').returns('Agent');
            global.$A.get.withArgs('$Label.c.CL_ATM_Profile').returns('Agent');

            let toastTitle = 'Send Mail';
            let toastMessage = 'potato';

            let toastEvent = {
                setParams: function () { },
                fire: function () { }
            };

            global.$A.get.withArgs('e.force:showToast').returns(toastEvent);
            global.$A.get.withArgs("$Label.c.CL_UNKNOWN_CLIENT_ERROR").returns('potato');

            let toastParams = {
                'title': toastTitle,
                'message': toastMessage,
                'type': 'error'
            };

            let helperToastSetParamSpy = sinon.spy(toastEvent, 'setParams');
            let helperToastFireSpy = sinon.spy(toastEvent, 'fire');

            // Make call to method under test
            helper.processButtonClick(component, event);

            // do asserts
            sinon.assert.notCalled(responseGetReturnValueSpy);
            responseGetStateStub.restore();
            sinon.assert.calledWith(helperToastSetParamSpy, toastParams);
            sinon.assert.calledOnce(helperToastFireSpy);
        });

    });

    describe('canUserPerformOperation', function() {
        
        let component, globalAuraGetStub;
        
        before(() => {
            
            component = {
                get : function(someProperty) {}
            };
            
            global.$A = {
                get : function(someProperty) {}
            };
            globalAuraGetStub = sinon.stub($A, "get");
            globalAuraGetStub.withArgs("$Label.c.CL_Agent_Profile").returns('agent');
            globalAuraGetStub.withArgs("$Label.c.CL_ATM_Profile").returns('atm');
        });
        
        after(() => {
            global.$A = null;
            globalAuraGetStub.restore();
        });
        
        
        it('returns false when the user is not Agent, ATM', function() {
            
            let componentGetStub = sinon.stub(component, 'get');
            componentGetStub.returns('potato');
            
            let allowed = helper.canUserPerformOperation(component);
            
            assert(!allowed);
            sinon.assert.called(componentGetStub);
            sinon.assert.called(globalAuraGetStub);
            
            componentGetStub.restore()
            
        });
        
        it('returns true when the user is Agent', function() {
            
            let componentGetStub = sinon.stub(component, 'get');
            componentGetStub.returns('agent');
            
            let allowed = helper.canUserPerformOperation(component);
            
            assert(allowed);
            sinon.assert.called(componentGetStub);
            sinon.assert.called(globalAuraGetStub);
            
            componentGetStub.restore()
            
        });
        
        it('returns true when the user is Agent Team Member', function() {
            
            let componentGetStub = sinon.stub(component, 'get');
            componentGetStub.returns('atm');
            
            let allowed = helper.canUserPerformOperation(component);
            
            assert(allowed);
            sinon.assert.called(componentGetStub);
            sinon.assert.called(globalAuraGetStub);
            
            componentGetStub.restore()
            
        });
        
    });

    // Test method for function redirectButtonClick
    describe ('redirectButtonClick', function () {

        let buttonDataResp;

        before(() => {

            global.window = {
                open: function(url) {}
            };            

            let buttonDataResp = {
                sfAccountId : '12345AccId',
                agentAlias : 'ekbq'
            };

        });

        after(() => {
            global.$A = null;
        });

        it('calls helper method for launchSendMail', function () {

            // do setup
            let clickedButtonId  = 'sendMailBtn';

            let helperLaunchSendMailStub = sinon.stub(helper, "launchSendMail");

            // Make call to method under test
            helper.redirectButtonClick(clickedButtonId, buttonDataResp);

            // do asserts
            sinon.assert.calledWith(helperLaunchSendMailStub, buttonDataResp);
            
            // do restoration
            helperLaunchSendMailStub.restore();

        }); 

        it('calls helper method for launchSendEmail', function () {

            // do setup
            let clickedButtonId  = 'sendEmailBtn';
            
            let helperLaunchSendEmailStub = sinon.stub(helper, "launchSendEmail");

            // Make call to method under test
            helper.redirectButtonClick(clickedButtonId, buttonDataResp);            

            // do asserts
            sinon.assert.calledWith(helperLaunchSendEmailStub, buttonDataResp);
            
            // do restoration
            helperLaunchSendEmailStub.restore();

        }); 

        it('calls helper method for launchDirectMail', function () {

            // do setup
            let clickedButtonId  = 'directMailBtn';

            let helperLaunchDirectMailStub = sinon.stub(helper, "launchDirectMail");

            // Make call to method under test
            helper.redirectButtonClick(clickedButtonId, buttonDataResp);

            // do asserts
            sinon.assert.calledWith(helperLaunchDirectMailStub, buttonDataResp);
            
            // do restoration
            helperLaunchDirectMailStub.restore();
        }); 

    });

    // Test method for function launchSendMail
    describe('launchSendMail', function () {
        
        afterEach(() => {
            global.window = null;
        });
        
        it('launches sendMail link with correct parameters', function () {

            // do setup
            let buttonDataResp = {
                sfAccountId : '12345AccId',
                agentAlias : 'ekbq'
            };

            let baseUrl = '/apex/VFP_ExternalLink?LinkId=7';
            let urlParamPart1 = '&accountId=' + buttonDataResp.sfAccountId + '&agentAlias=' + buttonDataResp.agentAlias;
            let sendEmailUrl = baseUrl + urlParamPart1;

            global.window = {
                open: function(url) {}
            }
            let windowOpenSpy = sinon.spy(window, "open");

            // Make call to method under test
            helper.launchSendMail(buttonDataResp);

            // do asserts
            sinon.assert.calledWith(windowOpenSpy, sendEmailUrl);
        });

    });

    // Test method for function launchSendEmail
    describe('launchSendEmail', function () {

        afterEach(() => {
            global.window = null;
        });
        
        it('launches sendEmail link with correct parameters', function () {

            // do setup
            let buttonDataResp = {
                sfAccountId : '12345AccId',
                agentAlias : 'ekbq'
            };
            
            let baseUrl = '/apex/VFP_ExternalLink?LinkId=8';
            let urlParamPart1 = '&accountId=' + buttonDataResp.sfAccountId + '&agentAlias=' + buttonDataResp.agentAlias;
            let sendEmailUrl = baseUrl + urlParamPart1;

            global.window = {
                open: function(url) {}
            }
            let windowOpenSpy = sinon.spy(window, "open");

            // Make call to method under test
            helper.launchSendEmail(buttonDataResp);

            // do asserts
            sinon.assert.calledWith(windowOpenSpy, sendEmailUrl);
        });


    });

    // Test method for function launchDirectMail
    describe('launchDirectMail', function () {

        afterEach(() => {
            global.window = null;
        });

        it('launches directMail link with correct parameters', function () {

            // do setup
            let buttonDataResp = {
                agentId : '291234',             
                sfAccountId : '12345AccId',
                clientIdentifier : 'TEST123'        
            };
            
            let baseUrl = '/apex/VFP_ExternalLink?LinkId=82';
            let urlParamPart1 = '&clientID=' + buttonDataResp.clientIdentifier;
            let urlParamPart2 = '&agentID=' + buttonDataResp.agentId;
            let sendEmailUrl = baseUrl + urlParamPart1+ urlParamPart2;

            global.window = {
                open: function(url) {}
            }
            let windowOpenSpy = sinon.spy(window, "open");

            // Make call to method under test
            helper.launchDirectMail(buttonDataResp);

            // do asserts
            sinon.assert.calledWith(windowOpenSpy, sendEmailUrl);
        });
        
    });

    describe ('popUpToast', function () {
        
        after(() => {
            global.$A = null;
        });

        it('calls popupToast method with toast title', function() {
            
            //do setup
            let toastTitle = 'Send Email';
            let toastMessage = 'potato';
            
            let toastEvent = {
                setParams: function() {},
                fire: function() {}
            };
            
            global.$A = {
                get: function(field) {}
            };
            let globalGetStub = sinon.stub($A, "get");
            globalGetStub.withArgs('e.force:showToast').returns(toastEvent);
            
            let toastParams = {
                'title': 'Send Email',
                'message': 'potato',
                'type': 'error'
            };
            
            let helperToastSetParamSpy = sinon.spy(toastEvent, 'setParams');
            let helperToastFireSpy = sinon.spy(toastEvent, 'fire');
            
            // Make call to method under test
            helper.popUpToast(toastTitle, toastMessage);
            
            // do asserts
            sinon.assert.calledOnce(globalGetStub);
            sinon.assert.calledWith(helperToastSetParamSpy, toastParams);
            sinon.assert.calledOnce(helperToastFireSpy);
        });

    });
});

ERRORs##
1) AccMessageButtonsHelper
       processButtonClick
         calls the server, gets empty data and displays toast - Valid profile:
     AssertError: expected setParams to be called with arguments 
{ message: "Error", title: "Send Mail", type: "error" } { message: "potato", title: "Send Mail", type: "error" } 
      at Object.fail (node_modules/sinon/lib/sinon/assert.js:96:21)
      at failAssertion (node_modules/sinon/lib/sinon/assert.js:55:16)
      at Object.assert.(anonymous function) [as calledWith] (node_modules/sinon/lib/sinon/assert.js:80:13)
      at Context.<anonymous> (force-app/test/auraSpecs/specs/AccMessageButtons/AccMessageButtonsHelperTest.js:122:26)

  2) AccMessageButtonsHelper
       processButtonClick
         calls the server, gets data and redirect method for url launch - Valid profile:
     TypeError: Attempted to wrap getReturnValue which is already wrapped
      at checkWrappedMethod (node_modules/sinon/lib/sinon/util/core/wrap-method.js:39:21)
      at wrapMethod (node_modules/sinon/lib/sinon/util/core/wrap-method.js:85:13)
      at stub (node_modules/sinon/lib/sinon/stub.js:66:44)
      at Sandbox.stub (node_modules/sinon/lib/sinon/sandbox.js:290:33)
      at Context.<anonymous> (force-app/test/auraSpecs/specs/AccMessageButtons/AccMessageButtonsHelperTest.js:135:52)
  --------------
  Error: Stack Trace for original
      at wrapMethod (node_modules/sinon/lib/sinon/util/core/wrap-method.js:110:31)
      at stub (node_modules/sinon/lib/sinon/stub.js:66:44)
      at Sandbox.stub (node_modules/sinon/lib/sinon/sandbox.js:290:33)
      at Context.<anonymous> (force-app/test/auraSpecs/specs/AccMessageButtons/AccMessageButtonsHelperTest.js:90:52)

  3) AccMessageButtonsHelper
       processButtonClick
         calls the server, gets data and redirect method for popup launch - Invalid profile:
     TypeError: Attempted to wrap getState which is already wrapped
      at checkWrappedMethod (node_modules/sinon/lib/sinon/util/core/wrap-method.js:39:21)
      at wrapMethod (node_modules/sinon/lib/sinon/util/core/wrap-method.js:85:13)
      at stub (node_modules/sinon/lib/sinon/stub.js:66:44)
      at Sandbox.stub (node_modules/sinon/lib/sinon/sandbox.js:290:33)
      at Context.<anonymous> (force-app/test/auraSpecs/specs/AccMessageButtons/AccMessageButtonsHelperTest.js:160:46)
  --------------
  Error: Stack Trace for original
      at wrapMethod (node_modules/sinon/lib/sinon/util/core/wrap-method.js:110:31)
      at stub (node_modules/sinon/lib/sinon/stub.js:66:44)
      at Sandbox.stub (node_modules/sinon/lib/sinon/sandbox.js:290:33)
      at Context.<anonymous> (force-app/test/auraSpecs/specs/AccMessageButtons/AccMessageButtonsHelperTest.js:133:46)

  4) AccMessageButtonsHelper
       processButtonClick
         calls server and return Error:
     TypeError: Attempted to wrap getState which is already wrapped
      at checkWrappedMethod (node_modules/sinon/lib/sinon/util/core/wrap-method.js:39:21)
      at wrapMethod (node_modules/sinon/lib/sinon/util/core/wrap-method.js:85:13)
      at stub (node_modules/sinon/lib/sinon/stub.js:66:44)
      at Sandbox.stub (node_modules/sinon/lib/sinon/sandbox.js:290:33)
      at Context.<anonymous> (force-app/test/auraSpecs/specs/AccMessageButtons/AccMessageButtonsHelperTest.js:184:46)

 **/
}