/*
* Service that returns geocode data given a postal code and/or country code. This service uses 
* the geonames api to get geocode info and needs to be called inside a future call if run from
* a trigger. The geonames API does not have a batch interface and so all calls must be done one 
* at a time.
*
* If a country code is not provided then the US and CA country codes will be passed
* to the geonames service.
*
* The Geocode_Data_Row__c object is returned if a match is found. Otherwise the method will 
* return null.
*/
public class GeocodeService { 
	public static final string ENDPOINT_BASE = 'http://ba-ws.geonames.net/postalCodeSearch?username=gluna1&postalcode=';
	public static final set<string> US_CANADA_ISO_CODES = new set<string>{'US', 'CA'};
	public static final decimal TEST_RESPONSE_KNOXVILLE_LAT = 35.92242;
	public static final decimal TEST_RESPONSE_KNOXVILLE_LON = -83.79549;
	public static final string TEST_RESPONSE_POSTAL_CODE = '37929';
	public static final string TEST_RESPONSE_CITY = 'Knoxville';
	public static final string TEST_RESPONSE_COUNTRY = 'US';
	public static final string TEST_RESPONSE_STATE_CODE = 'TN';
	public static final string TEST_RESPONSE_STATE_NAME = 'Tennessee';
	public static final string TEST_RESPONSE_COUNTY = 'Knox';
	public static final string TEST_RESPONSE_KNOXVILLE = '<geonames><totalResultsCount>1</totalResultsCount><code><postalcode>' + TEST_RESPONSE_POSTAL_CODE + '</postalcode><name>' + TEST_RESPONSE_CITY + '</name><countryCode>' + TEST_RESPONSE_COUNTRY + '</countryCode><lat>' + TEST_RESPONSE_KNOXVILLE_LAT + '</lat><lng>' + TEST_RESPONSE_KNOXVILLE_LON + '</lng><adminCode1>' + TEST_RESPONSE_STATE_CODE + '</adminCode1><adminName1>' + TEST_RESPONSE_STATE_NAME + '</adminName1><adminCode2>093</adminCode2><adminName2>' + TEST_RESPONSE_COUNTY + '</adminName2><adminCode3/><adminName3/></code></geonames>';
	public static final string TEST_RESPONSE_NO_RESULTS = '<geonames><totalResultsCount>0</totalResultsCount></geonames>';
	public static final string DEFAULT_TEST_RESPONSE = TEST_RESPONSE_KNOXVILLE;
	
	public GeocodeService() {
	}
	
	public GeocodeService(string testResponseXML) {
		TestResponse = testResponseXML;
	}
	
	// Returns a Geocode_Data_Row__c for the given postal code. The default country codes will be used in this case. Null will 
	// be returned if no matches
	public Geocode_Data_Row__c getGeocodeData(string postalCode) {
		return getGeocodeData(postalCode, US_CANADA_ISO_CODES);
	}
	
	// Returns a Geocode_Data_Row__c for the given postal code and country code, or null if no match was found
	public Geocode_Data_Row__c getGeocodeData(string postalCode, string countryISOCode) {
		return getGeocodeData(postalCode, new set<string>{countryISOCode});
	}
	
	// Returns a Geocode_Data_Row__c object for the given postal code and set of country codes, or null if no match was found
	public Geocode_Data_Row__c getGeocodeData(string postalCode, set<string> countryISOCodes) {
		HttpResponse res = Test.isRunningTest() ? getTestResponse() 
												: getGeoNamesResponse(getGeonamesEndpoint(postalCode, countryISOCodes));
												
		return getGeocodeDataFromResponse(res);
	}
	
	// Given a response returns a Geocode_Data_Row__c. If there were no results then null will 
	// be returned.
	private Geocode_Data_Row__c getGeocodeDataFromResponse(HttpResponse res) {
		map<string, string> responseMap = getResponseMap(res);
		
		if (responseMap == null || responseMap.isEmpty()) {
        	return null;
        }
		
		integer totalResultCount = 0;
		if (responseMap.get('totalResultsCount') != null) {
			totalResultCount = integer.valueOf(responseMap.get('totalResultsCount'));
		}
		
		system.debug('# results returned from GeoNames call = ' + totalResultCount);
		if (totalResultCount == 0) {
			return null;
		}
		
		return createGeocodeDataFromResponseMap(responseMap);
	}
	
