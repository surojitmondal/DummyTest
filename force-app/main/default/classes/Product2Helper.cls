public class Product2Helper {

static List<CollaborationGroup> COLLABORATION_GROUP = [

        SELECT Id
        FROM CollaborationGroup
        //WHERE Name = 'group name'
        WHERE Name = :Constants.INVENTORY_ANNOUNCEMENTS
        OR Name = :('TEST'+Constants.INVENTORY_ANNOUNCEMENTS)
        LIMIT 1
    ];
	public static void AfterUpdate(List<Product2> newList, List<Product2> oldList){
        
        List<Product2> needsAnnouncement = new List<Product2>();
        
        Map<String, Inventory_Setting__mdt> records = 
            new Map<String, Inventory_Setting__mdt>();

        List<Inventory_Setting__mdt> inventorySettings = [SELECT Label, Low_Quantity_Alert__c FROM Inventory_Setting__mdt];
        for(Inventory_Setting__mdt inventorySetting:inventorySettings){
            records.put(inventorySetting.Label,inventorySetting);
        }
        
        for(Integer i=0;i<newList.size();i++){
            Inventory_Setting__mdt inventorySetting = 
                    (Inventory_Setting__mdt)records.get(newList[i].Family);
            Integer alertQuantity = (Integer)inventorySetting.Low_Quantity_Alert__c;
            
            if( newList[i].Quantity_Remaining__c <= alertQuantity ){
                   needsAnnouncement.add(newList[i]);
               }
            
            if( newList[i].Quantity_Remaining__c <= alertQuantity && 
               oldList[i].Quantity_Remaining__c > alertQuantity){
                   needsAnnouncement.add(newList[i]);
               }
        }
        
        PostAlerts(needsAnnouncement);
        
        
        
    }

  
    public static void PostAlerts(List<Product2> productList){
        List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
        for ( Product2 p : productList ){
            
            ConnectApi.AnnouncementInput announcement = 
                new ConnectApi.AnnouncementInput();
            ConnectApi.MessageBodyInput messageBodyInput = 
                new ConnectApi.MessageBodyInput();
            
            List<ConnectApi.MessageSegmentInput> messageSegmentInput = 
                new List<ConnectApi.MessageSegmentInput>();
            
            ConnectApi.TextSegmentInput bodySegmentInput = new ConnectApi.TextSegmentInput();
            bodySegmentInput.text = p.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;
            messageSegmentInput.add(bodySegmentInput);
            messageBodyInput.messageSegments = messageSegmentInput;
            
            announcement.parentId = COLLABORATION_GROUP.get(0).Id;
            announcement.sendEmails = false;
            announcement.expirationDate = System.today()+1;
            announcement.body = messageBodyInput;
            
            toPost.add(announcement);

            
        }
        AnnouncementQueueable announcementQueuable = new AnnouncementQueueable(toPost);
        announcementQueuable.toPost = toPost;
        
        Id jobId = System.enqueueJob(announcementQueuable);
    }
}