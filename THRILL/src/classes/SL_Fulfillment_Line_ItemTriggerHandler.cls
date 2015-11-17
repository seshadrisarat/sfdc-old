/**  
* \arg ClassName        : SL_Fulfillment_Line_ItemTriggerHandler
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Handler class for Fulfillment_Line_Item object.
*/
global class SL_Fulfillment_Line_ItemTriggerHandler extends SL_TriggerHandlerBase {

	public static final String STR_ERROR = 'The Industry Already Exists.';
	
	public override void beforeInsert(List<SObject> newListGeneric){
		List<Fulfillment_Line_Item__c> newList = (List<Fulfillment_Line_Item__c>) newListGeneric;
		/*BEFORE INSERT METHODS START*/
		checkDuplicateIndustryForSameGeoPoint(newList);
		/*BEFORE INSERT METHODS END*/
	}
	
	private void checkDuplicateIndustryForSameGeoPoint(List<Fulfillment_Line_Item__c> newList)
	{
		Map<Id, List<Fulfillment_Line_Item__c>> mapOfGeoMarketToListOfFulFilmentRecs = new Map<Id, List<Fulfillment_Line_Item__c>>();
		Set<Id> setOfInventoryOrderLine = new Set<Id>();
		Map<Id, Set<String>> mapOfGeoMarketToIndustryValues = new Map<Id, Set<String>>(); 
		
		Map<Id, Set<String>> mapGeoMarketToSetOfAccount = new Map<Id, Set<String>>();
		Map<Id, Set<String>> mapGeoMarketToSetOfIndustry = new Map<Id, Set<String>>();
		

		for(Fulfillment_Line_Item__c objFulfillmentLineItem : newList)
		{
			if(objFulfillmentLineItem.Geo_Market__c != NULL)
			{
				if(!mapOfGeoMarketToListOfFulFilmentRecs.containsKey(objFulfillmentLineItem.Geo_Market__c))
					mapOfGeoMarketToListOfFulFilmentRecs.put(objFulfillmentLineItem.Geo_Market__c, new List<Fulfillment_Line_Item__c>());
				
				mapOfGeoMarketToListOfFulFilmentRecs.get(objFulfillmentLineItem.Geo_Market__c).add(objFulfillmentLineItem);

				setOfInventoryOrderLine.add(objFulfillmentLineItem.Inventory_Order_Line__c);
			}	
		}

		if(mapOfGeoMarketToListOfFulFilmentRecs.isEmpty())
			return;

		mapOfGeoMarketToIndustryValues = collectSiblingIndustries(mapOfGeoMarketToListOfFulFilmentRecs.keySet());
		
		/* Start - Added By Pankaj Ganwani for handling the case when both Account and Industry field values are different on inserted Fulfillment line item record */
		for(Id geoMarketId : mapOfGeoMarketToIndustryValues.keySet())
		{
			for(String strAccountIndustryValue : mapOfGeoMarketToIndustryValues.get(geoMarketId))
			{
				String[] arrayAccountIndustryValue = strAccountIndustryValue.split('_');
				String accountId = arrayAccountIndustryValue[0];
				String accountIndustry = arrayAccountIndustryValue[1];
				
				if(!mapGeoMarketToSetOfAccount.containskey(geoMarketId))
					mapGeoMarketToSetOfAccount.put(geoMarketId, new Set<String>{accountId});
				else
					mapGeoMarketToSetOfAccount.get(geoMarketId).add(accountId);
					
				if(!mapGeoMarketToSetOfIndustry.containskey(geoMarketId))
					mapGeoMarketToSetOfIndustry.put(geoMarketId, new Set<String>{accountIndustry});
				else
					mapGeoMarketToSetOfIndustry.get(geoMarketId).add(accountIndustry);
			}
		}
		/* End - Added By Pankaj Ganwani for handling the case when both Account and Industry field values are different on inserted Fulfillment line item record */
		
		if(!mapOfGeoMarketToIndustryValues.isEmpty())
		{
			Map<Id, String> mapOfFullFillItemToIndustry = new Map<Id, String>();
			mapOfFullFillItemToIndustry = collectCurrentIndustries(setOfInventoryOrderLine, newList);


			for(Id geoIds : mapOfGeoMarketToListOfFulFilmentRecs.keySet())
			{
				for(Fulfillment_Line_Item__c objFulFilLineItem : mapOfGeoMarketToListOfFulFilmentRecs.get(geoIds))
				{
					if(mapOfFullFillItemToIndustry.containsKey(objFulFilLineItem.Inventory_Order_Line__c))
					{
						String strCurrentIndustry = mapOfFullFillItemToIndustry.get(objFulFilLineItem.Inventory_Order_Line__c);
						String [] strCurrentAccountIndustry = strCurrentIndustry.split('_');						
						
						if(mapOfGeoMarketToIndustryValues.containsKey(objFulFilLineItem.Geo_Market__c) && mapGeoMarketToSetOfIndustry.get(objFulFilLineItem.Geo_Market__c).contains(strCurrentAccountIndustry[1]) && !mapGeoMarketToSetOfAccount.get(objFulFilLineItem.Geo_Market__c).contains(strCurrentAccountIndustry[0]))
						{
							objFulFilLineItem.addError(STR_ERROR); 
						}
					}	
				}				
			}
		}
	}

	private Map<Id, Set<String>> collectSiblingIndustries(Set<Id> setOfGeoPointIds)
	{
		Map<Id, Set<String>> mapOfGeoMarketToIndustryValues = new Map<Id, Set<String>>();
		Set<Id> setOfOppLineItemIds = new Set<Id>();
		Set<Id> setOfFulFillItemsCreatedToday = new Set<Id>();
		Map<Id, String> mapOfOppIdToAccIndustry = new Map<Id, String>();

		for(Fulfillment_Line_Item__c objOldFullFillLineItems : [Select Id, Geo_Market__c, Inventory_Order_Line__c, Inventory_Order_Line__r.OpportunityProduct_Id__c 
																From Fulfillment_Line_Item__c 
																Where Geo_Market__c IN : setOfGeoPointIds 
																		AND CreatedDate = TODAY 
																		AND Inventory_Order_Line__c != NULL 
																		AND Inventory_Order_Line__r.OpportunityProduct_Id__c != NULL])
		{
			setOfOppLineItemIds.add(objOldFullFillLineItems.Inventory_Order_Line__r.OpportunityProduct_Id__c);
			setOfFulFillItemsCreatedToday.add(objOldFullFillLineItems.Id);
		}
		  
		  
		for(OpportunityLineItem objOLI: [Select Id, OpportunityId, Opportunity.Account.Industry 
											From OpportunityLineItem 
											Where Id IN : setOfOppLineItemIds 
													AND Opportunity.Account.Industry != NULL])
		{
			mapOfOppIdToAccIndustry.put(objOLI.Id, objOLI.Opportunity.AccountId + '_' +objOLI.Opportunity.Account.Industry);
		}
		
		  
		for(Fulfillment_Line_Item__c objFulDilLineItem : [select Id, Geo_Market__c, Inventory_Order_Line__r.OpportunityProduct_Id__c 
															From Fulfillment_Line_Item__c 
															Where ID IN : setOfFulFillItemsCreatedToday ])
		{
			if(mapOfOppIdToAccIndustry.containsKey(objFulDilLineItem.Inventory_Order_Line__r.OpportunityProduct_Id__c)) {
				if(!mapOfGeoMarketToIndustryValues.containsKey(objFulDilLineItem.Geo_Market__c))
						mapOfGeoMarketToIndustryValues.put(objFulDilLineItem.Geo_Market__c, new set<string>());
					
				mapOfGeoMarketToIndustryValues.get(objFulDilLineItem.Geo_Market__c).add(mapOfOppIdToAccIndustry.get(objFulDilLineItem.Inventory_Order_Line__r.OpportunityProduct_Id__c));
			}
		}
		return mapOfGeoMarketToIndustryValues;
	}


	public Map<Id, String> collectCurrentIndustries(Set<Id> setOfInventoryOrderLine, List<Fulfillment_Line_Item__c> newList)
	{
		Map<Id, List<Inventory_Order_Line__c>> mapOfOppLineIteToInvIds = new Map<Id, List<Inventory_Order_Line__c>>();
		Map<Id, String> mapOfInventoryIdToIndustries = new Map<Id, String>();

		for(Inventory_Order_Line__c objInventoryOrderLine : [Select Id, OpportunityProduct_Id__c 
																From Inventory_Order_Line__c 
																Where Id IN : setOfInventoryOrderLine 
																		AND OpportunityProduct_Id__c != NULL])
		{
			if(!mapOfOppLineIteToInvIds.containsKey(objInventoryOrderLine.OpportunityProduct_Id__c))
					mapOfOppLineIteToInvIds.put(objInventoryOrderLine.OpportunityProduct_Id__c, new List<Inventory_Order_Line__c>());
				
				mapOfOppLineIteToInvIds.get(objInventoryOrderLine.OpportunityProduct_Id__c).add(objInventoryOrderLine);
		}

		for(OpportunityLineItem objOLI: [Select Id, OpportunityId, Opportunity.Account.Industry 
											From OpportunityLineItem 
											Where Id IN : mapOfOppLineIteToInvIds.keySet() 
												AND Opportunity.Account.Industry != NULL])
		{
			for(Inventory_Order_Line__c objInvOrderLine : mapOfOppLineIteToInvIds.get(objOLI.Id))
			{
				mapOfInventoryIdToIndustries.put(objInvOrderLine.Id, objOLI.Opportunity.AccountId + '_' +objOLI.Opportunity.Account.Industry);
			}
		}
		return mapOfInventoryIdToIndustries;
	} 


	public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Fulfillment_Line_Item__c> oldMap = (Map<Id, Fulfillment_Line_Item__c>) oldMapGeneric;
		Map<Id, Fulfillment_Line_Item__c> newMap = (Map<Id, Fulfillment_Line_Item__c>) newMapGeneric;
		/*BEFORE UPDATE METHODS START*/
		
		/*BEFORE UPDATE METHODS END*/
	}
	
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Fulfillment_Line_Item__c> oldMap = (Map<Id, Fulfillment_Line_Item__c>) oldMapGeneric;
		/*BEFORE DELETE METHODS START*/
		
		/*BEFORE DELETE METHODS END*/
	}
	
	public override void afterInsert(Map<Id, SObject> newMapGeneric){
		Map<Id, Fulfillment_Line_Item__c> newMap = (Map<Id, Fulfillment_Line_Item__c>) newMapGeneric;
		/*AFTER INSERT METHODS START*/
		
		/*AFTER INSERT METHODS END*/
	}
	
	public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Fulfillment_Line_Item__c> oldMap = (Map<Id, Fulfillment_Line_Item__c>) oldMapGeneric;
		Map<Id, Fulfillment_Line_Item__c> newMap = (Map<Id, Fulfillment_Line_Item__c>) newMapGeneric;
		/*AFTER UPDATE METHODS START*/
		
		/*AFTER UPDATE METHODS END*/
	}
	
	public override void afterDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Fulfillment_Line_Item__c> oldMap = (Map<Id, Fulfillment_Line_Item__c>) oldMapGeneric;
		/*AFTER DELETE METHODS START*/
		
		/*AFTER DELETE METHODS END*/
	}
	
	public override void afterUndelete(Map<Id, SObject> newMapGeneric){
		Map<Id, Fulfillment_Line_Item__c> newMap = (Map<Id, Fulfillment_Line_Item__c>) newMapGeneric;
		/*AFTER UNDELETE METHODS START*/
		
		/*AFTER UNDELETE METHODS END*/
	}
	
}