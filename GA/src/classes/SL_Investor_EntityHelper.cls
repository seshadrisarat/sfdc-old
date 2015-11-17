/**  
* \arg ClassName        : SL_Investor_EntityHelper
* \arg JIRATicket       : GA-18
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 04/13/15
* \arg CreatededBy      : 
* \arg ModifiedBy       : Sandeep
* \arg Description      : Helper class
*/
public with sharing class SL_Investor_EntityHelper
{

	/*BEGIN PROPERTIES*/

	/*END PROPERTIES*/

	/***************************************************
	*	SHARED METHODS    					   		   *
	***************************************************/

	public static void copyAcct(map<Id,sObject> newMap)
	{
		Investor_Entity__c[] ieList = (Investor_Entity__c[]) newMap.values();
		Commitment__c[] cList = new Commitment__c[]{};
		Set<Id> ieIds = new Set<Id>();

		for(Investor_Entity__c ie : ieList)
		{
			if(ie.Account__c != null)
			{
				ieIds.add(ie.Id);
			}
		}

		cList = [Select Id,Investor__c, Investor_Entity__r.Account__c
				 From Commitment__c
				 WHERE Investor_Entity__c IN: ieIds];


		for(Commitment__c c : cList)
		{
			c.Investor__c = c.Investor_Entity__r.Account__c;
		}

		update cList;

	}

	/***************************************************
	*	BEFORE INSERT METHODS    					   *
	***************************************************/

	/***************************************************
	*	BEFORE UPDATE METHODS    					   *
	***************************************************/

	/***************************************************
	*	BEFORE DELETE METHODS    					   *
	***************************************************/

	/***************************************************
	*	AFTER INSERT METHODS    					   *
	***************************************************/

	public static void afterInsert(map<Id,sObject> newMap)
	{
		copyAcct(newMap);
	}
	
	/*
        @MethodName: onAfterInsert
        @param None : map<Id,Investor_Entity__c>
        @Description: After insert of Investor_Entity__c this method will call
    */
	public void onAfterInsert(map<Id,Investor_Entity__c> newMapInvestorEntity)
	{
		updateAccountCommitmentAmount(newMapInvestorEntity, null);//call the method for updates
	}

	/***************************************************
	*	AFTER UPDATE METHODS    					   *
	***************************************************/

	public static void afterUpdate(map<Id,sObject> oldMap, map<Id,sObject> newMap)
	{
		copyAcct(newMap);
	}
	/*
        @MethodName: onAfterUpdate
        @param None : map<Id,Investor_Entity__c> , map<Id,Investor_Entity__c> 
        @Description: After update of Investor_Entity__c this method will call
    */
	public void onAfterUpdate(map<Id,Investor_Entity__c> oldMapInvestorEntity, map<Id,Investor_Entity__c> newMapInvestorEntity)
	{
		updateAccountCommitmentAmount(newMapInvestorEntity, oldMapInvestorEntity);//call the method for updates
	}
	/***************************************************
	*	AFTER DELETE METHODS    					   *
	***************************************************/
	/*
        @MethodName: onAfterDelete
        @param None : map<Id,Investor_Entity__c> 
        @Description: After delete of Investor_Entity__c this method will call
    */
	public void onAfterDelete(map<Id,Investor_Entity__c> oldMapInvestorEntity)
	{
		updateAccountCommitmentAmount(oldMapInvestorEntity, null);//call the method for updates
	}
	/***************************************************
	*	AFTER UNDELETE METHODS    					   *
	***************************************************/
	/*
        @MethodName: onAfterUnDelete
        @param None : map<Id,Investor_Entity__c> 
        @Description: After undelete of Investor_Entity__c this method will call
    */
	public void onAfterUnDelete(map<Id,Investor_Entity__c> newMapInvestorEntity)
	{
		updateAccountCommitmentAmount(newMapInvestorEntity, null);//call the method for updates
	}
	
	/*
        @MethodName : updateAccountCommitmentAmount
        @param None : map<Id,Investor_Entity__c> , map<Id,Investor_Entity__c>  
        @Description: update the Account CommitmentAmount field
    */
	public void updateAccountCommitmentAmount(map<Id,Investor_Entity__c> newMapInvestorEntity, map<Id,Investor_Entity__c> oldMapInvestorEntity)
	{
	    set<Id> setAccountId = new set<Id>();//set to store the Account__c Id
	    List<Account> lstAccountToUpdate = new List<Account>();
	    map<Id, Decimal> mapAccountIdToDecimal = new map<Id, Decimal>();
	    
	    //Iterate over the Investor Entity new map and collect the Account__c, if Trigger is update then collect the old map Account__c and store into the old map
		for(Investor_Entity__c objInvestor_Entity: newMapInvestorEntity.values())
		{
		    if(objInvestor_Entity.Account__c != null)
		    {
		        setAccountId.add(objInvestor_Entity.Account__c);
		    }
		    if(Trigger.isUpdate && oldMapInvestorEntity.get(objInvestor_Entity.Id).Account__c != null)
		        setAccountId.add(oldMapInvestorEntity.get(objInvestor_Entity.Id).Account__c);
		}
		
		//query on Investor__c and collect into a map Account__c to Decimal
		for(Investor_Entity__c objInvestor_Entity : [SELECT Id, 
	                                                        Commitment_Amount__c, 
	                                                        Account__c 
	                                                   FROM Investor_Entity__c 
	                                                  WHERE Account__c IN : setAccountId 
	                                                    AND Commitment_Amount__c != null ])
		{   
			
		    if(!mapAccountIdToDecimal.containsKey(objInvestor_Entity.Account__c))
		        mapAccountIdToDecimal.put(objInvestor_Entity.Account__c, 0);
		    mapAccountIdToDecimal.put(objInvestor_Entity.Account__c, mapAccountIdToDecimal.get(objInvestor_Entity.Account__c) + objInvestor_Entity.Commitment_Amount__c);
		}
		//iterate over the set of Account__c and store into the list for update
		for(Id objAccountId : setAccountId)
		{
		    lstAccountToUpdate.add(new Account(Id = objAccountId, Commitment_Amount_Rolled_Up__c = mapAccountIdToDecimal.containsKey(objAccountId) ? mapAccountIdToDecimal.get(objAccountId): 0));
		}
		
		//if list is not empty then Update all the Account
		if(!lstAccountToUpdate.isEmpty())
		    update lstAccountToUpdate;
	}
}