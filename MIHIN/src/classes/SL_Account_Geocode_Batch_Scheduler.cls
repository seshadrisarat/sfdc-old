/*
*Class: SL_Account_Geocode_Batch_Scheduler
*Description: This class is used to schedule SL_Geocode_Batch_Scheduled batch process for Account object to update Account records with proper geocoding.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public class SL_Account_Geocode_Batch_Scheduler 
{
	public void doBatch()
    {
    	Integer jobs = [Select count() From AsyncApexJob Where ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];
    	if(jobs > 9)
    	{
    		
    	}
    	else
    	{
    		Id batchInstaceForAccount = database.executeBatch(new SL_Geocode_Batch_Scheduled('SELECT Id FROM Account WHERE (Geocoding_Required__c = true OR (Location__Longitude__s = null OR Location__Latitude__s = null)) AND(ShippingCity != null AND ShippingState != null) LIMIT 100'), 100);
   		}
    }
}