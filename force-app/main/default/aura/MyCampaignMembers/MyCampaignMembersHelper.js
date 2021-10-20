({
    getCampaignMembers : function(component, event, helper, sortField) {
        helper.toggleSpinnerVisibility(component, event, helper);
        var currentDir = component.get("v.arrowDirection");
 
        if (currentDir == 'arrowdown') {
            component.set("v.arrowDirection", 'arrowup');
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        
        console.log(component.get('v.selectedAccountName'));
        console.log(component.get('v.selectedCampaignName'));
        console.log(component.get('v.selectedCampaignMemberStatus'));
        
        var action = component.get("c.returnCampaignMembers");
        action.setParams({
            'sortField': sortField,
            'isAsc': component.get("v.isAsc"),
            'selectedAccountName' : component.get('v.selectedAccountName'),
            'selectedCampaignName' : component.get('v.selectedCampaignName'),
            'selectedCampaignMemberStatus' : component.get('v.selectedCampaignMemberStatus')
        });
        
        action.setCallback(this, function(response){
            var allCampaignMembers = [];
            if (response.getState() === "SUCCESS"){
                var members = response.getReturnValue();
                if (members.length > 0) {
                    for (var i = 0; i < members.length; i++) {
                        var questionURL = '';
                        var member = members[i];
                        var callDescriptionNotesTrimmed = member.CallDescriptionNotes;
                        if (callDescriptionNotesTrimmed && callDescriptionNotesTrimmed.length > 20) {
                            callDescriptionNotesTrimmed = callDescriptionNotesTrimmed.slice(0, 17) + "...";
                        }
                        
                        //Prepare Question URL
                        questionURL = "/apex/TakeSurvey_CampaignQuestions"
                        questionURL += "?camid=" + member.CampaignId;
                        questionURL += "&Id=" + member.Questionnaire;
                        if (member.LeadId) {
                            questionURL += "&lid=" + member.LeadId;
                        } else {
                            questionURL += "&cid=" + member.ContactId;
                        }
                        questionURL += "&memberid=" + member.CampaignMemberId;
                        allCampaignMembers.push({
                            "CampaignMemberId" : member.CampaignMemberId,
                            "CampaignId" : member.CampaignId,
                            "Url" : '/' + member.CampaignMemberId,
                            "Name" : member.Name,
                            "AccountName" : member.AccountName,
                            "Phone" : member.Phone,
                            "Email" : member.Email,
                            "EmailUrl" : "mailTo:" + member.Email,
                            "CampaignName" : member.CampaignName,
                            "CampaignUrl" : '/' +member.CampaignId,
                            "OldStatus" : member.OldStatus,
                            "NewStatus" : "--None--",
                            "StatusValues" : member.statusValues,
                            "CallDescriptionNotes" : member.CallDescriptionNotes,
                            "callDescriptionNotesTrimmed" : callDescriptionNotesTrimmed,
                            "CampaignQuestions" : questionURL,
                            "RecordTypeId" : member.CampaignRecordType,
                            "Questionnaire" : member.Questionnaire,
                            "ContactId" : member.ContactId,
                            "LeadId" : member.LeadId,
                            "CreatedDate": member.CreatedDate
                        });
                    }
                }
                component.set("v.allCampaignMembers", allCampaignMembers);
                if (component.get("v.initialLoad")) {
	                helper.populateDropDowns(component, event, helper);
                    component.set("v.initialLoad", false)
                }
                helper.toggleSpinnerVisibility(component, event, helper);
                
                //Filter records for Pagination
                var currentPageNumber = component.get("v.currentPageNumber");
                var totalPages = Math.ceil(allCampaignMembers.length / component.get("v.pageSize"));
                component.set("v.totalPages", totalPages);
                helper.showSelectedMembersOnPage(component, event, helper,currentPageNumber)
            }
        })
        $A.enqueueAction(action);
    },
    populateDropDowns : function(component, event, helper) {
        console.log('1');
        var accountNameSet = new Set();
        var campaignNameSet = new Set();
        var campaignMemberStatusSet = new Set();
        var accountNames = [];
        var campaignNames = [];
        var campaignMemberStatuses = [];
        accountNameSet.add('All Accounts');
        campaignNameSet.add('All Campaigns');
        campaignMemberStatusSet.add('All Statuses');
        var allCampaignMembers = component.get("v.allCampaignMembers");
        console.log(allCampaignMembers);
        //for (var i = 0; i < allCampaignMembers.length; i++) {
          //  var campaignMember = allCampaignMembers.get(i);
        for (var index in allCampaignMembers) {
            var campaignMember = allCampaignMembers[index];
            if (campaignMember.AccountName) {
                accountNameSet.add(campaignMember.AccountName);
            }
            if (campaignMember.CampaignName) {
                campaignNameSet.add(campaignMember.CampaignName);
            }
            if (campaignMember.OldStatus) {
                campaignMemberStatusSet.add(campaignMember.OldStatus);
            }
        }
        
        console.log(accountNameSet.values());
        for (let accountName of accountNameSet.values()) {
            accountNames.push(accountName);
        }
        for (let campaignName of campaignNameSet.values()) {
            campaignNames.push(campaignName);
        }
        for (let campaignMemberStatus of campaignMemberStatusSet.values()) {
            campaignMemberStatuses.push(campaignMemberStatus);
        }
        
        //console.log(accountNameSet);
        
        component.set("v.accountNames", accountNames);
        component.set("v.campaignNames", campaignNames);
        component.set("v.campaignMemberStatuses", campaignMemberStatuses);
        
        component.set("v.selectedAccountName", 'All Accounts');
        component.set("v.selectedCampaignName", 'All Campaigns');
        component.set("v.selectedCampaignMemberStatus", 'All Statuses');
        
        
    },
    save : function(component, event, helper) {
        helper.toggleSpinnerVisibility(component, event, helper);
        var action = component.get("c.saveCampaignChanges");
        action.setParams({
            updatedValues : JSON.stringify(component.get("v.allCampaignMembers"))
        })
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS"){
                if(!response.getReturnValue().isSuccess) {
                    var errors = "Error updating following records : \n";
                    var counter = 1;
                    var failedRecords = response.getReturnValue().campaignMemberNameAndErrorMap;
                    for (var memberName in failedRecords) {
                        var errorMessage = counter++ + " - " + memberName + " : " + failedRecords[memberName];
                        errors += errorMessage;
                        
                        //helper.showPopup(component,"slds-theme--error", errors)
                    }
                    var modal = component.find("modal_popup");
        			$A.util.removeClass(modal, 'hideDiv');
                    helper.showPopup(component, "ERROR", "slds-theme--error", errors);                    
                }
                
                //helper.showPopup(component, "ERROR", "slds-theme--error", " Please contact administrator.")
                //window.location.reload();
            }
            helper.toggleSpinnerVisibility(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    showSelectedMembersOnPage :  function(component, event, helper) {
        var currentPageNumber = component.get("v.currentPageNumber");
        var allCampaignMembers = component.get("v.allCampaignMembers");
        var pageSize = component.get("v.pageSize");
        var startingIndex = (currentPageNumber - 1) * pageSize;
        var endingIndex = (currentPageNumber * pageSize);
        //Check if the list has lesser number of records than ending Index
        if (allCampaignMembers.length < endingIndex) {
            endingIndex = (allCampaignMembers.length);
        }
        
        var campaignMembers = [];
        for (var i = startingIndex; i < endingIndex; i++) {
            campaignMembers.push(allCampaignMembers[i]);
        }
        component.set("v.campaignMembers", campaignMembers);
        
    },
    hideDescriptionModal : function(component, event, helper) {
        component.set("v.selectedCampaignId", "");
		component.set("v.selectedDescription", "");
        $A.util.toggleClass(component.find("descriptionModal"), "slds-hide");
    },
    toggleSpinnerVisibility: function(component, event, helper) {
        $A.util.toggleClass(component.find("spinner_box"), "slds-hide");
    },
	showPopup : function(component, popupHeader, popupTheme, popupMessage){
		component.set("v.popupHeader", popupHeader);
		component.set("v.popupTheme", popupTheme);
		component.set("v.popupMessage", popupMessage);
		$A.util.removeClass(component.find("modal_popup"), 'slds-hide');
		if (popupTheme == "slds-theme--error"){
			component.set("v.showCloseButton", false);
		} else {
			component.set("v.showCloseButton", true);
		}
	},
    hidemodal_popup : function(component) {
        var modal = component.find("modal_popup");
        $A.util.addClass(modal, 'hideDiv');
    }
    
})