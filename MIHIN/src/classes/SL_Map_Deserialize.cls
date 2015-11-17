/*
*Class: SL_Map_Deserialize
*Description: This class is used to accomodate the JSON response which comes from MapQuest API callout
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public class SL_Map_Deserialize
{
	
	public cls_results[] results;
	public cls_options options;
	public cls_info info;
	
	public class cls_results 
	{
		public cls_locations[] locations;
		public cls_providedLocation providedLocation;
	}
	
	public class cls_locations 
	{
		
		public cls_latLng latLng;
		public String adminArea4;	//Westchester County
		public String adminArea5Type;	//City
		public String adminArea4Type;	//County
		public String adminArea5;	//Yonkers
		public String street;	//25 McIntyre St
		public String adminArea1;	//US
		public String adminArea3;	//NY
		public String type;	//s
		public cls_displayLatLng displayLatLng;
		public String linkId;	//0
		public String postalCode;	//10708-1305
		public String sideOfStreet;	//L
		public boolean dragPoint;
		public String adminArea1Type;	//Country
		public String geocodeQuality;	//ADDRESS
		public String geocodeQualityCode;	//L1AAA
		public String mapUrl;	//https://open.mapquestapi.com/staticmap/v4/getmap?key=Fmjtd|luubnuu7ng,2a=o5-9uy0hw&type=map&size=225,160&pois=purple-1,40.947936,-73.836967,0,0|&center=40.947936,-73.836967&zoom=15&rand=-1808912929
		public String adminArea3Type;	//State
	}
	
	public class cls_latLng {
		public Double lng;	//-73.836967
		public Double lat;	//40.947936
	}
	
	public class cls_displayLatLng {
		public Double lng;	//-73.837044
		public Double lat;	//40.948051
	}
	
	public class cls_providedLocation {
		public String street;	//25 McIntyre St Yonkers New York
	}
	
	public class cls_options {
		public boolean ignoreLatLngInput;
		public Integer maxResults;	//-1
		public boolean thumbMaps;
	}
	
	public class cls_info {
		public cls_copyright copyright;
		public Integer statuscode;	//0
		//public cls_messages[] messages; - Commented by SS on 26.Nov.2013
	}
	
	public class cls_copyright {
		public String text;	//&copy; 2013 MapQuest, Inc.
		public String imageUrl;	//https://api-s.mqcdn.com/res/mqlogo.gif
		public String imageAltText;	//&copy; 2013 MapQuest, Inc.
	}
	
	public class cls_messages {
	}
	
	public static SL_Map_Deserialize parse(String json)
	{
		return (SL_Map_Deserialize) System.JSON.deserialize(json, SL_Map_Deserialize.class);
	}
}