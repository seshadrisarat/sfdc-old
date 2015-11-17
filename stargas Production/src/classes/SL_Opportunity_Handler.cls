/**
	*  ClassName      : SL_Opportunity_Handler
	*  JIRATicket     : STARGAS-5, STARGAS-19, STARGAS-20, STARGAS-21, STARGAS-24, STARGAS-26, STARGAS-32, STARGAS-35 and STARGAS-39
	*  CreatedOn      : 15/MAY/2014
	*  LastModifiedOn : 21/APR/2015
	*  CreatedBy      : Pankaj Ganwani
	*  ModifiedBy     : Pankaj Ganwani
	*  Description    : handler for updating the Opportunity object records with Zone data, Zone AR, Service Company, Sold by, Sold By - RepID and Owner Id
*/

public without sharing class SL_Opportunity_Handler 
{    
    /* Start - Variables */
    private static final String strEquipmentRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =:'Equipment_Sale' AND SobjectType =: 'Opportunity' LIMIT 1].Id;
    private static final String strPropaneRecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =:'Propane' AND SobjectType =: 'Opportunity' LIMIT 1].Id;
    /* End - Variables */
    
    /* Start - Constructor */
    public SL_Opportunity_Handler()
    {
    	//Do Nothing
    }
    /* End - Constructor */
    
    /*
        * MethodName        : onBeforeInsert
        * param             : list of the Opportunity records that are going to be inserted
        * Description       : This function will be called on before insert of opportunity.
    */
    public void onBeforeInsert(list<Opportunity> lstOpportunity)
    {
        //Calling function to update Opportunity
        updateOpportunity(null, lstOpportunity);
    }
    
    /*
        * MethodName        : onBeforeUpdate
        * param             : map<Opportunity> mapNewOpportunity, map<Opportunity> mapOldOpportunity
        * Description       : This function will be called on before update of opportunity.
    */
    public void onBeforeUpdate(map<Id,Opportunity> mapNewOpportunity, map<Id,Opportunity> mapOldOpportunity)
    {
        //Calling function to update Opportunity
        updateOpportunity(mapOldOpportunity,mapNewOpportunity.values());
    }
   	
   	/*
        * MethodName        : updateOpportunity
        * param             : map<Opportunity> mapNewOpportunity, list of Opportunity records
        * Description       : This function will be called on before insert and before update triggers
    */
   	private void updateOpportunity(Map<Id,Opportunity> mapIdToOpportunity, List<Opportunity> lstOpportunity)
   	{
   		Map<Id,Territory__c> mapTerritoryIdToTerritory = new Map<Id, Territory__c>();//map to contain Territory id to Territory object
   		Map<String,Decimal> mapDivisionGroupToVariablePrice = new Map<String,Decimal>();//map to hold the division group and its corresponding variable price
   		Set<String> setZoneData = new Set<String>();// Set of combined name for Zone Data
   		Set<String> setDivisionGroup = new Set<String>();// Set to hold the values of division groups corresponding to Territories of Opportunity
   		Map<String,Id> mapZoneDataToId = new Map<String,Id>();// map of ZoneData name to its corresponding Id
   		Set<Id> setTerritoryId = new Set<Id>();//Set of territory ids to fetch data from Territory object
   		Set<Id> setUserId = new Set<Id>();//set to hold the ids of sold by users if it is not null.
   		List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
   		Opportunity objOldOpportunity;//Declaring the reference of Opportunity object to contain old map value

   		//Iterating over opportunity object to check for filling sets declared above
   		for(Opportunity objOpportunity : lstOpportunity)
   		{
   			//Checking if this is the update case
   			if(mapIdToOpportunity!=null)
   			{
   				objOldOpportunity = mapIdToOpportunity.get(objOpportunity.Id);
   				setUserId.add(objOldOpportunity.CreatedById);
   			}
   			
   			
   			//Checking if opportunity is inserted or updated by comparing old map values with new maps
   			if(mapIdToOpportunity == null || (objOpportunity.ZL_Division__c != objOldOpportunity.ZL_Division__c
   											  || objOpportunity.ZL_Postal_Code__c!=objOldOpportunity.ZL_Postal_Code__c
   											  || objOpportunity.ZL_Street_Name__c!=objOldOpportunity.ZL_Street_Name__c
   											  || objOpportunity.Delivery_Street2__c != objOldOpportunity.Delivery_Street2__c
   											  || objOpportunity.Territory__c!=objOldOpportunity.Territory__c
   											  || objOpportunity.Sold_By__c!=objOldOpportunity.Sold_By__c))
   		   {
   				//Checking for nullity of Territory object
   				if(objOpportunity.Territory__c!=null)
   					setTerritoryId.add(objOpportunity.Territory__c);   				
   				
   				/* Start - This code portion comes under the functionality of STARGAS-32 */
   				if(objOpportunity.Sold_By__c!=null)
   					setUserId.add(objOpportunity.Sold_By__c);
   				/* End - This code portion comes under the functionality of STARGAS-32 */
   					
   				//Checking if division, postal code and street name is not empty
   				if(String.isNotEmpty(objOpportunity.ZL_Division__c) && String.isNotEmpty(objOpportunity.ZL_Postal_Code__c) && String.isNotEmpty(objOpportunity.ZL_Street_Name__c))
   					setZoneData.add(objOpportunity.ZL_Division__c.trim().toUpperCase() + objOpportunity.ZL_Postal_Code__c.trim().toUpperCase() + objOpportunity.ZL_Street_Name__c.trim().toUpperCase());	
   				
   				//collecting the opportunity records in a list
   				lstOpportunityToUpdate.add(objOpportunity);	  	
   		   }
   		}
   		
   		/* Start - This code portion comes under the functionality of STARGAS-32 */
   		//adding current user's id to set so that the related Sales_Rep_ID__c field value can be fetched using soql.
   		setUserId.add(Userinfo.getUserId());
   		
   		Map<Id,User> mapIdToUser = new Map<Id,User>([SELECT Id, Sales_Rep_ID__c FROM User WHERE Id IN:setUserId]);
   		/* End - This code portion comes under the functionality of STARGAS-32 */
   		
   		if(!setTerritoryId.isEmpty())
   		{
   			//Querying the data from Territory object to form a map of territory and its Id
   			for(Territory__c objTerritory : [SELECT Id, Name, Division_Service_Company__c, Division__r.Division_Oil_Pricing_Group__c, RESS_Rep__c, Oil_Rep__c, Propane_Rep__c FROM Territory__c WHERE Id IN:setTerritoryId])
   			{
   				mapTerritoryIdToTerritory.put(objTerritory.Id, objTerritory);
   				/* Start - This code portion comes under the functionality of STARGAS-35 */
   				if(objTerritory.Division__r.Division_Oil_Pricing_Group__c!=null)
   					setDivisionGroup.add(objTerritory.Division__r.Division_Oil_Pricing_Group__c);
   				/* End - This code portion comes under the functionality of STARGAS-35 */
   			}    
   		}   
        
        /* Start - This code portion comes under the functionality of STARGAS-35 */
        if(!setDivisionGroup.isEmpty())
        {
        	//fetching pricing table records corresponding to division group of related territories
        	for(Price_Table__c objPriceTable : [SELECT Variable_Price__c, Division_Group__c FROM Price_Table__c WHERE Division_Group__c IN : setDivisionGroup AND IsActive__c = true AND RecordType.DeveloperName = 'Oil' AND Variable_Price__c!=null])
        	{
        		mapDivisionGroupToVariablePrice.put(objPriceTable.Division_Group__c, objPriceTable.Variable_Price__c);
        	}
        }
        /* End - This code portion comes under the functionality of STARGAS-35 */
        
        if(!setZoneData.isEmpty())
	        //quering the Zone_Data based on the Name(combination of Opportunity ZL_Division, Postal_Code and Street_Name) and Id to the Opportunity Zone_Data field
			for(Zone_Data__c objZoneData : [select Id,Name,Delivery_Zone__c from Zone_Data__c where Name IN : setZoneData])
	    	{
	    		mapZoneDataToId.put(objZoneData.Name.toUpperCase(), objZoneData.Id);
	    	}
    	
    	if(!lstOpportunityToUpdate.isEmpty())
	    	//Iterating over opportunity object to map the values with opportunity trigger
	    	for(Opportunity objOpportunity : lstOpportunityToUpdate)
	    	{
	    		//Variable to contain value for Zone data
	    		String strZoneData = String.isNotEmpty(objOpportunity.ZL_Division__c) && String.isNotEmpty(objOpportunity.ZL_Postal_Code__c) && String.isNotEmpty(objOpportunity.ZL_Street_Name__c) ?
	    							 (objOpportunity.ZL_Division__c.trim() + objOpportunity.ZL_Postal_Code__c.trim() + objOpportunity.ZL_Street_Name__c.trim()).toUpperCase() : null;
	    		
	    		//Variable to value of territory
	    		String strTerritoryId = objOpportunity.Territory__c;
	    		Boolean isTerritoryExist = mapTerritoryIdToTerritory.containskey(strTerritoryId);
	    		
	    		//Checking  for nullity of Territory object and check TerritoryId contains or not and same as null. Then update the Opportunity's  Service Company picklist value
	    		if(strTerritoryId!=null && isTerritoryExist)
	    			objOpportunity.Service_Company_picklist__c = mapTerritoryIdToTerritory.get(strTerritoryId).Division_Service_Company__c;    		
	    		
	    		/* Start - This code portion comes under the functionality of STARGAS-32 */
	    		if(objOpportunity.Sold_By__c == NULL)
	    		{
	    			Id userId = mapIdToOpportunity!=null ? objOpportunity.CreatedById : Userinfo.getUserId();
	    			objOpportunity.Sold_By__c = userId;
	    			objOpportunity.Sold_By_RepID__c = mapIdToUser.get(userId).Sales_Rep_ID__c;
	    		}
	    		else
	    		{
	    			objOpportunity.Sold_By_RepID__c = mapIdToUser.get(objOpportunity.Sold_By__c).Sales_Rep_ID__c;
	    		}
	    		/* End - This code portion comes under the functionality of STARGAS-33 */
	    		
	    		/* Start - This code portion comes under the functionality of STARGAS-35 */
	    		objOpportunity.Variable__c = (String.isNotEmpty(strTerritoryId) && isTerritoryExist && mapDivisionGroupToVariablePrice.containskey(mapTerritoryIdToTerritory.get(strTerritoryId).Division__r.Division_Oil_Pricing_Group__c)) ? mapDivisionGroupToVariablePrice.get(mapTerritoryIdToTerritory.get(strTerritoryId).Division__r.Division_Oil_Pricing_Group__c) : null;
	    		/* End - This code portion comes under the functionality of STARGAS-35 */
	    		
	    		//Update the Opportunity's Zone Data field with ZoneData Id if ZoneData Id is not null	    		
	    		objOpportunity.Zone_Data__c = (strZoneData!=null && mapZoneDataToId.containskey(strZoneData.trim())) ? mapZoneDataToId.get(strZoneData) : null;
	    		
	    		//Checking if this is insert case
	    		if(mapIdToOpportunity == null)
	    		{
	    			if(isTerritoryExist)
	    			{
		    			//if opportunity record type is Equipment sale then assign the value of RESS_Rep__c
		    		 	if(objOpportunity.RecordTypeId == strEquipmentRecordTypeId)
		    		 	{
		    		 		 if(mapTerritoryIdToTerritory.get(strTerritoryId).RESS_Rep__c!=null)
		    				 	objOpportunity.OwnerId = mapTerritoryIdToTerritory.get(strTerritoryId).RESS_Rep__c;
		    		 	}
		    		 	//if opportunity record type is Propane then assign the value of Propane_Rep__c
		    		 	else if(objOpportunity.RecordTypeId == strPropaneRecordTypeId)
		    		 	{
		    		 		if(mapTerritoryIdToTerritory.get(strTerritoryId).Propane_Rep__c!=null)
		    		 			objOpportunity.OwnerId = mapTerritoryIdToTerritory.get(strTerritoryId).Propane_Rep__c;
		    		 	}
		    		 	//otherwise assign the value of Oil_Rep__c field
		    		 	else
		    		 	{
		    		 		if(mapTerritoryIdToTerritory.get(strTerritoryId).Oil_Rep__c!=null)
		    		 			objOpportunity.OwnerId = mapTerritoryIdToTerritory.get(strTerritoryId).Oil_Rep__c;
		    		 	}
	    			}
	    		}
	    	}
   	}
   	
   	/*
    * MethodName        : onAfterInsert
    * param             : Map of Opportunity records
    * Description       : This function will be called on after insert of Opportunity record.
    */
	public void onAfterInsert(Map<Id,Opportunity> mapOfNewOpportunity)
	{
		//calling function to create service contract records and update opportunity
		createServiceContracts(null,mapOfNewOpportunity);
	}
	
	/*
    * MethodName        : onAfterUpdate
    * param             : map of old and new opportunity records
    * Description       : This function will be called on after insert of Opportunity record.
    */
	public void onAfterUpdate(Map<Id,Opportunity> mapOfOldOpportunity, Map<Id,Opportunity> mapOfNewOpportunity)
	{
		//calling function to create service contract records and update opportunity
		createServiceContracts(mapOfOldOpportunity,mapOfNewOpportunity);
	}
	
	private void createServiceContracts(Map<Id,Opportunity> mapOfOldOpportunity, Map<Id,Opportunity> mapOfNewOpportunity)
	{
		Map<Id,Id> mapOppIdToAccId = new Map<Id,Id>();//map of opportunity id to account id
		Set<Id> setRecordType = new Set<Id>();// set to contain record type values of oil, propane and service only
		List<Service_Contract__c> lstServiceContract = new List<Service_Contract__c>(); //list of service contract records
  		Map<Id,String> mapOppIdToZoneAR = new Map<Id,String>();
		if(mapOfOldOpportunity == null)
		{
			//Iterating over record type to contain record type and its developer name
			for(RecordType objrecordType : [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN ('Oil','Propane','Service_Only') AND SobjectType =: 'Opportunity'])
			{
				setRecordType.add(objrecordType.Id);
			}
	 
			//Iterating over opportunity object to fill the map with source client Id with its corresponding last opportunity id
			for(Opportunity objOpportunity : [SELECT Id,RecordTypeId, ZL_ZoneAR_Lookup_Value__c, Account.RecordType.DeveloperName, Account.Source_Client_Account__c, Account.Service_Contract_Is_Transferrable__c, Service_Contract_Is_Transferrable__c, AccountId
											  FROM Opportunity 
											  WHERE Id IN: mapOfNewOpportunity.keySet() 
											  ORDER BY CreatedDate])
			{
				if(setRecordType.contains(objOpportunity.RecordTypeId))
				{
					if(objOpportunity.Account.RecordType.DeveloperName == 'Prospect' && objOpportunity.Account.Service_Contract_Is_Transferrable__c && objOpportunity.Service_Contract_Is_Transferrable__c)
						mapOppIdToAccId.put(objOpportunity.Account.Source_Client_Account__c,objOpportunity.Id);
					else if(objOpportunity.Account.RecordType.DeveloperName == 'Energy_Account')
						mapOppIdToAccId.put(objOpportunity.AccountId,objOpportunity.Id);		
				}			
				mapOppIdToZoneAR.put(objOpportunity.Id, objOpportunity.ZL_ZoneAR_Lookup_Value__c);
			}
			//Fetching the service contract records corresponding to the map key set collected above and performing mapping of Associated_Opportunity__c with opportunity id
			for(Service_Contract__c objSC : [SELECT Id, Client_Prospect__c,Associated_Opportunity__c 
											 FROM   Service_Contract__c 
											 WHERE  Client_Prospect__c IN: mapOppIdToAccId.keyset()])
			{
				lstServiceContract.add(new Service_Contract__c(Id = objSC.Id, Associated_Opportunity__c = mapOppIdToAccId.get(objSC.Client_Prospect__c)));
			}
			update lstServiceContract;
		}
		else
		{
			for(Opportunity objOpportunity : mapOfNewOpportunity.values())
			{
				if(objOpportunity.ZL_ZoneAR_Lookup_Value__c!=mapOfOldOpportunity.get(objOpportunity.Id).ZL_ZoneAR_Lookup_Value__c)
					mapOppIdToZoneAR.put(objOpportunity.Id, objOpportunity.ZL_ZoneAR_Lookup_Value__c);
			}
		}
		
		if(!mapOppIdToZoneAR.isEmpty())
			updateOpportunity(mapOppIdToZoneAR);
	}
	
	private void updateOpportunity(Map<Id,String> mapOppIdToZoneAR)
	{
		List<Opportunity> lstOpportunity = new List<Opportunity>();
		Map<String,Id> mapZoneARToId = new Map<String,Id>();
		Set<String> setZoneAR = new Set<String>(mapOppIdToZoneAR.values());
		if(setZoneAR.contains(null))
			setZoneAR.remove(null);
		//quering the Zone_AR__c based on the ZL_ZoneAR_Lookup_Value__c field value
		for(Zone_AR__c objZoneAR : [select Id,Name from Zone_AR__c WHERE Name IN : setZoneAR])
    	{	
    		mapZoneARToId.put(objZoneAR.Name, objZoneAR.Id);
    	}
		
		for(Id OpportunityId : mapOppIdToZoneAR.keyset())
		{
			lstOpportunity.add(new Opportunity(Id = OpportunityId, Zone_AR__c = mapOppIdToZoneAR.get(OpportunityId)!=null && mapZoneARToId.containskey(mapOppIdToZoneAR.get(OpportunityId)) ? mapZoneARToId.get(mapOppIdToZoneAR.get(OpportunityId)) : null));
		}
		update lstOpportunity;
	}
}