/**
* @ClassName    : SL_Relationship_GroupHandler   
* @JIRATicket   : HIL-17, HIL-21
* @CreatedOn    : 20/OCT/2015
* @CreatedBy	: Nrusingh
* @ModifiedBy   : Pankaj Ganwani
* @Description  : Handler class used to update the finanical accounts
*/  
public with sharing class SL_Relationship_GroupHandler 
{
	public void onAfterUpdate(Map <Id, Relationship_Group__c> oldMap, Map <Id, Relationship_Group__c> newMap)
	{
		updateFinancialAccounts(oldMap,newMap);
	}
	
	/*
        * MethodName : updateFinancialAccounts
        * Param      : (Map <Id, Relationship_Group__c> oldMap, Map <Id, Relationship_Group__c> newMap
        * Description: update financial accounts
    */ 
	private void updateFinancialAccounts(Map <Id, Relationship_Group__c> oldMap, Map <Id, Relationship_Group__c> newMap)
	{
		Map <Id, Id> mapRGIdToRepCode = new Map <Id, Id>(); 
		Map <Id, Id> mapNewRGIdToRepCode = new Map <Id, Id>(); 
		Map <Id, List<Group_Account__c>> mapHouseholdToGrpAcc = new Map <Id, List<Group_Account__c>>(); 
		List<Group_Account__c> lstUpdated = new List<Group_Account__c>(); 
		for(Relationship_Group__c objRG : newMap.values())
		{
			Relationship_Group__c objOldGM;
			if(!oldMap.isEmpty())
			{	
				objOldGM = oldMap.get(objRG.Id);
				if(objRG.Rep_Code__c != objOldGM.Rep_Code__c )
				{
					mapRGIdToRepCode.put(objRG.Id,objOldGM.Rep_Code__c );	
					mapNewRGIdToRepCode.put(objRG.Id,objRG.Rep_Code__c);
				}
			}
		}
		if(!mapRGIdToRepCode.isEmpty())
		{
			for(Group_Account__c objGA : [SELECT Id, Financial_Account__c,Relationship_Group__r.Rep_Code__c,Financial_Account__r.Rep_Code__c, Relationship_Group__c FROM Group_Account__c 
											WHERE Relationship_Group__c IN:mapRGIdToRepCode.KeySet() 
										])
			{
				if(!mapHouseholdToGrpAcc.containsKey(objGA.Relationship_Group__c))
					mapHouseholdToGrpAcc.put(objGA.Relationship_Group__c, new List<Group_Account__c>{objGA});
				else
					mapHouseholdToGrpAcc.get(objGA.Relationship_Group__c).add(objGA);
			}
			if(!mapHouseholdToGrpAcc.isEmpty())
			{
				for(Id householdId : mapRGIdToRepCode.keySet())
				{
					if(mapHouseholdToGrpAcc.containsKey(householdId))		
					{
						for(Group_Account__c obj : mapHouseholdToGrpAcc.get(householdId))
						{
							if(obj.Financial_Account__c !=null &&
							 obj.Financial_Account__r.Rep_Code__c == mapRGIdToRepCode.get(householdId)
							 && obj.Financial_Account__r.Rep_Code__c != mapNewRGIdToRepCode.get(householdId))
							 	lstUpdated.add(new Group_Account__c(Id =obj.Id, Relationship_Group__c = null));
						}
					}		
				}
			}
		}
		update lstUpdated;
		createChildSharing(mapNewRGIdToRepCode.keyset());
	}
	
	/* Start - Added by Pankaj Ganwani as per the requirement of HIL-21 on 13/OCT/2015 */
	private void createChildSharing(Set<Id> setRGIds)
	{
		//Calling opportunity trigger handler method to create sharing rules corresponding to the updated rep code.
		SL_OpportunityHandler.createSharingRule([SELECT Id, Primary_Household__c FROM Opportunity WHERE Primary_Household__c IN : setRGIds], false);
		SL_ProductsServicesHandler.createSharingRule([Select Id, Household__c From Products_Services__c WHERE Household__c IN : setRGIds], false);
		SL_InterestsHandler.createSharingRule([Select Id, Household__c From Interests__c WHERE Household__c IN : setRGIds], false);
		Relationships.createSharingRule([Select Id, Primary_Household__c From Relationship__c WHERE Primary_Household__c IN : setRGIds], false);
		SL_LiabilityHandler.createSharingRule([Select Id, Primary_Household__c From Liability__c WHERE Primary_Household__c IN : setRGIds], false);
		SL_IncomeSourceHandler.createSharingRule([Select Id, Primary_Relationship_Group__c From Income_Source__c WHERE Primary_Relationship_Group__c IN : setRGIds], false);
		SL_InsuranceHandler.createSharingRule([Select Id, Primary_Relationship_Group__c From Insurance__c WHERE Primary_Relationship_Group__c IN : setRGIds], false);
		SL_FinancialPlanHandler.createSharingRule([Select Id, Relationship_Group__c From Financial_Plan__c WHERE Relationship_Group__c IN : setRGIds], false);
		SL_DocumentHandler.createSharingRule([Select Id, Primary_Relationship_Group__c From Document__c WHERE Primary_Relationship_Group__c IN : setRGIds], false);
	}
	/* End - Added by Pankaj Ganwani as per the requirement of HIL-21 on 13/OCT/2015 */
}