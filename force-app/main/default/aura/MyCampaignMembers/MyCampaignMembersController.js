({
    doInit : function(component, event, helper) {
        helper.toggleSpinnerVisibility(component, event, helper);
        helper.getCampaignMembers(component, event, helper, 'CreatedDate');
    },
    refreshCampaignMembers : function(component, event, helper) {
    	helper.getCampaignMembers(component, event, helper, 'CreatedDate');
	},
    sortName : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'name');
        helper.getCampaignMembers(component, event, helper, 'Name');
    },
    sortAccountName : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'accountName');
        helper.getCampaignMembers(component, event, helper, 'Account_Name__c');
    },
    sortPhone : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'phone');
        helper.getCampaignMembers(component, event, helper, 'Phone');
    },
    sortEmail : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'email');
        helper.getCampaignMembers(component, event, helper, 'Email');
    },
    sortCampaignName : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'campaignName');
        helper.getCampaignMembers(component, event, helper, 'Campaign_Name__c');
    },
    sortStatus : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'status');
        helper.getCampaignMembers(component, event, helper, 'Status');
    },
    sortMembCreatedDate : function(component, event, helper) {
        component.set("v.selectedTabsoft", 'memberCreatedDate');
        helper.getCampaignMembers(component, event, helper, 'CreatedDate');
    },
    save : function(coomponent, event, helper) {
        helper.save(coomponent, event, helper);
    },
    cancel : function(coomponent, event, helper) {
        window.location.reload();
    },
    editDescription : function(component, event, helper) {
        var campaignMemberId = event.getSource().get("v.class").replace("blockBox ", "");
        var selectedDescription = event.getSource().get("v.title");
        var campaignMembers = component.get("v.campaignMembers");
        for (var i = 0; i < campaignMembers.length; i++) {
            var campaignMember = campaignMembers[i];
            if (campaignMember.CampaignMemberId === campaignMemberId) {
                component.set("v.selectedCampaignId", campaignMember.CampaignMemberId);
                component.set("v.selectedDescription", selectedDescription);
            }
        }
        $A.util.toggleClass(component.find("descriptionModal"), "slds-hide");
    },
    updateDescription : function(component, event, helper) {
        var selectedDescription = component.get("v.selectedDescription");
        var selectedCampaignId = component.get("v.selectedCampaignId");
        var campaignMembers = component.get("v.campaignMembers");
        for (var i = 0; i < campaignMembers.length; i++) {
            var campaignMember = campaignMembers[i];
            if (campaignMember.CampaignMemberId === selectedCampaignId) {
                campaignMember.CallDescriptionNotes = selectedDescription;
                campaignMember.callDescriptionNotesTrimmed = selectedDescription;
                if (selectedDescription && selectedDescription.length > 20) {
                    campaignMember.callDescriptionNotesTrimmed = selectedDescription.slice(0, 17) + "...";
                } 
            }
        }
        component.set("v.campaignMembers", campaignMembers);
        helper.hideDescriptionModal(component, event, helper);
    },
    cancelDescription : function(component, event, helper) {
        helper.hideDescriptionModal(component, event, helper);
    },
    goFirst : function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.showSelectedMembersOnPage(component, event, helper);
        
    },
    goPrevious : function(component, event, helper) {
        var currentPageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", (currentPageNumber - 1));
        helper.showSelectedMembersOnPage(component, event, helper);
    },
    goNext : function(component, event, helper) {
        var currentPageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", (currentPageNumber + 1));
        helper.showSelectedMembersOnPage(component, event, helper);
    },
    goLast : function(component, event, helper) {
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.showSelectedMembersOnPage(component, event, helper);
    },
    closeWarningBox : function(component, event, helper){
		//window.location.reload();
		//helper.showPopup(component);
		helper.hidemodal_popup(component);
	}
})