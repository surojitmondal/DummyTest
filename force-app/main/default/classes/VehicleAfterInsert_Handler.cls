public class VehicleAfterInsert_Handler {
public static Boolean isFirstRun = true;
    
    public Static void testBoolean(List<Vehicle__c> vehicleList){
        if(isFirstRun){
        System.debug('VehicleSizeIs:'+vehicleList.size());
        List<Contact> contactList = new List<Contact>();
        for(Vehicle__c vehicleRecord : vehicleList){
            Contact contRecord = new Contact(LastName = 'ContName'+vehicleRecord.Name);
            contactList.add(contRecord);
        }
        System.debug('CONTACTLISTSIZE:'+contactList.Size());
        insert contactList;
        
            isFirstRun = false;
        }
    }
}