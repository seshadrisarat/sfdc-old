public class SL_BorrowerRatingHistoryHandler
{
	/*	START : Global variables	*/
	private Set<Id> setAccountIds = new Set<Id>();
	/*	END : Global variables	*/
	//	Constructor
	public SL_BorrowerRatingHistoryHandler()
	{
		//	Does nothing
	}
	//	Method called on After insert event
	public void onAfterInsert(Map<Id, Borrower_Rating_History__c> mapBorrowerHistories)
	{
		for(Borrower_Rating_History__c objBorrowerRatingHistory : mapBorrowerHistories.values())
		{
			setAccountIds.add(objBorrowerRatingHistory.Account__c);
		}
		updateBrowserRatingOnAccount(setAccountIds, null);
	}
	//	Method called on After Update event
	public void onAfterUpdate(Map<Id, Borrower_Rating_History__c> mapNewBorrowerHistories, Map<Id, Borrower_Rating_History__c> mapOldBorrowerHistories)
	{
		for(Borrower_Rating_History__c objBorrowerRatingHistory : mapNewBorrowerHistories.values())
		{
			if(objBorrowerRatingHistory.Effective_Date__c != mapOldBorrowerHistories.get(objBorrowerRatingHistory.Id).Effective_Date__c ||
			   objBorrowerRatingHistory.New_Borrower_Rating__c != mapOldBorrowerHistories.get(objBorrowerRatingHistory.Id).New_Borrower_Rating__c ||
			   objBorrowerRatingHistory.Account__c != mapOldBorrowerHistories.get(objBorrowerRatingHistory.Id).Account__c)
		   {
				setAccountIds.add(objBorrowerRatingHistory.Account__c);
		   }
		}
		updateBrowserRatingOnAccount(setAccountIds, null);
	}
	//	Method called on After Delete event
	public void onBeforeDelete(Map<Id, Borrower_Rating_History__c> mapBorrowerHistories)
	{
		for(Borrower_Rating_History__c objBorrowerRatingHistory : mapBorrowerHistories.values())
		{
			setAccountIds.add(objBorrowerRatingHistory.Account__c);
		}
		updateBrowserRatingOnAccount(setAccountIds, mapBorrowerHistories.keyset());
	}
	//	Method called on After UnDelete event
	public void onAfterUnDelete(Map<Id, Borrower_Rating_History__c> mapBorrowerHistories)
	{
		for(Borrower_Rating_History__c objBorrowerRatingHistory : mapBorrowerHistories.values())
		{
			setAccountIds.add(objBorrowerRatingHistory.Account__c);
		}
		updateBrowserRatingOnAccount(setAccountIds, null);
	}
	//	Common method that is called to update the Account.Borrower_Risk_Rating__c value from the latest effective dated borrower history record  
	public void updateBrowserRatingOnAccount(set<Id> setAccountIds, Set<Id> setBorrowerHistoryIds)
	{
		//	Method variables
		List<Account> lstAccountsToUpdate =  new List<Account>();
		Map<Id, String> mapAccountIdToBorrowerRating = new Map<Id, String>();
		Map<Id, Borrower_Rating_History__c> mapAccountIdToBRH = new Map<Id, Borrower_Rating_History__c>();
		//	 Forms a map that stores the AccountId as the key and the borrower rating of the latest effective borrower rating history  
		for(Borrower_Rating_History__c objBH : [select Id, Account__c, New_Borrower_Rating__c, Effective_Date__c, CreatedDate  
												From Borrower_Rating_History__c 
												Where Account__c IN : setAccountIds AND
													  Id NOT IN : setBorrowerHistoryIds 
												order by Effective_Date__c desc nulls last])
		{
			if(!mapAccountIdToBorrowerRating.containsKey(objBH.Account__c))
			{
				mapAccountIdToBorrowerRating.put(objBH.Account__c, objBH.New_Borrower_Rating__c);
				mapAccountIdToBRH.put(objBH.Account__c, objBH);
			}
			else
			{
				if(objBH.Effective_Date__c == mapAccountIdToBRH.get(objBH.Account__c).Effective_Date__c && 
				   objBH.CreatedDate > mapAccountIdToBRH.get(objBH.Account__c).CreatedDate)
				{
					mapAccountIdToBorrowerRating.put(objBH.Account__c, objBH.New_Borrower_Rating__c);
					mapAccountIdToBRH.put(objBH.Account__c, objBH);
				}
			}
		}
		//	Updates the borrower rating of the latest effective borrower rating history on respective Account
		for(Id idAccount : mapAccountIdToBorrowerRating.keyset())
		{
			Account objAccount = new Account(Id = idAccount, Borrower_Risk_Rating__c = mapAccountIdToBorrowerRating.get(idAccount));
			lstAccountsToUpdate.add(objAccount);
		}
		setAccountIds.removeAll(mapAccountIdToBorrowerRating.keyset());
		system.debug('--------setAccountIds---------'+setAccountIds);
		for(Id idAccount : setAccountIds)
		{
			Account objAccount = new Account(Id = idAccount, Borrower_Risk_Rating__c = null);
			lstAccountsToUpdate.add(objAccount);
		}
		system.debug('--------lstAccountsToUpdate------------'+lstAccountsToUpdate);
		if(!lstAccountsToUpdate.isEmpty())
			update lstAccountsToUpdate;
	}

}