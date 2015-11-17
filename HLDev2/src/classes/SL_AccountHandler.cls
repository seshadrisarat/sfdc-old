/**  
* \arg ClassName		: SL_AccountHandler
* \arg JIRATicket		: HL-23
* \arg CreatedOn		: 05/AUG/2014
* \arg LastModifiedOn	: 03/SEP/2014
* \arg CreatededBy		: Lodhi
* \arg ModifiedBy		: -
* \arg Description		: Handler class for Account Trigger
*/
public with sharing class SL_AccountHandler implements SL_ITrigger
{
	/* Start - Variables */
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    private static Map<Id, List<Account>> mapParentIdToLstAccount;
    private static Map<Id, Set<Id>> mapParentIdToSetChildId;
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_AccountHandler(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
        BatchSize = size;
	}
	/* End - Constructor */
	
	/* Start - Constructor */
	public SL_AccountHandler()
	{
		// do nothing
	}
	/* End - Constructor */
	
	/*Start - Merge from production handler class*/
    public void bulkBefore() {
        if (Trigger.isInsert) {
        } else if (Trigger.isUpdate) {
        } else if (Trigger.isDelete) {
        }
    }
    
    public void bulkAfter() {
        if (Trigger.isInsert) {
            SL_Account.updateInvestmentAccounts((Account[])trigger.new);
        } else if (Trigger.isUpdate) {
            SL_Account.updateInvestmentAccounts((Account[])trigger.new);
        } else if (Trigger.isDelete) {
        }
    }
    
    public void beforeInsert(SObject so) {
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
    }
    
    public void beforeDelete(SObject so) {
    }
    
    public void afterInsert(SObject so) {
    }
    
    public void afterUpdate(SObject oldSo, SObject so) {
    }
    
    public void afterDelete(SObject so) {
    }
    
    public void afterUndelete(SObject so) {
    }
    
    public void andFinally() {
    }
	/*End - Merge from production handler class*/
	
	/*
		@MethodName : onBeforeInsert 
		@param 	    : List of Account
		@Description: Update ultimate parent field on record. 
	*/
	public void onBeforeInsert(List<Account> lstAccount)
	{
		Set<Id> setParentId = new Set<Id>(); //Set for parent Id of account record.
		for(Account objAccount : lstAccount)
		{
			if(objAccount.ParentId != null) //To check if whether the Account contains ParentId.
				setParentId.add(objAccount.ParentId);
		}
		//Map used to store filter Account 
		Map<Id, Account> mapIdToAccount = new Map<Id, Account>([SELECT Id, Ultimate_Parent__c FROM Account WHERE Id IN:setParentId]);
		
		for(Account objAccount : lstAccount)
		{
			if(objAccount.ParentId != null && mapIdToAccount.containsKey(objAccount.ParentId))
			{
				//If Ultimate Parent Id is null then update the Child with its Parent Account Id as Ultimate Parent.
				objAccount.Ultimate_Parent__c = (mapIdToAccount.get(objAccount.ParentId).Ultimate_Parent__c != null)
												? mapIdToAccount.get(objAccount.ParentId).Ultimate_Parent__c 
												: objAccount.ParentId;
			}
		}
	}
	/* End */
	
	/*
		@MethodName : onAfterUpdate 
		@param 	    : map of old and new Account.
		@Description: Update ultimate parent field on child records. 
	*/
	public void onAfterUpdate(Map<Id, Account> mapIdToAccountOld, Map<Id, Account> mapIdToAccountNew)
	{
		Set<Id> setParentId = new Set<Id>(); //Set Parent Account Id to Updated Account record.
		Set<Id> setUltimateParentId = new Set<Id>();//Set of Ultimate Parent Id of the Updated Account record.
		
		mapParentIdToLstAccount = new Map<Id, List<Account>>();//Map to contains Parent Id ans List of Account.
		Map<Id, Account> mapIdToAccount = new Map<Id, Account>();//Map to contain Account Id to Object Account.
		
		//getting the utimate id to get all the related child records.
		for(Account objAccount : mapIdToAccountNew.values())
		{
			if(objAccount.ParentId != mapIdToAccountOld.get(objAccount.Id).ParentId)
			{
				if(objAccount.ParentId == null)
					setParentId.add(objAccount.Id);
				else if(objAccount.ParentId != null && !mapIdToAccountNew.containsKey(objAccount.ParentId))
					setParentId.add(objAccount.ParentId);
				
				if(mapIdToAccountOld.get(objAccount.Id).Ultimate_Parent__c != null)
					setUltimateParentId.add(mapIdToAccountOld.get(objAccount.Id).Ultimate_Parent__c);
				else if(mapIdToAccountOld.get(objAccount.Id).ParentId == null)
					setUltimateParentId.add(objAccount.Id);
				
				if(objAccount.ParentId  != null && mapParentIdToLstAccount.containsKey(objAccount.ParentId))
					mapParentIdToLstAccount.get(objAccount.ParentId).add(objAccount);
				else if(objAccount.ParentId  != null)
					mapParentIdToLstAccount.put(objAccount.ParentId, new List<Account>{objAccount});
					
				mapIdToAccount.put(objAccount.Id, objAccount);
			}
		}
		
		if(!mapIdToAccount.isEmpty())//calling method to update utimate parent Id.
			updateUltimateParent(mapIdToAccount, setParentId, setUltimateParentId);
	}
	/* End */
	
	/*
		@MethodName : onAfterUpdate 
		@param 	    : map of old Account.
		@Description: Update ultimate parent field on child records. 
	*/
	public void onBeforeDelete(Map<Id, Account> mapIdToAccountOld)
	{
		mapParentIdToLstAccount = new Map<Id, List<Account>>();//Map to contains Parent Id ans List of Account.
		mapParentIdToSetChildId = new Map<Id, Set<Id>>();
		Set<Id> setUltimateParentId = new Set<Id>();//Set of Ultimate Parent Id before delete.
		
		//getting the utimate id to get all the related child records.
		for(Account objAccount : mapIdToAccountOld.values())
		{
			//checks to set ultimate Id if not null else assigns the Parent Id as the Ultimate Id
			if(objAccount.Ultimate_Parent__c != null)
				setUltimateParentId.add(mapIdToAccountOld.get(objAccount.Id).Ultimate_Parent__c);
			else
				setUltimateParentId.add(objAccount.Id);
		}
		
		for(Account objAccount : [SELECT Id, 
									     ParentId, 
									     Ultimate_Parent__c 
									FROM Account 
									WHERE ParentId IN: mapIdToAccountOld.keySet() 
									AND Id NOT IN: mapIdToAccountOld.keySet()])
		{
			if(mapParentIdToSetChildId.containsKey(objAccount.ParentId))
				mapParentIdToSetChildId.get(objAccount.ParentId).add(objAccount.Id);
			else
				mapParentIdToSetChildId.put(objAccount.ParentId, new Set<Id>{objAccount.Id});
		}
		
		for(Account objAccount : [SELECT Id, 
									   	 Ultimate_Parent__c, 
									   	 ParentId 
									FROM Account 
								   WHERE Ultimate_Parent__c IN: setUltimateParentId 
								     AND Id NOT IN: mapIdToAccountOld.keySet()])
		{
			if(mapParentIdToLstAccount.containsKey(objAccount.ParentId))
				mapParentIdToLstAccount.get(objAccount.ParentId).add(objAccount);
			else
				mapParentIdToLstAccount.put(objAccount.ParentId, new List<Account>{objAccount});
		}
	}
	/* End */
	
	/*
		@MethodName : onAfterDelete 
		@param 	    : map of old Account.
		@Description: Update ultimate parent field on child records. 
	*/
	public void onAfterDelete(Map<Id, Account> mapIdToAccountOld)
	{
		List<Account> lstAccountToUpdate = new List<Account>();//List to update the Account after delete of any Account Record
		
		for(Account objAccount : mapIdToAccountOld.values())
		{
			if(mapParentIdToSetChildId.containsKey(objAccount.Id))
			{
				for(Id childId : mapParentIdToSetChildId.get(objAccount.Id))
				{
					lstAccountToUpdate.add(new Account(Id = childId, Ultimate_Parent__c = null));
					if(mapParentIdToLstAccount.containsKey(childId))//Check whether Parent Id is present in the List of Account in Map to update particular Child Records.
					{
						lstAccountToUpdate.addAll(updateChildRecordUltimateParent(mapParentIdToLstAccount.get(childId), mapIdToAccountOld.keySet(), childId));
					}
				}
			}
		}
		
		//Update the Account and its child record with the Ultimate Parent Id  
		if(!lstAccountToUpdate.isEmpty())
			update lstAccountToUpdate;
	}
	/* End */
	
	/*
		@MethodName : updateUltimateParent 
		@param 	    : map of account, set of parent ids and set of ultimate parent ids.
		@Description: Update ultimate parent field on child records. 
	*/
	private void updateUltimateParent(Map<Id, Account> mapIdToAccount, Set<Id> setParentId, Set<Id> setUltimateParentId)
	{
		List<Account> lstTopParentAccount = [SELECT Id, Ultimate_Parent__c, ParentId FROM Account WHERE Id IN: setParentId ];
		
		List<Account> lstAccountToUpdate = new List<Account>(); //List to Update the updated Account
		for(Account objAccount : [SELECT Id, 
										 Ultimate_Parent__c, 
										 ParentId 
									FROM Account 
								   WHERE Ultimate_Parent__c IN: setUltimateParentId 
								     AND Id NOT IN: mapIdToAccount.keySet()])
		{
			mapIdToAccount.put(objAccount.Id, objAccount);
			if(objAccount.ParentId != null)
			{
				if(mapParentIdToLstAccount.containsKey(objAccount.ParentId))
					mapParentIdToLstAccount.get(objAccount.ParentId).add(objAccount);
				else
					mapParentIdToLstAccount.put(objAccount.ParentId, new List<Account>{objAccount});
			}
		}
		//Iterate on updated Account records and calls the method to get the child record to update with Ultimate Parent and Parent Id.
		for(Account objAccount : lstTopParentAccount)
		{
			if(objAccount.ParentId != null && mapParentIdToLstAccount.containsKey(objAccount.Id))
			{
				/*lstAccountToUpdate.add(new Account(Id = objAccount.Id, Ultimate_Parent__c = (mapIdToAccount.get(objAccount.ParentId).Ultimate_Parent__c != null)
																							? mapIdToAccount.get(objAccount.ParentId).Ultimate_Parent__c 
																							: objAccount.ParentId));*/
																							
				lstAccountToUpdate.addAll(updateChildRecordUltimateParent(mapParentIdToLstAccount.get(objAccount.Id),
																          setParentId, 
																          objAccount.Ultimate_Parent__c));
			}
			else if(objAccount.ParentId == null && mapParentIdToLstAccount.containsKey(objAccount.Id))
			{
				lstAccountToUpdate.add(new Account(Id = objAccount.Id, Ultimate_Parent__c = null));
				lstAccountToUpdate.addAll(updateChildRecordUltimateParent(mapParentIdToLstAccount.get(objAccount.Id), 
																		  setParentId, 
																		  objAccount.Id));
			}
			//checks if Parent Id is not null to update the child Account records. 
			/*else if(objAccount.ParentId != null)
			{
				lstAccountToUpdate.add(new Account(Id = objAccount.Id, Ultimate_Parent__c = (mapIdToAccount.get(objAccount.ParentId).Ultimate_Parent__c != null)
																							? mapIdToAccount.get(objAccount.ParentId).Ultimate_Parent__c 
																							: objAccount.ParentId));
			}*/
			else if(objAccount.ParentId == null)
			{
				lstAccountToUpdate.add(new Account(Id = objAccount.Id, Ultimate_Parent__c = null));
			}
		}
		//Update the Account and its child record with the Ultimate Parent Id and its Parent Id.
		if(!lstAccountToUpdate.isEmpty())
			update lstAccountToUpdate;
	}
	/* End */
	
	/*
		@MethodName : updateChildRecordUltimateParent 
		@param 	    : list of account, set of id of the records whose parent id changes and ultimateId.
		@Description: Update ultimate parent field on child records. 
	*/
	private List<Account> updateChildRecordUltimateParent(List<Account> lstAccount, Set<Id> setParentChangeId, Id ultimateId)
	{
		List<Account> lstAccountToUpdate = new List<Account>();//List to return child Account records to update.
		//getting the utimate id to get all the related child records.
		for(Account objAccount : lstAccount)
		{
			//check if Account Record contains any child records
			if(!setParentChangeId.contains(objAccount.Id))
			{
				if(objAccount.ParentId != null && mapParentIdToLstAccount.containsKey(objAccount.Id))
				{
					lstAccountToUpdate.add(new Account(Id = objAccount.Id, Ultimate_Parent__c = ultimateId));
					//calls the method itself in recursion till it gets all its child 
					lstAccountToUpdate.addAll(updateChildRecordUltimateParent(mapParentIdToLstAccount.get(objAccount.Id), setParentChangeId, ultimateId));
				}
				else if(objAccount.ParentId != null)
				{
					lstAccountToUpdate.add(new Account(Id = objAccount.Id, Ultimate_Parent__c = ultimateId));
				}
			}
		}
		return lstAccountToUpdate;//return list of child Accounts of particular parents to update its Ultimate Parent and its Parent
	}
	/* End */
}