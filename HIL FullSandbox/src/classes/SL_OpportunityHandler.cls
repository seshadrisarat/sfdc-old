/**
* \arg ClassName      		: SL_OpportunityHandler
* \arg JIRATicket       	: HIL-21
* \arg CreatedOn        	: 12/OCT/2015
* \arg LastModifiedOn   	: 13/OCT/2015
* \arg CreatededBy      	: Pankaj Ganwani
* \arg LastModifiedBy       : Pankaj Ganwani
* \arg Description      	: Opportunity trigger Handler for updating the household field value on inserted Opportunity record and creation of sharing records based on the values of Rep Codes.
*/
public class SL_OpportunityHandler
{
	/* Start - Constructor */
    public SL_OpportunityHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Opportunity> lstNewOpportunities)
    {
        updateOpp_Household(lstNewOpportunities);
    }
    
    public static void onAfterInsert(List <Opportunity> lstNewOpportunities)
    {
        createSharingRule(lstNewOpportunities, true);
    }
    
    private static void updateOpp_Household(List<Opportunity> lstOpportunities)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        List<Opportunity> lstFilteredOpp = new List<Opportunity>();
        
        for(Opportunity objOpportunity : lstOpportunities)
        {
        	if(objOpportunity.AccountId!=NULL)
        	{
        		setAccountIds.add(objOpportunity.AccountId);
        		lstFilteredOpp.add(objOpportunity);
        	}
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Opportunity objOpportunity : lstFilteredOpp)
        {
        	if(mapAccIdToHousehold.containskey(objOpportunity.AccountId))
        		objOpportunity.Primary_Household__c = mapAccIdToHousehold.get(objOpportunity.AccountId);
        }
    }
    
    //This method will also be called from Household trigger handler when rep code is modified on the corresponding household record.
    public static void createSharingRule(List<Opportunity> lstNewOpportunities, Boolean isOppTrigger)
    {
        Map<Id,Id> mapOppIdToHouseHoldId = new Map<Id,Id>();
        
        for(Opportunity objOpp : lstNewOpportunities)
        {
        	if(objOpp.Primary_Household__c!=NULL)
        		mapOppIdToHouseHoldId.put(objOpp.Id, objOpp.Primary_Household__c);
        }
        
        if(!isOppTrigger)
        	Database.delete([SELECT Id FROM OpportunityShare WHERE OpportunityId IN : mapOppIdToHouseHoldId.keyset()],false);
        
        Database.insert(SL_Util_CreateChildSharings.createSharingRecords(mapOppIdToHouseHoldId),false);
    }    
}