	// Given a response map returns a Geocode_Data_Row__c
	private Geocode_Data_Row__c createGeocodeDataFromResponseMap(map<string, string> responseMap) {
		Geocode_Data_Row__c geocodeData = new Geocode_Data_Row__c();
		
		string lat = responseMap.get('lat');
		if (!String.isEmpty(lat)) { 
			geocodeData.Geocode__Latitude__s = decimal.valueOf(lat);
        }            
    	
    	string lng = responseMap.get('lng');
        if (!String.isEmpty(lng)) {  
            geocodeData.Geocode__Longitude__s = decimal.valueOf(lng); 
        }
        
        string postalCode = responseMap.get('postalcode');
        if (!String.isEmpty(postalCode)) {
        	geocodeData.Postal_Code__c = postalCode;
        	geocodeData.Name = postalCode;
        }
        
        string countryCode = responseMap.get('countryCode');
        if (!String.isEmpty(countryCode)) {
        	geocodeData.Country__c = countryCode;
        }
        
        string city = responseMap.get('name');
        if (!String.isEmpty(city)) {
        	geocodeData.City_Name__c = city;
        }
        
        string stateCode = responseMap.get('adminCode1');
        if (!String.isEmpty(stateCode)) {
        	geocodeData.State_Province_Abbreviation__c = stateCode;
        }
        
        string stateName = responseMap.get('adminName1');
        if (!String.isEmpty(stateName)) {
        	geocodeData.State_Province_Name__c = stateName;
        }
        
        string countyName = responseMap.get('adminName2');
        if (!String.isEmpty(countyName)) {
        	geocodeData.County_Name__c = countyName;
        }
        
        return geocodeData;
	}
	
	// Given the response returns a map of the values
	private map<string, string> getResponseMap(HttpResponse res) {
		map<string, string> responseMap = new map<string, string>();
		
		if (res != null && res.getStatus() == 'OK') {
			try {
          		for (Dom.XMLNode child : res.getBodyDocument().getRootElement().getChildElements()) {
                	if (child.getname() == 'status') {
                		string message = child.getAttributeValue('message', null);
                		system.debug('WebService Exception =' + message);
                  		return null;
		         	} 
		         	if (child.getname() == 'totalResultsCount') {
		         		responseMap.put(child.getName(), child.getText());	
		         	}      
		            else if (child.getname() == 'code') {
		            	for (Dom.XMLNode child1 : child.getChildElements()) {
		                	responseMap.put(child1.getName(), child1.getText());  
		                }                    
		            }
		            else if (child.getname() == 'geoname'){
		            	for (Dom.XMLNode child1 : child.getChildElements()) {
		                	responseMap.put(child1.getName(), child1.getText());  
		                }
		            }  
		        }
       		} 
       		catch(System.XmlException exp) {
       	    	system.debug('XML Parsing Exception = '+ exp.getMessage());
            	return null;    
        	}  	
		}
			
		return responseMap;
	}
	
	// Returns a test response
	private HttpResponse getTestResponse() {
		HttpResponse res = new HttpResponse();
		
		res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(testResponse);
        
        return res;
	}
	
	// Connects to the geonames API using the specified endpoint and returns the response
	private HttpResponse getGeoNamesResponse(string endpoint) {
		Http h = new Http();
	    HttpRequest req = new HttpRequest();	
	    req.setMethod('GET');
	    req.setEndpoint(endpoint);
	    	
	    HttpResponse res = h.send(req);
	    return res;
	}
	
	// Returns the endpoint for a given postal code and country code
	private string getGeonamesEndpoint(string postalCode, set<string> countryISOCodes) {
		string endpoint = GeocodeService.ENDPOINT_BASE + postalCode;
		
		for (string countryISOCode : countryISOCodes) {
			endpoint += '&country=' + countryISOCode;
		}
		
		system.debug('GeoNames Endpoint=' + endpoint);
		return endpoint;
	}
	
	// Allows callers to set the response for test classes
	public string TestResponse {
		get {
			if (testResponse == null) {
				testResponse = DEFAULT_TEST_RESPONSE;
			}
			return testResponse;
		}
		set;
	}
}