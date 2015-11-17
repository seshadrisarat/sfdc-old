/**
*  ClassName      		: SL_ProspectServiceContractHandler
*  JIRATicket    	    : STARGAS-37
*  CreatedOn      		: 24/MAR/2015
*  LastModifiedOn       : 23/APR/2015
*  ModifiedBy     		: Pankaj Ganwani
*  Description    		: This class serves as trigger handler for prospect service contract trigger.
*/
public with sharing class SL_ProspectServiceContractHandler 
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_ProspectServiceContractHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	/*
        * MethodName        : onAfterInsert
        * param             : list of inserted prospect service contract records
        * Description       : This function will be called on after insert event of trigger to update the related Opportunity with recently inserted record
    */
	public static void onAfterInsert(List<Prospect_Service_Contract__c> lstPSC)
	{
		updateOpportunity(lstPSC, NULL);
	}
	
	/*
        * MethodName        : onAfterUpdate
        * param             : old and new map of prospect service contract records
        * Description       : This function will be called on after update event of trigger to update the related Opportunity with recently updated record.
    */
	public static void onAfterUpdate(Map<Id, Prospect_Service_Contract__c> mapOldPSC, Map<Id, Prospect_Service_Contract__c> mapNewPSC)
	{
		List<Prospect_Service_Contract__c> lstPSC = new List<Prospect_Service_Contract__c>();
		
		for(Prospect_Service_Contract__c objPSC : mapNewPSC.values())
		{
			if(objPSC.Service_Plan_Code__c!=mapOldPSC.get(objPSC.Id).Service_Plan_Code__c || objPSC.Expiration_Renewal_Date__c!=mapOldPSC.get(objPSC.Id).Expiration_Renewal_Date__c 
			|| objPSC.Start_Date_formula__c!=mapOldPSC.get(objPSC.Id).Start_Date_formula__c || objPSC.Energy_Price__c!=mapOldPSC.get(objPSC.Id).Energy_Price__c 
			|| objPSC.CARE_Transfer_Price__c!=mapOldPSC.get(objPSC.Id).CARE_Transfer_Price__c || objPSC.Do_you_want_CARE__c!=mapOldPSC.get(objPSC.Id).Do_you_want_CARE__c 
			|| objPSC.Transfer_CARE__c!=mapOldPSC.get(objPSC.Id).Transfer_CARE__c || objPSC.Tank_Type_Location__c!=mapOldPSC.get(objPSC.Id).Tank_Type_Location__c 
			|| objPSC.Prior_release_of_fuel_from_your_system__c!=mapOldPSC.get(objPSC.Id).Prior_release_of_fuel_from_your_system__c 
			|| objPSC.Prior_release_of_fuel_on_your_property__c!=mapOldPSC.get(objPSC.Id).Prior_release_of_fuel_on_your_property__c)
			
			{
				lstPSC.add(objPSC);
			}
		}
		
		if(!lstPSC.isEmpty())
			updateOpportunity(lstPSC, NULL);
	}
	
	public static void onAfterDelete(List<Prospect_Service_Contract__c> lstPSC)
	{
		Set<Id> setOpportunityId = new Set<Id>();// set to hold the opportunity ids of those records, we have to find next most recent prospect service contract record for.
		
		//Iterating over list of deleted PRC records to hold the opportunity ids.
		for(Prospect_Service_Contract__c objPSC : lstPSC)
			setOpportunityId.add(objPSC.Opportunity__c);
		
		if(!setOpportunityId.isEmpty())
			updateOpportunity(NULL, setOpportunityId);
	}
	
	/*
        * MethodName        : updateOpportunity
        * param             : list of prospect service contract records
        * Description       : This function will be called from both onafterinsert and onafterupdate functions to update the opportunity records.
    */
	private static void updateOpportunity(List<Prospect_Service_Contract__c> lstPSC, Set<Id> setOpportunityId)
	{
		Map<Id, Opportunity> mapIdToOpportunity = new Map<Id, Opportunity>();//This list contains those opportunity,which needs to be updated
		
		for(Prospect_Service_Contract__c objPSC : !Trigger.isDelete ? [SELECT Service_Plan_Code__r.Service_Contract_Code__c, Opportunity__c, Expiration_Renewal_Date__c, Start_Date_formula__c, Energy_Price__c, CARE_Transfer_Price__c, Do_you_want_CARE__c, Transfer_CARE__c, Tank_Type_Location__c, Prior_release_of_fuel_from_your_system__c, Prior_release_of_fuel_on_your_property__c FROM Prospect_Service_Contract__c WHERE Id IN:lstPSC ORDER BY LastModifiedDate]
												    				: [SELECT Service_Plan_Code__r.Service_Contract_Code__c, Opportunity__c, Expiration_Renewal_Date__c, Start_Date_formula__c, Energy_Price__c, CARE_Transfer_Price__c, Do_you_want_CARE__c, Transfer_CARE__c, Tank_Type_Location__c, Prior_release_of_fuel_from_your_system__c, Prior_release_of_fuel_on_your_property__c FROM Prospect_Service_Contract__c WHERE Opportunity__c IN:setOpportunityId ORDER BY LastModifiedDate])
		{
			mapIdToOpportunity.put(objPSC.Opportunity__c, new Opportunity(Id = objPSC.Opportunity__c, 
																		  Service_Contract_Code__c = objPSC.Service_Plan_Code__r.Service_Contract_Code__c, 
																		  Service_Contract_Expiration_Date__c = objPSC.Expiration_Renewal_Date__c, 
																		  Service_Contract_Start_Date__c = objPSC.Start_Date_formula__c, 
																		  Service_Contract_Amount__c = objPSC.Energy_Price__c,
																		  CARE_Transfer_Price__c = objPSC.CARE_Transfer_Price__c,
																		  Do_you_want_CARE__c = objPSC.Do_you_want_CARE__c,
																		  Tank_Type_Location_Service__c = objPSC.Tank_Type_Location__c,
																		  Prior_System__c = objPSC.Prior_release_of_fuel_from_your_system__c,
																		  Prior_Property__c = objPSC.Prior_release_of_fuel_on_your_property__c,
																		  Transfer_CARE__c = objPSC.Transfer_CARE__c ? 'Yes' : 'No'));
		}
		
		if(Trigger.isDelete)
		{
			for(Id opportunityId : setOpportunityId)
			{
				if(!mapIdToOpportunity.containskey(opportunityId))
					mapIdToOpportunity.put(opportunityId, new Opportunity(Id = opportunityId, 
																		  Service_Contract_Code__c = NULL, 
																		  Service_Contract_Expiration_Date__c = NULL, 
																		  Service_Contract_Start_Date__c = NULL, 
																		  Service_Contract_Amount__c = NULL,
																		  CARE_Transfer_Price__c = NULL,
																		  Do_you_want_CARE__c = NULL,
																		  Tank_Type_Location_Service__c = NULL,
																		  Prior_System__c = NULL,
																		  Prior_Property__c = NULL,
																		  Transfer_CARE__c = NULL));
			}
		}
		
		if(!mapIdToOpportunity.isEmpty())
			update mapIdToOpportunity.values();
	}
}