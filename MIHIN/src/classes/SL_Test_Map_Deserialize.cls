/*
*Class: SL_Test_Map_Deserialize
*Description: This test class is used to test SL_Map_Deserialize class functionality and its code coverage
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
@isTest
private class SL_Test_Map_Deserialize
{
    
    @isTest
    static void test_Map_Deserialize() 
    {
        String json=        '{"results":[{"locations":[{"latLng":{"lng":-73.836967,"lat":40.947936},"adminArea4":"Westchester County","adminArea5Type":"City","adminArea4Type":"County","adminArea5":"Yonkers","street":"25 McIntyre St","adminArea1":"US","adminArea3":"NY","type":"s","displayLatLng":{"lng":-73.837044,"lat":40.948051},'+
        '       "linkId":0,'+
        '       "postalCode":"10708-1305",'+
        '       "sideOfStreet":"L",'+
        '       "dragPoint":false,'+
        '       "adminArea1Type":"Country",'+
        '       "geocodeQuality":"ADDRESS",'+
        '       "geocodeQualityCode":"L1AAA",'+
        '       "mapUrl":"https://open.mapquestapi.com/staticmap/v4/getmap?key=Fmjtd|luubnuu7ng,2a=o5-9uy0hw&type=map&size=225,160&pois=purple-1,40.947936,-73.836967,0,0|&center=40.947936,-73.836967&zoom=15&rand=-1808912929",'+
        '       "adminArea3Type":"State"}],'+
        '       "providedLocation":'+
        '           {"street":"25 McIntyre St Yonkers New York"}},'+
        ''+
        ''+
        '   {"locations":['+
        '       {"latLng":'+
        '           {"lng":-73.995701,'+
        '           "lat":40.726682},'+
        '       "adminArea4":"New York County",'+
        '       "adminArea5Type":"City",'+
        '       "adminArea4Type":"County",'+
        '       "adminArea5":"New York","street":"648 Broadway",'+
        '       "adminArea1":"US",'+
        '       "adminArea3":"NY",'+
        '       "type":"s",'+
        '       "displayLatLng":'+
        '           {"lng":-73.995613,'+
        '           "lat":40.726578},'+
        '       "linkId":0,'+
        '       "postalCode":"10012-2348",'+
        '       "sideOfStreet":"R",'+
        '       "dragPoint":false,'+
        '       "adminArea1Type":"Country",'+
        '       "geocodeQuality":"ADDRESS",'+
        '       "geocodeQualityCode":"L1AAB",'+
        '       "mapUrl":"https://open.mapquestapi.com/staticmap/v4/getmap?key=Fmjtd|luubnuu7ng,2a=o5-9uy0hw&type=map&size=225,160&pois=purple-1,40.726682,-73.995701,0,0|&center=40.726682,-73.995701&zoom=15&rand=-1808912929",'+
        '       "adminArea3Type":"State"}],'+
        '       "providedLocation":{"street":"648 Broadway New York New York 10012"}}],'+
        ''+
        ''+
        '   "options":'+
        '       {"ignoreLatLngInput":false,'+
        '       "maxResults":-1,'+
        '       "thumbMaps":true},'+
        '   "info":'+
        '       {"copyright":'+
        '           {"text":"&copy; 2013 MapQuest, Inc.",'+
        '           "imageUrl":"https://api-s.mqcdn.com/res/mqlogo.gif",'+
        '           "imageAltText":"&copy; 2013 MapQuest, Inc."},'+
        '   "statuscode":0,'+
        '   "messages":[]}}';
        SL_Map_Deserialize obj = SL_Map_Deserialize.parse(json);
        new SL_Map_Deserialize.cls_copyright();
        new SL_Map_Deserialize.cls_displayLatLng();
        new SL_Map_Deserialize.cls_info();
        new SL_Map_Deserialize.cls_latLng();
        new SL_Map_Deserialize.cls_locations();
        new SL_Map_Deserialize.cls_messages();
        new SL_Map_Deserialize.cls_options();
        new SL_Map_Deserialize.cls_providedLocation();
        new SL_Map_Deserialize.cls_results();    
        System.assert(obj != null);
    }
    
    @isTest
    static void test_Contact_to_Address() 
    {
        Test.startTest();
        List<String> lstContactId = new List<String>();
        SL_DefaultAddressForContactMap__c objDefaultAddressForContactMap = new SL_DefaultAddressForContactMap__c(Name = 'SL_DefaultAddress',
                                                                                                                Contact_Address__c = 'East Lansing, MI');
        insert objDefaultAddressForContactMap;
        
        
        MapSettings__c objMS = new MapSettings__c(Name='default', BatchSize__c = 5, Endpoint__c = 'www.mihin.com',  Key__c ='Test');
        insert objMS;
        
        Contact objContact = new Contact(LastName = 'Test Contact-01', Geocoding_Required__c = false, 
                                         Location__Latitude__s = -73.837044, Location__Longitude__s = 40.948051,
                                         OtherStreet = 'Test Street', OtherCity = 'NY', OtherState = 'DC', OtherPostalCode = 'PN123');
        insert objContact;
        lstContactId.add(objContact.Id);
        
        SL_Contact_to_Address.ConvertToAddress(lstContactId, true);
        SL_Contact_to_Address.ConvertToAddress(lstContactId, false);
        Test.stopTest();
    }
    @isTest
    static void test_Geocode_Batch_Scheduler() 
    {
        Test.startTest();
        SL_DefaultAddressForContactMap__c objDefaultAddressForContactMap = new SL_DefaultAddressForContactMap__c(Name = 'SL_DefaultAddress',
                                                                                                                Contact_Address__c = 'East Lansing, MI');
        insert objDefaultAddressForContactMap;
        
        
        MapSettings__c objMS = new MapSettings__c(Name='default', BatchSize__c = 5, Endpoint__c = 'www.mihin.com',  Key__c ='Test');
        insert objMS;
        
        Contact objContact = new Contact(LastName = 'Test Contact-01', Geocoding_Required__c = true, 
                                         OtherStreet = 'Test Street', OtherCity = 'NY', OtherState = 'DC', OtherPostalCode = 'PN123');
        insert objContact;
        
        SL_Geocode_Batch_Scheduler objGBS = new SL_Geocode_Batch_Scheduler();
  
        Test.stopTest();
    }   
   
}