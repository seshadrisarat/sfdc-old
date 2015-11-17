/*
*Class: SL_Test_Response_Mapquest
*Description: This test class is used to test response that has been received from callout to MapQuest API and its code coverage
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global class SL_Test_Response_Mapquest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"results":[{"locations":[{"latLng":{"lng":-73.836967,"lat":40.947936},"adminArea4":"Westchester County","adminArea5Type":"City","adminArea4Type":"County","adminArea5":"Yonkers","street":"25 McIntyre St","adminArea1":"US","adminArea3":"NY","type":"s","displayLatLng":{"lng":-73.837044,"lat":40.948051},'+
		'		"linkId":0,'+
		'		"postalCode":"10708-1305",'+
		'		"sideOfStreet":"L",'+
		'		"dragPoint":false,'+
		'		"adminArea1Type":"Country",'+
		'		"geocodeQuality":"ADDRESS",'+
		'		"geocodeQualityCode":"L1AAA",'+
		'		"mapUrl":"https://open.mapquestapi.com/staticmap/v4/getmap?key=Fmjtd|luubnuu7ng,2a=o5-9uy0hw&type=map&size=225,160&pois=purple-1,40.947936,-73.836967,0,0|&center=40.947936,-73.836967&zoom=15&rand=-1808912929",'+
		'		"adminArea3Type":"State"}],'+
		'		"providedLocation":'+
		'			{"street":"25 McIntyre St Yonkers New York"}},'+
		''+
		''+
		'	{"locations":['+
		'		{"latLng":'+
		'			{"lng":-73.995701,'+
		'			"lat":40.726682},'+
		'		"adminArea4":"New York County",'+
		'		"adminArea5Type":"City",'+
		'		"adminArea4Type":"County",'+
		'		"adminArea5":"New York","street":"648 Broadway",'+
		'		"adminArea1":"US",'+
		'		"adminArea3":"NY",'+
		'		"type":"s",'+
		'		"displayLatLng":'+
		'			{"lng":-73.995613,'+
		'			"lat":40.726578},'+
		'		"linkId":0,'+
		'		"postalCode":"10012-2348",'+
		'		"sideOfStreet":"R",'+
		'		"dragPoint":false,'+
		'		"adminArea1Type":"Country",'+
		'		"geocodeQuality":"ADDRESS",'+
		'		"geocodeQualityCode":"L1AAB",'+
		'		"mapUrl":"https://open.mapquestapi.com/staticmap/v4/getmap?key=Fmjtd|luubnuu7ng,2a=o5-9uy0hw&type=map&size=225,160&pois=purple-1,40.726682,-73.995701,0,0|&center=40.726682,-73.995701&zoom=15&rand=-1808912929",'+
		'		"adminArea3Type":"State"}],'+
		'		"providedLocation":{"street":"648 Broadway New York New York 10012"}}],'+
		''+
		''+
		'	"options":'+
		'		{"ignoreLatLngInput":false,'+
		'		"maxResults":-1,'+
		'		"thumbMaps":true},'+
		'	"info":'+
		'		{"copyright":'+
		'			{"text":"&copy; 2013 MapQuest, Inc.",'+
		'			"imageUrl":"https://api-s.mqcdn.com/res/mqlogo.gif",'+
		'			"imageAltText":"&copy; 2013 MapQuest, Inc."},'+
		'	"statuscode":0,'+
		'	"messages":[]}}');
        res.setStatusCode(200);
        return res;
    }
}