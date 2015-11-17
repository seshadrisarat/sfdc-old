/**
* \arg \b ClassName      : SL_Equipment_Handler
* \arg \b JIRATicket     : FAEF-2, FAEF-14
* \arg \b CreatedOn      : 03/07/2013
* \arg \b ModifiedBy     : -
* \arg \b Description    : This is the handler class for Equipment trigger.When an Equipment is inserted then it will take all serial numbers from serial numbers field and create
*							Equipment Item record for each serial number. 
*/

public without sharing class SL_Equipment_Handler 
{
	private static boolean EquipmentHandlerHasRun = false;

	public SL_Equipment_Handler()
	{
	}
	
	/*!
      *  @MethodName    : onAfterInsert.
      *  @param 		: List of Equipment.
      *  @Description   : Called After insert of the Equipment.
    */
    public void onAfterInsert(Map<Id, Equipment__c> mapNew)
    {
    	if(!EquipmentHandlerHasRun)
    	{
			EquipmentHandlerHasRun = true;
            List<Equipment__c> fullEquipList = [SELECT Id,Schedule__r.Letter_of_Intent__r.Account__c,Description__c,Serial_Numbers__c,Quantity__c,Location__c,Location_Upload__c 
                                                                          FROM Equipment__c 
                                                                          WHERE Id IN:mapNew.keySet()];

			Map<Id, Equipment__c> mapNew_Full = new Map<Id,Equipment__c>(fullEquipList);
			LookupLocation(mapNew_Full);
			FixEquipmentItems(null,mapNew);
		}
    }	
	
	/*!
      *  @MethodName    : onAfterUpdate.
      *  @param 		: List of Equipment and Map Of Id and Equipment
      *  @Description   : Called After update of the Equipment.
    */
    public void onAfterUpdate(Map<Id, Equipment__c> mapOld, Map<Id, Equipment__c> mapNew)
    {
    	if(!EquipmentHandlerHasRun)
    	{
			EquipmentHandlerHasRun = true;
            List<Equipment__c> fullEquipList = [SELECT Id,Schedule__r.Letter_of_Intent__r.Account__c,Description__c,Serial_Numbers__c,Quantity__c,Location__c,Location_Upload__c, (Select Id, Serial__c,Description__c FROM Equipment_Items__r ORDER BY Name)
                                                                          FROM Equipment__c 
                                                                          WHERE Id IN:mapNew.keySet()];
			Map<Id, Equipment__c> mapNew_Full = new Map<Id,Equipment__c>(fullEquipList);
			FixEquipmentItems(mapOld,getEquipment_ChangedQtySerialDesc(mapOld,mapNew_Full));
			LookupLocation(getEquipment_ChangedLocation(mapOld,mapNew_Full));
		}
    }

    private void LookupLocation(Map<Id, Equipment__c> mapNew)
    {
    	Set<Id> setAcctIds = new Set<Id>();
    	for(Equipment__c equip: mapNew.values())
    	{
    		setAcctIds.add(equip.Schedule__r.Letter_of_Intent__r.Account__c);
    	}
    	Map<Id,Location__c> allLocations = new Map<Id,Location__c>([SELECT Id, Location_Number__c,Account__c 
    									  FROM Location__c 
    									  WHERE Account__c IN :setAcctIds]);

		Map<Id,Map<String,Id>> mapAccountId_LocNum_Id = new Map<Id,Map<String,Id>> ();

		for(Location__c loc : allLocations.values())
		{
			Id acctId = (Id) loc.Account__c;
			String locNum = loc.Location_Number__c;

			if(!mapAccountId_LocNum_Id.containsKey(acctId))
			{
				mapAccountId_LocNum_Id.put(acctId,new Map<String,Id>());
			}

			mapAccountId_LocNum_Id.get(acctId).put(locNum,loc.Id);	
		}

  		List<Equipment__c> listToUpdate = new List<Equipment__c>();
  		for(Equipment__c equip: mapNew.values())
  		{
            if(equip.Schedule__r.Letter_of_Intent__r.Account__c !=null)
            {
                Id acctId = (Id) equip.Schedule__r.Letter_of_Intent__r.Account__c;
    			String equipLocUpload = zeroFillInteger((equip.Location_Upload__c!=null?equip.Location_Upload__c:0));
    			if((equipLocUpload !=null) && 
                   (mapAccountId_LocNum_Id != null) &&
                   (mapAccountId_LocNum_Id.get(acctId) !=null))
    			{
    	  			Id locId =  (Id) mapAccountId_LocNum_Id.get(acctId).get(equipLocUpload);
                    Decimal uploadLocation = equip.Location_Upload__c;
                    if((equip.Location__c !=null) &&
                       (locId != equip.Location__c))
                    {
                        locId = equip.location__c;
                        uploadLocation = null;
                    }
    	  			Equipment__c equipToAdd = new Equipment__c(Id=equip.Id,Location_Upload__c =uploadLocation, Account__c = acctId, Location__c = locId);
    				listToUpdate.add(equipToAdd);	
    			}
            }
  		}

  		if(!listToUpdate.isEmpty())
  		{
  			update listToUpdate;
  		}

    }
    private String zeroFillInteger(Decimal myInt)
    {
        String over99  = '';
        String under100 = '0';
        String under10  = '00';

        String outputString = String.valueOf(0);

        if(myInt > 0)
            outputString = (myInt > 9?(myInt > 99?over99:under100):under10) + String.valueOf(myInt);

        return outputString;
    }


    private void FixEquipmentItems(Map<Id, Equipment__c> mapOld, Map<Id, Equipment__c> mapNew)
    {
    	if(!mapNew.isEmpty())
    	{
    		List<Equipment_Item__c> listToUpsert = new List<Equipment_Item__c>();
    		List<Equipment_Item__c> listToDelete = new List<Equipment_Item__c>();

    		for(Equipment__c equip: mapNew.values())
    		{
    			List<String> serials = new List<String>();
                String tempSerials = equip.Serial_Numbers__c;
    			//parse the serial #'s.
    			if(tempSerials != null)
    			{
                    tempSerials.replace(';', ',');
    				serials = tempSerials.split(',');	
    			}
    			
    			if(equip.Quantity__c != null)
    			{
    				Integer equipItemsCount = (equip.Equipment_Items__r!=null?equip.Equipment_Items__r.size():0);
    				List<Equipment_Item__c> eqpItems = equip.Equipment_Items__r;

    				// Quantity was increased, we need to create new records.
    				if(equip.Quantity__c > equipItemsCount)
    				{
    					for(Integer i =equipItemsCount; i< equip.Quantity__c; i++)
		    			{
		    				String serial='';
		    				if(!serials.isEmpty() && serials.size() > i )
		    				{
		    					serial = serials[i].trim();
		    				}
		    				Equipment_Item__c eqpItemToAdd = new Equipment_Item__c(Equipment__c = equip.Id, Description__c = equip.Description__c,Serial__c = serial);
		    				listToUpsert.add(eqpItemToAdd);
		    			}
    				}

    				// Quantity was decreased, we need to delete some records.
    				else if(equip.Quantity__c < equipItemsCount)
    				{
    					for(Integer i =Integer.valueOf(equip.Quantity__c); i< equipItemsCount; i++)
    					{
		    				Equipment_Item__c eqpItemToDel = new Equipment_Item__c(Id = eqpItems[i].Id);
		    				listToDelete.add(eqpItemToDel);
		    			}
    				}

    				// Serial Numbers field or Description field was changed, we need to update some records.
    				if((mapOld !=null) &&
                       (equip !=null) &&
                       (equip.Id !=null) &&
                       (mapOld.get(equip.Id) !=null) &&
                       (equip.Serial_Numbers__c != null) &&
                       (mapOld.get(equip.Id) !=null) &&
                       (mapOld.get(equip.Id).Serial_Numbers__c != null) &&
                       ((equip.Serial_Numbers__c != mapOld.get(equip.Id).Serial_Numbers__c) ||
    				    (equip.Description__c != mapOld.get(equip.Id).Description__c)))
    				{
    					for(Integer i = 0; i<equip.Quantity__c; i++)
    					{
    						String serial='';
		    				if(!serials.isEmpty() && serials.size() > i )
		    				{
		    					serial = serials[i].trim();
		    				}

		    				Equipment_Item__c eqpItemToAdd = new Equipment_Item__c(Serial__c=serial,Equipment__c = equip.Id,Description__c= equip.Description__c);
		    				if(eqpItems.size()>i)
		    				{
		    					eqpItemToAdd.Id = (Id) eqpItems[i].Id;
		    				}

		    				listToUpsert.add(eqpItemToAdd);	
    					}
    				}
	    		}
    		}

    		if(!listToUpsert.isEmpty())
    		{
    			upsert listToUpsert;
    		}
    		if(!listToDelete.isEmpty())
    		{
    			delete listToDelete;
    		}
    	}
    }

    private Map<Id,Equipment__c> getEquipment_ChangedLocation (Map<Id, Equipment__c> mapOld, Map<Id, Equipment__c> mapNew)
    {
    	Map<Id, Equipment__c> resultMap = new Map<Id, Equipment__c>();

    	for(Equipment__c equip : mapNew.values())
    	{
    		if((equip.Location_Upload__c != mapOld.get(equip.Id).Location_Upload__c) || 
    		   (equip.Location__c != mapOld.get(equip.Id).Location__c))
    		{
    			resultMap.put(equip.Id,equip);
    		}
    	}
    	return resultMap;
    }

    private Map<Id,Equipment__c> getEquipment_ChangedQtySerialDesc (Map<Id, Equipment__c> mapOld, Map<Id, Equipment__c> mapNew)
    {
    	Map<Id, Equipment__c> resultMap = new Map<Id, Equipment__c>();

    	for(Equipment__c equip : mapNew.values())
    	{
    		if((equip.Quantity__c != mapOld.get(equip.Id).Quantity__c) ||
    		   (equip.Serial_Numbers__c != mapOld.get(equip.Id).Serial_Numbers__c) ||
    		   (equip.Description__c != mapOld.get(equip.Id).Description__c))
    		{
    			resultMap.put(equip.Id,equip);
    		}
    	}
    	return resultMap;
    }
}




