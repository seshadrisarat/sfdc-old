/*
*Class: SL_Contact_to_Address
*Description: This class is used update the contact records with geocoding based on thier other address field value
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global class SL_Contact_to_Address
{    
    webservice static List<List<String>> ConvertToAddress(List<String> Cons, boolean page){
    	
        List<List<String>> geocodes = new List<List<String>>();
        List<String> address = new List<String>();
        List<Contact> contacts = [SELECT Id, Geocoding_Required__c, Location__Longitude__s, Location__Latitude__s, OtherStreet, OtherCity, OtherState, OtherPostalCode
                                  FROM Contact
                                  WHERE Id=:Cons];
        //Fetching address from custom setting and passing it to the map quest web service to get coordinates of default address
        SL_DefaultAddressForContactMap__c objDefaultAddressForContactMap = [SELECT Contact_Address__c 
        																	FROM SL_DefaultAddressForContactMap__c 
        																	WHERE Name=:'SL_DefaultAddress' LIMIT 1];
        If(page)
        {
            if(contacts[0].Location__Longitude__s != null && Contacts[0].Location__Latitude__s != null && contacts[0].Geocoding_Required__c == false)
            {
	            Location l = new Location(String.valueOf(Contacts[0].Location__Longitude__s),String.valueOf(Contacts[0].Location__Latitude__s));
	            geocodes.add(l.Stringify(l));
	            return geocodes;
            }
            else if(contacts[0].OtherStreet!=null || Contacts[0].OtherCity!=null || Contacts[0].OtherState!=null || Contacts[0].OtherPostalCode!=null)
        	{
        		address.add(contacts[0].OtherStreet+'##'+Contacts[0].OtherCity+'##'+Contacts[0].OtherState+'##'+Contacts[0].OtherPostalCode);
        		return SL_Geocode_Batch.Geocode(address);
        	}
        	else
        	{
        		address.add((objDefaultAddressForContactMap.Contact_Address__c).replace(',','##'));
        		return SL_Geocode_Batch.Geocode(address);
        	}
        }
        
        for(integer i = 0; i < Cons.size(); i++)
        {
        	address.add(contacts[i].OtherStreet+'##'+Contacts[i].OtherCity+'##'+Contacts[i].OtherState+'##'+Contacts[i].OtherPostalCode);
        }
        
        geocodes = SL_Geocode_Batch.Geocode(address);
        
        for(integer i = 0; i < Cons.size(); i++){
            contacts[i].Location__Longitude__s = decimal.valueOf(geocodes[i][0]);
            contacts[i].Location__Latitude__s = decimal.valueOf(geocodes[i][1]);
            contacts[i].Geocoding_Required__c = false;
        }
        update contacts;
        return geocodes;
    }

	public class Location
	{
    	public String Longitude;
    	public String Latitude;
    
    	public Location(String lon, String lat)
    	{
        	Longitude = lon;
        	Latitude = lat;
    	}
        
    	public List<String> Stringify(Location loc){
            List<String> lonlat = new List<String>{loc.Longitude,loc.Latitude};
        	return lonlat;
    	}
	}
}