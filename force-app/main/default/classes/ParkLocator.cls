public class ParkLocator {
    
    public static List<String> country(String passedCountry){
        ParkService.ParksImplPort parksByCount = new ParkService.ParksImplPort();
        return parksByCount.byCountry(passedCountry);
        
    }
}