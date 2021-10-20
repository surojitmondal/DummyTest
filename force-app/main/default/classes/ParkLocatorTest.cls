@isTest
public class ParkLocatorTest {
    @isTest static void testMock(){
        test.setMock(WebserviceMock.class, new ParkServiceMock());
        String[] parksName = ParkLocator.Country('India');
        List<String> country = new List<String>();
                country.add('Anamudi Shola National Park');
                country.add('Anshi National Park');
                country.add('Bandipur National Park');
        System.assertEquals(country, parksName, 'park names are not as expected');
    }
}