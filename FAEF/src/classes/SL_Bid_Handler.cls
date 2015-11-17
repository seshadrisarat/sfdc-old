/**
* \arg \b ClassName      : SL_Bid_Handler
* \arg \b JIRATicket     : FAEF-31
* \arg \b CreatedOn      : 12/Sep/2014
* \arg \b ModifiedBy     : Harsh
* \arg \b Description    : This is the handler class for dlrs_BidTrigger trigger to prevent the actions occuring for avoiding duplicate values.	
*/
public without sharing class SL_Bid_Handler 
{
	public static Final String strTypePickListValueForProceed = '3rd Party Equipment Sale';
	
	public static final String BID_STATUS_WON = 'Won';
	
	//Constructor of a Handler Class
	public SL_Bid_Handler()
	{
		/* Do nothing. */
	}
	
	/*
	    * MethodName 	: onAfterInsert.
	    * param 		: Map<Id, Bid__c> mapNewBidRecords
	    * Description	: This function will call After Insert of the Bid__c.
    */
	public void  onAfterInsert(Map<Id, Bid__c> mapNewBidRecords)
	{
		List<Bid__c> lstBidsToProcess = new List<Bid__c>();
    	for(Bid__c objBid : mapNewBidRecords.values())
    	{
    		if(objBid.Status__c == BID_STATUS_WON)
				lstBidsToProcess.add(objBid);
    	}
    	
    	if(!lstBidsToProcess.isEmpty())
    		createProceedRecordsAndMapWithEquipment(lstBidsToProcess);
	}
	
	/*
	    * MethodName 	: onBeforeUpdate.
	    * param 		: Map<Id, Bid__c> mapOldBidRecords, Map<Id, Bid__c> mapNewBidRecords
	    * Description	: This function will call Before Update of the Bid__c.
    */
    public void onAfterUpdate(Map<Id, Bid__c> mapOldBidRecords, Map<Id, Bid__c> mapNewBidRecords)
    {
    	List<Bid__c> lstBidsToProcess = new List<Bid__c>();
    	for(Bid__c objBid : mapNewBidRecords.values())
    	{
    		if(objBid.Status__c == BID_STATUS_WON && objBid.Status__c != mapOldBidRecords.get(objBid.Id).Status__c)
				lstBidsToProcess.add(objBid);
    	}
    	
    	if(!lstBidsToProcess.isEmpty())
    		createProceedRecordsAndMapWithEquipment(lstBidsToProcess);
    }
    
    /*
	    * MethodName 	: createProceedRecordsAndMapWithEquipment.
	    * param 		: List<Bid__c> lstBidsToProcess
	    * Description	: This function will create a proceed record and update the Equipment records.
    */
    private void createProceedRecordsAndMapWithEquipment(List<Bid__c> lstBidsToProcess)
    {
    	Map<Id, Id> MapOfEquimentIdToBidIds = new MAP<Id, Id>();								// Map is used to keep Equipment Id to BidIds
    	Map<Id, set<Id>> MapOfBidIdToListOfScheduleIds = new Map<Id, set<Id>>();				// Map is used to keep BidIds to list of scheduledIds
    	Map<Id, Double> mapBidIdToWonAmount = new Map<Id, Double>();
    	
    	List<Bid_Item__c> lstBidItemToUpdate = new List<Bid_Item__c>();
    	
    	
    	Map<String, Id> mapOfBidToSchIdIdToProceesId = new Map<String, Id>();		// Map to keep the BidId to newly Inserted Proceed Ids
    	
    	List<Proceeds__c> lstProceedToInsert = new List<Proceeds__c>();		// Set to keep the list of Proceed records to insert
    	List<Equipment__c> lstEquipmenToUpdate = new List<Equipment__c>();	// Set to keep the list of Equipment records to Update
    	
    	// Iterating on BidItems to add the BidItem.Equipment__c in to the setOfEquimentIds
    	for(Bid_Item__c objBdItem : [Select Id, Bid__c, Lot_Item__c, Bid_Item_Amount__c, Lot_Item__r.Equipment__c From Bid_Item__c 
									  Where Bid__c IN : lstBidsToProcess 
									   AND Lot_Item__r.Equipment__c != NULL])
		{
			MapOfEquimentIdToBidIds.put(objBdItem.Lot_Item__r.Equipment__c, objBdItem.Bid__c);
			
			if(!mapBidIdToWonAmount.containsKey(objBdItem.Bid__c))
				mapBidIdToWonAmount.put(objBdItem.Bid__c, 0);
			
			if(objBdItem.Bid_Item_Amount__c != null)	
				mapBidIdToWonAmount.put(objBdItem.Bid__c, mapBidIdToWonAmount.get(objBdItem.Bid__c) + objBdItem.Bid_Item_Amount__c);
			
			lstBidItemToUpdate.add(new Bid_Item__c(Id = objBdItem.Id, Status__c = 'Won'));
		}
		
		// Adding ScheuduleId to List Of Equipment records into the mapOfScheduledIdsToListOfEquipments
		if(!MapOfEquimentIdToBidIds.isEmpty()){
			for(Equipment__c objEqp : [Select Id, Schedule__c From Equipment__c Where Id IN: MapOfEquimentIdToBidIds.keySet()])
			{
				if(!MapOfBidIdToListOfScheduleIds.containsKey(MapOfEquimentIdToBidIds.get(objEqp.Id)))
					MapOfBidIdToListOfScheduleIds.put(MapOfEquimentIdToBidIds.get(objEqp.Id), new set<Id>{objEqp.Schedule__c});
				else
					MapOfBidIdToListOfScheduleIds.get(MapOfEquimentIdToBidIds.get(objEqp.Id)).add(objEqp.Schedule__c);
			}
		}
		
		
    	// Iterating over new bid records to create Proceed records
		for(Bid__c objBid : lstBidsToProcess)
		{
			If(MapOfBidIdToListOfScheduleIds.containsKey(objBid.Id))
			{
				for(String strScheduleIds : MapOfBidIdToListOfScheduleIds.get(objBid.Id))
				{
					Proceeds__c objNewProceed = new Proceeds__c(Amount__c = (mapBidIdToWonAmount.containsKey(objBid.Id)) 
																				? mapBidIdToWonAmount.get(objBid.Id) / MapOfBidIdToListOfScheduleIds.get(objBid.Id).size() : 0,
															   Date_Posted__c = Date.Today(),
															   Type__c = strTypePickListValueForProceed,
															   Schedule__c = strScheduleIds,
															   Bid__c = objBid.Id); 
					
					lstProceedToInsert.add(objNewProceed);
				}
			}
		}
		
		Database.SaveResult[] lstBidItemToUpdateResult;
		try{
			if(!lstBidItemToUpdate.isEmpty())
				lstBidItemToUpdateResult = 	Database.update(lstBidItemToUpdate, false);
		}
		catch(DMLException ex){
			Set<Id> setOfBidIdsForErrorShown = new Set<Id>();
    		Set<Id> setOfBidItemUpdateIds = new Set<Id>();
    		
    		// iterating on Database.saveResult to get the successed ProceedIds
    		for (Database.SaveResult saveResult : lstBidItemToUpdateResult) {
    			if(saveResult.isSuccess())
    				setOfBidItemUpdateIds.add(saveResult.getId());
    		}
    		
    		// Checking for all prceeds that are in lstProceedToInsert
			for(Bid_Item__c objBidItem : lstBidItemToUpdate)
    		{
    			if(!setOfBidItemUpdateIds.contains(objBidItem.Id))
    				setOfBidIdsForErrorShown.add(objBidItem.Bid__c);
    		}
    		
    		if(!setOfBidIdsForErrorShown.isEmpty())
    		{
    			for(Bid__c objBid : lstBidsToProcess)
    			{
    				if(setOfBidIdsForErrorShown.contains(objBid.Id))
    					objBid.addError(ex.getMEssage());
    			}
    		}
    		
		}
		
    	Database.SaveResult[] lstProceedsInsertionResult;
    	try{
	    	// Inserting Proceed records
			If(!lstProceedToInsert.isEmpty())
				lstProceedsInsertionResult = Database.insert(lstProceedToInsert, false);
    	}
    	catch(system.DMLException ex){
    		Set<Id> setOfBidIdsForErrorShown = new Set<Id>();
    		Set<Id> setOfInsertedProceedIds = new Set<Id>();
    		
    		// iterating on Database.saveResult to get the successed ProceedIds
    		for (Database.SaveResult saveResult : lstProceedsInsertionResult) {
    			if(saveResult.isSuccess())
    				setOfInsertedProceedIds.add(saveResult.getId());
    		}
    		
    		// Checking for all prceeds that are in lstProceedToInsert
			for(Proceeds__c objProceed : lstProceedToInsert)
    		{
    			if(!setOfInsertedProceedIds.contains(objProceed.Id))
    				setOfBidIdsForErrorShown.add(objProceed.Bid__c);
    		}
    		
    		if(!setOfBidIdsForErrorShown.isEmpty())
    		{
    			for(Bid__c objBid : lstBidsToProcess)
    			{
    				if(setOfBidIdsForErrorShown.contains(objBid.Id))
    					objBid.addError(ex.getMEssage());
    			}
    		}
    	}	
    	
    	
    	if(!lstProceedToInsert.isEmpty()){
			for(Proceeds__c ojProceed : lstProceedToInsert)
				mapOfBidToSchIdIdToProceesId.put(ojProceed.Bid__c+'-'+ojProceed.Schedule__c, ojProceed.Id);
    	}
		
		// Updating the Equipments
		for(Equipment__c objEqup : [Select Id, Schedule__c From Equipment__c Where Id IN: MapOfEquimentIdToBidIds.keySet()])
		{
			// Checking the mapOfBidToSchIdIdToProceesId contains the combination of the Bid-ObjEqp.Schedule__c and then updating the corresponding Equipments
			if(mapOfBidToSchIdIdToProceesId.containsKey(MapOfEquimentIdToBidIds.get(objEqup.Id)+ '-' + objEqup.Schedule__c)){
				objEqup.Proceed_For_Won_Auction__c = mapOfBidToSchIdIdToProceesId.get(MapOfEquimentIdToBidIds.get(objEqup.Id)+ '-' + objEqup.Schedule__c);
				objEqup.Status__c = strTypePickListValueForProceed;
				lstEquipmenToUpdate.add(objEqup);
			}
		}
		Database.SaveResult[] lstEqupUpdateResult;
		try{
			// Updating Equipment records
			If(!lstEquipmenToUpdate.isEmpty())
				lstEqupUpdateResult = Database.update(lstEquipmenToUpdate, false);
		}
		catch(DMLException ex){
			Set<Id> setOfBidIdsForErrorShown = new Set<Id>();
			Set<Id> setOfUpdatedEqupIds = new Set<Id>();
    		
    		// iterating on Database.saveResult to get the successed ProceedIds
    		for (Database.SaveResult saveResult : lstEqupUpdateResult) {
    			if(saveResult.isSuccess())
    				setOfUpdatedEqupIds.add(saveResult.getId());
    		}
    		
    		// Getting the Bid Id from the unsuccessed Equp records checkin for all equpment that are going to update from this lstEquipmenToUpdate
			for(Equipment__c objEqp : lstEquipmenToUpdate)
    		{
    			if( MapOfEquimentIdToBidIds.containsKey(objEqp.Id) && !setOfUpdatedEqupIds.contains(objEqp.Id) )
    				setOfBidIdsForErrorShown.add(MapOfEquimentIdToBidIds.get(objEqp.Id));
    		}
    		
    		// Showing Error Message on the triggered Bid records
    		if(!setOfBidIdsForErrorShown.isEmpty())
    		{
    			for(Bid__c objBid : lstBidsToProcess)
    			{
    				if(setOfBidIdsForErrorShown.contains(objBid.Id))
    					objBid.addError(ex.getMEssage());
    			}
    		}
		}
    }
}