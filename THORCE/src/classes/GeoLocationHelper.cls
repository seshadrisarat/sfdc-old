/*
*		GeoLocationHelper is helper class for retrieving map coordinates lat/lng from google map geocode api.
* 
*		Author	:	Wilson Ng 
*		Date	:	November 09, 2012
* 
*
*		Geocoding Courtesy of MapQuest http://www.mapquest.com/
*/
public with sharing class GeoLocationHelper {

	// mapquest version - new 1-9-2013
	
	// max limit of callouts allowed
	static string MAPQUEST_GEOCODE_URL	= 'http://open.mapquestapi.com/geocoding/v1/address?inFormat=kvp&outFormat=json&location={0}'; 
	static integer MAX_CALLOUT			= 10;

	static public boolean enabled = Common_Config__c.getInstance().Enable_Server_side_Geocode__c;
	static public boolean firstTime = true;		// prevent recursive updates

	@future (callout=true)  // future method needed to run callouts from Triggers
	static public void getGeoLocation(list<string> propertyIds) {		// limit of 10 calls in list, otherwise, job will fail
		firstTime = false;
		list<Property__c> updList = new List<Property__c>();
		integer i=0;
		// gather property info
		list<Property__c> properties = [SELECT Id, Street__c, City__c, State__c, Zip_Code__c, Map_Coordinates__Longitude__s, Map_Coordinates__Latitude__s FROM Property__c WHERE id in :propertyIds];
		for(Property__c p : properties) {
			// create an address string
			String address = '';
			if(string.isNotEmpty(p.Street__c)) address += p.Street__c+', ';
			if(string.isNotEmpty(p.City__c)) address += p.City__c+', ';
			if(string.isNotEmpty(p.State__c)) address += p.State__c+', ';
			if(string.isNotEmpty(p.Zip_Code__c)) address += p.Zip_Code__c +', ';
			if(string.isNotEmpty(address)) {
				address = EncodingUtil.urlEncode(address, 'UTF-8');
		 		system.debug('address is ' + address);
				// build callout
				Http h = new Http();
				HttpRequest req = new HttpRequest();
				req.setEndpoint(string.format(MAPQUEST_GEOCODE_URL, new string[] { address } ));
				req.setMethod('GET');
				req.setTimeout(10000);
		 
				try {
					// callout
					string resBody;
					if(!Test.isRunningTest()) {
						HttpResponse res = h.send(req);
						resBody = res.getBody();
					}
					else {
						// for testing
						resbody = TEST_RESPONSE; 
					}
					system.debug('response body is ' + resBody);
					// parse Json response from response
					MapquestGeocodeJson j = (MapquestGeocodeJson)JSON.deserialize(resBody, MapquestGeocodeJson.class);
					if(j.results.size() > 0 && j.results[0].locations.size() > 0) {
						MapquestGeocodeLatLng location = j.results[0].locations[0].latLng;
						system.debug('location is: ' + location);
		 
						// update coordinates
						if (location != null) {
							p.Map_Coordinates__Latitude__s = location.lat;
							p.Map_Coordinates__Longitude__s = location.lng;
		 					updList.add(p);
						}
					}
					else {
						system.debug('No results from mapquest geocode api call.  status is: ' + j.info.statuscode + '   messages are: ' + string.join(j.info.messages, ','));
					}
					
				} catch (Exception e) {
					// ignore and continue
					system.debug('Exception: ' + e);
				}
				
				// exit loop if max callouts exceeded
				// note: mapquest supports batch mode up to 100 per request - however i tried using the batch mode, and if 1 location address failed, then all locations response come back empty...therefore we are not using the batch mode version
				if(++i >= MAX_CALLOUT)
					break;
			}
		}
		
		// save all updates
		if(updList.size() > 0) 
			update updList;
	}
	
	public class MapquestGeocodeJson {
		public MapquestGeocodeResult[] results {get; set;}
		public MapquestGeocodeOption options {get; set;}
		public MapquestGeocodeInfo info {get; set;}
	}
	public class MapquestGeocodeResult {
		public MapquestGeocodeLocation[] locations {get; set;}
		public MapquestGeocodeProvidedLocation providedLocation {get; set;}
	}
	public class MapquestGeocodeLocation {
		public MapquestGeocodeLatLng latLng {get; set;}
		public MapquestGeocodeLatLng displayLatLng {get; set;}
		public string adminArea1 {get; set;}
		public string adminArea1Type {get; set;}
		public string adminArea3 {get; set;}
		public string adminArea3Type {get; set;}
		public string adminArea4 {get; set;}
		public string adminArea4Type {get; set;}
		public string adminArea5 {get; set;}
		public string adminArea5Type {get; set;}
		public boolean dragPoint {get; set;}
		public string geocodeQuality {get; set;}
		public string geocodeQualityCode {get; set;}
		public decimal linkId {get; set;}
		public string mapUrl {get; set;}
		public string postalCode {get; set;}
		public string street {get; set;}
		public string sideOfStreet {get; set;}
		public string type {get; set;}
	}
	public class MapquestGeocodeProvidedLocation {
		public string location {get; set;}
	}	
	public class MapquestGeocodeLatLng {
		public decimal lat {get; set;}
		public decimal lng {get; set;}
	}
	public class MapquestGeocodeOption {
		public boolean ignoreLatLngInput {get; set;}
		public decimal maxResults {get; set;}
		public boolean thumbMaps {get; set;}
	}
	public class MapquestGeocodeInfo {
		public MapquestGeocodeCopyright copyright {get; set;}
		public decimal statuscode {get; set;}
		public string[] messages {get; set;}
	}
	public class MapquestGeocodeCopyright {
		public string text {get; set;}
		public string imageUrl {get; set;}
		public string imageAltText {get; set;}
	}
	static string TEST_RESPONSE = '{"results":[{"locations":[{"latLng":{"lng":-73.98916,"lat":40.74475},"adminArea4":"New York","adminArea5Type":"City","adminArea4Type":"County","adminArea5":"New York City","street":"31 West 27th Street","adminArea1":"United States of America","adminArea3":"New York","type":"s","displayLatLng":{"lng":-73.98916,"lat":40.74475},"linkId":0,"postalCode":"10001","sideOfStreet":"N","dragPoint":false,"adminArea1Type":"Country","geocodeQuality":"ADDRESS","geocodeQualityCode":"L1XAA","mapUrl":"http://open.mapquestapi.com/staticmap/v4/getmap?type=map&size=225,160&pois=purple-1,40.7447503333333,-73.9891596666667,0,0|&center=40.7447503333333,-73.9891596666667&zoom=12&key=Kmjtd%7Cluu7n162n1%2C22%3Do5-h61wh&rand=128446514","adminArea3Type":"State"}],"providedLocation":{"location":"31 w 27th street,new york city,ny,10001"}}],"options":{"ignoreLatLngInput":false,"maxResults":-1,"thumbMaps":true},"info":{"copyright":{"text":"© 2012 MapQuest, Inc.","imageUrl":"http://api.mqcdn.com/res/mqlogo.gif","imageAltText":"© 2012 MapQuest, Inc."},"statuscode":0,"messages":[]}}';
	
	
	//
	// test methods
	@isTest
	static void testThisClass() {
		// create dummy data
		GeoLocationHelper.firstTime = false;		// don't execute from trigger
		Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='test location');
		insert loc;
		Property__c[] props = new list<Property__c>();
		for(integer i=0; i<5; i++)
			props.add(new Property__c(Name='prop'+i, Location_Neighborhood__c=loc.Id, Street__c='dummy street', City__c='dummy city', State__c='NY', Zip_Code__c='10001'));
		insert props;
		
		Test.startTest();
		list<string> ids = new list<string>();
		for(Property__c p : props)
			ids.add(p.Id);
		GeoLocationHelper.getGeoLocation(ids);
		Test.stopTest();			// executes asynchronous function in synchronous mode
		
		// check results
		Property__c[] propsResult = [select id, Map_Coordinates__Latitude__s, Map_Coordinates__Longitude__s from Property__c where id in :ids];
		system.assert(propsResult[0].Map_Coordinates__Latitude__s!=null, 'Error: GeoLocationHelper did not retrieve or update map coordinates latitude.');
		system.assert(propsResult[0].Map_Coordinates__Longitude__s!=null, 'Error: GeoLocationHelper did not retrieve or update map coordinates longitude.');
	}
	
	@isTest
	static void testThisClass_Parser() {
		// parse Json response from response
		MapquestGeocodeJson j = (MapquestGeocodeJson)JSON.deserialize(TEST_RESPONSE, MapquestGeocodeJson.class);
		
		system.assert(j.results.size()>0, 'Error: MapquestGeocodeJson did not properly parse results array.');
		system.assertNotEquals(null, j.info, 'Error: MapquestGeocodeJson did not properly parse info value.');
		system.assertEquals(0, j.info.statuscode, 'Error: MapquestGeocodeJson did not properly parse status code value.');

		system.assert(j.results[0].locations.size()>0, 'Error: MapquestGeocodeJson did not properly parse locations array.');
		system.assertEquals('United States of America', j.results[0].locations[0].adminArea1, 'Error: MapquestGeocodeJson did not properly parse adminarea1 value.');
		system.assertEquals('Country', j.results[0].locations[0].adminArea1Type, 'Error: MapquestGeocodeJson did not properly parse adminarea1type value.');
		system.assertEquals('New York', j.results[0].locations[0].adminArea3, 'Error: MapquestGeocodeJson did not properly parse adminarea3 value.');
		system.assertEquals('State', j.results[0].locations[0].adminArea3Type, 'Error: MapquestGeocodeJson did not properly parse adminarea3type value.');
		system.assertEquals('New York', j.results[0].locations[0].adminArea4, 'Error: MapquestGeocodeJson did not properly parse adminarea4 value.');
		system.assertEquals('County', j.results[0].locations[0].adminArea4Type, 'Error: MapquestGeocodeJson did not properly parse adminarea4type value.');
		system.assertEquals('New York City', j.results[0].locations[0].adminArea5, 'Error: MapquestGeocodeJson did not properly parse adminarea5 value.');
		system.assertEquals('City', j.results[0].locations[0].adminArea5Type, 'Error: MapquestGeocodeJson did not properly parse adminarea5type value.');
		system.assertNotEquals(null, j.results[0].locations[0].displayLatLng, 'Error: MapquestGeocodeJson did not properly parse display latlng value.');
		system.assertEquals(false, j.results[0].locations[0].dragPoint, 'Error: MapquestGeocodeJson did not properly parse dragpoint value.');
		system.assertEquals('ADDRESS', j.results[0].locations[0].geocodeQuality, 'Error: MapquestGeocodeJson did not properly parse quality value.');
		system.assertEquals('L1XAA', j.results[0].locations[0].geocodeQualityCode, 'Error: MapquestGeocodeJson did not properly parse qualitycode value.');
		system.assertEquals(0, j.results[0].locations[0].linkId, 'Error: MapquestGeocodeJson did not properly parse linkid value.');
		system.assertEquals('http://open.mapquestapi.com/staticmap/v4/getmap?type=map&size=225,160&pois=purple-1,40.7447503333333,-73.9891596666667,0,0|&center=40.7447503333333,-73.9891596666667&zoom=12&key=Kmjtd%7Cluu7n162n1%2C22%3Do5-h61wh&rand=128446514', j.results[0].locations[0].mapUrl, 'Error: MapquestGeocodeJson did not properly parse mapurl value.');
		system.assertEquals('10001', j.results[0].locations[0].postalCode, 'Error: MapquestGeocodeJson did not properly parse adminarea5type value.');
		system.assertEquals('31 West 27th Street', j.results[0].locations[0].street, 'Error: MapquestGeocodeJson did not properly parse street value.');
		system.assertEquals('N', j.results[0].locations[0].sideOfStreet, 'Error: MapquestGeocodeJson did not properly parse sideofstreet value.');
		system.assertEquals('s', j.results[0].locations[0].type, 'Error: MapquestGeocodeJson did not properly parse type value.');
		
		system.assertNotEquals(null, j.results[0].providedLocation, 'Error: MapquestGeocodeJson did not properly parse provided location.');
		system.assertEquals('31 w 27th street,new york city,ny,10001', j.results[0].providedLocation.location, 'Error: MapquestGeocodeJson did not properly parse providedlocation value.');

		system.assertNotEquals(null, j.options, 'Error: MapquestGeocodeJson did not properly parse options value.');
		system.assertEquals(false, j.options.ignoreLatLngInput, 'Error: MapquestGeocodeJson did not properly parse options ignore latlng input value.');
		system.assertEquals(-1, j.options.maxResults, 'Error: MapquestGeocodeJson did not properly parse options max results value.');
		system.assertEquals(true, j.options.thumbMaps, 'Error: MapquestGeocodeJson did not properly parse options thumb maps value.');
		
		system.assertNotEquals(null, j.info.copyright, 'Error: MapquestGeocodeJson did not properly parse info copyright value.');
		system.assertEquals('© 2012 MapQuest, Inc.', j.info.copyright.text, 'Error: MapquestGeocodeJson did not properly parse info copyright text value.');
		system.assertEquals('http://api.mqcdn.com/res/mqlogo.gif', j.info.copyright.imageUrl, 'Error: MapquestGeocodeJson did not properly parse info copyright image url value.');
		system.assertEquals('© 2012 MapQuest, Inc.', j.info.copyright.imageAltText, 'Error: MapquestGeocodeJson did not properly parse info copyright iamge alt text value.');
		
		system.assert(j.info.messages.size()==0, 'Error: MapquestGeocodeJson did not properly parse messages array.');
	}
	
	/* google version - commented out 1-9-2013
	
	// max limit of callouts allowed
	static string GOOGLE_GEOCODE_URL	= 'http://maps.google.com/maps/api/geocode/json?address={0}&sensor=false'; 
	static integer MAX_CALLOUT			= 10;

	static public boolean enabled = Common_Config__c.getInstance().Enable_Server_side_Geocode__c;
	static public boolean firstTime = true;		// prevent recursive updates

	@future (callout=true)  // future method needed to run callouts from Triggers
	static public void getGeoLocation(list<string> propertyIds) {		// limit of 10 calls in list, otherwise, job will fail
		firstTime = false;
		list<Property__c> updList = new List<Property__c>();
		integer i=0;
		// gather property info
		list<Property__c> properties = [SELECT Id, Street__c, City__c, State__c, Zip_Code__c, Map_Coordinates__Longitude__s, Map_Coordinates__Latitude__s FROM Property__c WHERE id in :propertyIds];
		for(Property__c p : properties) {
			// create an address string
			String address = '';
			if(string.isNotEmpty(p.Street__c)) address += p.Street__c+', ';
			if(string.isNotEmpty(p.City__c)) address += p.City__c+', ';
			if(string.isNotEmpty(p.State__c)) address += p.State__c+', ';
			if(string.isNotEmpty(p.Zip_Code__c)) address += p.Zip_Code__c +', ';
			if(string.isNotEmpty(address)) {
				address = EncodingUtil.urlEncode(address, 'UTF-8');
		 		system.debug('address is ' + address);
				// build callout
				Http h = new Http();
				HttpRequest req = new HttpRequest();
				req.setEndpoint(string.format(GOOGLE_GEOCODE_URL, new string[] { address } ));
				req.setMethod('GET');
				req.setTimeout(10000);
		 
				try {
					// callout
					string resBody;
					if(!Test.isRunningTest()) {
						HttpResponse res = h.send(req);
						resBody = res.getBody();
					}
					else {
						// for testing
						resbody = TEST_RESPONSE; 
					}
					system.debug('response body is ' + resBody);
					// parse Json response from response
					GoogleGeoCodeJson j = (GoogleGeoCodeJson)JSON.deserialize(resBody, GoogleGeoCodeJson.class);
					if(j.results.size() > 0) {
						GoogleGeoCodeLatLng location = j.results[0].geometry.location;
						system.debug('location is: ' + location);
		 
						// update coordinates
						if (location != null) {
							p.Map_Coordinates__Latitude__s = location.lat;
							p.Map_Coordinates__Longitude__s = location.lng;
		 					updList.add(p);
						}
					}
					else {
						system.debug('No results from google geocode api call.  status is: ' + j.status);
					}
					
				} catch (Exception e) {
					// ignore and continue
					system.debug('Exception: ' + e);
				}
				
				// exit loop if max callouts exceeded
				if(++i >= MAX_CALLOUT)
					break;
			}
		}
		
		// save all updates
		if(updList.size() > 0) 
			update updList;
	}
	
	//
	// Json class for deserializing the google map response
	public class GoogleGeoCodeJson {
		public GoogleGeoCodeResults[] results {get; set;}
		public string status {get; set;}
	}
	public class GoogleGeoCodeResults {
		public GoogleGeoCodeAddressComponents[] address_components {get; set;}
		public string formatted_address {get; set;}
		public GoogleGeoCodeGeometry geometry {get; set;}
		public string[] types {get; set;}
	}
	public class GoogleGeoCodeAddressComponents {
		public string long_name {get; set;}
		public string short_name {get; set;}
		public string[] types {get; set;}
	}
	public class GoogleGeoCodeGeometry {
		public GoogleGeoCodeBounds bounds {get; set;}
		public GoogleGeoCodeLatLng location {get; set;}			// lat and lng is stored here
		public string location_type {get; set;}
		public GoogleGeoCodeBounds viewport {get; set;}
	}	
	public class GoogleGeoCodeBounds {
		public GoogleGeoCodeLatLng northeast {get; set;}
		public GoogleGeoCodeLatLng southwest {get; set;}
	}
	public class GoogleGeoCodeLatLng {
		public decimal lat {get; set;}
		public decimal lng {get; set;}
	}
	static string TEST_RESPONSE = '{ "results" : [ { "address_components" : [ { "long_name" : "31", "short_name" : "31", "types" : [ "street_number" ] }, { "long_name" : "W 27th St", "short_name" : "W 27th St", "types" : [ "route" ] }, { "long_name" : "Midtown South Central", "short_name" : "Midtown South Central", "types" : [ "neighborhood", "political" ] }, { "long_name" : "Manhattan", "short_name" : "Manhattan", "types" : [ "sublocality", "political" ] }, { "long_name" : "New York", "short_name" : "New York", "types" : [ "locality", "political" ] }, { "long_name" : "New York", "short_name" : "New York", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "New York", "short_name" : "NY", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "United States", "short_name" : "US", "types" : [ "country", "political" ] }, { "long_name" : "10001", "short_name" : "10001", "types" : [ "postal_code" ] } ], "formatted_address" : "31 W 27th St, New York, NY 10001, USA", "geometry" : { "location" : { "lat" : 40.74471230, "lng" : -73.98964440 }, "location_type" : "ROOFTOP", "viewport" : { "northeast" : { "lat" : 40.74606128029150, "lng" : -73.98829541970849 }, "southwest" : { "lat" : 40.74336331970850, "lng" : -73.99099338029150 } } }, "types" : [ "street_address" ] } ], "status" : "OK" }';
	
	//
	// test methods
	@isTest
	static void testThisClass() {
		// create dummy data
		GeoLocationHelper.firstTime = false;		// don't execute from trigger
		Location_Neighborhood__c loc = new Location_Neighborhood__c(Name='test location');
		insert loc;
		Property__c[] props = new list<Property__c>();
		for(integer i=0; i<5; i++)
			props.add(new Property__c(Name='prop'+i, Location_Neighborhood__c=loc.Id, Street__c='dummy street', City__c='dummy city', State__c='NY', Zip_Code__c='10001'));
		insert props;
		
		Test.startTest();
		list<string> ids = new list<string>();
		for(Property__c p : props)
			ids.add(p.Id);
		GeoLocationHelper.getGeoLocation(ids);
		Test.stopTest();			// executes asynchronous function in synchronous mode
		
		// check results
		Property__c[] propsResult = [select id, Map_Coordinates__Latitude__s, Map_Coordinates__Longitude__s from Property__c where id in :ids];
		system.assert(propsResult[0].Map_Coordinates__Latitude__s!=null, 'Error: GeoLocationHelper did not retrieve or update map coordinates latitude.');
		system.assert(propsResult[0].Map_Coordinates__Longitude__s!=null, 'Error: GeoLocationHelper did not retrieve or update map coordinates longitude.');
	}
	
	@isTest
	static void testThisClass_Parser() {
		// parse Json response from response
		GoogleGeoCodeJson j = (GoogleGeoCodeJson)JSON.deserialize(TEST_RESPONSE, GoogleGeoCodeJson.class);
		
		system.assertEquals(j.status, 'OK', 'Error: GoogleGeoCodeJson did not properly parse status value.');
		system.assert(j.results.size()>0, 'Error: GoogleGeoCodeJson did not properly parse results array.');

		system.assert(j.results[0].address_components.size()>0, 'Error: GoogleGeoCodeJson did not properly parse address_components array.');
		system.assertEquals(j.results[0].address_components[0].long_name, '31', 'Error: GoogleGeoCodeJson did not properly parse address_components[0].long_name value.');
		system.assertEquals(j.results[0].address_components[0].short_name, '31', 'Error: GoogleGeoCodeJson did not properly parse address_components[0].short_name value.');
		system.assert(j.results[0].address_components[0].types.size()>0, 'Error: GoogleGeoCodeJson did not properly parse address_components[0].types array.');

		system.assertEquals(j.results[0].formatted_address, '31 W 27th St, New York, NY 10001, USA', 'Error: GoogleGeoCodeJson did not properly parse formatted_address value.');
		system.assert(j.results[0].types.size()>0, 'Error: GoogleGeoCodeJson did not properly parse types array.');

		system.assert(j.results[0].geometry != null, 'Error: GoogleGeoCodeJson did not properly parse geometry value.');
		system.assert(j.results[0].geometry.bounds == null, 'Error: GoogleGeoCodeJson did not properly parse geometry.bounds value.');
		
		system.assert(j.results[0].geometry.location != null, 'Error: GoogleGeoCodeJson did not properly parse geometry.location value.');
		system.assertEquals(j.results[0].geometry.location.lat, 40.74471230, 'Error: GoogleGeoCodeJson did not properly parse geometry.location.lat value.');
		system.assertEquals(j.results[0].geometry.location.lng, -73.98964440, 'Error: GoogleGeoCodeJson did not properly parse geometry.location.lng value.');
		system.assertEquals(j.results[0].geometry.location_type, 'ROOFTOP', 'Error: GoogleGeoCodeJson did not properly parse geometry.location_type value.');
		
		system.assert(j.results[0].geometry.viewport != null, 'Error: GoogleGeoCodeJson did not properly parse geometry.viewport value.');
		system.assert(j.results[0].geometry.viewport.northeast != null, 'Error: GoogleGeoCodeJson did not properly parse geometry.viewport.northeast value.');
		system.assert(j.results[0].geometry.viewport.southwest != null, 'Error: GoogleGeoCodeJson did not properly parse geometry.viewport.southwest value.');
	}
	*/
}