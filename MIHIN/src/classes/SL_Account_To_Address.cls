/*
*Class: SL_Account_To_Address
*Description: This class is used to get the coordinates of Account addresses that are being passed from SL_Geocode_Batch_Scheduler class and update the Account records.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global class SL_Account_To_Address 
{
	webservice static List<List<String>> ConvertToAddress(List<String> lstAccountIds, Boolean page)
	{    	
        List<List<String>> lstGeocodes = new List<List<String>>();//List to get coordinates of Account address
        List<String> lstAddress = new List<String>();//List to fill Account addresses for passing to SL_Geocode_Batch class
        
        //Fetching the list of Account records which comes under Account ids which is passed from SL_Geocode_Batch_Scheduled
        List<Account> lstAccount = [SELECT Id, Geocoding_Required__c, Location__Longitude__s, Location__Latitude__s, 
        								   ShippingStreet,ShippingState,ShippingPostalCode,ShippingCity
                                    FROM   Account
                                    WHERE  Id IN:lstAccountIds];
        
        //If the ConvertToAddress function is called from ContactPage then page = true and only one record is requested
        If(page && lstAccount[0].Location__Longitude__s != null && lstAccount[0].Location__Latitude__s != null && lstAccount[0].Geocoding_Required__c == false)
        {
            Location objLocation = new Location(String.valueOf(lstAccount[0].Location__Longitude__s),String.valueOf(lstAccount[0].Location__Latitude__s));
            lstGeocodes.add(objLocation.Stringify(objLocation));
            return lstGeocodes;
        }
        
        //Iterating on list of Account ids to fill the address to lstAddress and pass it SL_Geocode_Batch
        for(Integer intAccountIndex = 0; intAccountIndex < lstAccountIds.size(); intAccountIndex++)
        {
        	lstAddress.add(lstAccount[intAccountIndex].ShippingStreet+'##'+lstAccount[intAccountIndex].ShippingCity+'##'+lstAccount[intAccountIndex].ShippingState+'##'+lstAccount[intAccountIndex].ShippingPostalCode);
        }
        
        lstGeocodes = SL_Geocode_Batch.Geocode(lstAddress);//Fetching the values of Latitudes and Longitudes
        //Iterating on list of Account ids to assign the values of latitudes and longitudes and updating the list
        for(Integer intAccountIndex = 0; intAccountIndex < lstAccountIds.size(); intAccountIndex++)
        {
            lstAccount[intAccountIndex].Location__Longitude__s = decimal.valueOf(lstGeocodes[intAccountIndex][0]);
            lstAccount[intAccountIndex].Location__Latitude__s = decimal.valueOf(lstGeocodes[intAccountIndex][1]);
            lstAccount[intAccountIndex].Geocoding_Required__c = false;
        }
        update lstAccount;//perform DML
        return lstGeocodes;
    }
	
	/* 
    	@ClassName 		: Location
    	@CreatedBy 		: Pankaj Ganwani
    	@JIRA ticket 	: MIHIN-62 
        @Description	: This class is used to hold the values of Longitude and Latitude   
    */
	public class Location
	{
    	public String strLongitude;
    	public String strLatitude;
    
    	public Location(String strLongitude, String strLatitude)
    	{
        	this.strLongitude = strLongitude;
        	this.strLatitude = strLatitude;
    	}
        
    	public List<String> Stringify(Location objLocation)
    	{
            List<String> lstLongitudeLatitude = new List<String>{objLocation.strLongitude,objLocation.strLatitude};
        	return lstLongitudeLatitude;
    	}
	}
}