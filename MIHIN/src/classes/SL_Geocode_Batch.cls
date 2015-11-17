/*
*Class: SL_Geocode_Batch
*Description: This class is used to get the values of latitudes and longitudes corresponding to the addresses passed using callout to MapQuest API
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public class SL_Geocode_Batch
{	
    public static List<List<String>> Geocode(List<String> address)
    {    	
        MapSettings__c ms = MapSettings__c.getInstance();
		Integer len = address.size();
        Integer numCalls = (ms.BatchSize__c != null) ? Integer.valueOf(math.floor(len/ms.BatchSize__c)+1) : Integer.valueOf(math.floor(len/100)+1);
        List<List<String>> toDo = new List<List<String>>();
        try
        {
	        for(integer i = 0; i < numCalls; i++)
	        {	            
	            String JSONString = '';
	            //check for last section
	            if(i == numCalls - 1)
	            {
	                for(integer j = (integer.valueOf(ms.BatchSize__c)*i); j < len; j++)
	                {
	                   JSONString += SL_Geocode_Batch.formJSON(address[j]) + '},';	                   
	                }
	            //do batches of 100, the max mapquest allows
	            }
	            else
	            {
	                for(integer j = (integer.valueOf(ms.BatchSize__c)*i); j < (integer.valueOf(ms.BatchSize__c)*(i+1)); j ++)
	                {
	                    if(j < ((integer.valueOf(ms.BatchSize__c)*(i+1))-1))
	                    {
	                    	JSONString += SL_Geocode_Batch.formJSON(address[j]) + '},';
	                    }
	                    else
	                    {
	                    	 JSONString += SL_Geocode_Batch.formJSON(address[j]) + '}]}';
	                    }
	             	}
	         	}
	            toDo.addAll(SL_Geocode_Batch.Callout(ms.Endpoint__c+ms.Key__c, '{"locations":['+JSONString.replace('\n','')+']}'));
	        }
        }
        catch(Exception ex)
        {
        	System.debug('============Exception==========='+ex.getLineNumber() +'-------'+ex);
        	System.debug('Stack Trace: ' + ex.getStackTraceString());
        }
        return toDo;
	}
    static List<String[]> Callout(String URL, String Body){
    
        List<List<String>> ltln = new List<List<String>>();
    	try
    	{
	    	Http h = new Http();
	        system.debug(Body);
	    	HttpRequest req = new HttpRequest();
	        req.setHeader('Content-Type', 'Application-JSON');
	        req.setMethod('POST');
	        req.setTimeout(120000);
	        req.setEndpoint(URL);
	        req.setBody(Body);
	        SL_Map_Deserialize deserialized;
	       	if(!Test.isRunningTest())
	       	{
	        	HttpResponse res = h.send(req);
	        	deserialized = SL_Map_Deserialize.parse(res.getBody());
	       	}
	       	else
	       	{
	       		deserialized = SL_Map_Deserialize.parse(getJSON());
	       		
	       	}
	        
	        for(SL_Map_Deserialize.cls_results results : deserialized.results)
	        {
	            List<String> location = new List<String>{String.valueOf(results.locations[0].latLng.lng), String.valueOf(results.locations[0].latLng.lat)};
	            ltln.add(location);
	        }
    	}
    	catch(System.calloutException e)
    	{
    		system.debug('## MapQuest Callout Exception'+e);
    	}
    	return ltln;
    }
    
    /*
    	@MethodName : formJSON
    	@param		: Address of type string
		@Description: This method is used to form valid json string    	
    */
    public Static String formJSON(String strAddress)
    {
    	String JSONString = '{';
    	String[] strAddressParts = strAddress.split('##');
    	if(strAddressParts.size() == 4)
    	{
    		if(strAddressParts[0].length() > 0 && strAddressParts[0] != 'null')
    		JSONString+='"street":"'+ strAddressParts[0].replace('\r\n','') +'"';
    	
	    	//Checking if city is not null
	    	if(strAddressParts[1].length() > 0 && strAddressParts[1] != 'null')
	    	{
	    		//Checking if string contains some address part
	    		if(JSONString.length() > 1)
	    			JSONString+=',"city":"'+ strAddressParts[1] +'"';
	    		else
	    			JSONString+='"city":"'+ strAddressParts[1] +'"';
	    	}
	    	
	    	//Checking if state is not null
	    	if(strAddressParts[2].length() > 0 && strAddressParts[2] != 'null')
	    	{
	    		//Checking if string contains some address part
	    		if(JSONString.length() > 1)
	    			JSONString+=',"state":"'+ strAddressParts[2] +'"';
	    		else
	    			JSONString+='"state":"'+ strAddressParts[2] +'"';
	    	}
	    	//Checking if postal code is not null
	    	if(strAddressParts[3].length() > 0 && strAddressParts[3] != 'null')
	    	{
	    		//Checking if string contains some address part
	    		if(JSONString.length() > 1)
	    			JSONString+=',"postalCode":"'+ strAddressParts[3] +'"';
	    		else
	    			JSONString+='"postalCode":"'+ strAddressParts[3] +'"';
	    	}
	    }
	    else if(strAddressParts.size() == 2)
	    {
	    	if(strAddressParts[0].length() > 0 && strAddressParts[0] != 'null')
	    	{
	    		JSONString+='"city":"'+ strAddressParts[0] +'"';
	    	}
	    	if(strAddressParts[1].length() > 0 && strAddressParts[1] != 'null')
	    	{
	    		if(JSONString.length() > 1)
	    			JSONString+=',"state":"'+ strAddressParts[1] +'"';
	    		else
	    			JSONString+='"state":"'+ strAddressParts[1] +'"';
	    	}
	    }
	    else if(strAddressParts.size() == 1)
	    {
	    	if(strAddressParts[0].length() > 0 && strAddressParts[0] != 'null')
	    	{
	    		JSONString+='"postalCode":"'+ strAddressParts[0] +'"';
	    	}
	    }
	    System.debug('=====================JSONString========================'+JSONString);
    	return JSONString;
    }
    
    private static String getJSON()
    {
    	String json=		'{"results":[{"locations":[{"latLng":{"lng":-73.836967,"lat":40.947936},"adminArea4":"Westchester County","adminArea5Type":"City","adminArea4Type":"County","adminArea5":"Yonkers","street":"25 McIntyre St","adminArea1":"US","adminArea3":"NY","type":"s","displayLatLng":{"lng":-73.837044,"lat":40.948051},'+
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
		'	"messages":[]}}';
		return json;
    }
}