// OLD CODE_------------------
	/*!
      *  @MethodName    : UpdateLocation.
      *  @param 		: List of Equipment and Map Of Id and Equipment
      *  @Description   : Called from Before insert and Before Update methods of the Equipment.
    */
	/*public void UpdateLocation(List<Equipment__c> lstNewEquipment, Map<Id, Equipment__c> mapOldEquipment)
 	{
 		try
 		{
	  		Map<Decimal, Id> mapLocationNumber_Location = new Map<Decimal,Id>();    		//Storing all location number with its location which will be helpful for finding out Locations based on location number
	  		Set<Id> setAccountIds = new Set<Id>();											//Storing all the Account Ids which will be helpful for finding out Locations which are related to it.
	  		Set<Decimal> setLocationNumber = new Set<Decimal>();							//Storing all the Location Number of all equipment records being upserted to update their locations
	  		Set<Id> setSchedules = new Set<Id>();											//Storing all the Schedule Ids which will be helpful for finding out Accounts which are related to it.
	  		Set<Id> setLocationIds = new Set<Id>();											//Storing all the Location Ids which will be helpful for finding out Location Number if Location is filled by user
	  		Map<Id, String> mapLocationId_Location = new Map<Id, String>();					//Storing all the Schedule Ids which will be helpful for finding out Account Ids related to each schedule
	  		Map<Id, Id> mapLocationId_AccountId = new Map<Id, Id>();						//String all Account ids related to locations found, to replace equipment's account with this account
	  		Map<String, Id> MapAccountId_LocationNumber_Location = new Map<String, Id>();   //Storing All Account Ids to find Location based on Location Number 
	  		Map<String, Decimal> MapAccountId_MapLocation_LocationNumber = new Map<String, Decimal>(); //Storing All Account Ids to find Location Number based on Location
	  		
	  		///Iterate with Equipment records and add required schedules, Location number and Location Ids in set
	  		for(Equipment__c objEquipment : lstNewEquipment)
	 		{
	 			///Add schedules in set to get Account Id related to these schedules
	      		setSchedules.add(objEquipment.Schedule__c);
	      		
	      		///Insert case, If location null and Location Upload not null.If so, add Location number in set which can be used to fetch all locations based on location number
	      		if(objEquipment.Location_Upload__c != null && objEquipment.Location__c == null)
	       			setLocationNumber.add(objEquipment.Location_Upload__c.stripTrailingZeros());
	       			
	       		///Update case, If Location changes, fetch all locations.
	      		if(mapOldEquipment != null && objEquipment.Location__c != null && objEquipment.Location__c != mapOldEquipment.get(objEquipment.Id).Location__c)
	       			setLocationIds.add(objEquipment.Location__c);
	     	}
	  		
	  		///Iterate with Schedules to fetch its LOI's Opportunity's Account Id
	  		for(Schedule__c objSchedule : [SELECT Id, Letter_of_Intent__r.Account__c, Letter_of_Intent__c
	               							FROM Schedule__c 
	           								WHERE Id IN : setSchedules])
	     	{
	     		///Add Account ids in a set to fetch locations based on these accounts
	     		if(objSchedule.Letter_of_Intent__c != null && objSchedule.Letter_of_Intent__r.Account__c != null)
	      			setAccountIds.add(objSchedule.Letter_of_Intent__r.Account__c);
	 		}
	  		
	  		///Iterate with Location and fetch its Location Number 
	  		for(Location__c objLocation : [Select Name, Location_Number__c, Id, Account__c From Location__c where Account__c IN: setAccountIds OR Id IN : setLocationIds])
	  		{
	  			///If Location number is filled then add its corresponding Location in a map to fetch location based on location number
	   			if(setLocationNumber.contains(Decimal.valueOf(objLocation.Location_Number__c).stripTrailingZeros()))
	    			mapLocationNumber_Location.put(Decimal.valueOf(objLocation.Location_Number__c).stripTrailingZeros(), objLocation.Id);
	    			
	    		///If location is filled and location number blank in equipment, add Location in a map to fetch location number based on location
	   			if(objLocation.Location_Number__c != null && objLocation.Location_Number__c != '')
	    			mapLocationId_Location.put(objLocation.Id, objLocation.Location_Number__c);
	    			
	    		///To update equipment's account with location's account	
    			mapLocationId_AccountId.put(objLocation.Id, objLocation.Account__c);
    			
    			///To Update Location if Location Number is provided and vice versa based on Account 
    			if(objLocation.Location_Number__c != null && objLocation.Location_Number__c != '')
    			{
    				MapAccountId_LocationNumber_Location.put(objLocation.Account__c+'_'+decimal.valueOf(objLocation.Location_Number__c).stripTrailingZeros() , objLocation.Id);
    				MapAccountId_MapLocation_LocationNumber.put(objLocation.Account__c+'_'+objLocation.Id, decimal.valueOf(objLocation.Location_Number__c).stripTrailingZeros());
    			}
	  		}
	  		
			///Iterate with Equipment and update the required fields  		
	  		for(Equipment__c objEquipment : lstNewEquipment)
	  		{  
	  			///If Account null, update its account equal Location's account
	  			if(objEquipment.Location__c != null)
	  				objEquipment.Account__c = mapLocationId_AccountId.get(objEquipment.Location__c);
	  			else if(objEquipment.Location_Upload__c != null && mapLocationId_AccountId != null && mapLocationNumber_Location.containsKey(objEquipment.Location_Upload__c.stripTrailingZeros())
	  					&& mapLocationId_AccountId.containsKey(mapLocationNumber_Location.get(objEquipment.Location_Upload__c.stripTrailingZeros())) 
	  					&& mapLocationId_AccountId.get(mapLocationNumber_Location.get(objEquipment.Location_Upload__c.stripTrailingZeros())) != null 
	  					&& mapLocationNumber_Location != null &&  mapLocationNumber_Location.get(objEquipment.Location_Upload__c.stripTrailingZeros()) != null )
	  			{
  					objEquipment.Account__c = mapLocationId_AccountId.get(mapLocationNumber_Location.get(objEquipment.Location_Upload__c.stripTrailingZeros()));
	  			}
	  				
	    		///If Location upload is filled and location blank, then update location
	    		if((mapOldEquipment == null && objEquipment.Account__c != null && MapAccountId_LocationNumber_Location != null && objEquipment.Location_Upload__c != null 
	    		&& MapAccountId_LocationNumber_Location.containsKey(objEquipment.Account__c+'_'+objEquipment.Location_Upload__c.stripTrailingZeros())
	    		&& MapAccountId_LocationNumber_Location.get(objEquipment.Account__c+'_'+objEquipment.Location_Upload__c.stripTrailingZeros()) != null)
	    		|| (mapOldEquipment != null && mapOldEquipment.get(objEquipment.Id).Location_Upload__c.stripTrailingZeros() !=  objEquipment.Location_Upload__c.stripTrailingZeros()))
	    			
	    			objEquipment.Location__c = MapAccountId_LocationNumber_Location.get(objEquipment.Account__c+'_'+objEquipment.Location_Upload__c.stripTrailingZeros());
	    		
	    		///If location upload blank, location present, update location number
	    		if(objEquipment.Account__c != null && MapAccountId_MapLocation_LocationNumber != null && objEquipment.Location__c != null && 
	    		MapAccountId_MapLocation_LocationNumber.get(objEquipment.Account__c+'_'+objEquipment.Location__c) != null)
	    			objEquipment.Location_Upload__c = MapAccountId_MapLocation_LocationNumber.get(objEquipment.Account__c+'_'+objEquipment.Location__c);
	    		
	  		}
 		}
 		catch(Exception e)
 		{
			system.debug('-------Exception-----'+e.getMessage()+'---at line number---'+e.getLineNumber()); 			
 		}
 	}*/
	
	/*!
      *  @MethodName    : onAfterInsert.
      *  @param 		: List of Equipment.
      *  @Description   : This function will call After insert of the Equipment.
    */
    /*public void onAfterInsert(Map<Id, Equipment__c> mapNewEquipment)
    {
        createEquipmentItems(mapNewEquipment);
    }*/
    
    /*!
      *  @MethodName : onAfterUpdate.
      *  @param 	 : List of Equipment.
      *  @Description: This function will call After Update of the Equipment.
    */
    /*public void onAfterUpdate(Map<Id, Equipment__c> mapNewEquipment, Map<Id, Equipment__c> mapOldEquipment)
    {
        updateEquipmentItems(mapNewEquipment, mapOldEquipment);
    }/*
    
    /*!
      *  @MethodName: createEquipmentItems
      *  @param     : List of Notes.
      *  @Description: create Equipment item records for each serial number
    */
    /*private void createEquipmentItems(Map<Id, Equipment__c> mapNewEquipment)
    {
    	
    	// This map is use to store mapping of Equipment id and serial numbers.
		Map<String, set<String>> mapParentIdToLstSerialNo = new Map<String, set<String>>();
		Map<String, Integer> mapParentIdToQTYNumber = new Map<String, Integer>();    	
    	mapEquipmentIdToScheduleId = new Map<String,String>();
    	for(Equipment__c sObjEquipment : mapNewEquipment.values())
    	{
    		mapEquipmentIdToScheduleId.put(sObjEquipment.Id,sObjEquipment.Schedule__c);
    		Set<String> setSerialNo = new Set<String>();
    		if(sObjEquipment.Serial_Numbers__c != null && sObjEquipment.Serial_Numbers__c != '')
    		{
    			// Spliting the serial number and then trim the white space.
    			for(String strS : sObjEquipment.Serial_Numbers__c.split(','))
    			{
    				if(strS.Trim() != '')
    					setSerialNo.add(strS.Trim());	
    			}
    			mapParentIdToLstSerialNo.put(sObjEquipment.Id, setSerialNo);
    			mapParentIdToQTYNumber.put(sObjEquipment.Id, setSerialNo.size());
    		}
    		else
    		{
    			mapParentIdToLstSerialNo.put(sObjEquipment.Id, setSerialNo);
    		}
    	}
    	upsertEquipmentAndEqipmentItem(mapParentIdToLstSerialNo, mapParentIdToQTYNumber, getAccountIdToUpdateEquipmentField(mapEquipmentIdToScheduleId)); 
    	
    }*/
	
	/*!
      *  @MethodName: updateEquipmentItems
      *  @param None: List of Notes.
      *  @Description: create Equipment item records for each serial number
    *//*
    private void updateEquipmentItems(Map<Id, Equipment__c> mapNewEquipment, Map<Id, Equipment__c> mapOldEquipment)
    {
    		mapEquipmentIdToScheduleId = new Map<String,String>();
    		List<Equipment_Item__c> lstEquipmentItems = new List<Equipment_Item__c>(); //!< List of Equipment Item to be inserted.
    		List<Equipment_Item__c> lstEquipmentItemNotSyncd = new List<Equipment_Item__c>();//List of Equipment Item to be deleted.
    		
    		Set<String> setRecentSerialNumbers = new Set<String>();
	    	Set<String> setTotalSerialNo = new Set<String>(); //!< Storing the serial numbers after spliting 
	    	Set<String> setSerialNumbers1 = new Set<String>(); //!< Storing the serial numbers after spliting to get new Item
	    	Set<String> setSerialNumbers2 = new Set<String>(); //!< Storing the serial numbers after spliting to comparison with existing items
	    	
	    	Map<String, Set<String>> mapEquipmentIdToSetOldSerialNo = new Map<String, Set<String>>(); //!< Store EquipmentId and set of related serial no. for old records.
	    	Map<String, Set<String>> mapEquipmentIdToSetNewSerialNo = new Map<String, Set<String>>(); //!< Store EquipmentId and set of related serial no. for new records.
	    	Map<String, Integer> mapEquipmentIdToQTY = new Map<String, Integer>(); //!< Store EquipmentId with respective quantity.
	    	Map<String, Set<String>> mapEquipmentIdToSetOldSerialNo2 = new Map<String, Set<String>>(); //!< Store EquipmentId and set of related serial no. for old records for comparison.
	    	Map<String, Set<String>> mapEquipmentIdToSetNewSerialNO2 = new Map<String, Set<String>>(); //!< Store EquipmentId and set of related serial no. for new records for comparison.
	    	Map<String, Set<String>> mapEquipmentIdToSetAllSerialNumbers = new Map<String, Set<String>>();
	    	
	    	for(Equipment__c sObjEquipment : mapNewEquipment.values())
	    	{
	    		List<String> lstSerialNo = new List<String>();
				Set<String> setSerialNo = new Set<String>();
	    		setSerialNumbers1 = new Set<String>();
	    		setSerialNumbers2 = new Set<String>();
	    		setTotalSerialNo = new Set<String>();
	    		
	    		if(sObjEquipment.Schedule__c !=  mapOldEquipment.get(sObjEquipment.Id).Schedule__c)
	    			mapEquipmentIdToScheduleId.put(sObjEquipment.Id, sObjEquipment.Schedule__c);
	    		
	    		if(sObjEquipment.Serial_Numbers__c != mapOldEquipment.get(sObjEquipment.Id).Serial_Numbers__c 
	    			|| sObjEquipment.Quantity__c != mapOldEquipment.get(sObjEquipment.Id).Quantity__c)
	    		{
	    			if(sObjEquipment.Serial_Numbers__c !=null && sObjEquipment.Serial_Numbers__c != '')
		    		{
		    			String strReplaceNewLineCharacter = sObjEquipment.Serial_Numbers__c;
		    			
		    			// Spliting the serial number and then trim the white space.
		    			for(String strS : strReplaceNewLineCharacter.split(','))
		    			{
		    				strS = strS.replace('\n', '');
		    				strS = strS.replace('\r', '');
		    				strS = strS.replace('\t', '');
		    				//strS = strS.replace('\r\n', ' ');
		    				if(strS.Trim() != '')
		    					setTotalSerialNo.add(strS.Trim());	
		    			}
		    			
		    			
		    			mapEquipmentIdToQTY.put(sObjEquipment.Id, setTotalSerialNo.size());
		    			setSerialNumbers1.addAll(setTotalSerialNo);
		    			setSerialNumbers2.addAll(setTotalSerialNo);
		    			mapEquipmentIdToSetNewSerialNo.put(sObjEquipment.Id, setSerialNumbers1);
		    			mapEquipmentIdToSetNewSerialNO2.put(sObjEquipment.Id, setSerialNumbers2);
		    			mapEquipmentIdToSetAllSerialNumbers.put(sObjEquipment.Id, setTotalSerialNo);
		    		}
		    		else
		    		{
		    			mapEquipmentIdToSetNewSerialNo.put(sObjEquipment.Id, setSerialNumbers1);
		    			mapEquipmentIdToSetNewSerialNo2.put(sObjEquipment.Id, setSerialNumbers1);
		    			mapEquipmentIdToSetAllSerialNumbers.put(sObjEquipment.Id, setTotalSerialNo);
	    				//mapEquipmentIdToQTY.put(sObjEquipment.Id, 0);
		    		}
		    		lstSerialNo = new List<String>();
		    		setSerialNumbers1 = new Set<String>();
	    			setSerialNumbers2 = new Set<String>();
	    			
		    		if(mapOldEquipment.get(sObjEquipment.Id).Serial_Numbers__c !=null && mapOldEquipment.get(sObjEquipment.Id).Serial_Numbers__c != '')
		    		{
		    			// Spliting the serial number and then trim the white space.
		    			for(String strS : mapOldEquipment.get(sObjEquipment.Id).Serial_Numbers__c.split(','))
		    			{
		    				strS = strS.replace('\n', '');
		    				strS = strS.replace('\r', '');
		    				strS = strS.replace('\t', '');
		    				if(strS.Trim() != '')
		    					lstSerialNo.add(strS.Trim());	
		    			}
		    			system.debug('--3--'+lstSerialNo);
		    			setSerialNumbers1.addAll(lstSerialNo);
		    			setSerialNumbers2.addAll(lstSerialNo);
		    			mapEquipmentIdToSetOldSerialNo.put(sObjEquipment.Id, setSerialNumbers1);
		    			mapEquipmentIdToSetOldSerialNo2.put(sObjEquipment.Id, setSerialNumbers2);
		    		}
		    		else
		    		{
		    			mapEquipmentIdToSetOldSerialNo.put(sObjEquipment.Id, setSerialNumbers1);
		    			mapEquipmentIdToSetOldSerialNo2.put(sObjEquipment.Id, setSerialNumbers2);
		    		}
		    				    		
		    		if(mapEquipmentIdToSetNewSerialNo.keyset().contains(sObjEquipment.Id) && mapEquipmentIdToSetOldSerialNo.keyset().contains(sObjEquipment.Id) )
		    		{
		    			mapEquipmentIdToSetNewSerialNo.get(sObjEquipment.Id).removeAll(mapEquipmentIdToSetOldSerialNo.get(sObjEquipment.Id));
		    		}
		    		
		    		if(mapEquipmentIdToSetNewSerialNO2.containsKey(sObjEquipment.Id) && mapEquipmentIdToSetOldSerialNo2.containsKey(sObjEquipment.Id))
		    		{
		    			mapEquipmentIdToSetOldSerialNo2.get(sObjEquipment.Id).removeAll(mapEquipmentIdToSetNewSerialNO2.get(sObjEquipment.Id));
		    		}
		    		
	    		}
	    	}
	    	upsertEquipmentAndEqipmentItem(mapEquipmentIdToSetNewSerialNo, mapEquipmentIdToQTY, getAccountIdToUpdateEquipmentField(mapEquipmentIdToScheduleId));
	    	
	    	lstEquipmentItems = new List<Equipment_Item__c>();
	    	for(Equipment_Item__c sObjEquipment : 	[	Select Id, Serial__c, Equipment__c
	    												From Equipment_Item__c
	    												Where Equipment__c IN:mapEquipmentIdToSetOldSerialNo2.keyset()
	    												
	    											])
	    	{
	    		
	    		if(sObjEquipment.Serial__c == null || sObjEquipment.Serial__c == '' || mapEquipmentIdToSetAllSerialNumbers.containsKey(sObjEquipment.Equipment__c) && !mapEquipmentIdToSetAllSerialNumbers.get(sObjEquipment.Equipment__c).contains(sObjEquipment.Serial__c))
	    		{
	    			lstEquipmentItemNotSyncd.add(sObjEquipment);
	    		}
	    	}
	    	if(!lstEquipmentItemNotSyncd.isEmpty())
	    	{
	    		Database.delete (lstEquipmentItemNotSyncd, false);
	    	}
		
    }*/
    
    /*!
      *  @MethodName	: upsertEquipmentAndEqipmentItem
      *  @param None	: Map of String to set of serial number and map of string to quantity field.
      *  @Description	: Insert Equipment and Equipment Item records.
    */
    /*private void upsertEquipmentAndEqipmentItem(Map<String, set<String>> mapParentIdToLstSerialNo, Map<String, Integer> mapEquipmentIdToQTY, Map<String,String> mapSchedularIdToAccountId)
    {
    	List<Equipment_Item__c> lstEquipmentItems = new List<Equipment_Item__c>(); //!< List of Equipment Item to be inserted.
    	List<Equipment__c> lstEquipment = new List<Equipment__c>(); //!< List of Equipment to be inserted.
    	
		for(String strEquipmentId : mapParentIdToLstSerialNo.keyset())
    	{
			for(String strSerialNumbers : mapParentIdToLstSerialNo.get(strEquipmentId))
    		{
    			Equipment_Item__c sObjEquipmentItem = new Equipment_Item__c();
    			sObjEquipmentItem.Serial__c = strSerialNumbers;
    			sObjEquipmentItem.Equipment__c = strEquipmentId;
    			lstEquipmentItems.add(sObjEquipmentItem);
    		}
    		
    			
    		Equipment__c sObjEquipment = new Equipment__c(Id=strEquipmentId);
    		if(mapEquipmentIdToQTY.containsKey(strEquipmentId))
    			sObjEquipment.Quantity__c = mapEquipmentIdToQTY.get(strEquipmentId);
    		
    		//Added lodhi to Equipment_c.Account__c = Equipmentc.Scheduler.Letter_of_Intentr.Account_c 
    		if(mapEquipmentIdToScheduleId.containsKey(strEquipmentId) && mapSchedularIdToAccountId.containsKey(mapEquipmentIdToScheduleId.get(strEquipmentId)))
    		{
    			sObjEquipment.Account__c = mapSchedularIdToAccountId.get(mapEquipmentIdToScheduleId.get(strEquipmentId));
    			mapEquipmentIdToScheduleId.remove(strEquipmentId);
    		}
    		
	   		lstEquipment.add(sObjEquipment);
    	}
    	
    	for(String strEquipmentId : mapEquipmentIdToScheduleId.keySet())
		{	
			if(mapEquipmentIdToScheduleId.containsKey(strEquipmentId) && mapSchedularIdToAccountId.containsKey(mapEquipmentIdToScheduleId.get(strEquipmentId)))
				lstEquipment.add(new Equipment__c(Id=strEquipmentId, Account__c= mapSchedularIdToAccountId.get(mapEquipmentIdToScheduleId.get(strEquipmentId))));
		}
    		
    	
    	if(!lstEquipment.isEmpty() && !SL_RecursionHelper.isRecursive)
    	{
    		Database.update (lstEquipment, false);
    	}
    	
    	if(!lstEquipmentItems.isEmpty())
    	{
    		Database.insert (lstEquipmentItems, false);
    	}
	}*/
	
	/*!  
      *  @MethodName	: getAccountIdToUpdateEquipmentField
      *  @param None	: Map of EquipmentId to Schedelar Id.
      *  @Description	: getting Account Id from the Schedule__c.Letter_of_Intent__r.Account__c
    */
    /*private Map<String,String> getAccountIdToUpdateEquipmentField(Map<String,String> mapEquipmentIdToSchedularId)
    {
    	Map<String,String> mapSchedularIdToAccountId = new Map<String,String>();
    	
    	for(Schedule__c objSchedule : [SELECT Id, Letter_of_Intent__r.Account__c, Letter_of_Intent__c 
    								   FROM Schedule__c 
    								   WHERE Id IN: mapEquipmentIdToSchedularId.values()])
    	{
    		mapSchedularIdToAccountId.put(objSchedule.Id, objSchedule.Letter_of_Intent__r.Account__c);
    		
    		///Lodhi ---Comment this code because the field Letter_of_Intent__r.Account__c is changed from formula to look up 
    		//String strAccountId = objSchedule.Letter_of_Intent__r.Account__c;
    		//if(objSchedule.Letter_of_Intent__r.Account__c != null)
    		//{
    		//	strAccountId = strAccountId.substring(strAccountId.indexOf('001'),strAccountId.length()-1);
    		//	strAccountId = strAccountId.substring(0,strAccountId.indexOf('"'));
    		//	mapSchedularIdToAccountId.put(objSchedule.Id, strAccountId);
    		//}
    		//else
    		//{
    		//	mapSchedularIdToAccountId.put(objSchedule.Id, null);
    		//}
    	}
    	return mapSchedularIdToAccountId;
    }*/