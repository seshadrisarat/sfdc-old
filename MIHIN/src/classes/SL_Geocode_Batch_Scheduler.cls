/*
*Class: SL_Geocode_Batch_Scheduler
*Description: This class is used to schedule the SL_Geocode_Batch_Scheduled batch class.
*Copyright 2013 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
global class SL_Geocode_Batch_Scheduler implements Schedulable
{
    
    /*public void doBatch()
    {
    	Integer jobs = [Select count() From AsyncApexJob Where ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];
    	if(jobs > 9)
    	{
    		
    	}
    	else
    	{
    		id batchinstanceid = database.executeBatch(new SL_Geocode_Batch_Scheduled('SELECT Id FROM Contact WHERE (Geocoding_Required__c = true OR (Location__Longitude__s = null OR Location__Latitude__s = null)) AND(OtherCity != null AND OtherState != null) LIMIT 100'), 100);
    		id batchinstanceidforaccount = database.executeBatch(new SL_Geocode_Batch_Scheduled('SELECT Id FROM Account WHERE (Geocoding_Required__c = true OR (Location__Longitude__s = null OR Location__Latitude__s = null)) AND(ShippingCity != null AND ShippingState != null) LIMIT 100'), 100);
   		}
    }*/
    global void execute(SchedulableContext sc) 
	{
      Integer jobs = [Select count() From AsyncApexJob Where ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];       
      if(jobs > 9)
      {
      	
      }
      else
      {
	      database.executebatch(new SL_Geocode_Batch_Scheduled('SELECT Id FROM Contact WHERE (Geocoding_Required__c = true OR (Location__Longitude__s = null OR Location__Latitude__s = null)) AND(OtherCity != null AND OtherState != null)'), 100);
	      database.executeBatch(new SL_Geocode_Batch_Scheduled('SELECT Id FROM Account WHERE (Geocoding_Required__c = true OR (Location__Longitude__s = null OR Location__Latitude__s = null)) AND(ShippingCity != null AND ShippingState != null)'), 100);
      }
   }
}