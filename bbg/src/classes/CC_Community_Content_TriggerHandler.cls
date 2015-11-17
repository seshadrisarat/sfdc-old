public without sharing class CC_Community_Content_TriggerHandler {
	
	public static void handleEventsBeforeInsert(List<CORECONNECT__CC_Community_Content__c> eventListNew)
	{
		geocodeLocal(eventListNew);	
	}
	
	public static void handleEventsBeforeUpdate(Map<Id,CORECONNECT__CC_Community_Content__c> eventMapOld, List<CORECONNECT__CC_Community_Content__c> eventListNew)
	{
		geocodeLocal(eventListNew);	
	}
	
	public static void handleEventsAfterInsert(List<CORECONNECT__CC_Community_Content__c> eventListNew)
	{
		
		Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Community_Content__c.getRecordTypeInfosByName().get('ScheduledContent').getRecordTypeId();
		
		Map<Id,String> newListToProcess = new Map<Id,String>();
		
		for(CORECONNECT__CC_Community_Content__c event : eventListNew)
		{
			if(
			event.RecordTypeId == devRecordTypeId 
			&& event.CORECONNECT__Location_Postal_Code__c != null 
			&& event.CORECONNECT__Location_Geocode__Latitude__s == null 
			&& event.CORECONNECT__Location_Geocode__Longitude__s == null)
			{
				String postalCode = event.CORECONNECT__Location_Postal_Code__c;
				if(postalCode.contains(' '))
				{
					postalCode = postalCode.split(' ')[0];
				}
				newListToProcess.put(event.Id,postalCode);
			}
		}
		
		if(newListToProcess.keySet().size() > 0)
		{
			processInBatches(newListToProcess);
		}
	}
	
	public static void handleEventsAfterUpdate(Map<Id,CORECONNECT__CC_Community_Content__c> eventMapOld, List<CORECONNECT__CC_Community_Content__c> eventListNew)
	{
		
		Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Community_Content__c.getRecordTypeInfosByName().get('ScheduledContent').getRecordTypeId();
		
		Map<Id,String> newListToProcess = new Map<Id,String>();
		
		for(CORECONNECT__CC_Community_Content__c event : eventListNew)
		{
			
			CORECONNECT__CC_Community_Content__c oldEvent = eventMapOld.get(event.Id);
			
			if(
			event.RecordTypeId == devRecordTypeId 
			&& event.CORECONNECT__Location_Postal_Code__c != null
			&& 	(
					(
						event.CORECONNECT__Location_Geocode__Latitude__s == null 
						&& event.CORECONNECT__Location_Geocode__Longitude__s == null
					) 
					|| (oldEvent!= null && event.CORECONNECT__Location_Postal_Code__c != oldEvent.CORECONNECT__Location_Postal_Code__c)
				)
			)
			{
				String postalCode = event.CORECONNECT__Location_Postal_Code__c;
				if(postalCode.contains(' '))
				{
					postalCode = postalCode.split(' ')[0];
				}
				newListToProcess.put(event.Id,postalCode);
			}
			
		}
		
		if(newListToProcess.keySet().size() > 0)
		{
			processInBatches(newListToProcess);
		}
		
	}
	
	private static void processInBatches(Map<Id,String> eventToZipMap)
	{
		Integer counterTotal = 0;
		Map<Id,String> tmpEventToZipMap = new Map<Id,String>();
		for(Id eventId : eventToZipMap.keySet())
		{
			counterTotal++;
			tmpEventToZipMap.put(eventId, eventToZipMap.get(eventId));
			
			if(tmpEventToZipMap.keySet().size() == 100 || counterTotal == eventToZipMap.keySet().size())
			{
				CC_Community_Content_TriggerHandler.geocodeEvents(tmpEventToZipMap);
				tmpEventToZipMap = new Map<Id,String>();
			}
			
		}
		
	}
	
	private static void geocodeLocal(List<CORECONNECT__CC_Community_Content__c> eventListNew)
	{
		Id devRecordTypeId = Schema.SObjectType.CORECONNECT__CC_Community_Content__c.getRecordTypeInfosByName().get('ScheduledContent').getRecordTypeId();
		
		Map<Id,String> newListToProcess = new Map<Id,String>();
		List<String> zipcodeList = new List<String>();
		
		for(CORECONNECT__CC_Community_Content__c event : eventListNew)
		{
			
			if(event.RecordTypeId == devRecordTypeId && String.isEmpty(event.CORECONNECT__Location_Postal_Code__c))
			{
				event.CORECONNECT__Location_Geocode__Latitude__s = null;
				event.CORECONNECT__Location_Geocode__Longitude__s = null;
			}
			else if(event.RecordTypeId == devRecordTypeId && !String.isEmpty(event.CORECONNECT__Location_Postal_Code__c))
			{
				String postalCode = event.CORECONNECT__Location_Postal_Code__c;
				if(postalCode.contains(' '))
				{
					postalCode = postalCode.split(' ')[0];
				}
				zipcodeList.add(postalCode);
			}
		}
		
		if(zipcodeList.size() > 0)
		{
			
			List<Geocode_Data_Row__c> gdrList = [SELECT Id, Name, Postal_Code__c, Geocode__Latitude__s, Geocode__Longitude__s FROM Geocode_Data_Row__c WHERE Name In :zipcodeList OR Postal_Code__c IN :zipcodeList];
			
			Map<String,Geocode_Data_Row__c> gdrMap = new Map<String,Geocode_Data_Row__c>();
			
			for(Geocode_Data_Row__c gdr : gdrList)
			{
				gdrMap.put(gdr.Postal_Code__c, gdr);
			}
			
			for(CORECONNECT__CC_Community_Content__c event : eventListNew)
			{
				if(event.RecordTypeId == devRecordTypeId && !String.isEmpty(event.CORECONNECT__Location_Postal_Code__c))
				{
					String postalCode = event.CORECONNECT__Location_Postal_Code__c;
					if(postalCode.contains(' '))
					{
						postalCode = postalCode.split(' ')[0];
					}
					Geocode_Data_Row__c gdr = gdrMap.get(postalCode);
					if(gdr != null)
					{
						event.CORECONNECT__Location_Geocode__Latitude__s = gdr.Geocode__Latitude__s;
						event.CORECONNECT__Location_Geocode__Longitude__s = gdr.Geocode__Longitude__s;
					}
				}
			}
			
		}
	}
	
	@future
	public static void geocodeEvents(Map<Id,String> eventToZipMap)
	{
		
		List<CORECONNECT__CC_Community_Content__c> eventListToUpdate = new List<CORECONNECT__CC_Community_Content__c>();
		
		for(Id eventId : eventToZipMap.keySet())
		{
			
			String postalCode = eventToZipMap.get(eventId);
			
			if(postalCode != null)
			{
				Geocode_Data_Row__c gdr = SROCUtilities.postalCodeToGeocodeData(postalCode);
				
				if(gdr != null)
				{
					CORECONNECT__CC_Community_Content__c tmpEvent = new CORECONNECT__CC_Community_Content__c();
					tmpEvent.Id = eventId;
					tmpEvent.CORECONNECT__Location_Geocode__Latitude__s = gdr.Geocode__Latitude__s;
					tmpEvent.CORECONNECT__Location_Geocode__Longitude__s = gdr.Geocode__Longitude__s;
					
					eventListToUpdate.add(tmpEvent);
				}
				
			}
			
		}
		
		if(eventListToUpdate.size() > 0)
		{
			update eventListToUpdate;
		}
		
	}
	
}