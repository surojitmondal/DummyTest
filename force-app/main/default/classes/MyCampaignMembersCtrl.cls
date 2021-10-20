public class MyCampaignMembersCtrl {
    
    @AuraEnabled
    public static List<CampaignWrapper> returnCampaignMembers(String sortField, Boolean isAsc, String selectedAccountName, String selectedCampaignName, String selectedCampaignMemberStatus) {
        List<CampaignWrapper> campaignMembers = new List<CampaignWrapper>();
        List<String> campaignTypeValues = new List<String> {'Sales MKTG','Lead Gen','Nurture','Targeted Outreach','Targeted Outreach - GAM','NCA','Sales MTS','CD&S Sales Queue','Data Sales','Platform Solutions'};
        List<String> campaignStatusValues01 = new List<String> {'In Progress','Post-Live',''};
        //List<String> statusValues01 = new List<String> {'Ready for Outreach','Contacted/Sent','Contacted','SQL','PQL','MQL','Sales Pitch Conducted'};
        List<String> statusValues01 = new List<String> {'Ready for Outreach'};
        List<String> campaignStatusValues02 = new List<String> {'Planned','Completed','Canceled','RDP','Expired'};
        List<String> statusValues02 = new List<String> {'Initial Outreach Required'};
        Map<Id, List<String>> campaignIdToStatusMap = new Map<Id, List<String>>();
        Set<Id> campaignIds = new Set<Id>();
        system.debug(UserInfo.getUserRoleId());
        String campaignMemberQuery = 'SELECT Id, Name, CreatedDate, Campaign_Name__c, CampaignID, Account_name__c, Status, Phone, Title, Email, Member_Owner__c, Campaign.Questionnaire__c, Auto_Opportunity__c, Call_Description_Notes__c, Campaign_Member_Id__c , ContactId, Campaign_Status__c, My_Campaign_Member__c, Campaign_Type__c, LeadId, New_Status__c, Campaign.RecordTypeId';
        campaignMemberQuery += ' From CampaignMember';
        campaignMemberQuery += ' WHERE Campaign.IsActive = true AND Campaign.StartDate != NULL AND ';
        campaignMemberQuery += ' ((Campaign.Type IN :campaignTypeValues AND Campaign.Status in :campaignStatusValues01 AND Status IN :statusValues01 AND My_Campaign_Member__c = true)';
        campaignMemberQuery += ' OR';
        campaignMemberQuery += ' (My_Campaign_Member__c = true AND Campaign.Status NOT IN :campaignStatusValues02 AND (Touch_Point_Overdue__c = True  OR Status = :statusValues02)))';
        
        if (String.isNotBlank(selectedAccountName) && selectedAccountName != 'All Accounts') {
            campaignMemberQuery += ' AND Account_Name__c = :selectedAccountName';
        }
        
        if (String.isNotBlank(selectedCampaignName) && selectedCampaignName != 'All Campaigns') {
            campaignMemberQuery += ' AND Campaign_Name__c = :selectedCampaignName';
        }
        
        if (String.isNotBlank(selectedCampaignMemberStatus) && selectedCampaignMemberStatus != 'All Statuses') {
            campaignMemberQuery += ' AND Status = :selectedCampaignMemberStatus';
        }
        
        if (String.isNotBlank(sortField)) {
            if (isAsc) {
                campaignMemberQuery += ' ORDER BY ' + sortField + ' ASC NULLS FIRST';
            } else {
                campaignMemberQuery += ' ORDER BY ' + sortField + ' DESC NULLS LAST';
            }
        }
        
        System.debug(campaignMemberQuery);
        List<CampaignMember> members = Database.query(campaignMemberQuery);
        for (CampaignMember member : members) {
            campaignIds.add(member.CampaignId);
        }
        
        List<CampaignMemberStatus> campaignStatuses = [SELECT Id, CampaignId, Label FROM CampaignMemberStatus WHERE CampaignId IN :campaignIds];
        for (CampaignMemberStatus campaignStatus : campaignStatuses) {
            List<String> statuses = new List<String>();
            if (campaignIdToStatusMap.containsKey(campaignStatus.CampaignId)) {
                statuses = campaignIdToStatusMap.get(campaignStatus.CampaignId);
            } else {
                statuses.add('--None--');
            }
            statuses.add(campaignStatus.Label);
            campaignIdToStatusMap.put(campaignStatus.CampaignId, statuses);
        }
        
        System.debug('campaignMemberQuery ----> '+campaignMemberQuery);
        for (CampaignMember member : members ) {
            campaignMembers.add(new CampaignWrapper(String.ValueOf(member.CampaignID), String.ValueOf(member.Id), member.Name, member.Account_Name__c, member.Phone, member.Email, member.Campaign_Name__c, member.Status, member.Call_Description_Notes__c, campaignIdToStatusMap.get(member.CampaignId), String.valueOf(member.Campaign.RecordTypeId), member.Campaign.Questionnaire__c, String.ValueOf(member.ContactId), String.ValueOf(member.LeadId), String.valueOf(member.CreatedDate)));
        }
        return campaignMembers;
    }
    
    @AuraEnabled
    public static Map<Id, List<String>> returnCampaignStatusValues() {
        List<String> campaignStatusValues = new List<String>();
        Set<String> campaignStatusValuesSet = new Set<String>();
        Map<Id, List<String>> statusValuesMap = new Map<Id, List<String>>();
        Set<Id> campaignIds = new Set<Id>();
        for (CampaignWrapper member : MyCampaignMembersCtrl.returnCampaignMembers('Name', true, '', '', '')) {
            campaignIds.add(member.CampaignId);
        }
        List<CampaignMemberStatus> campaignStatuses = [SELECT Id, CampaignId, Label FROM CampaignMemberStatus WHERE CampaignId IN :campaignIds];
        for (CampaignMemberStatus campaignStatus : campaignStatuses) {
            List<String> statuses = new List<String>();
            if (statusValuesMap.containsKey(campaignStatus.CampaignId)) {
                statuses = statusValuesMap.get(campaignStatus.CampaignId);
            } else {
                statuses.add('--None--');
            }
            statuses.add(campaignStatus.Label);
            statusValuesMap.put(campaignStatus.CampaignId, statuses);
        }
        return statusValuesMap;
    }
    
    @AuraEnabled
    public static UpdateResultWrapper saveCampaignChanges(String updatedValues) {
        System.debug(updatedValues);
        List<CampaignMember> campaignsToUpdate = new List<CampaignMember>();
        Map<Id, CampaignWrapper> oldValues = new Map<Id, CampaignWrapper>();
        Boolean isSuccess = true;
        Map<String, String> campaignMemberNameAndErrorMap = new Map<String, String>();
        
        List<CampaignWrapper> updatedValuesWrapper = (List<CampaignWrapper>) JSON.deserialize(updatedValues, List<CampaignWrapper>.class);
        
        for (CampaignWrapper oldValue : MyCampaignMembersCtrl.returnCampaignMembers('Name', true, '', '', '')) {
            oldValues.put(oldValue.CampaignMemberId, oldValue);
        }
        
        //Compare Changes
        for (CampaignWrapper updatedValueWrapper : updatedValuesWrapper) {
            CampaignMember campaignToUpdate = new CampaignMember(Id = updatedValueWrapper.CampaignMemberId);
            Boolean recordUpdated = false;
            CampaignWrapper oldValue = oldValues.get(updatedValueWrapper.CampaignMemberId);
            if (updatedValueWrapper.NewStatus != '--None--' && oldValue.OldStatus != updatedValueWrapper.NewStatus) {
                campaignToUpdate.Status = updatedValueWrapper.NewStatus;
                recordUpdated = true;
            }
            if (oldValue.CallDescriptionNotes != updatedValueWrapper.CallDescriptionNotes) {
                campaignToUpdate.Call_Description_Notes__c = updatedValueWrapper.CallDescriptionNotes;
                recordUpdated = true;
            }
            
            if (recordUpdated) {
                campaignsToUpdate.add(campaignToUpdate);
            }
        }
        if (!campaignsToUpdate.isEmpty()) {
            Map<Id, String> memberIdToErrorMap = new Map<Id, String>();
            List<Database.SaveResult> updateResults = Database.update(campaignsToUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                Database.SaveResult updateResult = updateResults.get(i);
                if (!updateResult.isSuccess()) {
                    isSuccess = false;
                    memberIdToErrorMap.put(campaignsToUpdate.get(i).Id, updateResult.getErrors().get(0).getMessage());
                }
            }
            if (!isSuccess) {
                for (CampaignWrapper member : updatedValuesWrapper) {
                    if (memberIdToErrorMap.containsKey(member.CampaignMemberId)) {
                        campaignMemberNameAndErrorMap.put(member.Name, memberIdToErrorMap.get(member.CampaignMemberId));
                    }
                }
            }
        }
        System.debug(isSuccess);
        System.debug(campaignMemberNameAndErrorMap);
        return (new UpdateResultWrapper(isSuccess, campaignMemberNameAndErrorMap));
    }
    
    public class CampaignWrapper {
        @AuraEnabled public String CampaignId{get;set;}
        @AuraEnabled public String CampaignMemberId{get;set;}
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String AccountName{get;set;}
        @AuraEnabled public String Phone{get;set;}
        @AuraEnabled public String Email{get;set;}
        @AuraEnabled public String CampaignName{get;set;}
        @AuraEnabled public String OldStatus{get;set;}
        @AuraEnabled public String NewStatus{get;set;}
        @AuraEnabled public String CallDescriptionNotes{get;set;}
        @AuraEnabled public String callDescriptionNotesTrimmed{get;set;}
        @AuraEnabled public String CampaignQuestions{get;set;}
        @AuraEnabled public List<String> statusValues {get; set;}
        @AuraEnabled public String CampaignRecordType{get;set;}
        @AuraEnabled public String Questionnaire{get;set;}
        @AuraEnabled public String ContactId{get;set;}
        @AuraEnabled public String LeadId{get;set;}        
        @AuraEnabled public String CreatedDate{get;set;}  
        
        public CampaignWrapper(String CampaignId, String CampaignMemberId, String Name, String AccountName, String Phone, String Email, String CampaignName, String OldStatus, String CallDescriptionNotes, List<String> statusValues, String CampaignRecordType, String Questionnaire, String ContactId, String LeadId, string CreatedDate) {
            this.CampaignId = CampaignId;
            this.CampaignMemberId = CampaignMemberId;
            this.Name = Name;
            this.AccountName = AccountName;
            this.Phone = Phone;
            this.Email = Email;
            this.CampaignName = CampaignName;
            this.OldStatus = OldStatus;
            this.CallDescriptionNotes = CallDescriptionNotes;
            this.statusValues = statusValues;
            this.CampaignRecordType = CampaignRecordType;
            this.Questionnaire = Questionnaire;
            this.ContactId = ContactId;
            this.LeadId = LeadId;
            this.CreatedDate = CreatedDate;
        }
    }
    
    public class UpdateResultWrapper {
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public Map<String, String> campaignMemberNameAndErrorMap {get;set;}
        public UpdateResultWrapper(Boolean isSuccess, Map<String, String> campaignMemberNameAndErrorMap) {
            this.isSuccess = isSuccess;
            this.campaignMemberNameAndErrorMap = campaignMemberNameAndErrorMap;
        }
    }
    
}

