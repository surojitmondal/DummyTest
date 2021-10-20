public with sharing class DataTableController {
    
    @AuraEnabled
    public static String getLeadOptyConversionData(Date startDate, Date endDate){
        Map<String, userWrapper> userWrapperMap = new Map<String, userWrapper>();
        
        for(AggregateResult  aggr: [SELECT Count(Id) RECCOUNT, OwnerId, Owner.Name  
                                    FROM LEAD WHERE CreatedDate >= :startDate and LastmodifiedDate < :endDate Group by Ownerid, Owner.Name]){
            userWrapper userWrapperRec = new userWrapper();
            userWrapperRec.OwnerId = (String)aggr.get('OwnerId'); 
            userWrapperRec.OwnerName = (String)aggr.get('Name'); 
            userWrapperRec.TotalLeads = (Integer)aggr.get('RECCOUNT');
            userWrapperMap.put((String)aggr.get('OwnerId'), userWrapperRec);
        }
System.debug(userWrapperMap);
        for(AggregateResult  aggr: [SELECT MAX(CREATEDDATE) MAXDate, SUM(AMOUNT) TOTALAMNT, Count(Id) RECCOUNT, OwnerId, Owner.Name  FROM Opportunity WHERE StageName = 'Closed Won' AND CreatedDate >= :startDate and LastmodifiedDate < :endDate Group by Ownerid, Owner.Name]){
            userWrapper userWrapperRec = userWrapperMap.containsKey((String)aggr.get('OwnerId')) ? userWrapperMap.get((String)aggr.get('OwnerId')) : new userWrapper();
            userWrapperRec.OwnerId = (String)aggr.get('OwnerId'); 
            userWrapperRec.OwnerName = (String)aggr.get('Name'); 
            userWrapperRec.TotalOpps = (Integer)aggr.get('RECCOUNT');
            userWrapperRec.TotalValOpp = (Decimal)aggr.get('TOTALAMNT');
            userWrapperRec.ConvRate = (userWrapperRec.TotalOpps != 0 && userWrapperRec.TotalLeads != 0) ? (((Decimal)userWrapperRec.TotalOpps/ userWrapperRec.TotalLeads)) : 0;
            userWrapperRec.MaxCreatedDateOpp = (DateTime)aggr.get('MAXDate');
            userWrapperMap.put((String)aggr.get('OwnerId'), userWrapperRec);
        }
        System.debug(userWrapperMap);

        return JSON.serialize(userWrapperMap.values());
    }

    public class userWrapper {
        public String OwnerId {get;set;}
        public String OwnerName {get;set;}
        public Integer TotalLeads {get;set;}
        public Integer TotalOpps {get;set;}
        public Decimal ConvRate {get;set;}
        public DateTime MaxCreatedDateOpp {get;set;}
        public Decimal TotalValOpp {get;set;}

        public userWrapper(){
            this.OwnerId = '';
            this.OwnerName = '';
            this.TotalLeads = 0;
            this.TotalOpps = 0;
            this.ConvRate = 0.0;
            this.MaxCreatedDateOpp = null;
            this.TotalValOpp = 0.0;
        }
    }

}