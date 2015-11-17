/**  
* \arg ClassName        : SL_OpportunityTriggerHandler
* \arg JIRATicket       : NPD-89
* \arg CreatedOn        : 10/Sep/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : Handler class for Opportunity object.
*/
global class SL_OpportunityTriggerHandler extends SL_TriggerHandlerBase {

    public static boolean isAfterInsert = true;//created boolean for avoid recursive call 
    
	public override void beforeInsert(List<SObject> newListGeneric){
		List<Opportunity> newList = (List<Opportunity>) newListGeneric;
		/*BEFORE INSERT METHODS START*/
		updateOppPracticeAndParentAccount(new Map<Id, Opportunity>(), newList);
		/*BEFORE INSERT METHODS END*/
	}
	
	public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldMapGeneric;
		Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) newMapGeneric;
		/*BEFORE UPDATE METHODS START*/
		updateOppPracticeAndParentAccount(oldMap, newMap.values());
		/*BEFORE UPDATE METHODS END*/
	}
	
	public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldMapGeneric;
		/*BEFORE DELETE METHODS START*/
		
		/*BEFORE DELETE METHODS END*/
	}
	
	public override void afterInsert(Map<Id, SObject> newMapGeneric){
		Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) newMapGeneric;
		/*AFTER INSERT METHODS START*/
		
		/*AFTER INSERT METHODS END*/
	}
	
	public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
		Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldMapGeneric;
		Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) newMapGeneric;
		/*AFTER UPDATE METHODS START*/
		if(isAfterInsert)
		{
    		createAsset(oldMap, newMap.Values());
    		isAfterInsert = false;
		}
		/*AFTER UPDATE METHODS END*/
	}
	
	public override void afterDelete(Map<Id, SObject> oldMapGeneric){
		Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) oldMapGeneric;
		/*AFTER DELETE METHODS START*/
		
		/*AFTER DELETE METHODS END*/
	}
	
	public override void afterUndelete(Map<Id, SObject> newMapGeneric){
		Map<Id, Opportunity> newMap = (Map<Id, Opportunity>) newMapGeneric;
		/*AFTER UNDELETE METHODS START*/
		
		/*AFTER UNDELETE METHODS END*/
	}
	
	/*
        * MethodName        : updateOppPracticeAndParentAccount
        * param             : Map<Id, Opportunity> oldMapOpp, List<Opportunity> newListOpp
        * Description       : This method will update opp field based on select account id.
    */
	private void updateOppPracticeAndParentAccount(Map<Id, Opportunity> oldMapOpp, List<Opportunity> newListOpp)
	{
	    map<Id, Account> mapAccountIdToAccount = new map<Id, Account>();
	    for(Opportunity objOpportunity: newListOpp)
	    {
	        if(!Trigger.isUpdate || (Trigger.isUpdate && objOpportunity.AccountId != oldMapOpp.get(objOpportunity.Id).AccountId)
	            && objOpportunity.AccountId != null)
	        {
	            mapAccountIdToAccount.put(objOpportunity.AccountId, new Account());
	        }
	        if(objOpportunity.AccountId == null)
	        {
	            objOpportunity.Practice__c = objOpportunity.Parent_Account__c = null;
	        }
	    }
	    
	    for(Account objAccount: [SELECT Id, Practice__c, ParentId FROM Account WHERE Id IN: mapAccountIdToAccount.keySet()])
	    {
	        mapAccountIdToAccount.put(objAccount.Id, objAccount);
	    }
	    
	    for(Opportunity objOpportunity: newListOpp)
	    {
	        if(objOpportunity.AccountId != null && mapAccountIdToAccount.containsKey(objOpportunity.AccountId))
	        {
	            objOpportunity.Practice__c = mapAccountIdToAccount.get(objOpportunity.AccountId).Practice__c;
	            objOpportunity.Parent_Account__c = mapAccountIdToAccount.get(objOpportunity.AccountId).ParentId;
	        }
	    }
	}
	
	/*
        * MethodName        : createAsset
        * param             : Map<Id, Opportunity> oldMapOpp, List<Opportunity> newListOpp
        * Description       : This method will create asset records.
    */
	private void createAsset(Map<Id, Opportunity> oldMapOpp, List<Opportunity> newListOpp)
	{
	    set<Id> setOpportunityIds = new set<Id>();
	    List<Asset> lstAssetToInsert = new List<Asset>();
	    for(Opportunity objOpportunity: newListOpp)
	    {
	        if(objOpportunity.Assets_Created__c && objOpportunity.Assets_Created__c != oldMapOpp.get(objOpportunity.Id).Assets_Created__c)
	        {
	            setOpportunityIds.add(objOpportunity.Id);
	        }
	    }
	    for(OpportunityLineItem objOpportunityLineItem:[SELECT Start_Date__c , UnitPrice, 
	                                                           End_Date__c,
	                                                           OpportunityId,
	                                                           Opportunity.AccountId,
	                                                           Product2.Name
	                                                      FROM OpportunityLineItem WHERE OpportunityId IN: setOpportunityIds])
	    {
	        lstAssetToInsert.add(new Asset(PurchaseDate = objOpportunityLineItem.Start_Date__c,
	                                       UsageEndDate = objOpportunityLineItem.End_Date__c,
	                                       Name = objOpportunityLineItem.Product2.Name, Price = objOpportunityLineItem.UnitPrice,
	                                       Originating_Opportunity__c = objOpportunityLineItem.OpportunityId,
	                                       AccountId = objOpportunityLineItem.Opportunity.AccountId));
	    }
	    insert lstAssetToInsert;
	}
}