/*
* Test class for the GeocodeService
*/
@isTest
public class GeocodeService_Test {

	// Tests that setting the test response in the constructor works
	public static testMethod void constructorSetsTestResponse() {
		GeocodeService service = new GeocodeService('dummy');
		system.assertEquals('dummy', service.TestResponse, 'The test response should equal the value passed into the constructor');
	}
	
	// Tests that the default constructor uses the default test response
	public static testMethod void defaultConstructorUsesDefaultTestResponse() {
		GeocodeService service = new GeocodeService();
		system.assertEquals(GeocodeService.DEFAULT_TEST_RESPONSE, service.TestResponse, 'The test response should equal the value of the default');
	}
	
	// Tests that the correct data is returned
	public static testMethod void getLocation_ReturnsCorrectData() {
		GeocodeService service = new GeocodeService();	
		Geocode_Data_Row__c loc = service.getGeocodeData('90210');
		
		system.assertNotEquals(null, loc, 'The location should have been returned');
		system.assertEquals(GeocodeService.TEST_RESPONSE_KNOXVILLE_LAT, loc.Geocode__Latitude__s, 'The latitude should be the same');
		system.assertEquals(GeocodeService.TEST_RESPONSE_KNOXVILLE_LON, loc.Geocode__Longitude__s, 'The longitude should be the same');
		system.assertEquals(GeocodeService.TEST_RESPONSE_POSTAL_CODE, loc.Postal_Code__c, 'The postal code should be the same');
		system.assertEquals(GeocodeService.TEST_RESPONSE_COUNTRY, loc.Country__c, 'The country should be the same');
		system.assertEquals(GeocodeService.TEST_RESPONSE_STATE_CODE, loc.State_Province_Abbreviation__c, 'The state code should be the same');
		system.assertEquals(GeocodeService.TEST_RESPONSE_STATE_NAME, loc.State_Province_Name__c, 'The state name should be the same');
		system.assertEquals(GeocodeService.TEST_RESPONSE_COUNTY, loc.County_Name__c, 'The county should be the same');
		system.assertEquals(GeocodeService.TEST_RESPONSE_CITY, loc.City_Name__c, 'The city should be the same');
	}
	
	// Tests that getLocation passing a country works corretly
	public static testMethod void getLocation_WithCountryWorks() {
		GeocodeService service = new GeocodeService();	
		Geocode_Data_Row__c loc = service.getGeocodeData('90210', 'US');
		
		system.assertNotEquals(null, loc, 'The location should have been returned');
		system.assertEquals(GeocodeService.TEST_RESPONSE_KNOXVILLE_LAT, loc.Geocode__Latitude__s, 'The latitude should be the same');
		system.assertEquals(GeocodeService.TEST_RESPONSE_KNOXVILLE_LON, loc.Geocode__Longitude__s, 'The longitude should be the same');
	}
	
	// Tests that getLocation passing a set of country codes works corretly
	public static testMethod void getLocation_WithCountrySetWorks() {
		GeocodeService service = new GeocodeService();	
		Geocode_Data_Row__c loc = service.getGeocodeData('90210', GeocodeService.US_CANADA_ISO_CODES);
		
		system.assertNotEquals(null, loc, 'The location should have been returned');
		system.assertEquals(GeocodeService.TEST_RESPONSE_KNOXVILLE_LAT, loc.Geocode__Latitude__s, 'The latitude should be the same');
		system.assertEquals(GeocodeService.TEST_RESPONSE_KNOXVILLE_LON, loc.Geocode__Longitude__s, 'The longitude should be the same');
	}
	
	// Tests that when no results are returned null is returned
	public static testMethod void getLocation_NoResultsReturnsNull() {
		GeocodeService service = new GeocodeService(GeocodeService.TEST_RESPONSE_NO_RESULTS);	
		Geocode_Data_Row__c loc = service.getGeocodeData('90210');
		
		system.assertEquals(null, loc, 'The location should have been null');	
	}
}