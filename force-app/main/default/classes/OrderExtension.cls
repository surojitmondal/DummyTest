public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    public ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardSetController standardSetController){
  
    }
   
    
    public OrderExtension(ApexPages.StandardController standardController){
        if(standardController == null){
          standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Product2Id, Product2.Family, Product2.Name, Product2.Quantity_Remaining__c, UnitPrice FROM PricebookEntry]));
          standardSetController.setPageSize(Constants.DEFAULT_ROWS);
        }
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }

        resetSsc();
        total = 0;

        for (OrderItem oi : orderRecord.OrderItems) {
            orderItemMap.put(oi.Product2Id, oi);
            if (oi.Quantity > 0) {
                if (null == pieData) {
                    pieData = new List<ChartHelper.ChartData>();
                }
                pieData.add(new chartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice));
                total += oi.UnitPrice * oi.Quantity;
            }

        }
        GetOrderItems();
    }

    public void resetSsc() {
        String query = 'SELECT Name, Product2.Family, Product2.Name, Product2Id, UnitPrice, Product2.Quantity_Remaining__c'
                     + '  FROM PricebookEntry WHERE IsActive = TRUE';

        if (selectedFamily != null && selectedFamily != Constants.SELECT_ONE) {
            query += ' AND Product2.Family = \'' + selectedFamily + '\'';
        }
        query += ' ORDER BY Name';

        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }
public void GetOrderItems() {
        orderItemList = new List<OrderItem>();
        for (SObject obj : standardSetController.getRecords()) {
            PricebookEntry pbe = (PricebookEntry)obj;
            if (orderItemMap.containsKey(pbe.Product2Id)) {
                orderItemList.add(orderItemMap.get(pbe.Product2Id));
            } else {
                orderItemList.add(new OrderItem(
                    PricebookEntryId=pbe.Id,
                    Product2Id=pbe.Product2Id,
                    UnitPrice=pbe.UnitPrice,
                    Quantity=0,
                    Product2=pbe.Product2
                ));
            }
        }
    }
public void onFieldChange(){
        for (OrderItem oi : orderItemList) {
            orderItemMap.put(oi.Product2Id, oi);
        }

        pieData = null;
        total = 0;
       for (OrderItem oi : orderItemMap.values()) {

            if (oi.Quantity > 0) {
                if (null == pieData) {
                    pieData = new List<chartHelper.ChartData>();
                }
                pieData.add(new chartHelper.ChartData(oi.Product2.Name, oi.Quantity * oi.UnitPrice));
                total += oi.UnitPrice * oi.Quantity;
            }
        }
    }
public void SelectFamily(){
        resetSsc();
        GetOrderItems();
    }

   public void Save(){
        System.Savepoint sp = Database.setSavepoint();
        try {
            if (null == orderRecord.Pricebook2Id) {
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord;

            List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
            List<OrderItem> orderItemsToDelete = new List<OrderItem>();
            //for (OrderItem oi : orderItemList) {
            for (OrderItem oi : orderItemMap.values()) {
                if (oi.Quantity > 0) {
                    if (null == oi.OrderId) {
                        oi.OrderId = orderRecord.Id;
                    }
                    orderItemsToUpsert.add(oi);
                } else if (oi.Id != null) {
                    orderItemsToDelete.add(oi);
                }
            }
            upsert orderItemsToUpsert;
            delete orderItemsToDelete;
        } catch (Exception e) {
            Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,Constants.ERROR_MESSAGE));
        }

    }
public void First(){
        this.standardSetController.first();
        GetOrderItems();
    }
public void Next(){
        this.standardSetController.next();
        GetOrderItems();
    }
public void Previous(){
        this.standardSetController.previous();
        GetOrderItems();
    }
public void Last(){
        this.standardSetController.last();
        GetOrderItems();
    }
public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }
public Boolean GetHasNext(){

        return standardSetController.getHasNext();
    }
public Integer GetTotalPages(){
        return (Integer)Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
    }
public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }
public List<SelectOption> GetFamilyOptions() {
        List<SelectOption> options = new List<SelectOption>{
            new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE)
        };

        for (Schema.PicklistEntry ple : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(ple.getValue(), ple.getLabel()));
        }
        return options;
    }
public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}