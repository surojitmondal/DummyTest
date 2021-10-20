public without sharing class ChartHelper {
	@AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();
        //ToDo: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
        for(AggregateResult ar : [SElECT FAMILY family, SUM(QUANTITY_REMAINING__C) total FROM Product2 
                                  WHERE QUANTITY_REMAINING__C > 0 GROUP BY FAMILY]){
                                      cht.add(new ChartData((String)ar.get('family'),Integer.valueOf(ar.get('total'))));
                                  }
               //  And return a list of chartData
        //  Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}